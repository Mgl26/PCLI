
	#Detalle: Funcion que evalua los posibles Datastore a eliminar, busca todos los datastore que no tienen VMs asociadas.
	#Detalle Ejemplo: Get-DatastoreForDelete

Function Get-DatastoreForDelete{
	write-host "Se muestran los datastore que no tienen vms registrada, adicional se debe validar que no tengan discos activos"
	Get-Datastore | %{$ds = $_;$_} | Where-Object {!$_.extensiondata.vm} | Where-Object {$_.name -notlike "*ESX*"}| Select-Object name, CapacityGB, FreeSpaceGB, Datacenter, @{N="Naa";E={$_.extensiondata.info.vmfs.extent.diskname}}, @{N="LUNID";E={($_ | get-vmhost | Get-EsxCli | Select-Object -First 1).storage.core.path.list() | Where-Object {$_.device -eq $ds.extensiondata.info.vmfs.extent.diskname} | Select-Object -First 1 @{N="LUNID";E={($_.runtimename).split(':')[3]} } }} | ft -AutoSize
}	