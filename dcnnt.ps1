###DESCONECTA CON EL O LOS VCENTER SEGÚN SE ESPECIFIQUE CON EL PARAMETRO ENVIADO (SI ES VACIO SE DESCONECTA DE TODAS LAS CONEXIONES REALIZADAS)
function dcnnt($dvcenter) {

	#Detalle: Funcion que facilita la desconexion de los vcenter, realiza desconexion dependiendo del resultado de la funcion "inv"
	#Detalle Ejemplo1: "dcnnt Heroes" realiza desconexion de todos los vCenter del resultado inv Heroes
	#Detalle Ejemplo2: "dcnnt 10.89.0.38" realiza desconexion al vCenter con direccion IP
	#Detalle Ejemplo3: "dcnnt correo" realiza desconexion a todos los vCenter del resultado inv Correo

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