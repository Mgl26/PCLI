function Get-LunId
{
	param($CanonicalName, $VMHost)
	
	#Get advanced host properties
	$VMHostView = Get-VMHost $VMHost | Get-View
	
	#Get two different collections with luns
	#The first one matches the canonical name with a key
	$HostLunsByCanonicalName = Get-VMHost $VMHost | Get-SCSILun
	#The second one matches the key with a lun id
	$HostLunsByKey = $VMHostView.Config.StorageDevice.ScsiTopology | 
		ForEach {$_.Adapter} | ForEach {$_.Target} | ForEach {$_.Lun}
	
	#Use the first collection to translate the canonicalname into the key
	$Key = ($HostLunsByCanonicalName | Where {$_.CanonicalName -eq $CanonicalName}).Key
	#Use the second colleciton to find the luns with the key
	$MatchingLuns = $HostLunsByKey | Where {$_.ScsiLun -eq $Key}
	
	#Every path to the lun will be a match, 
	#so let's deduplicate and see if there is really a single result
	$NumResults = ($MatchingLuns | Group-Object Lun | Measure-Object).Count
	If ($NumResults -gt 1)
	{
		#Multiple luns found
		$MatchingLuns | Group-Object Lun | ForEach {$_.Name}
	}
	ElseIf ($NumResults -eq 1)
	{
		#Single result found
		($MatchingLuns | Select -First 1).Lun
	}
	Else
	{
		#No results found
		"No result"
	}
}