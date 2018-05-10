###CONECTA CON EL O LOS VCENTER SEGÚN SE ESPECIFIQUE CON EL PARAMETRO ENVIADO (SI ES VACIO SE CONECTA CON TODOS LOS VCENTER REGISTRADOS EN EL CREDENTIALSTOREITEM)
function cnnt ($vcenter) {

	#Detalle: Funcion que facilita la conexion hacia los vcenter, realiza conexion dependiendo del resultado de la funcion "inv"
	#Detalle Ejemplo1: "cnnt Heroes" realiza conexion a todos los vCenter del resultado inv Heroes
	#Detalle Ejemplo2: "cnnt 10.89.0.38" realiza conexion al vCenter con direccion IP
	#Detalle Ejemplo3: "cnnt correo" realiza conexion a todos los vCenter del resultado inv Correo
	
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
