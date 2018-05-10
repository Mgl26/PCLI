Function Inv ($cliente){

	$ruta = "\\192.168.27.17\admin_vmware\Inventario\Inventario_PCLI.csv"
	#$ruta = "D:\Documentos\Respaldo_pivote\Admin_VMWare\Inventario\Inventario_PCLI.csv"

	$inv = Import-Csv $ruta -Delimiter ";"

	$storeItem = Get-VICredentialStoreItem
	
	$ErrorActionPreference = "SilentlyContinue"

	foreach($reg in $storeItem){
		#$Usr = $reg.User
		#$Hts = $reg.Host
		#$tem = $inv | Where-Object {$_.IP -eq $Hts}
		$tem = $inv | Where-Object {$_.IP -eq $reg.Host}
		$tem.VICredentials = $reg.User
	}

	$result = $inv | Where-Object {$_.cliente -like "*$cliente*" -or $_.NOMBRE_DISPOSITIVO -like "*$cliente*" -or $_.IP -like "*$cliente*"}
	
	if(!$result){
		Write-host "No se encontraron resultados" -ForegroundColor red
	}else{
		foreach($res in $result){$res}
	}
	
	
}
