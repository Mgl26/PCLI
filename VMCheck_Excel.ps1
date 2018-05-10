function Get-VMCheck-excel {
    $vmss = @()
    $result = @()
    $fecha = get-date -Format D
    $cant_server = 0
    $count_sheet = 1

    do {
     $input = (Read-Host "Ingresa el nombre de la VM")
     if ($input -ne '') {$vmss += $input;$cant_server++}
    }
    until ($input -eq '')
    write-host "cantidad de servidores: $cant_server"
   
    #Se crea el documento excel
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true
    $workbook = $excel.Workbooks.Add()
    $workbook.ActiveSheet.Name = "Resultado_Total"

    $vms = get-vm $vmss | where-object {$_.PowerState -eq "PoweredOn"}
    foreach ($vm in $vms){
        $count_sheet++
        write-host $count_sheet
        $salida = "" | select VM, PowerState, DataCenter, IPAddress, SCSI, VMTolls, OSGuest, Nics, NicsConnect, ESXVersion, vHW, HardDisk, GuestDisk, HotPlug_Mem, HotPlug_CPU, Mem_GB, Reserv_Mem, Num_CPU, Reserv_CPU, Check_Time_Sync_check, Check_Time_Sync_general
        $salida.VM = $vm.name
        $salida.PowerState = $vm.PowerState
        $salida.DataCenter = Get-datacenter -VM $vm
        $salida.IPAddress = (@($vm | Get-VMGuest).ipaddress -join ',')
        $salida.SCSI = (@($vm | Get-ScsiController).type -join ',')
        $salida.VMTolls = $vm.extensiondata.guest.toolsstatus
        $salida.OSGuest = ($vm).extensiondata.summary.config.guestfullname
        $salida.Nics = (@(Get-NetworkAdapter -VM $vm).type -join ',')
        $salida.NicsConnect = (@(Get-NetworkAdapter -VM $vm).WakeOnLanEnabled -join ',')
        $salida.ESXVersion = ($vm | get-vmhost).extensiondata.config.product.version
        $salida.vHW = ($vm).extensiondata.config.version
        $salida.HardDisk = (Get-HardDisk -VM $vm).count
        $salida.GuestDisk = ($vm.Extensiondata.Guest.Disk.DiskPath).count
        $salida.HotPlug_Mem = ($vm).extensiondata.Config.MemoryHotAddEnabled
        $salida.HotPlug_CPU = ($vm).extensiondata.Config.CpuHotAddEnabled
        $salida.Num_CPU = ($vm).extensiondata.config.hardware.NumCPU
        $salida.Reserv_CPU = ($vm).extensiondata.ResourceConfig.CpuAllocation.Reservation
        $salida.Mem_GB = ($vm | select MemoryGB).MemoryGB
        $salida.Reserv_Mem = ($vm).extensiondata.ResourceConfig.MemoryAllocation.Reservation
        $salida.Check_Time_Sync_check = ($vm).extensiondata.config.Tools.SyncTimeWithHost
        $salida.Check_Time_Sync_general = (@(($vm).extensiondata.config.extraconfig | Where-Object {$_.key -like "time*"} | select value).value -join ',')
       
        #Almacena los valores en variable para ser mostrados
        $result += $salida
       
        #Validaciones
       
        #Valida la controladora de la tarjeta SCSI
        $resp_scsi = "OK"
        $color_scsi = 4
        if (($vm).extensiondata.summary.config.guestfullname -like "*Windows*" ){
            foreach ($controller in ($vm | Get-ScsiController).type){
				write-host "este es el valor $controller"
                if ($controller -ne "VirtualLsiLogicSAS" ){
					write-host "entre al condicional"
                    $resp_scsi = "NO OKdfa"
                    $color_scsi = 3
                    break
                }
            }
        }
        else{
            foreach ($controller in ($vm | Get-ScsiController).type){
                if ($controller -ne "VirtualLsiLogic" -And $controller -ne "ParaVirtual"){
                    $resp_scsi = "NO OK"
                    $color_scsi = 3
                    break
                }
            }
        }
       
        #Valida que las tarjetas de red esten conectadas
        $res_nic_connec = "OK"
        $color_nic = 4
        foreach($nic_connected in (Get-NetworkAdapter -VM $vm).WakeOnLanEnabled){
            if($nic_connected -ne "True"){
                $res_nic_connec = "NO OK"
                $color_nic = 3
                break
            }
        }
       
        #Valida el tipo de tarjeta de red
        $res_nic_tipo = "OK"
        $color_nic_tipo = 4
        foreach($nic_tipo in (Get-NetworkAdapter -VM $vm).type){
            if($nic_tipo -ne "Vmxnet3"){
                $res_nic_tipo = "NO OK"
                $color_nic_tipo = 3
                break
            }
        }
       
       
        #Valida que los discos virtuales corresponda con la cantidad de discos fisicos
        $resp_disk = "OK"
        $color_disk = 4
        if((Get-HardDisk -VM $vm).count -ne ($vm.Extensiondata.Guest.Disk.DiskPath).count){
            $resp_disk = "NO OK"
            $color_disk = 3
        }
       
        #Valida que los VMtools estén OK
        $resp_vmtools = "OK"
        $color_vmtools = 4
        if ($vm.extensiondata.guest.toolsstatus -ne "toolsOk"){
            $resp_vmtools = "NO OK"
            $color_vmtools = 3
        }
       
        #Valida Hardware VirtualLsiLogic
        $resp_vhw = "OK"
        $color_vhw = 4
        if($salida.ESXVersion -like "3.5*"){
            if($salida.vHW -ne "vmx-04"){
                $resp_vhw = "NO OK"
                $color_vhw = 3
            }
        }
        if($salida.ESXVersion -like "4*"){
            if($salida.vHW -ne "vmx-07"){
                $resp_vhw = "NO OK"
                $color_vhw = 3
            }
        }
        if($salida.ESXVersion -like "5.0*"){
            if($salida.vHW -ne "vmx-08"){
                $resp_vhw = "NO OK"
                $color_vhw = 3
            }
        }
        if($salida.ESXVersion -like "5.1*"){
            if($salida.vHW -ne "vmx-09"){
                $resp_vhw = "NO OK"
                $color_vhw = 3
            }
        }
        if($salida.ESXVersion -like "5.5*"){
            if($salida.vHW -ne "vmx-10"){
                $resp_vhw = "NO OK"
                $color_vhw = 3
            }
        }
        if($salida.ESXVersion -like "6.0*"){
            if($salida.vHW -ne "vmx-11"){
                $resp_vhw = "NO OK"
                $color_vhw = 3
            }
        }
        if($salida.ESXVersion -like "6.5*"){
            if($salida.vHW -ne "vmx-13"){
                $resp_vhw = "NO OK"
                $color_vhw = 3
            }
        }
       
        #Valida que esté habilitado el HotPlug de memoria y CpuAllocation
        $resp_hotplug = "OK"
        $color_hotplug = 4
        if ($salida.HotPlug_Mem -ne "True" -Or $salida.HotPlug_CPU -ne "True"){
            $resp_hotplug = "NO OK"
            $color_hotplug = 3
        }
       
        #Valida que no exista reserva de memoria
        $resp_resev_mem = "OK"
        $color_mem = 4
        if($salida.Reserv_Mem -ne 0){
            $resp_resev_mem = "NO OK"
            $color_mem = 3
        }
       
        #Valida que no exista reserva de CPU
        $resp_resev_CPU = "OK"
        $color_cpu = 4
        if($salida.Reserv_CPU -ne 0){
            $resp_resev_CPU = "NO OK"
            $color_cpu = 3
        }
       
        #Valida el CheckTime
        $resp_checktime = "OK"
        $color_time = 4
        foreach($check in (($vm).extensiondata.config.extraconfig | Where-Object {$_.key -like "time*"}).value){
            if($check -ne 0 -And $check -ne "false"){
                $resp_checktime = "NO OK"
                $color_time = 3
                break
            }
        }
        if(($vm).extensiondata.config.Tools.SyncTimeWithHost -ne 0){
            $resp_checktime = "NO OK"
            $color_time = 3
        }
       
        #Crea la hoja con el nombre del servidor evaluado
        $w = $workbook.Sheets.Add()
        $workbook.ActiveSheet.Name = $vm.Name
       
        #$escribe = $workbook.Worksheets.Item($count_sheet)
        $escribe = $workbook.ActiveSheet
       
        $escribe.Cells.Item(2,3) = "Nombre VM"
        $escribe.Cells.Item(2,3).Interior.ColorIndex =48
        $escribe.Cells.Item(2,3).Font.Size = 12
        $escribe.Cells.Item(2,3).Font.Bold=$True
        $escribe.Cells.Item(2,4) = $vm.Name
       
        $escribe.Cells.Item(3,3) = "IP"
        $escribe.Cells.Item(3,3).Interior.ColorIndex =48
        $escribe.Cells.Item(3,3).Font.Size = 12
        $escribe.Cells.Item(3,3).Font.Bold=$True
        $escribe.Cells.Item(3,4) = $salida.IPAddress
       
        $escribe.Cells.Item(4,3) = "Fecha"
        $escribe.Cells.Item(4,3).Interior.ColorIndex =48
        $escribe.Cells.Item(4,3).Font.Size = 12
        $escribe.Cells.Item(4,3).Font.Bold=$True
        $escribe.Cells.Item(4,4) = $fecha
       
        $escribe.Cells.Item(7,3) = "Revision"
        $escribe.Cells.Item(7,3).Font.Size = 12
        $escribe.Cells.Item(7,3).Font.Bold=$True
        $escribe.Cells.Item(7,3).Interior.ColorIndex =48
        $escribe.Cells.Item(7,4) = "OK / NO OK"
        $escribe.Cells.Item(7,4).Font.Size = 12
        $escribe.Cells.Item(7,4).Font.Bold=$True
        $escribe.Cells.Item(7,4).Interior.ColorIndex =48
        $escribe.Cells.Item(7,5) = "Observaciones"
        $escribe.Cells.Item(7,5).Font.Size = 12
        $escribe.Cells.Item(7,5).Font.Bold=$True
        $escribe.Cells.Item(7,5).Interior.ColorIndex =48
       
        $escribe.Cells.Item(8,3) = "Guest OS vs Config Guest"
        $escribe.Cells.Item(8,3).Font.Size = 12
        $escribe.Cells.Item(8,3).Font.Bold=$True
        $escribe.Cells.Item(8,4) = "OK (Validar)"
        $escribe.Cells.Item(8,4).Interior.ColorIndex =6
        $escribe.Cells.Item(8,5) = "Revisar que la VM corresponde al SO Descrito" + $salida.OSGuest
       
        $escribe.Cells.Item(9,3) = "Controladora SCSI soportada"
        $escribe.Cells.Item(9,3).Font.Size = 12
        $escribe.Cells.Item(9,3).Font.Bold=$True
        $escribe.Cells.Item(9,4) = $resp_scsi
        $escribe.Cells.Item(9,4).Interior.ColorIndex = $color_scsi
        $escribe.Cells.Item(9,5) = $salida.SCSI
       
        $escribe.Cells.Item(10,3) = "Conexion de tarjetas de red"
        $escribe.Cells.Item(10,3).Font.Size = 12
        $escribe.Cells.Item(10,3).Font.Bold=$True
        $escribe.Cells.Item(10,4) = $res_nic_connec
        $escribe.Cells.Item(10,4).Interior.ColorIndex = $color_nic
        $escribe.Cells.Item(10,5) = $salida.NicsConnect
       
        $escribe.Cells.Item(11,3) = "Tarjeta tipo VMXNET3"
        $escribe.Cells.Item(11,3).Font.Size = 12
        $escribe.Cells.Item(11,3).Font.Bold=$True
        $escribe.Cells.Item(11,4) = $res_nic_tipo
        $escribe.Cells.Item(11,4).Interior.ColorIndex = $color_nic_tipo
        $escribe.Cells.Item(11,5) = $salida.Nics
       
        $escribe.Cells.Item(12,3) = "Particiones vs Discos virtuales"
        $escribe.Cells.Item(12,3).Font.Size = 12
        $escribe.Cells.Item(12,3).Font.Bold=$True
        $escribe.Cells.Item(12,4) = $resp_disk
        $escribe.Cells.Item(12,4).Interior.ColorIndex = $color_disk
        $escribe.Cells.Item(12,5) = " Guest " + $salida.GuestDisk + " discos vs Hard " + $salida.HardDisk + " discos"
       
        $escribe.Cells.Item(13,3) = "Estado Vmtools"
        $escribe.Cells.Item(13,3).Font.Size = 12
        $escribe.Cells.Item(13,3).Font.Bold=$True
        $escribe.Cells.Item(13,4) = $resp_vmtools
        $escribe.Cells.Item(13,4).Interior.ColorIndex = $color_vmtools
        $escribe.Cells.Item(13,5) = $vm.extensiondata.guest.toolsstatus
       
        $escribe.Cells.Item(14,3) = "Version de hardware virtual"
        $escribe.Cells.Item(14,3).Font.Size = 12
        $escribe.Cells.Item(14,3).Font.Bold=$True
        $escribe.Cells.Item(14,4) = $resp_vhw
        $escribe.Cells.Item(14,4).Interior.ColorIndex = $color_vhw
        $escribe.Cells.Item(14,5) = "Version Hardware " + $salida.vHW + " vs Version ESXi " + $salida.ESXVersion
       
        $escribe.Cells.Item(15,3) = "Estado Hot/Plug CPU/MEM"
        $escribe.Cells.Item(15,3).Font.Size = 12
        $escribe.Cells.Item(15,3).Font.Bold=$True
        $escribe.Cells.Item(15,4) = $resp_hotplug
        $escribe.Cells.Item(15,4).Interior.ColorIndex = $color_hotplug
        $escribe.Cells.Item(15,5) = "Hot/Plug Mem " + $salida.HotPlug_Mem + " Hot/Plug CPU " + $salida.HotPlug_CPU
       
        $escribe.Cells.Item(16,3) = "Reserva Memoria"
        $escribe.Cells.Item(16,3).Font.Size = 12
        $escribe.Cells.Item(16,3).Font.Bold=$True
        $escribe.Cells.Item(16,4) = $resp_resev_mem
        $escribe.Cells.Item(16,4).Interior.ColorIndex = $color_mem
        $escribe.Cells.Item(16,5) = $salida.Reserv_Mem
       
        $escribe.Cells.Item(17,3) = "Reserva Hz CPU"
        $escribe.Cells.Item(17,3).Font.Size = 12
        $escribe.Cells.Item(17,3).Font.Bold=$True
        $escribe.Cells.Item(17,4) = $resp_resev_CPU
        $escribe.Cells.Item(17,4).Interior.ColorIndex = $color_cpu
        $escribe.Cells.Item(17,5) = $salida.Reserv_CPU
       
        $escribe.Cells.Item(18,3) = "Check Time"
        $escribe.Cells.Item(18,3).Font.Size = 12
        $escribe.Cells.Item(18,3).Font.Bold=$True
        $escribe.Cells.Item(18,4) = $resp_checktime
        $escribe.Cells.Item(18,4).Interior.ColorIndex = $color_time
        $escribe.Cells.Item(18,5) = "check " + $salida.Check_Time_Sync_check + "vmx " + $salida.Check_Time_Sync_general
       
        #COLOCA LOS BORDES DE TABLA
        $selection = $escribe.range("C2:D4")
        $selection.select()
           
        $selection.Borders.Item(7).Weight = 2
        $selection.Borders.Item(8).Weight = 2
        $selection.Borders.Item(9).Weight = 2
        $selection.Borders.Item(10).Weight = 2
        $selection.Borders.Item(11).Weight = 2
        $selection.Borders.Item(12).Weight = 2
       
        $selection = $escribe.range("C7:E18")
        $selection.select()
       
        $selection.Borders.Item(7).Weight = 2
        $selection.Borders.Item(8).Weight = 2
        $selection.Borders.Item(9).Weight = 2
        $selection.Borders.Item(10).Weight = 2
        $selection.Borders.Item(11).Weight = 2
        $selection.Borders.Item(12).Weight = 2
       
        $objRange = $escribe.UsedRange
        [void] $objRange.EntireColumn.Autofit()
    }

    $Workbook.worksheets.item($cant_server + 1).Delete()
    $result
    $result | Export-Csv -Path "c:\temp\vmcheck_$fecha.csv" -notype
}