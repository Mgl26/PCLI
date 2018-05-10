Function Get-PathSelections(){
	
	$date = get-date -f "ddMMyyyy"
	$ds = Read-Host "Datastore que coincidan con un valor (Vacio busca todos los datastore)"

	$result = Get-VMHost | %{$vmhts = $_; $_} | Get-Datastore *$ds* | %{$ds = $_;$_} | Get-ScsiLun | select @{N="Host";E={$vmhts}}, @{N="Datastore";E={$ds}}, CanonicalName, MultipathPolicy

	$result
	$result | export-csv c:\temp\$date"PathSelections.csv" -NoTypeInformation -Delimiter ";"
}