function Get-Capacidades ()
{
	$tablaCPU = "" | select Hosts, CPU_Core_Total, Penalizacion_Recurso_Protegido, Core_Fisicos, vCPU_Sobre_Comprometer_Ratio, Provision_de_vCPU, Disponible_vCPU
	$tablaRAM = "" | select Hosts, GB_RAM_Bruto, Penalizacion_Overhead_de_VM, GB_Memoria_RAM_Overhead, Penalizacion_Recurso_Protegido_HA, GB_Memoria_HA, Total_Penalizacion, Total_Recursos_GB, Disponible_vRAM
	$clusters = get-cluster
	foreach($cluster in $clusters){
		Write-Host "==================================================" -ForegroundColor green
		Write-Host "===            $cluster            ===" -ForegroundColor green
		Write-Host "==================================================" -ForegroundColor green
		Write-Host ""
		Write-Host ""
		
		$countHost = 0
		$hosts = $cluster | get-vmhost
		$countHost = $hosts.count
		$VMs = $cluster | get-vm
		$CPUTotal = 0
		$MEMFisicoTotal = 0
		foreach($esxhost in $hosts){
			$CPUTotal += $esxhost.NumCpu
			$MEMFisicoTotal += $esxhost.MemoryTotalGB
		}
		$VMMEMTotal = 0
		$VMCPUTotal = 0
		foreach($VM in $VMs){
			$VMCPUTotal += $VM.NumCpu
			$VMMEMTotal += $VM.MemoryGB
		}	
		
		$CPUPenalizacion = $CPUTotal / 2
		$CPUcorefisico = $CPUTotal - $CPUPenalizacion
		$CPURatio = $CPUcorefisico * 4
		$CPUDisponible = $CPURatio - $VMCPUTotal
		
		$MEMOverhead = ($MEMFisicoTotal * 3) / 100
		$MEMPenalizaHA = 100 / $hosts.count
		$MEMHA = ($MEMFisicoTotal * $MEMPenalizaHA) / 100
		$MEMTotal = $MEMFisicoTotal - ($MEMOverhead + $MEMHA)
		$MEMDisponible = $MEMTotal - $VMMEMTotal
		
		$tablaCPU.Hosts = $countHost
		$tablaCPU.CPU_Core_Total = "{0:N0}" -f $CPUTotal
		$tablaCPU.Penalizacion_Recurso_Protegido = "{0:N0}" -f $CPUPenalizacion
		$tablaCPU.Core_Fisicos = "{0:N0}" -f $CPUcorefisico
		$tablaCPU.vCPU_Sobre_Comprometer_Ratio = "{0:N0}" -f $CPURatio
		$tablaCPU.Provision_de_vCPU = "{0:N0}" -f $VMCPUTotal
		$tablaCPU.Disponible_vCPU = "{0:N0}" -f $CPUDisponible
		
		
		$tablaRAM.Hosts = $countHost
		$tablaRAM.GB_RAM_Bruto = "{0:N0}" -f $MEMFisicoTotal
		$tablaRAM.Penalizacion_Overhead_de_VM = "3%"
		$tablaRAM.GB_Memoria_RAM_Overhead = "{0:N0}" -f $MEMOverhead
		$tablaRAM.Penalizacion_Recurso_Protegido_HA = "{0:N0}" -f $MEMPenalizaHA
		$tablaRAM.GB_Memoria_HA = "{0:N0}" -f $MEMHA
		$tablaRAM.Total_Penalizacion = "{0:N0}" -f $MEMTotal
		$tablaRAM.Total_Recursos_GB = "{0:N0}" -f $VMMEMTotal
		$tablaRAM.Disponible_vRAM = "{0:N0}" -f $MEMDisponible
		
		#write-host "---------- Cluster -------------"
		#$cluster.name
		#write-host "---------- CPU -------------"
		#Write-Host "Core CPU Total: " $CPUTotal
		#Write-Host "Penalizacion de Recurso Protegido: " $CPUPenalizacion
		#Write-Host "Core Fisicos: " $CPUcorefisico
		#Write-Host "vCPU Sobre Comprometer Ratio 4 vCPU por Core: " $CPURatio
		#Write-Host "Provision de vCPU: " $VMCPUTotal
		#Write-Host "Disponible vCPU " $CPUDisponible
		#write-host "---------- Memoria -------------"
		#Write-Host "GB RAM Bruto: " $MEMFisicoTotal
		#Write-Host "Penalizacion Overhead de VM: 3%"
		#Write-Host "GB Memoria RAM Overhead " $MEMOverhead
		#Write-Host "Penalizacion Recurso Protegido HA: " $MEMPenalizaHA
		#Write-Host "GB Memoria HA " $MEMHA
		#Write-Host "Total Penalizacion: " $MEMTotal
		#Write-Host "Total Recursos GB " $VMMEMTotal
		#Write-Host "Disponible vRAM " $MEMDisponible
		Write-Host "----------- vCPU -----------" -ForegroundColor yellow
		$tablaCPU
		Write-Host ""
		Write-Host "----------- vRAM -----------" -ForegroundColor yellow
		$tablaRAM
	}

}
