function Get-CDConnected(){
	$cdrom = @()
	ForEach ($vms in (Get-Cluster | Get-VM )) {
		ForEach ($vm in $vms | where { $_ | Get-CDDrive | where { $_.ConnectionState.Connected -eq "true" -and $_.ISOPath -like "*.ISO*"}}) { 
			$objGuest= "" | Select vCenter, Nombre_VM, NombreGUestOs,OSFullName, ipaddress, IsoPath
			$objGuest.vCenter= $vm.ExtensionData.Client.ServiceUrl.Split('/')[2]
			$objGuest.Nombre_VM = $vm.name
			$objGuest.NombreGUestOs = $vm.guest.hostname
			$objGuest.OSFullName =  $vm.guest.OSFullName
			$objGuest.Ipaddress = $vm.ExtensionData.guest.ipaddress
			$objGuest.Isopath = ($vm | Get-CDDrive).isopath
			$cdrom += $objGuest    
		}
	}
	
	$cdrom | Sort-Object -Property OSFullName | FT -Autosize
	$win = $cdrom | where-object {$_.OSFullName -like "*Windows*"}
	$linux = $cdrom | where-object {$_.OSFullName -notlike "*Windows*"}
	$win | Sort-Object -Property OSFullName | Export-Csv -Path C:\Temp\Check_ISO_Report_Windows.csv -NoTypeInformation -Delimiter ";"
	$linux | Sort-Object -Property OSFullName | Export-Csv -Path C:\Temp\Check_ISO_Report_Linux.csv -NoTypeInformation -Delimiter ";"
}