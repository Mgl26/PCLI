function buscar($valor, $valor2)
{
	$BasePath = "\\192.168.27.17\admin_vmware\RVTools"
	$vc = Import-Csv \\192.168.27.17\admin_vmware\Inventario\Inventario_PCLI.csv -Delimiter ";"
	$Date_a = (Get-Date -f "yyyy")	#almacena año actual
	$Date_m = (Get-Date -f "MM")	#almacena mes actual
	$Date_d = (Get-Date -f "dd")	#almacena día actual
	if ($Date_d -lt 16)
	{
		$Date = $Date_a+$Date_m+"01"
	}
	else
	{
		$Date = $Date_a+$Date_m+"16"
	}
	$files = @()
	
	$vMAC = Test-MACAddress $valor
	if($vMAC){
		$splitMac = $valor.Split(":")
		Write-Host ""
		if($splitMac[0] -ne "00"){write-host "La MACAddress $valor no corresponde al Pool de Mac virtuales" -ForegroundColor red}
		Write-Host ""
		if($splitMac[1] -ne "50"){write-host "La MACAddress $valor no corresponde al Pool de Mac virtuales" -ForegroundColor red}
		Write-Host ""
		if($splitMac[2] -ne "56"){write-host "La MACAddress $valor no corresponde al Pool de Mac virtuales" -ForegroundColor red}
		Write-Host ""
	} 
	$vIP = Test-IP $valor
	
	if ($vMAC -eq $true -or $vIP -eq $tru)
	{
		
		Get-ChildItem "$BasePath\*\$Date" -Filter *network.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor*" -or $_."Mac Address" -like "*$valor*" -or $_."IP Address" -like "*$valor*"}  | select VM, Adapter, Network, "Mac Address", "IP Address", Datacenter, Cluster, Host, "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
	} 
	elseif ($valor -eq "?")
	{
		Write-host "NOMRE"
		Write-host "	Buscar"
		Write-host ""
		Write-host "SINOPSIS"
		Write-host "	Este comando realiza busqueda de valores especificos dentro de las plataformas virtuales VMware"
		Write-host ""
		Write-host ""
		Write-host "SINTAXIS"
		Write-host "	Buscar [<VM>] [<DNS Name>] [<Datacenter>] [<Cluster>] [<Cliente>]"
		Write-host ""
		Write-host "	Buscar [[Host] <Nombre_Host> <Datacenter> <Cluster> <IP_vCenter>]"
		Write-host ""
		Write-host "	Buscar [[DataStore] <Nombre_DataStore> <Nombre_Host> <Tipo>]"
		Write-host ""
		Write-host "	Buscar [[Discos] <VM> <Cluster> <Datacenter> <Host>]"
		Write-host ""
		Write-host "	Buscar [[Particion] <VM> <Disk>]"
		Write-host ""
		Write-host "	Buscar [[Red] <VM> <IP> <MacAddress>]"
		Write-host ""
		Write-host "	Buscar [[SnapShot] <VM> <Descripcion>]"
		Write-host ""
		Write-host "	Buscar [[Naa] <VM>]"
		Write-host ""
		Write-host ""
		Write-host "DESCRIPCION"
		Write-host "	Se realiza la busqueda segun los argumentos que se coloquen en archivos RVTools almacenados con anterioridad en un servidor con carpeta compartida"
		Write-host ""
		Write-host ""
		Write-host "EJEMPLOS"
		Write-host ""
		Write-host "------------------------------ Ejemplo 1 ---------------------------"
		Write-host ""
		Write-host "	Buscar VM_ENTEL"
		Write-host ""
		Write-host "	========== OD2-VCENTER01  -  16-08-2017 2:03:32 ===============" -ForegroundColor red
		Write-host ""
		Write-host "	VM             : SALFA_DC1"
		Write-host "	DNS Name       : DC2008.salfa.cl"
		Write-host "	Powerstate     : poweredOff"
		Write-host "	CPUs           : 2"
		Write-host "	Memory         : 2048"
		Write-host "	NICs           : 2"
		Write-host "	Disks          : 1"
		Write-host "	Host           : od3-esx14.ond.entel.cl"
		Write-host "	Cluster        : CDV2_DC01_SER2"
		Write-host "	Datacenter1    : CDC2_DC01"
		Write-host "	Provisioned MB : 52895"
		Write-host "	In Use MB      : 22862"
		Write-host "	VI SDK Server  : 10.81.141.64"
		Write-host ""	
		
		Write-host "------------------------------ Ejemplo 2 ---------------------------"
		Write-host "	"
		Write-host "	Buscar Red VM_ENTEL"
		Write-host "	"
		Write-host "	========== OD2-VCENTER01  -  16-08-2017 2:03:32 ===============" -ForegroundColor red
		Write-host "	"
		Write-host "	==================== OD2-VCENTER01  -  16-08-2017 2:03:34 ========================="
		Write-host "	"
		Write-host "	VM          : SALFA_DC1"
		Write-host "	Adapter     : E1000"
		Write-host "	Network     : VM-LAN_SALFA_2"
		Write-host "	Mac Address : 00:50:56:9e:1b:71"
		Write-host "	IP Address  : 10.82.213.132"
		Write-host "	Datacenter1 : CDC2_DC01"
		Write-host "	Cluster     : CDV2_DC01_SER2"
		Write-host "	Host        : od3-esx14.ond.entel.cl"
		Write-host "	"
		Write-host "	VM          : SALFA_DC1"
		Write-host "	Adapter     : Vmxnet3"
		Write-host "	Network     : VM-Mgmt2"
		Write-host "	Mac Address : 00:50:56:9e:76:e3"
		Write-host "	IP Address  : 10.81.133.8"
		Write-host "	Datacenter1 : CDC2_DC01"
		Write-host "	Cluster     : CDV2_DC01_SER2"
		Write-host "	Host        : od3-esx14.ond.entel.cl"
		Write-host ""
		Write-host ""
		
	}
	
	elseif ($valor -eq "host")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *Host.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.host -like "*$valor2*" -or $_."Datacenter" -like "*$valor2*" -or $_."cluster" -like "*$valor2*" -or $_."VI SDK Server" -like "*$valor2*"}  | select Host, Datacenter, Cluster, "ESX Version", "NTP Server(s)", "Serie de Servidor", "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				
				$tamVMK = Import-CSVCustom $file.fullname.Replace("RVTools_tabvHost.csv","RVTools_tabvSC_VMK.csv")
				$result | Add-Member NoteProperty -Name IP_Host -Value $null
				
				foreach ($res in $result){
					$res.IP_Host = ($tamVMK | where-object {$_.Host -eq $res.Host})."IP Address"
					$res
				}
			}
		}
	}
	elseif ($valor -eq "particion")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *vPartition.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor2*" -or $_.Disk -like "*$valor2*"} | select VM, Disk, "Capacity MB", "Consumed MB", "Free MB", "Free %", Host, Cluster, Datacenter1, "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
	}
	
	elseif ($valor -eq "red")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *network.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor2*" -or $_."IP Address" -like "*$valor2*" -or $_."Mac Address" -like "*$valor2*"}  | select VM, Adapter, Network, "Mac Address", "IP Address", Datacenter1, Cluster, Host
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
	}	
	
	elseif ($valor -eq "Discos")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *vDisk.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor2*" -or $_.Datacenter -like "*$valor2*" -or $_.Cluster -like "*$valor2*" -or $_.Host -like "*$valor2*"} | select VM, Disk, "Capacity MB", Raw, Path, "Free %", Host, Cluster, Datacenter, "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
	}		
	
	elseif ($valor -eq "naa")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *vDisk.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor2*"}
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach($registro in $result)
				{
					$ds_large = $registro.Path
					$ds_split = $ds_large.Split("[")[1]
					$ds = $ds_split.Split("]")[0]
					$registro | select Datacenter1, @{N="VM";E={$valor2}}, "Capacity MB", @{N="DataStore";E={$ds}}, @{N="Naa";E={(Import-CSVCustom $file.fullname.Replace("RVTools_tabvDisk.csv","RVTools_tabvDatastore.csv") | where-object {$_.name -eq $ds}).address}}
				}
			}
		}
	}	
	
	elseif ($valor -eq "datastore")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *vDatastore.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.Name -like "*$valor2*" -or $_.Hosts -like "*$valor2*" -or $_."Type" -like "*$valor2*"} | select Name, "type", Address, "Capacity MB", "Provisioned MB", "In Use MB", "Free %", "# VMs", Hosts, "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
	}
	
	elseif ($valor -eq "snapshot")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *vSnapshot.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor2*" -or $_."OS according to the configuration file" -like "*$valor2*" -or $_."Description" -like "*$valor2*"} | select VM, Name, "Date / time", Powerstate, Filename, "Size MB (total)", "Description", Cluster, Host, "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
	}
	
	else
	{	
		Get-ChildItem "$BasePath\*\$Date" -Filter *info.csv -Recurse | %{$files += $_} 
		
		foreach ($file in $files)
		{			
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor*" -or $_."DNS Name" -like "*$valor*" -or $_.Datacenter -like "*$valor*" -or $_.Cliente -like "*$valor*" -or $_.Cliente1 -like "*$valor*" -or $_.Cluster -like "*$valor*" -or $_.Datacenter1 -like "*$valor*"} | select VM, "DNS Name", Powerstate, CPUs, Memory, NICs,Disks, "HW version", host, Cluster, Datacenter1, "Provisioned MB", "In Use MB",  "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
		
	}
}
