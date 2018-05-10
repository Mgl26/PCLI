
	<#	
	
	Detalle: Funcion que obtiene el numero de serial por cada uno de los ESX a los que se encuentre conectado
	Detalle Ejemplo: Get-SerialNumber
	
	#>

function Get-SerialNumber() {

	$date = get-date -f "dd/MM/yyyy"

	$result = Get-Vmhost | Get-View | Sort-object Name |
	select Name,
	@{N='Product';E={$_.Config.Product.FullName}},
	@{N='Build';E={$_.Config.Product.Build}},
	@{Name="Serial Number"; Expression={($_.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq "ServiceTag"}).IdentifierValue}}
	
	$result
	Write-Host ""
	Write-Host "Se exporto el archivo C:\temp\"$date"Serial-number.csv" -ForegroundColor Blue
	Write-Host ""
	$result | export-csv c:\temp\$date"Serial-number.csv" -NoTypeInformation -Delimiter ";"
}