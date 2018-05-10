function Get-InfoVMS-Datasore{
	$vms = @()
	$valor = read-host "Introduce el nombre del datastore"
	$ds = get-datastore $valor
	foreach ($vm in $ds.extensiondata.vm){
		$result = "" | select Datastore, VM, IP
		$result.Datastore = $ds.name
		$result.VM = get-vm -id $vm
		$result.IP = [string]::Join(",",((get-vmguest (get-vm -id $vm)) | select IPaddress).ipaddress)
		$vms += $result
	}
	$vms
	$vms | export-csv c:\temp\DS_Info_VMs.csv -notypeinformation -delimiter ";"
}