
#Detalle: Funcion que obtiene las WWPN de los ESX a los que se encuentre conectado
#Detalle Ejemplo: Get-WWN


Function Get-WWN(){
	$report = @()
	$date = get-date -f "ddMMyyyy"
	foreach ($cluster in (Get-Cluster)) {
		("Processing cluster " + $cluster.Name + " ...")
		foreach ($vhost in (Get-VMHost -Location $cluster.Name)) {
			("   Processing host " + $vhost.Name + " ...")
			$row = "" | select Cluster, VMHost, Dev1, WWN1, Dev2, WWN2, Dev3, WWN3, Dev4, WWN4
			$row.Cluster = $cluster.Name
			$row.VMHost = $vhost.Name
			foreach ($hba in (Get-VMHostHba -VMHost $vhost -Type FibreChannel)) {
				if ($hba.ExtensionData.Status -eq "online") {
					$wwn = ("{0:X}" -f $hba.PortWorldWideName) -replace '(..(?!$))','$1:'
					if ($row.WWN1 -eq $null) {
						$row.Dev1 = $hba.Device
						$row.WWN1 = $wwn
					} elseif ($row.WWN2 -eq $null) {
						$row.Dev2 = $hba.Device
						$row.WWN2 = $wwn
					} elseif ($row.WWN3 -eq $null) {
						$row.Dev3 = $hba.Device
						$row.WWN3 = $wwn
					} elseif ($row.WWN4 -eq $null) {
						$row.Dev4 = $hba.Device
						$row.WWN4 = $wwn
					}
				}        
			}
			$report += $row
		}
	}
	 
	"Exporting report data to $outputFile ..."
	$report
	Write-host "Se exporto el resultado en la ruta C:\temp\"$date"WWN.csv"
	$report | Export-Csv "C:\temp\"$date"_WWN.csv" -NoTypeInformation -Delimiter ";"
}