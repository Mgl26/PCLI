#requires -version 3
#requires -module VMware.VimAutomation.Core

Function Get-ProtectedVMList {

  <#
    .SYNOPSIS
      Returns a list of virtual machines protected by SRM.
    .DESCRIPTION
      Returns a list of virtual machines protected by SRM. Also includes SRM detail for each
      protected virtual machine.  Optionally, use the PassThru switch to return virtual machine
      objects instead.
      By default, we return the following properties (unless using PassThru):
      MoRef
      ProtectedVm
      PeerProtectedVm
      State
      PeerState
      NeedsConfiguration
      ProtectionGroup
      
    .NOTES
      Author:        Mike Nisk
      Prior Art:     Based on https://github.com/codyhosterman/powercli/blob/master/findsrmVMs.ps1
      Requirements:  You should already be connected to one or more vCenter and SRM servers.
      Tested On:     Microsoft PowerShell 5.1 (requires PowerShell 3.0 or greater)
      Tested On:     VMware PowerCLI 6.5.3 (requires PowerCLI 6.5.1 or greater)
      Tested On:     VMware vCenter Server 6.0, ESXi 6.0, SRM 6.1.1 (6.5 or later desired, not required)
    .PARAMETER PassThru
      Optionally, return virtual machine objects instead of the default SRM detail for one 
      or more protected virtual machines. Use this switch if you want results that are like
      Get-VM.
      
    .EXAMPLE
    Get-ProtectedVMList
    This example returns the SRM protected virtual machine moref, along with additional properties
    showing the SRM related health. 
    .EXAMPLE
    Get-ProtectedVMList -PassThru
    This example uses the PassThru switch which returns virtual machine objects.
  #>
  
  [CmdletBinding()]
  Param(
    
    #Switch. Activate the PassThru switch to return virtual machine objects for SRM Protected virtual machines.
    [switch]$PassThru
    
  )
  
  Process {

    $srmapi = $Global:DefaultSrmServers.ExtensionData
    $srmpgs = $srmapi.protection.listprotectiongroups()

    $SrmObjects = @()
    foreach($protGroup in $srmpgs){

      $protGroupName = $protGroup.GetInfo().Name
      
      $VMs = $protGroup.ListProtectedVMs()
      Foreach($vmid in $VMs){
        $SrmObjects += [PSCustomObject] @{
          MoRef              = [string]$vmid.VM.MoRef
          ProtectedVm        = [string]$vmid.ProtectedVm
          PeerProtectedVm    = [string]$vmid.PeerProtectedVm
          State              = [string]$vmid.State
          PeerState          = [string]$vmid.PeerState
          NeedsConfiguration = [bool]$vmid.NeedsConfiguration
          ProtectionGroup    = [string]$protGroupName
        }
      }
    }
    
    #Handle PassThru  
    If($PassThru){
      $VMObjects = Get-VM -Id $SrmObjects.MoRef
    }
  } #End Process
  
  End{
    If($PassThru){
      return $VMObjects
    }
    Else{
      return $SrmObjects
    }
  }#End End
} #End Function