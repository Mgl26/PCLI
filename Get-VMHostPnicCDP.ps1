<#
    
	Detalle: Funcion que obtiene los datos CDP de los ESX a los que se encuentre conectado
	Detalle Ejemplo: 	Get-VMHost | Get-VMHostPnicCDP
	
	.SYNOPSIS
        Gets CDP/LLDP information for ESXi physical nic.
 
    .DESCRIPTION
        Gets CDP/LLDP information for ESXi physical nic.
 
    .PARAMETER  VMHost
        VMHost Can be piped to this function, it can VMHost object from get-vmhost or it get be HostSystme object from Get-View.
 
    .PARAMETER  pnic
        This is the physical nic adapter name, for example: vmnic0 , it supports array as well: vmnic0,vmnic2,vmnicN.
 
    .PARAMETER  lldp
        If paramenter -lldp was give, it will output content of lldpinfo from QueryNetworkHint method.
 
    .EXAMPLE
        PS C:\> Get-VMHostPnicCDP   -pnic vmnic0 -VMHost 'esxi1.local.lan'
        Without passing through pipeline it acceppts 1 vmhost only.
 
    .EXAMPLE
        PS C:\> Get-VMHostPnicCDP  -VMHost 'esxi1.local.lan'
        When -pnic parameter is skipped, CDP will be retrieved for all pnics in ESXi.
 
    .EXAMPLE
        PS C:\> 'esxi1.local.lan','esxi2' | Get-VMHostPnicCDP   -pnic vmnic0
        You can pass multiple VMHost names through pipeline
 
    .EXAMPLE
        PS C:\> get-vmhost -name 'esxi1.local.lan' | Get-VMHostPnicCDP -pnic vmnic1
        You can pass object directly from get-vmhost
 
    .EXAMPLE
        PS C:\>  get-view -viewtype hostsystem -filter @{'name'='esxi1.local.lan'} | Get-VMHostPnicCDP -pnic vmnic1
        You can pass object directly from get-view
 
    .NOTES
        NAME: Get-VMHostPnicCDP
        AUTHOR: Grzegorz Kulikowski
        LASTEDIT : 09/07/2015
 
    .LINK
        https://psvmware.wordpress.com
 
#>
function Get-VMHostPnicCDP {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Object]
        $VMHost,
        [Parameter(Position=1)]
        [System.String[]]
        $pnic,
        [switch]$lldp
    )
    begin {
        try
        {
            if (!$global:defaultVIserver) { 'Not connected to VirtualCenter';break }
        }
        catch
        {
        }
    }
    process {
        try {
			$date = get-date -f "ddMMyyyy"
			$result = @()
            switch (($VMHost.GetType()).FullName)
            {
                'VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl'
                {
                    $NetworkSystemConfigManager = get-view -id $vmhost.ExtensionData.ConfigManager.NetworkSystem
                }
                'VMware.Vim.HostSystem'
                {
                    $NetworkSystemConfigManager = Get-View -id $vmhost.ConfigManager.NetworkSystem
                }
                'System.String'
                {
                    $VMHost = Get-View -viewtype HostSystem -Property Name, ConfigManager.NetworkSystem -Filter @{ 'name' = $VMHost }
                    $NetworkSystemConfigManager = Get-View -id $vmhost.ConfigManager.NetworkSystem
                }
            }
            if (!$pnic) { [string[]]$pnic = $NetworkSystemConfigManager.NetworkConfig.Pnic | %{ $_.device } }
            foreach ($EsxiPnic in $pnic)
            {
                if ($lldp) { 
				
					$NetworkSystemConfigManager.QueryNetworkHint($esxipnic) | %{ $_.lldpinfo } | Select-Object *, @{ n = 'Esxi'; e = { $VMHost.name } }, @{ n = 'ESXiPnic'; e = { $EsxiPnic } }  | export-csv c:\temp\$date"CDP.csv" -NoTypeInformation -Delimiter ";" -Append
					$NetworkSystemConfigManager.QueryNetworkHint($esxipnic) | %{ $_.lldpinfo } | Select-Object *, @{ n = 'Esxi'; e = { $VMHost.name } }, @{ n = 'ESXiPnic'; e = { $EsxiPnic } } 
					#$result += $NetworkSystemConfigManager.QueryNetworkHint($esxipnic) | %{ $_.lldpinfo } | Select-Object *, @{ n = 'Esxi'; e = { $VMHost.name } }, @{ n = 'ESXiPnic'; e = { $EsxiPnic } } 
					
				}
                else
                {
                    $NetworkSystemConfigManager.QueryNetworkHint($esxipnic) | %{ $_.ConnectedSwitchPort } | Select-Object *, @{ n = 'Esxi'; e = { $VMHost.name } }, @{ n = 'ESXiPnic'; e = { $EsxiPnic } } | export-csv c:\temp\$date"CDP.csv" -NoTypeInformation -Delimiter ";" -Append
                    $NetworkSystemConfigManager.QueryNetworkHint($esxipnic) | %{ $_.ConnectedSwitchPort } | Select-Object *, @{ n = 'Esxi'; e = { $VMHost.name } }, @{ n = 'ESXiPnic'; e = { $EsxiPnic } }
                    #$result += $NetworkSystemConfigManager.QueryNetworkHint($esxipnic) | %{ $_.ConnectedSwitchPort } | Select-Object *, @{ n = 'Esxi'; e = { $VMHost.name } }, @{ n = 'ESXiPnic'; e = { $EsxiPnic } }
                }
            }
			#$result | export-csv c:\temp\$date"CDP.csv" -NoTypeInformation -Delimiter ";"
        }
        catch [VMware.Vim.VimException]
        {
            $_.Exception
            'Maybe the pnic you are reffering to, does not exist ?'
        }
    }
    end {
        try {
        }
        catch {
        }
    }
}