Function Get-CapacidadesVSAN(){
	$clusters = @()
	$vsans = @()
	$result = @()
	$clusters = get-cluster

	#----- EXCEL ------ CREA ARCHIVO EXCEL
	$excel = New-Object -ComObject Excel.Application
	$excel.Visible = $true
	$workbook = $excel.Workbooks.Add()
	$count_vsan = 0
	foreach ($cluster in $clusters){
		$table = "" | select Cliente, Datacenter, Datastore, "DS_Total(TB)", "DS_Usado(TB)","DS_Provisionado(TB)","DS_Libre(TB)", '70% Max_Usado(TB)', 'Penalizacion 30%(TB)', "Penalizacion_Total(TB)","DS_FTT(TB)","RAM_Provision(TB)", "FTT_RAM(TB)", "DS_Total_Provision(TB)", "Total_Disponible(TB)","Total_Disponible_Real(TB)"
		$vms = @()
		$mem_provisionado = @()
		$ds_provisionado = @()
		Clear-variable -Name "vms"
		Clear-variable -Name "mem_provisionado"
		Clear-variable -Name "ds_provisionado"
		$ds_provisionado = 0
		$mem_provisionado = 0
		$vms = $cluster | get-vm
		$datacenter = $cluster | get-datacenter

		foreach($vm in $vms){
			$ds_provisionado += $vm.ProvisionedSpaceGB
			$mem_provisionado += $vm.MemoryGB
		}
		$ds_vsans = $cluster | get-datastore *vsanDatastore*
		foreach($ds_vsan in $ds_vsans){
			$count_vsan++
			#----- EXCEL ------ AGREGA NUEVA HOJA CON NOMBRE DE CLUSTER
			$w = $workbook.Sheets.Add()
			$workbook.ActiveSheet.Name = $datacenter.name
			$escribe = $workbook.ActiveSheet

			$ds_total = $ds_vsan.CapacityGB / 1024
			$ds_provisionado = $ds_provisionado / 1024
			$ds_libre = $ds_vsan.FreeSpaceGB / 1024
			$ds_usado = $ds_total - $ds_libre
			$ds_penaliza = $ds_total * 0.3
			$ds_penaliza_total = $ds_total - $ds_penaliza
			#$ds_ftt = $ds_provisionado * 2
			$ds_ftt = $ds_provisionado
			$ds_ram = $mem_provisionado / 1024
			$ds_ftt_ram = $ds_ram * 2
			$ds_total_provision = $ds_ftt + $ds_ftt_ram
			$ds_total_disponible = $ds_penaliza_total - $ds_usado
			$ds_total_disponible_real = $ds_penaliza_total - $ds_total_provision


			$table.Cliente = $cluster.uid.split("=")[1].split("\")[0]
			$table.Datacenter = $datacenter
			$table.Datastore = $ds_vsan
			$table."DS_Total(TB)" = [math]::Round($ds_total,1)
			$table."DS_Usado(TB)" = [math]::Round($ds_usado,1)
			$table."DS_Provisionado(TB)" = [math]::Round($ds_provisionado,1)
			$table."DS_Libre(TB)" = [math]::Round($ds_libre,1)
			$table.'70% Max_Usado(TB)' = [math]::Round($ds_penaliza_total,1)
			$table.'Penalizacion 30%(TB)' = [math]::Round($ds_penaliza,1)
			$table."Penalizacion_Total(TB)" = [math]::Round($ds_penaliza_total,1)
			$table."DS_FTT(TB)" = [math]::Round($ds_ftt,1)
			$table."RAM_Provision(TB)" = [math]::Round($ds_ram,1)
			$table."FTT_RAM(TB)" = [math]::Round($ds_ftt_ram,1)
			$table."DS_Total_Provision(TB)" = [math]::Round($ds_total_provision,1)
			$table."Total_Disponible(TB)" = [math]::Round($ds_total_disponible,1)
			$table."Total_Disponible_Real(TB)" = [math]::Round($ds_total_disponible_real,1)

			$result += $table

			#----- EXCEL ------  ENCABEZADO

			$escribe.Cells.Item(2,3) = $cluster.name
			$escribe.Cells.Item(2,3).Interior.ColorIndex = 16
			$escribe.Cells.Item(2,3).HorizontalAlignment = -4108
			$escribe.Cells.Item(2,3).Font.Bold=$True
			$escribe.Cells.Item(2,3).Font.ColorIndex = 2
			$escribe.Cells.Item(2,3).font.size = 13

			$escribe.Cells.Item(2,4) = $cluster.uid.split("=")[1].split("\")[0]
			$escribe.Cells.Item(2,4).Interior.ColorIndex = 16
			$escribe.Cells.Item(2,4).HorizontalAlignment = -4108
			$escribe.Cells.Item(2,4).Font.Bold=$True
			$escribe.Cells.Item(2,4).Font.ColorIndex = 2
			$escribe.Cells.Item(2,4).font.size = 13

			$escribe.Cells.Item(2,5) = $datacenter.name
			$escribe.Cells.Item(2,5).Interior.ColorIndex = 16
			$escribe.Cells.Item(2,5).HorizontalAlignment = -4108
			$escribe.Cells.Item(2,5).Font.Bold=$True
			$escribe.Cells.Item(2,5).Font.ColorIndex = 2
			$escribe.Cells.Item(2,5).font.size = 13

			$escribe.Cells.Item(4,4) = $ds_vsan.name
			$escribe.Cells.Item(4,4).Interior.ColorIndex = 16
			$escribe.Cells.Item(4,4).HorizontalAlignment = -4108
			$escribe.Cells.Item(4,4).Font.Bold=$True
			$escribe.Cells.Item(4,4).Font.ColorIndex = 2
			$escribe.Cells.Item(4,4).font.size = 13

			$escribe.Cells.Item(6,2) = "CAPACIDADES"
			$escribe.Cells.Item(6,2).Interior.ColorIndex = 16
			$escribe.Cells.Item(6,2).HorizontalAlignment = -4108
			$escribe.Cells.Item(6,2).Font.Bold=$True
			$escribe.Cells.Item(6,2).Font.ColorIndex = 2
			$escribe.Cells.Item(6,2).font.size = 13

			$escribe.Cells.Item(6,3) = ""
			$escribe.Cells.Item(6,3).Interior.ColorIndex = 16

			$escribe.Cells.Item(6,4) = "PENALIZACION"
			$escribe.Cells.Item(6,4).Interior.ColorIndex = 16
			$escribe.Cells.Item(6,4).HorizontalAlignment = -4108
			$escribe.Cells.Item(6,4).Font.Bold=$True
			$escribe.Cells.Item(6,4).Font.ColorIndex = 2
			$escribe.Cells.Item(6,4).font.size = 13

			$escribe.Cells.Item(6,5) = ""
			$escribe.Cells.Item(6,5).Interior.ColorIndex = 16

			$escribe.Cells.Item(6,6) = "PROVISION"
			$escribe.Cells.Item(6,6).Interior.ColorIndex = 16
			$escribe.Cells.Item(6,6).HorizontalAlignment = -4108
			$escribe.Cells.Item(6,6).Font.Bold=$True
			$escribe.Cells.Item(6,6).Font.ColorIndex = 2
			$escribe.Cells.Item(6,6).font.size = 13

			$escribe.Cells.Item(6,7) = ""
			$escribe.Cells.Item(6,7).Interior.ColorIndex = 16

			$escribe.Cells.Item(7,2) = "Capacidad Total(TB):"
			$escribe.Cells.Item(7,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(7,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(7,2).Font.Bold=$True


			$escribe.Cells.Item(7,3) = [math]::Round($ds_total,1)
			$escribe.Cells.Item(7,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(7,4) = "30% Penalizacion(TB):"
			$escribe.Cells.Item(7,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(7,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(7,4).Font.Bold=$True

			$escribe.Cells.Item(7,5) = [math]::Round($ds_penaliza,1)
			$escribe.Cells.Item(7,5).HorizontalAlignment = -4131

			$escribe.Cells.Item(7,6) = "FTT Provisionado(TB):"
			$escribe.Cells.Item(7,6).Interior.ColorIndex = 15
			$escribe.Cells.Item(7,6).HorizontalAlignment = -4152
			$escribe.Cells.Item(7,6).Font.Bold=$True

			$escribe.Cells.Item(7,7) = [math]::Round($ds_ftt,1)
			$escribe.Cells.Item(7,7).HorizontalAlignment = -4131

			$escribe.Cells.Item(8,2) = "Espacio Usado(TB):"
			$escribe.Cells.Item(8,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(8,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(8,2).Font.Bold=$True

			$escribe.Cells.Item(8,3) = [math]::Round($ds_usado,1)
			$escribe.Cells.Item(8,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(8,4) = "70% max Usado(TB):"
			$escribe.Cells.Item(8,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(8,4).HorizontalAlignment = -4152
			$escribe.Cells.Item(8,4).Font.Bold=$True

			$escribe.Cells.Item(8,5) = [math]::Round($ds_penaliza_total,1)
			$escribe.Cells.Item(8,5).HorizontalAlignment = -4131

			$escribe.Cells.Item(8,6) = "RAM Provisionado(TB):"
			$escribe.Cells.Item(8,6).Interior.ColorIndex = 15
			$escribe.Cells.Item(8,6).HorizontalAlignment = -4152
			$escribe.Cells.Item(8,6).Font.Bold=$True


			$escribe.Cells.Item(8,7) = [math]::Round($ds_ram,1)
			$escribe.Cells.Item(8,7).HorizontalAlignment = -4131

			$escribe.Cells.Item(9,2) = "Espacio Libre(TB):"
			$escribe.Cells.Item(9,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(9,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(9,2).Font.Bold=$True

			$escribe.Cells.Item(9,3) = [math]::Round($ds_libre,1)
			$escribe.Cells.Item(9,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(9,6) = "FTT RAM(TB):"
			$escribe.Cells.Item(9,6).Interior.ColorIndex = 15
			$escribe.Cells.Item(9,6).HorizontalAlignment = -4152
			$escribe.Cells.Item(9,6).Font.Bold=$True

			$escribe.Cells.Item(9,7) = [math]::Round($ds_ftt_ram,1)
			$escribe.Cells.Item(9,7).HorizontalAlignment = -4131
			$escribe.Cells.Item(10,2) = "Espacio Provisionado(TB):"
			$escribe.Cells.Item(10,2).Interior.ColorIndex = 15
			$escribe.Cells.Item(10,2).HorizontalAlignment = -4152
			$escribe.Cells.Item(10,2).Font.Bold=$True

			$escribe.Cells.Item(10,3) = [math]::Round($ds_provisionado,1)
			$escribe.Cells.Item(10,3).HorizontalAlignment = -4131

			$escribe.Cells.Item(10,6) = "PROVISION TOTAL(TB):"
			$escribe.Cells.Item(10,6).Interior.ColorIndex = 15
			$escribe.Cells.Item(10,6).HorizontalAlignment = -4152
			$escribe.Cells.Item(10,6).Font.Bold=$True

			$escribe.Cells.Item(10,7) = [math]::Round($ds_total_provision,1)
			$escribe.Cells.Item(10,7).HorizontalAlignment = -4131

			$escribe.Cells.Item(12,4) = "DISPONIBILIDAD"
			$escribe.Cells.Item(12,4).Interior.ColorIndex = 16
			$escribe.Cells.Item(12,4).HorizontalAlignment = -4108
			$escribe.Cells.Item(12,4).Font.Bold=$True
			$escribe.Cells.Item(12,4).Font.ColorIndex = 2
			$escribe.Cells.Item(12,4).font.size = 13

			$escribe.Cells.Item(13,3) = "70% Max Usado(TB)"
			$escribe.Cells.Item(13,3).Interior.ColorIndex = 15
			$escribe.Cells.Item(13,3).Font.Bold=$True

			$escribe.Cells.Item(13,4) = "Disco Usado(TB)"
			$escribe.Cells.Item(13,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(13,4).Font.Bold=$True

			$escribe.Cells.Item(13,5) = "Disponible(TB)"
			$escribe.Cells.Item(13,5).Interior.ColorIndex = 15
			$escribe.Cells.Item(13,5).Font.Bold=$True

			$escribe.Cells.Item(14,3) = [math]::Round($ds_penaliza_total,1)
			$escribe.Cells.Item(14,3).HorizontalAlignment = -4108

			$escribe.Cells.Item(14,4) = [math]::Round($ds_usado,1)
			$escribe.Cells.Item(14,4).HorizontalAlignment = -4108
			if($ds_total_disponible -le 0) {$color = 3} else {$color = 4}
			$escribe.Cells.Item(14,5) = [math]::Round($ds_total_disponible,1)
			$escribe.Cells.Item(14,5).Interior.ColorIndex = $color
			$escribe.Cells.Item(14,5).HorizontalAlignment = -4108

			$escribe.Cells.Item(16,3) = "70% Max Usado(TB)"
			$escribe.Cells.Item(16,3).Interior.ColorIndex = 15
			$escribe.Cells.Item(16,3).Font.Bold=$True

			$escribe.Cells.Item(16,4) = "Disco Provisionado(TB)"
			$escribe.Cells.Item(16,4).Interior.ColorIndex = 15
			$escribe.Cells.Item(16,4).Font.Bold=$True

			$escribe.Cells.Item(16,5) = "Disponible(TB)"
			$escribe.Cells.Item(16,5).Interior.ColorIndex = 15
			$escribe.Cells.Item(16,5).Font.Bold=$True

			$escribe.Cells.Item(17,3) = [math]::Round($ds_penaliza_total,1)
			$escribe.Cells.Item(17,3).HorizontalAlignment = -4108
			$escribe.Cells.Item(17,4) = [math]::Round($ds_total_provision,1)
			$escribe.Cells.Item(17,4).HorizontalAlignment = -4108
			$escribe.Cells.Item(17,5) = [math]::Round($ds_total_disponible_real,1)
			if($ds_total_disponible_real -le 0) {$real_color = 3} else {$real_color = 4}
			$escribe.Cells.Item(17,5).Interior.ColorIndex = $real_color
			$escribe.Cells.Item(17,5).HorizontalAlignment = -4108

			$escribe.columns.item("G").columnWidth = 150

			$MergeCells = $escribe.Range("F6:G6")
			$MergeCells.Select()
			$MergeCells.MergeCells = $true

			$MergeCells = $escribe.Range("D6:E6")
			$MergeCells.Select()
			$MergeCells.MergeCells = $true

			$MergeCells = $escribe.Range("B6:C6")
			$MergeCells.Select()
		    $MergeCells.MergeCells = $true

			$objRange = $escribe.UsedRange
			[void] $objRange.EntireColumn.Autofit()

			$selection1 = $escribe.range("C2:E2")
			$selection1.select()
			$selection1.Borders.Item(7).Weight = 2
			$selection1.Borders.Item(8).Weight = 2
			$selection1.Borders.Item(9).Weight = 2
			$selection1.Borders.Item(10).Weight = 2
			$selection1.Borders.Item(11).Weight = 2
			$selection1.Borders.Item(12).Weight = 2

			$selection2 = $escribe.range("D4")
			$selection2.select()
			$selection2.Borders.Item(7).Weight = 2
			$selection2.Borders.Item(8).Weight = 2
			$selection2.Borders.Item(9).Weight = 2
			$selection2.Borders.Item(10).Weight = 2
			$selection2.Borders.Item(11).Weight = 2
			$selection2.Borders.Item(12).Weight = 2

			$selection3 = $escribe.range("B6:G8")
			$selection3.select()
			$selection3.Borders.Item(7).Weight = 2
			$selection3.Borders.Item(8).Weight = 2
			$selection3.Borders.Item(9).Weight = 2
			$selection3.Borders.Item(10).Weight = 2
			$selection3.Borders.Item(11).Weight = 2
			$selection3.Borders.Item(12).Weight = 2

			$selection4 = $escribe.range("B9:C10")
			$selection4.select()
			$selection4.Borders.Item(7).Weight = 2
			$selection4.Borders.Item(8).Weight = 2
			$selection4.Borders.Item(9).Weight = 2
			$selection4.Borders.Item(10).Weight = 2
			$selection4.Borders.Item(11).Weight = 2
			$selection4.Borders.Item(12).Weight = 2

			$selection5 = $escribe.range("F9:G10")
			$selection5.select()
			$selection5.Borders.Item(7).Weight = 2
			$selection5.Borders.Item(8).Weight = 2
			$selection5.Borders.Item(9).Weight = 2
			$selection5.Borders.Item(10).Weight = 2
			$selection5.Borders.Item(11).Weight = 2
			$selection5.Borders.Item(12).Weight = 2

			$selection6 = $escribe.range("D12")
			$selection6.select()
			$selection6.Borders.Item(7).Weight = 2
			$selection6.Borders.Item(8).Weight = 2
			$selection6.Borders.Item(9).Weight = 2
			$selection6.Borders.Item(10).Weight = 2
			$selection6.Borders.Item(11).Weight = 2
			$selection6.Borders.Item(12).Weight = 2

			$selection7 = $escribe.range("C13:E14")
			$selection7.select()
			$selection7.Borders.Item(7).Weight = 2
			$selection7.Borders.Item(8).Weight = 2
			$selection7.Borders.Item(9).Weight = 2
			$selection7.Borders.Item(10).Weight = 2
			$selection7.Borders.Item(11).Weight = 2
			$selection7.Borders.Item(12).Weight = 2

			$selection8 = $escribe.range("C16:E17")
			$selection8.select()
			$selection8.Borders.Item(7).Weight = 2
			$selection8.Borders.Item(8).Weight = 2
			$selection8.Borders.Item(9).Weight = 2
			$selection8.Borders.Item(10).Weight = 2
			$selection8.Borders.Item(11).Weight = 2
			$selection8.Borders.Item(12).Weight = 2

			$Excel.ActiveWindow.DisplayGridlines = $false

		}
	}
	$Workbook.worksheets.item($count_vsan + 1).Delete()
	$result

}
