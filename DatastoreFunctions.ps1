Function Mount-Datastore {	
	
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
					Write-Host "Mounting VMFS Datastore $($DS.Name) on host $($hostview.Name)..."
					$StorageSys.MountVmfsVolume($DS.ExtensionData.Info.vmfs.uuid);
				}
			}
		}
	}
}

Function Attach-Datastore {
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
					$devices = $StorageSys.StorageDeviceInfo.ScsiLun
					Foreach ($device in $devices) {
						if ($device.canonicalName -eq $hostviewDSDiskName) {
							$LunUUID = $Device.Uuid
							Write-Host "Attaching LUN $($Device.CanonicalName) to host $($hostview.Name)..."
							$StorageSys.AttachScsiLun($LunUUID);
						}
					}
				}
			}
		}
	}
}
#
#Get-Datastore | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2ISCSI01 | Unmount-Datastore
#
#Get-Datastore IX2ISCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2iSCSI01 | Mount-Datastore
#
#Get-Datastore IX2iSCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2iSCSI01 | Detach-Datastore
#
#Get-Datastore IX2iSCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
#Get-Datastore IX2iSCSI01 | Attach-datastore
#
#Get-Datastore IX2iSCSI01 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
#
<#

Get-Datastore ULT_LUN_DQS_D_01_NFS | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
Get-Datastore ULT_LUN_DQS_D_01_DF2 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
Get-Datastore ULT_LUN_DQS_D_01_DF3 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
Get-Datastore ULT_LUN_DQS_D_01_LOG2 | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
Get-Datastore ULT_LUN_DQS_D_01_OS | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize
Get-Datastore ULT_LUN_DQS_D_01_DF1_NEW | Get-DatastoreMountInfo | Sort Datastore, VMHost | FT -AutoSize


Get-Datastore ULT_LUN_DQS_D_01_NFS | Unmount-Datastore
Get-Datastore ULT_LUN_DQS_D_01_DF2 | Unmount-Datastore
Get-Datastore ULT_LUN_DQS_D_01_DF3 | Unmount-Datastore
Get-Datastore ULT_LUN_DQS_D_01_LOG2 | Unmount-Datastore
Get-Datastore ULT_LUN_DQS_D_01_OS | Unmount-Datastore
Get-Datastore ULT_LUN_DQS_D_01_DF1_NEW | Unmount-Datastore


Get-Datastore ULT_LUN_DQS_D_01_NFS | Detach-datastore
Get-Datastore ULT_LUN_DQS_D_01_DF2 | Detach-datastore
Get-Datastore ULT_LUN_DQS_D_01_DF3 | Detach-datastore
Get-Datastore ULT_LUN_DQS_D_01_LOG2 | Detach-datastore
Get-Datastore ULT_LUN_DQS_D_01_OS | Detach-datastore
Get-Datastore ULT_LUN_DQS_D_01_DF1_NEW | Detach-datastore
#>