function Get-naa ()
{
	$fecha = (Get-Date -f "yyyyMMdd")
	$vms = @()
	$c = 1
	$v = 0

	write-host ""
	write-host ""
	write-host "...((1))-----------Obtener naa de una VM"
	write-host ""
	write-host "...((2))-----------Obtener naa de varias VMs"
	write-host ""
	write-host "...((3))-----------Obtener naa de VMs en una Carpeta"
	write-host ""
	write-host "...((4))-----------Obtener naa de VMs en un Host"
	write-host ""
	write-host "...((5))-----------Obtener naa de VMs en un Cluster"
	write-host ""
	write-host "...((6))-----------Obtener naa de todas las VMs"
	write-host ""
	$valor = read-host "Introduce un valor"
	
	switch ($valor) 
    { 
        1 
		{
			$vm = read-host "Introduce el nombre de la VM"
			
			get-vm $vm | %{$maquina = $_.name; $_} | Get-Datastore | select @{N="DC";E={Get-Datacenter}},
			@{N="VM";E={$maquina}},
			@{N="DS";E={$_.name}},
			@{N="Naa";E={$_.extensiondata.Info.Vmfs.Extent.DiskName}},
			CapacityGB | ft
			break
		} 
        2 
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
			CapacityGB | ft
			break
		} 
        3
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
        4 
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
        5 
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
        6 
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
