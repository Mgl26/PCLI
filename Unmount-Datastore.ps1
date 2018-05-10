Function Unmount-Datastore {

	#Detalle: ((FUNCION QUE REALIZA CAMBIOS EN LA PLATAFORMA)), Desmonta de la plataforma el o los datastore que se indiquen
	#Detalle Ejemplo1: Get-Datastore Nombre_Datastore | Unmount-Datastore ((((  DESMONTA EL DATASTORE INDICADO )))
	#Detalle Ejemplo2: Get-Datastore | Unmount-Datastore ((((( DESMONTA TODOS LOS DATASTORE DE LA PLATAFORMA ))))	
	
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline=$true)]
		$Datastore
	)
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
					Write-Host "Unmounting VMFS Datastore $($DS.Name) from host $($hostview.Name)..."
					$StorageSys.UnmountVmfsVolume($DS.ExtensionData.Info.vmfs.uuid);
				}
			}
		}
	}
}
