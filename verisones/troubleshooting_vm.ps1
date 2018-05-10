	#Estado VMTools
	#Estado Hardware Virtual
	#Ultimos eventos
	#Alarmas
	#Ultimas tareas 
	#Sistema Operativo

	function get-IncVM()
	{
		param(
			[string]$maquina
		)
		$fecha = get-date
		$vms = @()
		$vms = get-vm $maquina
		$hdisks = @()
		foreach($vm in $vms){
			Write-host ""
			Write-host ""
			write-host "============================ $vm ===============================" -ForegroundColor blue
			$vmguest = get-vmguest -VM $vm
			$hdisks = Get-HardDisk -VM $vm
			$ESXVersion = ($vm | get-vmhost).extensiondata.config.product.version
			$color_vhw = "Green"
			
			if($ESXVersion -like "3.5*"){
				if(($vm).extensiondata.config.version -ne "vmx-04"){
					$color_vhw = "Red"
				}
			}
			if($ESXVersion -like "4*"){
				if(($vm).extensiondata.config.version -ne "vmx-07"){
					$color_vhw = "Red"
				}
			}
			if($ESXVersion -like "5.0*"){
				if(($vm).extensiondata.config.version -ne "vmx-08"){
					$color_vhw = "Red"
				}
			}
			if($ESXVersion -like "5.1*"){
				if(($vm).extensiondata.config.version -ne "vmx-09"){
					$color_vhw = "Red"
				}
			}
			if($ESXVersion -like "5.5*"){
				if(($vm).extensiondata.config.version -ne "vmx-10"){
					$color_vhw = "Red"
				}
			}
			if($ESXVersion -like "6.0*"){
				if(($vm).extensiondata.config.version -ne "vmx-11"){
					$color_vhw = "Red"
				}
			}
			if($ESXVersion -like "6.5*"){
				if(($vm).extensiondata.config.version -ne "vmx-13"){
					$color_vhw = "Red"
				}
			}
			
			$color = "Green"
				Write-host ""
				Write-host ""
			Write-host "-------------- Datos de la VM $vm -------------" -ForegroundColor Yellow
				Write-host ""
					Write-host "VM: "$vm
				Write-host ""
					if($vm.PowerState -ne "PoweredOn"){$color = "Red"}
					Write-host "Estatus: "$vm.PowerState -ForegroundColor $color
				Write-host ""
					if($vm.extensiondata.guest.ToolsStatus -notlike "*OK*"){$color = "Red"}
					Write-host "VMTools: "$vm.extensiondata.guest.ToolsStatus -ForegroundColor $color
				Write-host ""
					Write-host "BootTime: " $vm.extensiondata.runtime.boottime
				Write-host ""
					Write-host "Sistema Operativo: " $vm.extensiondata.config.GuestFullName
				Write-host ""
					Write-host "Hardware Virtual: " $vm.extensiondata.config.version -ForegroundColor $color_vhw
				Write-host ""
					Write-host "Host: " ($vm | get-vmhost).name
				Write-host ""
				Write-host ""
			Write-host "-------------- Datos Discos y Particiones $vm -------------" -ForegroundColor Yellow
				Write-host ""
				Write-host ""
				Write-host "Hard Disks:" -ForegroundColor Yellow
					$hdisks
				Write-host ""
				Write-host ""
					Write-host "Particiones:" -ForegroundColor Yellow
					$disks = @()
					$disks = $vmguest.extensiondata.disk
					$rdisk = @()
					foreach($disk in $disks)
					{
						$rdisk += $disk
					}
					$rdisk | select DiskPath, @{N="Capacity GB";E={$_.Capacity / 1GB}}, @{N="FreeSpace GB";E={$_.FreeSpace / 1GB}} | ft -autosize
				Write-host ""
				Write-host ""
			Write-host "-------------- Datos Snapshot $vm -------------" -ForegroundColor Yellow
				Write-host ""
				Write-host ""
					$snapshot = get-snapshot -VM $vm
					if(!$snapshot){write-host "La VM no tiene snapshot" -ForegroundColor Green}else{Write-host "Snapshots: " $snapshot -ForegroundColor Red}
				Write-host ""
				Write-host ""
			Write-host "-------------- Datos Network $vm -------------" -ForegroundColor Yellow
				Write-host ""
				Write-host ""
					Write-host "IP Address: " $vmguest.extensiondata.ipaddress
					$vport = Get-VirtualPortGroup -VM $vm
				Write-host "Portgroups: " $vport | fl
				Write-host ""
				Write-host ""
			Write-host "-------------- Datos Eventos $vm -------------" -ForegroundColor Yellow
				Write-host ""
				Write-host ""
					Write-host "Ultimas Tareas: " -ForegroundColor Yellow
					$tasks = @()
					$tasks = Get-VIEvent -Entity $vm | Where-Object {$_.info -like "*task*"}
					$resulttask = @()
					foreach($task in $tasks)
					{
						
						$resulttask += $task
						#$task.CreatedTime
						#$task.UserName
						#$task.FullFormattedMessage
					}
					$resulttask | select CreatedTime, UserName, FullFormattedMessage | format-table -autosize
				Write-host ""
				Write-host ""
					Write-host "Ultimaos Eventos: " -ForegroundColor Yellow
					$events = Get-VIEvent -Entity $vm -MaxSamples 20
					$resultevents = @()
					foreach($event in $events){
						$resultevents += $event
					}
					$resultevents | Where-Object {$_.FullFormattedMessage -notlike "*task*"} | select UserName, FullFormattedMessage | ft -AutoSize
				Write-host ""
				Write-host ""
		}
	}

