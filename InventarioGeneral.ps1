Function Buscar-Todo ($busqueda){
	buscar $busqueda | Out-GridView -Title "Inventario de $busqueda"
}
Function Inventario ($busqueda){
	buscar $busqueda | Out-GridView -Title "Inventario de $busqueda"
}

function buscar($valor, $valor2)
{
	$BasePath = "\\192.168.27.17\admin_vmware\RVTools"
	$vc = Import-Csv \\192.168.27.17\admin_vmware\Inventario\Inventario_PCLI.csv -Delimiter ";"
	$Date_a = (Get-Date -f "yyyy")	#almacena año actual
	$Date_m = (Get-Date -f "MM")	#almacena mes actual
	$Date_d = (Get-Date -f "dd")	#almacena día actual
	
	if ($Date_d -lt (get-date -f 06))
	{
		$Date = $Date_a+$Date_m+"01"
	}
	elseif ($Date_d -lt (get-date -f 11))
	{
		$Date = $Date_a+$Date_m+"06"		
	}
	elseif ($Date_d -lt (get-date -f 16))
	{
		$Date = $Date_a+$Date_m+"11"		
	}	
	elseif ($Date_d -lt (get-date -f 21))
	{
		$Date = $Date_a+$Date_m+"16"
	}	
	elseif ($Date_d -lt (get-date -f 26))
	{
		$Date = $Date_a+$Date_m+"21"
	}	
	else
	{
		$Date = $Date_a+$Date_m+"26"
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
		
		Get-ChildItem "$BasePath\*\$Date" -Filter *network.csv -Recurse | ForEach-Object{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor*" -or $_."Mac Address" -like "*$valor*" -or $_."IP Address" -like "*$valor*"}  | Select-Object VM, Adapter, Network, "Mac Address", "IP Address", Datacenter, Cluster, Host, "VI SDK Server"
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | Where-Object{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
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
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor2*" -or $_."IP Address" -like "*$valor2*" -or $_."Mac Address" -like "*$valor2*"}  | select VM, Adapter, Network, Connected, "Mac Address", "IP Address", Datacenter1, Cluster, Host, "VI SDK Server"
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
					write-host "----------------------------------"
				}
			}
		}
	}	
	
	elseif ($valor -eq "datastore")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *vDatastore.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			
			#$result = Import-CSVCustom $file.fullname | Where-Object {$_.Name -like "*$valor2*" -or $_.Hosts -like "*$valor2*" -or $_."Type" -like "*$valor2*"} | select Name, "type", Address, @{N="Capacity GB";E={$_."Capacity MB"/1024}}, @{N="Provisioned GB";E={$_."Provisioned MB"/1024}}, @{N="In Use GB";E={$_."In Use MB"/1024}}, "Free %", "# VMs", URL, Hosts, "VI SDK Server"
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.Name -like "*$valor2*" -or $_.Hosts -like "*$valor2*" -or $_."Type" -like "*$valor2*"} | select Name, "type", Address, @{N="Capacity GB";E={$_."Capacity MB"/1024}}, @{N="Provisioned GB";E={$_."Provisioned MB"/1024}}, @{N="In Use GB";E={$_."In Use MB"/1024}}, "Free %", "# VMs", URL, Hosts, @{N="vCenter";E={$_."VI SDK Server"}}
			if($result)
			{
				write-host ""
				write-host "====================" ($vc | ?{$_.IP -eq $file.fullname.Split('\')[5]}).NOMBRE_DISPOSITIVO " - " $file.CreationTime  "=========================" -ForegroundColor red
				write-host ""
				foreach ($res in $result){$res}
			}
		}
	}
	
	elseif ($valor -eq "HBA")
	{
		Get-ChildItem "$BasePath\*\$Date" -Filter *vHBA.csv -Recurse | %{$files += $_} 
		foreach ($file in $files)
		{
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.Host -like "*$valor2*" -or $_.Datacenter -like "*$valor2*" -or $_.Cluster -like "*$valor2*" -or $_."VI SDK Server" -like "*$valor2*"} | select Host, Device, "Type", Status, Driver, Model, WWN, Cluster, Datacenter, "VI SDK Server"
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
	
	elseif ($valor -eq "capacidad")
	{
		if ($valor2 -like "heroes"){
		
			$cap_cpu_CDLV = Import-CSVCustom "$BasePath\172.19.15.60\$Date\RVTools_tabvCPU.csv"
			$cap_cpu_CDLV = $cap_cpu_CDLV | where-object {$_.cluster -like "*VSAN*"}
			$cap_mem_CDLV = Import-CSVCustom "$BasePath\172.19.15.60\$Date\RVTools_tabvMemory.csv"
			$cap_mem_CDLV = $cap_mem_CDLV | where-object {$_.cluster -like "*VSAN*"}
			$cap_host_CDLV = Import-CSVCustom "$BasePath\172.19.15.60\$Date\RVTools_tabvHost.csv"
			$cap_host_CDLV = $cap_host_CDLV | where-object {$_.cluster -like "*VSAN*"}
			$cap_disk_CDLV = Import-CSVCustom "$BasePath\172.19.15.60\$Date\RVTools_tabvDisk.csv"
			$cap_disk_CDLV = $cap_disk_CDLV | where-object {$_.cluster -like "*VSAN*"}
			$cap_ds_CDLV = Import-CSVCustom "$BasePath\172.19.15.60\$Date\RVTools_tabvDatastore.csv"
			$cap_ds_CDLV = $cap_ds_CDLV | where-object {$_.cluster -like "*VSAN*"}
			
			
			[int]$Provision_CPU_CDLV = 0
			[int]$CPU_Total = 0
			[int]$MEM_Total = 0
			[int]$Penaliza_OverHead_MEM = 0
			[int]$Penaliza_HA_MEM = 0
			[int]$Penaliza_Total = 0
			[int]$Recurso_Protegido_MEM = 0
			[int]$MEM_Disponible = 0
			[int]$Penaliza_CPU = $cap_host_CDLV[1]."# Cores"
			[int]$Penaliza_OverHead_MEM = 0
			[int]$Provision_MEM_CDLV = 0
			
			[int]$DS_Total = 0
			[int]$DS_Usado = 0
			[int]$DS_Libre = 0
			[int]$Penaliza_DS = 0
			[int]$Penalizado_Total_DS = 0
			[int]$Provision_Disk_CDLV = 0
			[int]$FTT1_DS = 0
			[int]$RAM_FTT1 = 0
			[int]$Total_Disponible_DS = 0
			
			foreach ($CPU_CDLV in $cap_cpu_CDLV){
				$Provision_CPU_CDLV = $Provision_CPU_CDLV + $CPU_CDLV.CPUs
			}			
			
			foreach ($MEM_CDLV in $cap_mem_CDLV){
				$Provision_MEM_CDLV = $Provision_MEM_CDLV + $MEM_CDLV."Size MB"
			}
						
			foreach ($DSK_CDLV in $cap_disk_CDLV){
				$Provision_Disk_CDLV = $Provision_Disk_CDLV + $DSK_CDLV."Capacity MB"
			}

			foreach ($DS_CDLV in $cap_ds_CDLV){
				$DS_Total = $DS_Total + $DS_CDLV."Capacity MB"
				$DS_Usado = $DS_Usado + $DS_CDLV."In Use MB"
				$DS_Libre = $DS_Libre + $DS_CDLV."Free MB"
			}			
			
			foreach ($Host_CDLV in $cap_host_CDLV){
				$CPU_Total = $CPU_Total + $Host_CDLV."# Cores"
				$MEM_Total = $MEM_Total + $Host_CDLV."# Memory"
			}
			
			##### CPU #######
			
			
			$CPU_Core_Fisico = $CPU_Total - $Penaliza_CPU
			$CPU_Ratio4 = $CPU_Core_Fisico * 4
			$CPU_Disponible = $CPU_Ratio4 - $Provision_CPU_CDLV
			
			write-host "-----------------------------------CPU-----------------------------------" 
			write-host "CPU Total" 
			$CPU_Total
			write-host "Penalizacion de cpu" 
			$Penaliza_CPU			
			write-host "Core Fisico" 
			$CPU_Ratio4
			
			write-host "CPU Provision" 
			$Provision_CPU_CDLV
			write-host "CPU Disponible" 
			$CPU_Disponible
			
			###### MEMORIA #######
			$MEM_Total = $MEM_Total / 1024
			$Provision_MEM_CDLV = $Provision_MEM_CDLV /1024
			$Penaliza_OverHead_MEM = 0.03 * $MEM_Total
			$Penaliza_HA_MEM = 0.15 * $MEM_Total
			$Penaliza_Total = $Penaliza_OverHead_MEM + $Penaliza_HA_MEM
			$Recurso_Protegido_MEM = $MEM_Total - $Penaliza_Total
			$MEM_Disponible = $Recurso_Protegido_MEM - $Provision_MEM_CDLV
			
			write-host "-----------------------------------Memoria-----------------------------------" 
			write-host "Memoria total" 
			$MEM_Total
			write-host "Provision memoria" 
			$Provision_MEM_CDLV
			write-host "Penalizacion total" 
			$Penaliza_Total
			write-host "Recurso Protegido Total" 
			$Recurso_Protegido_MEM
			
			
			write-host "Memoria disponible" 
			$MEM_Disponible
			
			###### DISCOS #######
			$DS_Total = $DS_Total / 1024 / 1024
			$Provision_Disk_CDLV = $Provision_Disk_CDLV /1024 / 1024
			$DS_Libre = $DS_Libre /1024 / 1024
			$Penaliza_DS = $DS_Total * 0.3
			$Penalizado_Total_DS = $DS_Total - $Penaliza_DS
			$FTT1_DS = $Provision_Disk_CDLV * 2
			$RAM = $Provision_MEM_CDLV
			$RAM = $RAM / 1024
			$RAM_FTT1 = $RAM * 2
			$Total_Provision = $FTT1_DS + $RAM_FTT1
			$Total_Disponible_DS = $Penalizado_Total_DS - $DS_Usado
			$DS_Usado = $DS_Usado / 1024 / 1024
			$Total_Disponible_DS = $Total_Disponible_DS / 1024 / 1024
			$RAM = "{0:N1}" -f $RAM
			
			write-host "-----------------------------------Discos-----------------------------------" 
			write-host "VSAN Total" 
			$DS_Total 
			write-host "Penalizado 30%"
			$Penaliza_DS
			write-host "Penalizado"
			$Penalizado_Total_DS
			write-host "Provision"
			$Provision_Disk_CDLV
			write-host "Usado"
			$DS_Usado
			write-host "Disponible"
			$DS_Libre
			write-host "Capacidad disponible crecimiento"
			$Penalizado_Total_DS - $DS_Usado
			
			
			
			$cap_cpu_AMU = Import-CSVCustom "$BasePath\10.89.0.39\$Date\RVTools_tabvCPU.csv"
			$cap_mem_AMU = Import-CSVCustom "$BasePath\10.89.0.39\$Date\RVTools_tabvMemory.csv"
			$cap_host_AMU = Import-CSVCustom "$BasePath\10.89.0.39\$Date\RVTools_tabvHost.csv"
			$cap_ds_AMU = Import-CSVCustom "$BasePath\10.89.0.39\$Date\RVTools_tabvDatastore.csv"
			
			$cap_cpu_CONT = Import-CSVCustom "$BasePath\10.89.0.93\$Date\RVTools_tabvCPU.csv"
			$cap_mem_CONT = Import-CSVCustom "$BasePath\10.89.0.93\$Date\RVTools_tabvMemory.csv"
			$cap_host_CONT = Import-CSVCustom "$BasePath\10.89.0.93\$Date\RVTools_tabvHost.csv"
			$cap_ds_CONT = Import-CSVCustom "$BasePath\10.89.0.93\$Date\RVTools_tabvDatastore.csv"
			
			
			#--------------------------------------------- excel -----------------------------------
			
			$excel = New-Object -ComObject Excel.Application
			$excel.Visible = $true
			$workbook = $excel.Workbooks.Add()
			#$workbook.ActiveSheet.Name = "Resultado_Total"
			#$w = $workbook.Sheets.Add()
			$workbook.ActiveSheet.Name = $valor2
       
			$escribe = $workbook.ActiveSheet
			
			###################### ENCABEZADO ######################
			
			$escribe.Cells.Item(2,2) = "Informe Capacidades "
			$escribe.Cells.Item(3,2) = "Cliente "
			
			
			########### CPU ###############
			
			$escribe.Cells.Item(5,2) = "Recursos CPU"
			$escribe.Cells.Item(5,2).Font.Size = 12
			$escribe.Cells.Item(5,2).Font.Bold=$True
			$escribe.Cells.Item(5,2).Interior.ColorIndex = 48
			$escribe.Cells.Item(5,3) = $cap_host_CDLV.count
			$escribe.Cells.Item(5,3).Font.Size = 12
			$escribe.Cells.Item(5,3).Font.Bold=$True
			$escribe.Cells.Item(5,3).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(6,2) = "Core CPU Total"
			$escribe.Cells.Item(6,3) = $CPU_Total
			
			$escribe.Cells.Item(9,2) = "Penalizacion" 
			$escribe.Cells.Item(9,2).Font.Size = 12
			$escribe.Cells.Item(9,2).Font.Bold=$True
			$escribe.Cells.Item(9,2).Interior.ColorIndex = 48	
			$escribe.Cells.Item(9,3).Font.Size = 12
			$escribe.Cells.Item(9,3).Font.Bold=$True
			$escribe.Cells.Item(9,3).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(10,2) = "Penalizacion de recurso protegido Core"
			$escribe.Cells.Item(10,3) = $Penaliza_CPU
			
			$escribe.Cells.Item(13,2) = "Recurso protegido"
			
			$escribe.Cells.Item(15,2) = "Core Fisicos"
			$escribe.Cells.Item(15,3) = $CPU_Core_Fisico
			
			$escribe.Cells.Item(17,2) = "vCPU Sobre comprometer Ratio 4 vCPU por Core"
			$escribe.Cells.Item(17,3) = $CPU_Ratio4
			
			$escribe.Cells.Item(18,2) = "Recurso provisionado"
			$escribe.Cells.Item(18,2).Font.Size = 12
			$escribe.Cells.Item(18,2).Font.Bold=$True
			$escribe.Cells.Item(18,2).Interior.ColorIndex = 48
			$escribe.Cells.Item(18,3).Font.Size = 12
			$escribe.Cells.Item(18,3).Font.Bold=$True
			$escribe.Cells.Item(18,3).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(19,2) = "Provision de vCPU"
			$escribe.Cells.Item(19,3) = $Provision_CPU_CDLV
			
			$escribe.Cells.Item(24,2) = "Recurso disponible"
			$escribe.Cells.Item(24,2).Font.Size = 12
			$escribe.Cells.Item(24,2).Font.Bold=$True
			$escribe.Cells.Item(24,2).Interior.ColorIndex = 48	
			$escribe.Cells.Item(24,3).Font.Size = 12
			$escribe.Cells.Item(24,3).Font.Bold=$True
			$escribe.Cells.Item(24,3).Interior.ColorIndex = 48				
			
			$escribe.Cells.Item(25,2) = "Disponible vCPU"
			$escribe.Cells.Item(25,3) = $CPU_Disponible
			
			
			############ MEMORIA ################
			
			$escribe.Cells.Item(5,5) = "Recursos Mem" 
			$escribe.Cells.Item(5,5).Font.Size = 12
			$escribe.Cells.Item(5,5).Font.Bold=$True
			$escribe.Cells.Item(5,5).Interior.ColorIndex = 48
			$escribe.Cells.Item(5,6) = $cap_host_CDLV.count 
			$escribe.Cells.Item(5,6).Font.Size = 12
			$escribe.Cells.Item(5,6).Font.Bold=$True
			$escribe.Cells.Item(5,6).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(6,5) = "GB RAM bruto" 
			$escribe.Cells.Item(6,6) = $MEM_Total 
			
			$escribe.Cells.Item(7,5) = "Penalizacion Overhead de VM" 
			$escribe.Cells.Item(7,6) = "3%" 
			
			$escribe.Cells.Item(8,5) = "GB Memoria RAM" 
			$escribe.Cells.Item(8,6) = $Penaliza_OverHead_MEM
			
			$escribe.Cells.Item(9,5) = "Penalizacion" 
			$escribe.Cells.Item(9,5).Font.Size = 12
			$escribe.Cells.Item(9,5).Font.Bold=$True
			$escribe.Cells.Item(9,5).Interior.ColorIndex = 48		
			$escribe.Cells.Item(9,6).Font.Size = 12
			$escribe.Cells.Item(9,6).Font.Bold=$True
			$escribe.Cells.Item(9,6).Interior.ColorIndex = 48			
			
			$escribe.Cells.Item(10,5) = "Penalizacion Recurso Protegido (HA)" 
			$escribe.Cells.Item(10,6) = "15%"
			
			$escribe.Cells.Item(11,5) = "GB Memoria RAM" 
			$escribe.Cells.Item(11,6) = $Penaliza_HA_MEM
					
			$escribe.Cells.Item(13,5) = "Total penalizado GB" 
			$escribe.Cells.Item(13,6) = $Penaliza_Total
			
			$escribe.Cells.Item(14,5) = "Total recurso protegido GB" 
			$escribe.Cells.Item(14,6) = $Recurso_Protegido_MEM
			
			$escribe.Cells.Item(18,5) = "Recurso provisionado" 
			$escribe.Cells.Item(18,5).Font.Size = 12
			$escribe.Cells.Item(18,5).Font.Bold=$True
			$escribe.Cells.Item(18,5).Interior.ColorIndex = 48			
			$escribe.Cells.Item(18,6).Font.Size = 12
			$escribe.Cells.Item(18,6).Font.Bold=$True
			$escribe.Cells.Item(18,6).Interior.ColorIndex = 48	
			
			$escribe.Cells.Item(19,5) = "Provision vRAM en VMs GB" 
			$escribe.Cells.Item(19,6) = $Provision_MEM_CDLV
			
			$escribe.Cells.Item(24,5) = "Recurso disponible"
			$escribe.Cells.Item(24,5).Font.Size = 12
			$escribe.Cells.Item(24,5).Font.Bold=$True
			$escribe.Cells.Item(24,5).Interior.ColorIndex = 48	
			$escribe.Cells.Item(24,6).Font.Size = 12
			$escribe.Cells.Item(24,6).Font.Bold=$True
			$escribe.Cells.Item(24,6).Interior.ColorIndex = 48				
			
			$escribe.Cells.Item(25,5) = "Disponible vRAM" 
			$escribe.Cells.Item(25,6) = $MEM_Disponible	
			
			############### DISCOS ##############
					
			$escribe.Cells.Item(5,8) = "Recursos VSAN" 
			$escribe.Cells.Item(5,8).Font.Size = 12
			$escribe.Cells.Item(5,8).Font.Bold=$True
			$escribe.Cells.Item(5,8).Interior.ColorIndex = 48
			$escribe.Cells.Item(5,9) = $cap_host_CDLV.count
			$escribe.Cells.Item(5,9).Font.Size = 12
			$escribe.Cells.Item(5,9).Font.Bold=$True
			$escribe.Cells.Item(5,9).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(6,8) = "DS Total" 
			$escribe.Cells.Item(6,9) = $DS_Total
			
			$escribe.Cells.Item(7,8) = "DS Usado" 
			$escribe.Cells.Item(7,9) = $DS_Usado
			
			$escribe.Cells.Item(8,8) = "DS Libre" 
			$escribe.Cells.Item(8,9) = $DS_Libre
			
			$escribe.Cells.Item(9,8) = "Penalizacion" 
			$escribe.Cells.Item(9,8).Font.Size = 12
			$escribe.Cells.Item(9,8).Font.Bold=$True
			$escribe.Cells.Item(9,8).Interior.ColorIndex = 48	
			$escribe.Cells.Item(9,9).Font.Size = 12
			$escribe.Cells.Item(9,9).Font.Bold=$True
			$escribe.Cells.Item(9,9).Interior.ColorIndex = 48	

			
			$escribe.Cells.Item(10,8) = "Penalizacion VSAN%" 
			$escribe.Cells.Item(10,9) = "30%"
			
			$escribe.Cells.Item(11,8) = "Penalizacion VSAN TB" 
			$escribe.Cells.Item(11,9) = $Penaliza_DS
			
			$escribe.Cells.Item(12,8) = "Total menos Penalizacion" 
			$escribe.Cells.Item(12,9) = $Penalizado_Total_DS
			
			$escribe.Cells.Item(18,8) = "Recurso provisionado"
			$escribe.Cells.Item(18,8).Font.Size = 12
			$escribe.Cells.Item(18,8).Font.Bold=$True
			$escribe.Cells.Item(18,8).Interior.ColorIndex = 48	
			$escribe.Cells.Item(18,9).Font.Size = 12
			$escribe.Cells.Item(18,9).Font.Bold=$True
			$escribe.Cells.Item(18,9).Interior.ColorIndex = 48				
			
			$escribe.Cells.Item(19,8) = "GB Provisionado" 
			$escribe.Cells.Item(19,9) = $Provision_Disk_CDLV
			
			$escribe.Cells.Item(20,8) = "FTT1" 
			$escribe.Cells.Item(20,9) = $FTT1_DS
			
			$escribe.Cells.Item(21,8) = "RAM" 
			$escribe.Cells.Item(21,9) = $RAM
			
			$escribe.Cells.Item(22,8) = "RAM FTT1" 
			$escribe.Cells.Item(22,9) = $RAM_FTT1
			
			$escribe.Cells.Item(23,8) = "Total Provisionado TB" 
			$escribe.Cells.Item(23,9) = $Total_Provision
			
			$escribe.Cells.Item(23,8) = "Recurso disponible" 
			
			##################### RESUMEN ####################
			
			$escribe.Cells.Item(30,2) = "Disponible vCPU"
			$escribe.Cells.Item(30,3) = $CPU_Disponible
			
			$escribe.Cells.Item(31,2) = "Disponible vRAM GB"
			$escribe.Cells.Item(31,3) = $MEM_Disponible
			
			$escribe.Cells.Item(29,5) = "Capacidad Bruta"
			$escribe.Cells.Item(29,6) = $DS_Total
			
			$escribe.Cells.Item(30,5) = "Capacidad 70% Max Usado"
			$escribe.Cells.Item(30,6) = $Penalizado_Total_DS
			
			$escribe.Cells.Item(31,5) = "Provision Disco"
			$escribe.Cells.Item(31,6) = $Total_Provision
			
			$escribe.Cells.Item(32,5) = "Uso de Disco"
			$escribe.Cells.Item(32,6) = $DS_Usado
			
			$escribe.Cells.Item(33,5) = "Disponible DS"
			$escribe.Cells.Item(33,6) = $DS_Total - $DS_Usado
			
			$escribe.Cells.Item(35,5) = "Disponible Provision Crecimiento"
			$escribe.Cells.Item(35,6) = $Penalizado_Total_DS - $DS_Usado
			
			############### FORMATO ###################
			
			$objRange = $escribe.UsedRange
			[void] $objRange.EntireColumn.Autofit()			
			
			
			
			
			
			$cap_cpu_URA = Import-CSVCustom "$BasePath\172.19.15.180\$Date\RVTools_tabvCPU.csv"
			$cap_mem_URA = Import-CSVCustom "$BasePath\172.19.15.180\$Date\RVTools_tabvMemory.csv"
			$cap_host_URA = Import-CSVCustom "$BasePath\172.19.15.180\$Date\RVTools_tabvHost.csv"
			$cap_ds_URA = Import-CSVCustom "$BasePath\172.19.15.180\$Date\RVTools_tabvDatastore.csv"
		}
		
		if ($valor2 -like "correo"){
		
			$cap_cpu_CDLV =  Import-CSV "$BasePath\10.89.0.38\$Date\RVTools_tabvCPU.csv"
			$cap_mem_CDLV =  Import-CSV "$BasePath\10.89.0.38\$Date\RVTools_tabvMemory.csv"
			$cap_host_CDLV = Import-CSV "$BasePath\10.89.0.38\$Date\RVTools_tabvHost.csv"
			$cap_disk_CDLV = Import-CSV "$BasePath\10.89.0.38\$Date\RVTools_tabvDisk.csv"
			$cap_ds_CDLV =   Import-CSV "$BasePath\10.89.0.38\$Date\RVTools_tabvDatastore.csv"
			
			[int]$Provision_CPU_CDLV = 0
			[int]$CPU_Total = 0
			[int]$MEM_Total = 0
			[int]$Penaliza_OverHead_MEM = 0
			[int]$Penaliza_HA_MEM = 0
			[int]$Penaliza_Total = 0
			[int]$Recurso_Protegido_MEM = 0
			[int]$MEM_Disponible = 0
			[int]$Penaliza_CPU = $cap_host_CDLV[1]."# Cores"
			[int]$Penaliza_OverHead_MEM = 0
			[int]$Provision_MEM_CDLV = 0
			
			[int]$DS_Total = 0
			[int]$DS_Usado = 0
			[int]$DS_Libre = 0
			[int]$Penaliza_DS = 0
			[int]$Penalizado_Total_DS = 0
			[int]$Provision_Disk_CDLV = 0
			[int]$FTT1_DS = 0
			[int]$RAM_FTT1 = 0
			[int]$Total_Disponible_DS = 0
			
			foreach ($CPU_CDLV in $cap_cpu_CDLV){
				$Provision_CPU_CDLV = $Provision_CPU_CDLV + $CPU_CDLV.CPUs
			}			
			
			foreach ($MEM_CDLV in $cap_mem_CDLV){
				$Provision_MEM_CDLV = $Provision_MEM_CDLV + $MEM_CDLV."Size MB"
			}
						
			foreach ($DSK_CDLV in $cap_disk_CDLV){
				$Provision_Disk_CDLV = $Provision_Disk_CDLV + $DSK_CDLV."Capacity MB"
			}

			foreach ($DS_CDLV in $cap_ds_CDLV){
				$DS_Total = $DS_Total + $DS_CDLV."Capacity MB"
				$DS_Usado = $DS_Usado + $DS_CDLV."In Use MB"
				$DS_Libre = $DS_Libre + $DS_CDLV."Free MB"
			}			
			
			foreach ($Host_CDLV in $cap_host_CDLV){
				$CPU_Total = $CPU_Total + $Host_CDLV."# Cores"
				$MEM_Total = $MEM_Total + $Host_CDLV."# Memory"
			}
			
			##### CPU #######
			
			
			$CPU_Core_Fisico = $CPU_Total - $Penaliza_CPU
			$CPU_Ratio4 = $CPU_Core_Fisico * 4
			$CPU_Disponible = $CPU_Ratio4 - $Provision_CPU_CDLV
			
			write-host "-----------------------------------CPU-----------------------------------" 
			write-host "CPU Total" 
			$CPU_Total
			write-host "Penalizacion de cpu" 
			$Penaliza_CPU			
			write-host "Core Fisico" 
			$CPU_Ratio4
			
			write-host "CPU Provision" 
			$Provision_CPU_CDLV
			write-host "CPU Disponible" 
			$CPU_Disponible
			
			###### MEMORIA #######
			$MEM_Total = $MEM_Total / 1024
			$Provision_MEM_CDLV = $Provision_MEM_CDLV /1024
			$Penaliza_OverHead_MEM = 0.03 * $MEM_Total
			$Penaliza_HA_MEM = 0.15 * $MEM_Total
			$Penaliza_Total = $Penaliza_OverHead_MEM + $Penaliza_HA_MEM
			$Recurso_Protegido_MEM = $MEM_Total - $Penaliza_Total
			$MEM_Disponible = $Recurso_Protegido_MEM - $Provision_MEM_CDLV
			
			write-host "-----------------------------------Memoria-----------------------------------" 
			write-host "Memoria total" 
			$MEM_Total
			write-host "Provision memoria" 
			$Provision_MEM_CDLV
			write-host "Penalizacion total" 
			$Penaliza_Total
			write-host "Recurso Protegido Total" 
			$Recurso_Protegido_MEM
			
			
			write-host "Memoria disponible" 
			$MEM_Disponible
			
			###### DISCOS #######
			$DS_Total = $DS_Total / 1024 / 1024
			$Provision_Disk_CDLV = $Provision_Disk_CDLV /1024 / 1024
			$DS_Libre = $DS_Libre /1024 / 1024
			$Penaliza_DS = $DS_Total * 0.3
			$Penalizado_Total_DS = $DS_Total - $Penaliza_DS
			$FTT1_DS = $Provision_Disk_CDLV * 2
			$RAM = $Provision_MEM_CDLV
			$RAM = $RAM / 1024
			$RAM_FTT1 = $RAM * 2
			$Total_Provision = $FTT1_DS + $RAM_FTT1
			$Total_Disponible_DS = $Penalizado_Total_DS - $DS_Usado
			$DS_Usado = $DS_Usado / 1024 / 1024
			$Total_Disponible_DS = $Total_Disponible_DS / 1024 / 1024
			$RAM = "{0:N1}" -f $RAM
			
			write-host "-----------------------------------Discos-----------------------------------" 
			write-host "VSAN Total" 
			$DS_Total 
			write-host "Penalizado 30%"
			$Penaliza_DS
			write-host "Penalizado"
			$Penalizado_Total_DS
			write-host "Provision"
			$Provision_Disk_CDLV
			write-host "Usado"
			$DS_Usado
			write-host "Disponible"
			$DS_Libre
			write-host "Capacidad disponible crecimiento"
			$Penalizado_Total_DS - $DS_Usado
			
			
			
			$cap_cpu_AMU = Import-CSV "$BasePath\10.89.0.39\$Date\RVTools_tabvCPU.csv"
			$cap_mem_AMU = Import-CSV "$BasePath\10.89.0.39\$Date\RVTools_tabvMemory.csv"
			$cap_host_AMU = Import-CSV "$BasePath\10.89.0.39\$Date\RVTools_tabvHost.csv"
			$cap_ds_AMU = Import-CSV "$BasePath\10.89.0.39\$Date\RVTools_tabvDatastore.csv"
			
			<# importa los achivos rvtools del site de contingencia 
			$cap_cpu_CONT = Import-CSV "$BasePath\10.89.0.93\$Date\RVTools_tabvCPU.csv"
			$cap_mem_CONT = Import-CSV "$BasePath\10.89.0.93\$Date\RVTools_tabvMemory.csv"
			$cap_host_CONT = Import-CSV "$BasePath\10.89.0.93\$Date\RVTools_tabvHost.csv"
			$cap_ds_CONT = Import-CSV "$BasePath\10.89.0.93\$Date\RVTools_tabvDatastore.csv"
			#>
			
			
			#--------------------------------------------- excel -----------------------------------
			
			$excel = New-Object -ComObject Excel.Application
			$excel.Visible = $true
			$workbook = $excel.Workbooks.Add()
			#$workbook.ActiveSheet.Name = "Resultado_Total"
			#$w = $workbook.Sheets.Add()
			$workbook.ActiveSheet.Name = $valor2
       
			$escribe = $workbook.ActiveSheet
			
			###################### ENCABEZADO ######################
			
			$escribe.Cells.Item(2,2) = "Informe Capacidades "
			$escribe.Cells.Item(3,2) = "Cliente "
			
			
			########### CPU ###############
			
			$escribe.Cells.Item(5,2) = "Recursos CPU"
			$escribe.Cells.Item(5,2).Font.Size = 12
			$escribe.Cells.Item(5,2).Font.Bold=$True
			$escribe.Cells.Item(5,2).Interior.ColorIndex = 48
			$escribe.Cells.Item(5,3) = $cap_host_CDLV.count
			$escribe.Cells.Item(5,3).Font.Size = 12
			$escribe.Cells.Item(5,3).Font.Bold=$True
			$escribe.Cells.Item(5,3).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(6,2) = "Core CPU Total"
			$escribe.Cells.Item(6,3) = $CPU_Total
			
			$escribe.Cells.Item(9,2) = "Penalizacion" 
			$escribe.Cells.Item(9,2).Font.Size = 12
			$escribe.Cells.Item(9,2).Font.Bold=$True
			$escribe.Cells.Item(9,2).Interior.ColorIndex = 48	
			$escribe.Cells.Item(9,3).Font.Size = 12
			$escribe.Cells.Item(9,3).Font.Bold=$True
			$escribe.Cells.Item(9,3).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(10,2) = "Penalizacion de recurso protegido Core"
			$escribe.Cells.Item(10,3) = $Penaliza_CPU
			
			$escribe.Cells.Item(13,2) = "Recurso protegido"
			
			$escribe.Cells.Item(15,2) = "Core Fisicos"
			$escribe.Cells.Item(15,3) = $CPU_Core_Fisico
			
			$escribe.Cells.Item(17,2) = "vCPU Sobre comprometer Ratio 4 vCPU por Core"
			$escribe.Cells.Item(17,3) = $CPU_Ratio4
			
			$escribe.Cells.Item(18,2) = "Recurso provisionado"
			$escribe.Cells.Item(18,2).Font.Size = 12
			$escribe.Cells.Item(18,2).Font.Bold=$True
			$escribe.Cells.Item(18,2).Interior.ColorIndex = 48
			$escribe.Cells.Item(18,3).Font.Size = 12
			$escribe.Cells.Item(18,3).Font.Bold=$True
			$escribe.Cells.Item(18,3).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(19,2) = "Provision de vCPU"
			$escribe.Cells.Item(19,3) = $Provision_CPU_CDLV
			
			$escribe.Cells.Item(24,2) = "Recurso disponible"
			$escribe.Cells.Item(24,2).Font.Size = 12
			$escribe.Cells.Item(24,2).Font.Bold=$True
			$escribe.Cells.Item(24,2).Interior.ColorIndex = 48	
			$escribe.Cells.Item(24,3).Font.Size = 12
			$escribe.Cells.Item(24,3).Font.Bold=$True
			$escribe.Cells.Item(24,3).Interior.ColorIndex = 48				
			
			$escribe.Cells.Item(25,2) = "Disponible vCPU"
			$escribe.Cells.Item(25,3) = $CPU_Disponible
			
			
			############ MEMORIA ################
			
			$escribe.Cells.Item(5,5) = "Recursos Mem" 
			$escribe.Cells.Item(5,5).Font.Size = 12
			$escribe.Cells.Item(5,5).Font.Bold=$True
			$escribe.Cells.Item(5,5).Interior.ColorIndex = 48
			$escribe.Cells.Item(5,6) = $cap_host_CDLV.count 
			$escribe.Cells.Item(5,6).Font.Size = 12
			$escribe.Cells.Item(5,6).Font.Bold=$True
			$escribe.Cells.Item(5,6).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(6,5) = "GB RAM bruto" 
			$escribe.Cells.Item(6,6) = $DS_Total 
			
			$escribe.Cells.Item(7,5) = "Penalizacion Overhead de VM" 
			$escribe.Cells.Item(7,6) = "3%" 
			
			$escribe.Cells.Item(8,5) = "GB Memoria RAM" 
			$escribe.Cells.Item(8,6) = $Penaliza_OverHead_MEM
			
			$escribe.Cells.Item(9,5) = "Penalizacion" 
			$escribe.Cells.Item(9,5).Font.Size = 12
			$escribe.Cells.Item(9,5).Font.Bold=$True
			$escribe.Cells.Item(9,5).Interior.ColorIndex = 48		
			$escribe.Cells.Item(9,6).Font.Size = 12
			$escribe.Cells.Item(9,6).Font.Bold=$True
			$escribe.Cells.Item(9,6).Interior.ColorIndex = 48			
			
			$escribe.Cells.Item(10,5) = "Penalizacion Recurso Protegido (HA)" 
			$escribe.Cells.Item(10,6) = "15%"
			
			$escribe.Cells.Item(11,5) = "GB Memoria RAM" 
			$escribe.Cells.Item(11,6) = $Penaliza_HA_MEM
					
			$escribe.Cells.Item(13,5) = "Total penalizado GB" 
			$escribe.Cells.Item(13,6) = $Penaliza_Total
			
			$escribe.Cells.Item(14,5) = "Total recurso protegido GB" 
			$escribe.Cells.Item(14,6) = $Recurso_Protegido_MEM
			
			$escribe.Cells.Item(18,5) = "Recurso provisionado" 
			$escribe.Cells.Item(18,5).Font.Size = 12
			$escribe.Cells.Item(18,5).Font.Bold=$True
			$escribe.Cells.Item(18,5).Interior.ColorIndex = 48			
			$escribe.Cells.Item(18,6).Font.Size = 12
			$escribe.Cells.Item(18,6).Font.Bold=$True
			$escribe.Cells.Item(18,6).Interior.ColorIndex = 48	
			
			$escribe.Cells.Item(19,5) = "Provision vRAM en VMs GB" 
			$escribe.Cells.Item(19,6) = $Provision_MEM_CDLV
			
			$escribe.Cells.Item(24,5) = "Recurso disponible"
			$escribe.Cells.Item(24,5).Font.Size = 12
			$escribe.Cells.Item(24,5).Font.Bold=$True
			$escribe.Cells.Item(24,5).Interior.ColorIndex = 48	
			$escribe.Cells.Item(24,6).Font.Size = 12
			$escribe.Cells.Item(24,6).Font.Bold=$True
			$escribe.Cells.Item(24,6).Interior.ColorIndex = 48				
			
			$escribe.Cells.Item(25,5) = "Disponible vRAM" 
			$escribe.Cells.Item(25,6) = $MEM_Disponible	
			
			############### DISCOS ##############
					
			$escribe.Cells.Item(5,8) = "Recursos VSAN" 
			$escribe.Cells.Item(5,8).Font.Size = 12
			$escribe.Cells.Item(5,8).Font.Bold=$True
			$escribe.Cells.Item(5,8).Interior.ColorIndex = 48
			$escribe.Cells.Item(5,9) = $cap_host_CDLV.count
			$escribe.Cells.Item(5,9).Font.Size = 12
			$escribe.Cells.Item(5,9).Font.Bold=$True
			$escribe.Cells.Item(5,9).Interior.ColorIndex = 48
			
			$escribe.Cells.Item(6,8) = "DS Total" 
			$escribe.Cells.Item(6,9) = $DS_Total
			
			$escribe.Cells.Item(7,8) = "DS Usado" 
			$escribe.Cells.Item(7,9) = $DS_Usado
			
			$escribe.Cells.Item(8,8) = "DS Libre" 
			$escribe.Cells.Item(8,9) = $DS_Libre
			
			$escribe.Cells.Item(9,8) = "Penalizacion" 
			$escribe.Cells.Item(9,8).Font.Size = 12
			$escribe.Cells.Item(9,8).Font.Bold=$True
			$escribe.Cells.Item(9,8).Interior.ColorIndex = 48	
			$escribe.Cells.Item(9,9).Font.Size = 12
			$escribe.Cells.Item(9,9).Font.Bold=$True
			$escribe.Cells.Item(9,9).Interior.ColorIndex = 48	

			
			$escribe.Cells.Item(10,8) = "Penalizacion VSAN%" 
			$escribe.Cells.Item(10,9) = "30%"
			
			$escribe.Cells.Item(11,8) = "Penalizacion VSAN TB" 
			$escribe.Cells.Item(11,9) = $Penaliza_DS
			
			$escribe.Cells.Item(12,8) = "Total menos Penalizacion" 
			$escribe.Cells.Item(12,9) = $Penalizado_Total_DS
			
			$escribe.Cells.Item(18,8) = "Recurso provisionado"
			$escribe.Cells.Item(18,8).Font.Size = 12
			$escribe.Cells.Item(18,8).Font.Bold=$True
			$escribe.Cells.Item(18,8).Interior.ColorIndex = 48	
			$escribe.Cells.Item(18,9).Font.Size = 12
			$escribe.Cells.Item(18,9).Font.Bold=$True
			$escribe.Cells.Item(18,9).Interior.ColorIndex = 48				
			
			$escribe.Cells.Item(19,8) = "GB Provisionado" 
			$escribe.Cells.Item(19,9) = $Provision_Disk_CDLV
			
			$escribe.Cells.Item(20,8) = "FTT1" 
			$escribe.Cells.Item(20,9) = $FTT1_DS
			
			$escribe.Cells.Item(21,8) = "RAM" 
			$escribe.Cells.Item(21,9) = $RAM
			
			$escribe.Cells.Item(22,8) = "RAM FTT1" 
			$escribe.Cells.Item(22,9) = $RAM_FTT1
			
			$escribe.Cells.Item(23,8) = "Total Provisionado TB" 
			$escribe.Cells.Item(23,9) = $Total_Provision
			
			$escribe.Cells.Item(23,8) = "Recurso disponible" 
			
			##################### RESUMEN ####################
			
			$escribe.Cells.Item(30,2) = "Disponible vCPU"
			$escribe.Cells.Item(30,3) = $CPU_Disponible
			
			$escribe.Cells.Item(31,2) = "Disponible vRAM GB"
			$escribe.Cells.Item(31,3) = $MEM_Disponible
			
			$escribe.Cells.Item(29,5) = "Capacidad Bruta"
			$escribe.Cells.Item(29,6) = $DS_Total
			
			$escribe.Cells.Item(30,5) = "Capacidad 70% Max Usado"
			$escribe.Cells.Item(30,6) = $Penalizado_Total_DS
			
			$escribe.Cells.Item(31,5) = "Provision Disco"
			$escribe.Cells.Item(31,6) = $Total_Provision
			
			$escribe.Cells.Item(32,5) = "Uso de Disco"
			$escribe.Cells.Item(32,6) = $DS_Usado
			
			$escribe.Cells.Item(33,5) = "Disponible DS"
			$escribe.Cells.Item(33,6) = $DS_Total - $DS_Usado
			
			$escribe.Cells.Item(35,5) = "Disponible Provision Crecimiento"
			$escribe.Cells.Item(35,6) = $Penalizado_Total_DS - $DS_Usado
			
			############### FORMATO ###################
			
			$objRange = $escribe.UsedRange
			[void] $objRange.EntireColumn.Autofit()
		}
	}
	
	elseif ($valor -eq "todo")
	{
		#Get-ChildItem "$BasePath\*\$Date" -Filter *vSnapshot.csv -Recurse | %{$files += $_}
		write-host ""
		write-host "==================== Informacion General de VM $valor2 ====================" -ForegroundColor Yellow
		write-host ""
		buscar $valor2 | ft -AutoSize
		write-host ""
		write-host "==================== Informacion Red de VM $valor2 ====================" -ForegroundColor Yellow
		write-host ""
		buscar red $valor2 | ft -AutoSize
		write-host ""
		write-host "==================== Informacion Discos Fisicos de VM $valor2 ====================" -ForegroundColor Yellow
		write-host ""
		buscar discos $valor2 | ft -AutoSize
		write-host ""
		write-host "==================== Informacion Particiones Logicas de VM $valor2 ====================" -ForegroundColor Yellow
		write-host ""
		buscar particion $valor2 | ft -AutoSize
	}
	
	else
	{	
		Get-ChildItem "$BasePath\*\$Date" -Filter *info.csv -Recurse | %{$files += $_} 
		
		foreach ($file in $files)
		{			
			$result = Import-CSVCustom $file.fullname | Where-Object {$_.VM -like "*$valor*" -or $_."DNS Name" -like "*$valor*" -or $_."VI SDK Server" -like "*$valor*" -or $_.Datacenter -like "*$valor*" -or $_.Cliente -like "*$valor*" -or $_.Cliente1 -like "*$valor*" -or $_.Cluster -like "*$valor*" -or $_.Datacenter1 -like "*$valor*"} | select VM, "DNS Name", Powerstate, Template, CPUs, Memory,"OS according to the VMware Tools", NICs,Disks, "HW version", host, Cluster, Datacenter1, "Provisioned MB", "In Use MB",  "VI SDK Server"
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