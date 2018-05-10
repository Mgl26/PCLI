
	<#	
	
	Detalle:
	Detalle Ejemplo: 
	
	#>
	<#
	$date = get-date -f "ddMMyyyy"
	
	$result
	Write-Host ""
	Write-Host "Se exporto el archivo C:\temp\"$date"Serial-number.csv" -ForegroundColor Blue
	Write-Host ""
	$result | export-csv c:\temp\$date"Serial-number.csv" -NoTypeInformation -Delimiter ";"
	
	
	
	#>


function Funciones($busqueda){
	$ruta = "\\192.168.27.17\Admin_VMWare\PCLI"
	$files = Get-ChildItem $ruta"\*.ps1"
	$contenido = @()
	
	foreach($line in Get-Content $files.fullname -Exclude "$ruta\Funciones.ps1") {
		
		if($line -match "Detalle"){
			
			<#if($valor -ne $line.PSChildName){
				write-host ""
				write-host ""
				Write-host "---------- " $line.PSChildName " ----------" -ForegroundColor Blue
				$valor = $line.PSChildName
				write-host ""
			}#>
			#$contenido += $line
			if(!$busqueda){
				if($valor -ne $line.PSChildName){
					write-host ""
					write-host ""
					Write-host "---------- " $line.PSChildName " ----------" -ForegroundColor Blue
					$valor = $line.PSChildName
					write-host ""
				}			
				$line
			}else{
				if($line.PSChildName -like "*$busqueda*"){
					if($valor -ne $line.PSChildName){
						write-host ""
						write-host ""
						Write-host "---------- " $line.PSChildName " ----------" -ForegroundColor Blue
						$valor = $line.PSChildName
						write-host ""
					}
					$line
				}
			}
		}
	}
}