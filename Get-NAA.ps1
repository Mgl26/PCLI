
	<#	
	
	Detalle: Funcion que obtiene el identificados Naa de los datastore asociados a una o mas maquinas
	Detalle Ejemplo:	 Get-Naa
	Detalle Ejemplo:	
	Detalle Ejemplo:	 ...((1))-----------Obtener Naa de una o varias VMs
	Detalle Ejemplo:	 
	Detalle Ejemplo:	 ...((2))-----------Obtener Naa de VMs en una Carpeta
	Detalle Ejemplo:	 
	Detalle Ejemplo:	 ...((3))-----------Obtener Naa de VMs en un Host
	Detalle Ejemplo:	 
	Detalle Ejemplo:	 ...((4))-----------Obtener Naa de VMs en un Cluster
	Detalle Ejemplo:	 
	Detalle Ejemplo:	 ...((5))-----------Obtener Naa de todas las VMs
	Detalle Ejemplo:	 
	Detalle Ejemplo:	 Introduce un valor: [INGRESA EL NUMERO CORRESPONDIENTE AL MENU]
	Detalle Ejemplo:	 
	Detalle Ejemplo:	 Ingresa el nombre de la VM #1: [NOMBRE-VM1]
	Detalle Ejemplo:	 Ingresa el nombre de la VM #2: [NOMBRE-VM2]
	Detalle Ejemplo:	 Ingresa el nombre de la VM #3: [NOMBRE-VM3]
	Detalle Ejemplo:	 Ingresa el nombre de la VM #4:
	#>

function Get-Naa ()
{
	$fecha = (Get-Date -f "yyyyMMdd")
	$vms = @()
	$c = 1
	$v = 0

	write-host ""
	write-host ""
	#write-host "...((1))-----------Obtener naa de una VM"
	#write-host ""
	write-host "...((1))-----------Obtener Naa de una o varias VMs"
	write-host ""
	write-host "...((2))-----------Obtener Naa de VMs en una Carpeta"
	write-host ""
	write-host "...((3))-----------Obtener Naa de VMs en un Host"
	write-host ""
	write-host "...((4))-----------Obtener Naa de VMs en un Cluster"
	write-host ""
	write-host "...((5))-----------Obtener Naa de todas las VMs"
	write-host ""
	$valor = read-host "Introduce un valor"
	$date = get-date -f "ddMMyyyy"
	switch ($valor) 
    { 
        <#
		1 
		{
			$vm = read-host "Introduce el nombre de la VM"
			
			
			get-vm $vm | %{$maquina = $_.name; $_} | Get-Datastore | %{$ds = $_; $_} | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$ds.name}},
			@{N="Naa";E={$ds.extensiondata.Info.Vmfs.Extent.DiskName}},
			@{N="LunID";E={((get-vmhost -VM $maquina | get-esxcli).storage.core.path.list() | Where-Object {$ds.Device -eq $_.extensiondata.Info.Vmfs.Extent.DiskName} | Select-Object -First 1 @{N="LunID";E={($_.RuntimeName).split(':')[3]}}).LunID }},
			@{N="WWN";E={((get-vmhost -VM $maquina | get-esxcli).storage.core.path.list() | Where-Object {$ds.Device -eq $_.extensiondata.Info.Vmfs.Extent.DiskName} | Select-Object -First 1 @{N="WWN";E={$_.TargetTransportDetails}}).WWN}},
			CapacityGB | ft
			break
		}
		#>
        1 
		{
			do 
			{
				$input = (Read-Host "Ingresa el nombre de la VM #$c")
				if ($input -ne '') 
				{
					$vms += $input;$cant_server++
					$c++
				}
			}until ($input -eq '')
			
			Get-VM $vms | %{$maquina = $_.name; $_} | Get-Datastore | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$_.name}},
			@{N="Naa";E={$_.extensiondata.Info.Vmfs.Extent.DiskName}},
			CapacityGB | ft -autosize
			
			Get-VM $vms | %{$maquina = $_.name; $_} | Get-Datastore | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$_.name}},
			@{N="Naa";E={$_.extensiondata.Info.Vmfs.Extent.DiskName}},
			CapacityGB |  export-csv c:\temp\$date"Naa.csv" -NoTypeInformation -Delimiter ";"
			
			break
		} 
        2
		{
			$fold = get-folder
			write-host $fold.name
			$folder = read-host "Introduce el nombre del folder"			
			
			Get-VM -Location $folder | %{$maquina = $_.name; $_} | Get-Datastore | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$_.name}},
			@{N="Naa";E={$_.extensiondata.Info.Vmfs.Extent.DiskName}},
			CapacityGB | ft
			break		
		
		} 
        3 
		{
			$vmh = get-vmhost | select name
			write-host $vmh.name
			$hostt = read-host "Introduce el nombre del Host"			
			
			Get-VMHost -Name $hostt | Get-VM | %{$maquina = $_.name; $_} | Get-Datastore | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$_.name}},
			@{N="Naa";E={$_.extensiondata.Info.Vmfs.Extent.DiskName}},
			CapacityGB | ft
			break
		} 
        4 
		{
			$clust = get-cluster | select name
			write-host $clust.name
			$clus = read-host "Introduce el nombre del cluster"			
			
			get-cluster -Name $clus | Get-VM | %{$maquina = $_.name; $_} | Get-Datastore | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$_.name}},
			@{N="Naa";E={$_.extensiondata.Info.Vmfs.Extent.DiskName}},
			CapacityGB | ft
			break
		
		} 
        5 
		{
			Get-VM | %{$maquina = $_.name; $_} | Get-Datastore | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$_.name}},
			@{N="Naa";E={$_.extensiondata.Info.Vmfs.Extent.DiskName}},
			CapacityGB | ft
			break
		
		} 
        default {"Opcion $valor no valida"}
    }
}
