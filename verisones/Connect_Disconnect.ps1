###CONECTA CON EL O LOS VCENTER SEGÚN SE ESPECIFIQUE CON EL PARAMETRO ENVIADO (SI ES VACIO SE CONECTA CON TODOS LOS VCENTER REGISTRADOS EN EL CREDENTIALSTOREITEM)
function cnnt ($vcenter) {
	
	if (!$vcenter){
		$store = Get-VICredentialStoreItem
		foreach ($server in $store)
		{
			Connect-VIServer -Server $server.host -User $server.User
		}
	}
	elseif($vcenter -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
		
		$user = Get-VICredentialStoreItem | Where-Object {$_.Host -eq $vcenter}
		Connect-VIServer -Server $vcenter -User $user.User
	}
	else{
		
		$inv = Import-Csv \\192.168.27.17\admin_vmware\Inventario\Inventario_PCLI.csv -Delimiter ";"
		$servers = $inv | Where-Object {$_.cliente -like "*$vcenter*" -or $_.NOMBRE_DISPOSITIVO -like "*$vcenter*" -or $_.IP -like "*$vcenter*"}
		
		$storeItem = Get-VICredentialStoreItem
		
		foreach($connect in $servers){
			$UserConnection = $storeItem | where-object {$_.Host -eq $connect.IP}
			Connect-VIServer -Server $connect.IP -User $UserConnection.User
		}
	}
}

###DESCONECTA CON EL O LOS VCENTER SEGÚN SE ESPECIFIQUE CON EL PARAMETRO ENVIADO (SI ES VACIO SE DESCONECTA DE TODAS LAS CONEXIONES REALIZADAS)
function dcnnt($dvcenter) {

	if (!$dvcenter){
	Disconnect-VIServer -Server * -Confirm:$false
	write-host "Se desconectaron todos los vCenter exitosamente"
	}
	elseif($dvcenter -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
		Disconnect-VIServer -Server $dvcenter -Confirm:$false
		write-host "Desconexión $dvcenter realizada con éxito"
	}
	else{
		$inv = Import-Csv \\192.168.27.17\admin_vmware\Inventario\Inventario_PCLI.csv -Delimiter ";"
		$servers = $inv | Where-Object {$_.cliente -like "*$dvcenter*" -or $_.NOMBRE_DISPOSITIVO -like "*$dvcenter*" -or $_.IP -like "*$dvcenter*"}
		
		foreach($disconnect in $servers){
			Disconnect-VIServer -Server $disconnect.IP -Confirm:$false
			write-host "Desconexión $disconnect.IP realizada con éxito"
		}
	}
}
