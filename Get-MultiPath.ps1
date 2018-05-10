Function Get-MultiPath($ds){
	
	#Detalle: Obtiene el Lun Path y el Path Selection de los datastore especificados
	#Detalle Ejemplo1: Obtiene los valores de los datastore que coincidan con el nombre G800
	#Detalle Ejemplo1: Get-MultiPath [*G800*]
	#Detalle Ejemplo2: Obtiene los valores del datastore especifico
	#Detalle Ejemplo2: Get-MultiPath [NombreDatastore]
	#Detalle Ejemplo3: Obtiene los valores de todos los datastores de la plataforma a la que esté conectado
	#Detalle Ejemplo3: Get-MultiPath
	$date = get-date -f "ddMMyyyy"
	$result = Get-Datastore $ds | %{$ds = $_; $_} | Get-ScsiLun | %{$lun = $_;$_} | Get-ScsiLunPath | Select-Object @{N="ESX";E={$lun.VMHost}}, @{N="Datastore";E={$ds}}, ScsiCanonicalName, @{N="MultiPathPolicy";E={$lun.MultipathPolicy}}, SanID, State
	
	$result
	Write-host "Se exporto el resultado a la ruta c:\temp\"$date"MultiPath.csv"
	$result  | export-csv c:\temp\$date"Serial-number.csv" -NoTypeInformation -Delimiter ";"
	
}