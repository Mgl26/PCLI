C:\Produccion\Reportes\Acceso\vCenters_conexion.ps1
$vms = get-vm
$fin = @()
$fecha = get-date -Format D
$titulo = 'Revision Diaria Control de Cambios VMs'
ForEach ($vm in $vms){
    $report = "" | Select-Object VMNombre, Inicio, Fin, Estado,  Dispositivo
    $temp = Get-VMConfigChanges -vm $vm -hours 8

    $report.VMNombre = $temp.VMName
    $report.Inicio = $temp.Start
    $report.Fin = $temp.End
    $report.Estado = $temp.State
    $report.Dispositivo = $temp.Device

    $fin += $report
}

ExportHTML $fin $titulo "C:\Produccion\temp\Out_Revision_Control_Cambios.htm" $fecha

Disconnect-VIServer -Server *