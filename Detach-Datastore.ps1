Function Detach-Datastore {
	
	#Detalle: ((FUNCION QUE REALIZA CAMBIOS EN LA PLATAFORMA)), ejecuta un Detach sobre el o los datastore que se indiquen
	#Detalle Ejemplo1: Get-Datastore Nombre_Datastore | Detach-datastore
	#Detalle Ejemplo2: Get-Datastore | Detach-datastore (((((EJECUTA EL DETACH EN TODOS LOS DATASTORE DE LA PLATAFORMA))))

	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
	
	#$x = Read-host "Esta funcion realizara cambios en la plataforma, si no esta seguro de realizarlos presiones Ctrl+C"
	
	Process {
		if (-not $Datastore) {
			Write-Host "No Datastore defined as input"
			Exit
		}
		Foreach ($ds in $Datastore) {
			$hostviewDSDiskName = $ds.ExtensionData.Info.vmfs.extent[0].Diskname
			if ($ds.ExtensionData.Host) {
				$attachedHosts = $ds.ExtensionData.Host
				Foreach ($VMHost in $attachedHosts) {
					$hostview = Get-View $VMHost.Key
					$StorageSys = Get-View $HostView.ConfigManager.StorageSystem
					$devices = $StorageSys.StorageDeviceInfo.ScsiLun
					Foreach ($device in $devices) {
						if ($device.canonicalName -eq $hostviewDSDiskName) {
							$LunUUID = $Device.Uuid
							Write-Host "Detaching LUN $($Device.CanonicalName) from host $($hostview.Name)..."
							$StorageSys.DetachScsiLun($LunUUID);
						}
					}
				}
			}
		}
	}
}