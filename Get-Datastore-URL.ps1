
	<#	
	Detalle: Funcion que realiza busqueda de los Datastore a partir de URL
	Detalle Ejemplo: Get-Datastore-URL
						 URL del Datastore a consultar: //vmfs/volumes/5a4bb011-08123793-9324-0025b51a0003/
	#>

function Get-Datastore-URL{
$ds = Read-Host "URL del Datastore a consultar"
Get-Datastore | Where-Object {$_.extensiondata.info.url -like "*$ds*"}
}