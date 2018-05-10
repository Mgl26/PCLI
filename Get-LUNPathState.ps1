function Get-LUNPathState {
    <#
            .SYNOPSIS
            No parameters needed. Just execute the script.
            .DESCRIPTION
            This script outputs the number of paths to each LUN.
     
            .EXAMPLE
            Get-LUNPathState -VMhosts 'esx01'
            Lists all LUN pats for ESXi host esx01.
            .EXAMPLE
            $esxihosts = Get-VMHost
            Get-LUNPathState -VMHosts $esxihosts
            Lists all LUN paths for all ESXi hosts in $esxihosts
    
            .NOTES
            Author: Patrick Terlisten, patrick@blazilla.de, Twitter @PTerlisten
    
            This script is provided "AS IS" with no warranty expressed or implied. Run at your own risk.
            This script is based on: http://www.vmwareadmins.com/list-the-path-and-path-state-for-every-vsphere-datastore-using-powercli/
            This work is licensed under a Creative Commons Attribution NonCommercial ShareAlike 4.0
            International License (https://creativecommons.org/licenses/by-nc-sa/4.0/).
    
            .LINK
            http://www.vcloudnine.de
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'ESXi Host',ValueFromPipeline = $true)]
        [Alias('Name')]
        [ValidateNotNullorEmpty()]
        $VMhosts
    )

    # Create empty hash table
    $ReportLunPathState = @()
	$date = get-date -f "ddMMyyyy"
	$dt = Get-Datacenter

    Write-Host -Object `n
    Write-Host -Object "$($VMhosts.length) host(s) needs to be processed. Please wait..."

    # Initialize counter variable
    $i = 0

    try
    {
        ForEach ($VMHost in $VMhosts) {
            # Increment counter variable
            $i++

            # Get all datastores from the current host
            $VMHostDatastores = Get-Datastore
    
            # Get all disks devices from the current host
            $VMHostScsiLuns = $VMHost | Get-ScsiLun -LunType disk


            ForEach ($VMHostScsiLun in $VMHostScsiLuns) {
                # Get LUN paths for each disk device
                $VMHostScsiLunPaths = $VMHostScsiLun | Get-ScsiLunPath
       
                # Count paths per disk device
                $report = $ReportLunPathState += ($VMHostScsiLunPaths | Measure-Object) | Select-Object `
                -Property @{N = 'Hostname'; E = {$VMHost.Name}}, `
                @{N = 'Datastore'; E = {$VMHostDatastores | Where-Object -FilterScript {($_.extensiondata.info.vmfs.extent | ForEach-Object -Process {$_.diskname}) -contains $VMHostScsiLun.CanonicalName}| Select-Object -ExpandProperty name}}, `
                @{N = 'CanonicalName'; E = {$VMHostScsiLun.CanonicalName}}, `
                @{N = '# of Paths'; E = {$_.Count}}, `
                @{N = 'Path State'; E = {$VMHostScsiLunPaths.State}}
            }
        }
		$report
		$report | export-csv c:\temp\$dt_$date_"LunPathState.csv" -NoTypeInformation -Delimiter ";"
    }

    catch
    {
        "Error was $_"
        $line = $_.InvocationInfo.ScriptLineNumber
        "Error was in Line $line"
    }

    finally
    {$ReportLunPathState | Format-Table -AutoSize}
}