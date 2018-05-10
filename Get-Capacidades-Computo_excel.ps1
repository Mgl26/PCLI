function Get-Capacidades_Excel()
{
	$tablaCPU = "" | select Hosts, CPU_Core_Total, Penalizacion_Recurso_Protegido, Core_Fisicos, vCPU_Sobre_Comprometer_Ratio, Provision_de_vCPU, Disponible_vCPU
	$tablaRAM = "" | select Hosts, GB_RAM_Bruto, Penalizacion_Overhead_de_VM, GB_Memoria_RAM_Overhead, Penalizacion_Recurso_Protegido_HA, GB_Memoria_HA, Total_Penalizacion, Total_Recursos_GB, Disponible_vRAM
	
	$countsheet = 0

	$CPUSobreCompromiso = read-host "Introduce el numero por Sobrecompromiso CPU (Por defecto: 4)"
	if(!$CPUSobreCompromiso){
		$CPUSobreCompromiso = 4
	}
	
	#----- EXCEL ------ CREA ARCHIVO EXCEL
	#$excel = New-Object -ComObject Excel.Application
	#$excel.Visible = $true
	#$workbook = $excel.Workbooks.Add()
	
		
	
	$clusters = get-cluster
	foreach($cluster in $clusters){
		$countsheet++
		Write-Host "==================================================" -ForegroundColor green
		Write-Host "===            $cluster            ===" -ForegroundColor green
		Write-Host "==================================================" -ForegroundColor green
		Write-Host ""
		Write-Host ""
		
		$countHost = 0
		$datacenter = $cluster | get-datacenter
		$hosts = $cluster | get-vmhost
		$countHost = $hosts.count
		$VMs = $cluster | get-vm
		$CPUTotal = 0
		$MEMFisicoTotal = 0
		
		#----- EXCEL ------ AGREGA NUEVA HOJA CON NOMBRE DE CLUSTER
		if($countsheet -ne 1){
			$w = $workbook.Sheets.Add()
		}
		$workbook.ActiveSheet.Name = "COMPUTO-$cluster-$datacenter"
		$escribe = $workbook.ActiveSheet
		
		
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
		
		$CPUPenalizacion = $hosts[0].NumCpu
		$CPUcorefisico = $CPUTotal - $CPUPenalizacion
		$CPURatio = $CPUcorefisico * $CPUSobreCompromiso
		$CPUDisponible = $CPURatio - $VMCPUTotal
		
		$MEMOverhead = ($MEMFisicoTotal * 3) / 100
		$MEMPenalizaHA = 100 / $hosts.count
		$MEMHA = ($MEMFisicoTotal * $MEMPenalizaHA) / 100
		$MEMTotal = $MEMFisicoTotal - ($MEMOverhead + $MEMHA)
		$MEMDisponible = $MEMTotal - $VMMEMTotal
		
		$tablaCPU.Hosts = $countHost
		$tablaCPU.CPU_Core_Total = [math]::round($CPUTotal,2)
		$tablaCPU.Penalizacion_Recurso_Protegido = [math]::round($CPUPenalizacion,2)
		$tablaCPU.Core_Fisicos = [math]::round($CPUcorefisico,2)
		$tablaCPU.vCPU_Sobre_Comprometer_Ratio = [math]::round($CPURatio,2)
		$tablaCPU.Provision_de_vCPU = [math]::round($VMCPUTotal,2)
		$tablaCPU.Disponible_vCPU = [math]::round($CPUDisponible,2)
		
		
		$tablaRAM.Hosts = $countHost
		$tablaRAM.GB_RAM_Bruto = [math]::round($MEMFisicoTotal,2)
		$tablaRAM.Penalizacion_Overhead_de_VM = "3%"
		$tablaRAM.GB_Memoria_RAM_Overhead = [math]::round($MEMOverhead,2)
		$tablaRAM.Penalizacion_Recurso_Protegido_HA = [math]::round($MEMPenalizaHA,2)
		$tablaRAM.GB_Memoria_HA = [math]::round($MEMHA,2)
		$tablaRAM.Total_Penalizacion = [math]::round($MEMTotal,2)
		$tablaRAM.Total_Recursos_GB = [math]::round($VMMEMTotal,2)
		$tablaRAM.Disponible_vRAM = [math]::round($MEMDisponible,2)
	
		Write-Host "----------- vCPU -----------" -ForegroundColor yellow
		$tablaCPU
		Write-Host ""
		Write-Host "----------- vRAM -----------" -ForegroundColor yellow
		$tablaRAM
		
		
		
		#----- EXCEL ------  ENCABEZADO
			
			$escribe.Cells.Item(2,2) = "COMPUTO"
			$escribe.Cells.Item(2,2).Interior.ColorIndex = 16
			$escribe.Cells.Item(2,2).HorizontalAlignment = -4108
			$escribe.Cells.Item(2,2).Font.Bold=$True
			$escribe.Cells.Item(2,2).Font.ColorIndex = 2
			$escribe.Cells.Item(2,2).font.size = 13			
			
			
			$escribe.Cells.Item(3,2) = $cluster.name 
			$escribe.Cells.Item(3,2).Interior.ColorIndex = 16
			$escribe.Cells.Item(3,2).HorizontalAlignment = -4108
			$escribe.Cells.Item(3,2).Font.Bold=$True
			$escribe.Cells.Item(3,2).Font.ColorIndex = 2
			$escribe.Cells.Item(3,2).font.size = 13
			
			$escribe.Cells.Item(3,3) = $cluster.uid.split("=")[1].split("\")[0]
			$escribe.Cells.Item(3,3).Interior.ColorIndex = 16
			$escribe.Cells.Item(3,3).HorizontalAlignment = -4108
			$escribe.Cells.Item(3,3).Font.Bold=$True
			$escribe.Cells.Item(3,3).Font.ColorIndex = 2
			$escribe.Cells.Item(3,3).font.size = 13
			
			$escribe.Cells.Item(3,5) = $datacenter.name
			$escribe.Cells.Item(3,5).Interior.ColorIndex = 16
			$escribe.Cells.Item(3,5).HorizontalAlignment = -4108
			$escribe.Cells.Item(3,5).Font.Bold=$True
			$escribe.Cells.Item(3,5).Font.ColorIndex = 2
			$escribe.Cells.Item(3,5).font.size = 13
			
			$escribe.Cells.Item(6,2) = "vCPU"
			$escribe.Cells.Item(6,2).Interior.ColorIndex = 16
			$escribe.Cells.Item(6,2).HorizontalAlignment = -4108
			$escribe.Cells.Item(6,2).Font.Bold=$True
			$escribe.Cells.Item(6,2).Font.ColorIndex = 2
			$escribe.Cells.Item(6,2).font.size = 13
			
			$escribe.Cells.Item(6,4) = "vRAM"
			$escribe.Cells.Item(6,4).Interior.ColorIndex = 16
			$escribe.Cells.Item(6,4).HorizontalAlignment = -4108
			$escribe.Cells.Item(6,4).Font.Bold=$True
			$escribe.Cells.Item(6,4).Font.ColorIndex = 2
			$escribe.Cells.Item(6,4).font.size = 13
			
			$escribe.Cells.Item(7,2) = "Hosts:"
			$escribe.Cells.Item(7,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(7,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(7,2).Font.Bold=$True
						
			$escribe.Cells.Item(7,3) = $countHost
			$escribe.Cells.Item(7,3).HorizontalAlignment = -4131
			
			$escribe.Cells.Item(7,4) = "Hosts:"
			$escribe.Cells.Item(7,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(7,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(7,4).Font.Bold=$True
			
			$escribe.Cells.Item(7,5) = $countHost
			$escribe.Cells.Item(7,5).HorizontalAlignment = -4131
			
			$escribe.Cells.Item(8,2) = "CPU Total:"
			$escribe.Cells.Item(8,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(8,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(8,2).Font.Bold=$True
			
			$escribe.Cells.Item(8,3) = [math]::round($CPUTotal,2)
			$escribe.Cells.Item(8,3).HorizontalAlignment = -4131
			
			$escribe.Cells.Item(8,4) = "RAM Bruto(GB):"
			$escribe.Cells.Item(8,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(8,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(8,4).Font.Bold=$True
			
			$escribe.Cells.Item(8,5) = [math]::round($MEMFisicoTotal,2)
			$escribe.Cells.Item(8,5).HorizontalAlignment = -4131
			
			$escribe.Cells.Item(9,2) = "Penalizacion Recurso Pretegido HA:"
			$escribe.Cells.Item(9,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(9,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(9,2).Font.Bold=$True
			
			$escribe.Cells.Item(9,3) = [math]::round($CPUPenalizacion,2)
			$escribe.Cells.Item(9,3).HorizontalAlignment = -4131
			
			$escribe.Cells.Item(9,4) = "Penalizacion Overhead:"
			$escribe.Cells.Item(9,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(9,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(9,4).Font.Bold=$True
			
			$escribe.Cells.Item(9,5) = "3%"
			$escribe.Cells.Item(9,5).HorizontalAlignment = -4131
			
			$escribe.Cells.Item(10,2) = "Core Fisico:"
			$escribe.Cells.Item(10,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(10,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(10,2).Font.Bold=$True

			$escribe.Cells.Item(10,3) = [math]::round($CPUcorefisico,2)
			$escribe.Cells.Item(10,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(10,4) = "RAM Overhead(GB):"
			$escribe.Cells.Item(10,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(10,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(10,4).Font.Bold=$True

			$escribe.Cells.Item(10,5) = [math]::round($MEMOverhead,2)
			$escribe.Cells.Item(10,5).HorizontalAlignment = -4131			

			$escribe.Cells.Item(11,2) = "CPU Sobre Comprometer Ratio:"
			$escribe.Cells.Item(11,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(11,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(11,2).Font.Bold=$True

			$escribe.Cells.Item(11,3) = [math]::round($CPURatio,2)
			$escribe.Cells.Item(11,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(11,4) = "Penalizacion HA:"
			$escribe.Cells.Item(11,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(11,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(11,4).Font.Bold=$True

			$escribe.Cells.Item(11,5) = [math]::round($MEMPenalizaHA,2)
			$escribe.Cells.Item(11,5).HorizontalAlignment = -4131			

			$escribe.Cells.Item(12,2) = "Provision vCPU:"
			$escribe.Cells.Item(12,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(12,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(12,2).Font.Bold=$True

			$escribe.Cells.Item(12,3) = [math]::round($VMCPUTotal,2)
			$escribe.Cells.Item(12,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(12,4) = "RAM HA(GB):"
			$escribe.Cells.Item(12,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(12,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(12,4).Font.Bold=$True

			$escribe.Cells.Item(12,5) = [math]::round($MEMHA,2)
			$escribe.Cells.Item(12,5).HorizontalAlignment = -4131	

			$escribe.Cells.Item(13,2) = "Disponibilidad vCPU:"
			$escribe.Cells.Item(13,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(13,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(13,2).Font.Bold=$True

			$escribe.Cells.Item(13,3) = [math]::round($CPUDisponible,2)
			$escribe.Cells.Item(13,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(13,4) = "Total Penalizacion(GB):"
			$escribe.Cells.Item(13,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(13,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(13,4).Font.Bold=$True

			#$escribe.Cells.Item(13,5) = [math]::round($MEMTotal,2)
			$escribe.Cells.Item(13,5) = [math]::round($MEMTotal,2)
			$escribe.Cells.Item(13,5).HorizontalAlignment = -4131	

			$escribe.Cells.Item(14,4) = "Provision vRAM(GB):"
			$escribe.Cells.Item(14,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(14,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(14,4).Font.Bold=$True

			#$escribe.Cells.Item(14,5) = [math]::round($VMMEMTotal,2)
			$escribe.Cells.Item(14,5) = [math]::round($VMMEMTotal,2)
			$escribe.Cells.Item(14,5).HorizontalAlignment = -4131			
			
			$escribe.Cells.Item(15,4) = "Disponible vRAM(GB):"
			$escribe.Cells.Item(15,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(15,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(15,4).Font.Bold=$True

			$escribe.Cells.Item(15,5) = [math]::round($MEMDisponible,2)
			$escribe.Cells.Item(15,5).HorizontalAlignment = -4131
			
			
			
			$escribe.Cells.Item(17,2) = "DISPONIBILIDAD vCPU"
			$escribe.Cells.Item(17,2).Interior.ColorIndex = 16
			$escribe.Cells.Item(17,2).HorizontalAlignment = -4108
			$escribe.Cells.Item(17,2).Font.Bold=$True
			$escribe.Cells.Item(17,2).Font.ColorIndex = 2
			$escribe.Cells.Item(17,2).font.size = 13
			
			$escribe.Cells.Item(18,2) = "Sobre Comprometer Ratio"
			$escribe.Cells.Item(18,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(18,2).Font.Bold=$True

			$escribe.Cells.Item(18,3) = "Provision vCPU"
			$escribe.Cells.Item(18,3).Interior.ColorIndex = 15
			$escribe.Cells.Item(18,3).Font.Bold=$True

						
			$escribe.Cells.Item(18,4) = "Disponibilidad vCPU"
			$escribe.Cells.Item(18,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(18,4).Font.Bold=$True
						
			$escribe.Cells.Item(19,2) = [math]::round($CPURatio,2)
			
			$escribe.Cells.Item(19,2).HorizontalAlignment = -4108

			$escribe.Cells.Item(19,3) = [math]::round($VMCPUTotal,2)
			$escribe.Cells.Item(19,3).HorizontalAlignment = -4108

			if($CPUDisponible -le 0) {$real_color = 3} else {$real_color = 4}
			$escribe.Cells.Item(19,4) = [math]::round($CPUDisponible,2)
			$escribe.Cells.Item(19,4).Interior.ColorIndex = $real_color
			$escribe.Cells.Item(19,4).HorizontalAlignment = -4108
			
						
			$escribe.Cells.Item(21,2) = "DISPONIBILIDAD vRAM"
			$escribe.Cells.Item(21,2).Interior.ColorIndex = 16
			$escribe.Cells.Item(21,2).HorizontalAlignment = -4108
			$escribe.Cells.Item(21,2).Font.Bold=$True
			$escribe.Cells.Item(21,2).Font.ColorIndex = 2
			$escribe.Cells.Item(21,2).font.size = 13
			
			$escribe.Cells.Item(22,2) = "Total Penalizacion(GB) "
			$escribe.Cells.Item(22,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(22,2).Font.Bold=$True

			$escribe.Cells.Item(22,3) = "Provision vRAM(GB)"
			$escribe.Cells.Item(22,3).Interior.ColorIndex = 15
			$escribe.Cells.Item(22,3).Font.Bold=$True

			$escribe.Cells.Item(22,4) = "Disponibilidad vRAM(GB)"
			$escribe.Cells.Item(22,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(22,4).Font.Bold=$True
			
			$escribe.Cells.Item(23,2) = [math]::round($MEMTotal,2)
			$escribe.Cells.Item(23,2).HorizontalAlignment = -4108

			$escribe.Cells.Item(23,3) = [math]::round($VMMEMTotal,2)
			$escribe.Cells.Item(23,3).HorizontalAlignment = -4108

			if($MEMDisponible -le 0) {$real_color = 3} else {$real_color = 4}
			$escribe.Cells.Item(23,4) = [math]::round($MEMDisponible,2)
			$escribe.Cells.Item(23,4).Interior.ColorIndex = $real_color
			$escribe.Cells.Item(23,4).HorizontalAlignment = -4108
			

			
			$MergeCells = $escribe.Range("B2:E2")
			$MergeCells.Select() 
			$MergeCells.MergeCells = $true
			
			$MergeCells = $escribe.Range("C3:D3")
			$MergeCells.Select() 
			$MergeCells.MergeCells = $true
			
			$MergeCells = $escribe.Range("B6:C6")
			$MergeCells.Select() 
			$MergeCells.MergeCells = $true
			
			$MergeCells = $escribe.Range("D6:E6")
			$MergeCells.Select() 
			$MergeCells.MergeCells = $true			
			
			$MergeCells = $escribe.Range("B17:D17")
			$MergeCells.Select() 
			$MergeCells.MergeCells = $true			
						
			$MergeCells = $escribe.Range("B21:D21")
			$MergeCells.Select() 
			$MergeCells.MergeCells = $true			
			
			$objRange = $escribe.UsedRange
			[void] $objRange.EntireColumn.Autofit()	
			
			$selection1 = $escribe.range("B2:E3")
			$selection1.select()
			$selection1.Borders.Item(7).Weight = 2
			$selection1.Borders.Item(8).Weight = 2
			$selection1.Borders.Item(9).Weight = 2
			$selection1.Borders.Item(10).Weight = 2
			$selection1.Borders.Item(11).Weight = 2
			$selection1.Borders.Item(12).Weight = 2
			
			$selection2 = $escribe.range("B6:E13")
			$selection2.select()
			$selection2.Borders.Item(7).Weight = 2
			$selection2.Borders.Item(8).Weight = 2
			$selection2.Borders.Item(9).Weight = 2
			$selection2.Borders.Item(10).Weight = 2
			$selection2.Borders.Item(11).Weight = 2
			$selection2.Borders.Item(12).Weight = 2			
			
			$selection3 = $escribe.range("D14:E15")
			$selection3.select()
			$selection3.Borders.Item(7).Weight = 2
			$selection3.Borders.Item(8).Weight = 2
			$selection3.Borders.Item(9).Weight = 2
			$selection3.Borders.Item(10).Weight = 2
			$selection3.Borders.Item(11).Weight = 2
			$selection3.Borders.Item(12).Weight = 2			
			
			$selection4 = $escribe.range("B17")
			$selection4.select()
			$selection4.Borders.Item(7).Weight = 2
			$selection4.Borders.Item(8).Weight = 2
			$selection4.Borders.Item(9).Weight = 2
			$selection4.Borders.Item(10).Weight = 2
			$selection4.Borders.Item(11).Weight = 2
			$selection4.Borders.Item(12).Weight = 2			
			
			$selection5 = $escribe.range("B18:D19")
			$selection5.select()
			$selection5.Borders.Item(7).Weight = 2
			$selection5.Borders.Item(8).Weight = 2
			$selection5.Borders.Item(9).Weight = 2
			$selection5.Borders.Item(10).Weight = 2
			$selection5.Borders.Item(11).Weight = 2
			$selection5.Borders.Item(12).Weight = 2		
			
			$selection6 = $escribe.range("B21")
			$selection6.select()
			$selection6.Borders.Item(7).Weight = 2
			$selection6.Borders.Item(8).Weight = 2
			$selection6.Borders.Item(9).Weight = 2
			$selection6.Borders.Item(10).Weight = 2
			$selection6.Borders.Item(11).Weight = 2
			$selection6.Borders.Item(12).Weight = 2			
			
			$selection7 = $escribe.range("B22:D23")
			$selection7.select()
			$selection7.Borders.Item(7).Weight = 2
			$selection7.Borders.Item(8).Weight = 2
			$selection7.Borders.Item(9).Weight = 2
			$selection7.Borders.Item(10).Weight = 2
			$selection7.Borders.Item(11).Weight = 2
			$selection7.Borders.Item(12).Weight = 2			
			
			$Excel.ActiveWindow.DisplayGridlines = $false
			
			
			
			$escribe.Cells.Item(7,2).Addcomment("Cantidad de Host (ESX) que componen el cluster")
			$escribe.Cells.Item(7,4).Addcomment("Cantidad de Host (ESX) que componen el cluster")
			$escribe.Cells.Item(8,2).Addcomment("Total de CPUs de todos los Host que componen el cluster")
			$escribe.Cells.Item(8,4).Addcomment("Cantidad de Memoria RAM(GB) de todos los Host que componen el cluster")
			$escribe.Cells.Item(9,2).Addcomment("Penalidad aplicada por Disponibilidad (HA)")
			$escribe.Cells.Item(9,4).Addcomment("Valor de penalidad reservada para manejo interno del cluster")
			$escribe.Cells.Item(10,2).Addcomment("Resultado de CPU total menos penalidad")
			$escribe.Cells.Item(10,4).Addcomment("Valor de Penalidad Overhead expresado en momoria RAM (RAM Bruto * 3%)")
			$escribe.Cells.Item(11,2).Addcomment("Valor de Sobrecompromido aplicable por CPU disponible(Core Fisico * 4)")
			$escribe.Cells.Item(11,4).Addcomment("Valor en porcentaje penalidad de un host menos por HA")
			$escribe.Cells.Item(12,2).Addcomment("Provision de vCPU de todas las maquinas del cluster")
			$escribe.Cells.Item(12,4).Addcomment("Valor penalizacion HA en Memoria RAM")
			$escribe.Cells.Item(13,2).Addcomment("Cantidad de CPUs disponible para provision")
			$escribe.Cells.Item(13,4).Addcomment("Valor total de penalizacion (HA + Overhead)")
			$escribe.Cells.Item(14,4).Addcomment("Provision de RAM en todas las maquinas virtuales")
			$escribe.Cells.Item(15,4).Addcomment("Cantidad de RAM (GB) disponible para provision")
			$escribe.Cells.Item(19,2).Addcomment("Cantidad de CPU habilitado para provision")
			$escribe.Cells.Item(19,3).Addcomment("Cantidad de vCPU provisionado")
			$escribe.Cells.Item(19,4).Addcomment("Cantidad de vCPU disponible para provision")
			$escribe.Cells.Item(23,2).Addcomment("Memoria Habilitada para provision")
			$escribe.Cells.Item(23,3).Addcomment("Cantidad de Memoria provisionada(GB)")
			$escribe.Cells.Item(23,4).Addcomment("Cantidad de Memoria disponible para provision")
			
		<#	
			$selection8 = $escribe.range("C16:E17")
			$selection8.select()
			$selection8.Borders.Item(7).Weight = 2
			$selection8.Borders.Item(8).Weight = 2
			$selection8.Borders.Item(9).Weight = 2
			$selection8.Borders.Item(10).Weight = 2
			$selection8.Borders.Item(11).Weight = 2
			$selection8.Borders.Item(12).Weight = 2		
		
		#>
		
		
		
	}

}
