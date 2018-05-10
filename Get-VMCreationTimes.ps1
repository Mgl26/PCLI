function Get-VMCreationTimes {

	#Detalle: Funcion que busca la fecha de creacion de la(s) VM(s) indicadas.
	#Detalle Ejemplo: Get-VMCreationTimes
	
	<#	
	
	Detalle: Funcion que busca la fecha de creacion de la(s) VM(s) indicadas.
	Detalle Ejemplo: Get-VMCreationTimes
	Detalle Ejemplo: Ingresa el nombre de la VM: [NOMBRE-VMV1]
	Detalle Ejemplo: Ingresa el nombre de la VM: [NOMBRE-VMV2]
	Detalle Ejemplo: Ingresa el nombre de la VM: [NOMBRE-VMV3]
	
	#>	

	$vmss = @()
	do 
	{
		$input = (Read-Host "Ingresa el nombre de la VM")
		if ($input -ne '') 
		{
			$vmss += $input;$cant_server++
			$c++
		}
	}until ($input -eq '')

   $vms = get-vm $vmss
   $vmevts = @()
   $vmevt = new-object PSObject
   foreach ($vm in $vms) {
      #Progress bar:
      $foundString = "       Found: "+$vmevt.name+"   "+$vmevt.createdTime+"   "+$vmevt.IPAddress+"   "+$vmevt.createdBy
      $searchString = "Searching: "+$vm.name
      $percentComplete = $vmevts.count / $vms.count * 100
      write-progress -activity $foundString -status $searchString -percentcomplete $percentComplete

      $evt = get-vievent $vm | sort createdTime | select -first 1
      $vmevt = new-object PSObject
      $vmevt | add-member -type NoteProperty -Name createdTime -Value $evt.createdTime
      $vmevt | add-member -type NoteProperty -Name name -Value $vm.name
      $vmevt | add-member -type NoteProperty -Name IPAddress -Value $vm.Guest.IPAddress
      $vmevt | add-member -type NoteProperty -Name createdBy -Value $evt.UserName
      #uncomment the following lines to retrieve the datastore(s) that each VM is stored on
      #$datastore = get-datastore -VM $vm
      #$datastore = $vm.HardDisks[0].Filename | sed 's/\[\(.*\)\].*/\1/' #faster than get-datastore
      #$vmevt | add-member -type NoteProperty -Name Datastore -Value $datastore
      $vmevts += $vmevt
      #$vmevt #uncomment this to print out results line by line
   }
   $vmevts | ft
   
	$date = get-date -f "ddMMyyyy"
	
	Write-Host ""
	Write-Host "Se exporto el archivo C:\temp\"$date"CreationVMs.csv" -ForegroundColor Blue
	Write-Host ""
	$vmevts | export-csv c:\temp\$date"CreationVMs.csv" -NoTypeInformation -Delimiter ";"   
   
}