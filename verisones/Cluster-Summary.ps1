function Get-ClusterSummary {
<#
.SYNOPSIS
  Gets summary information from the cluster
.DESCRIPTION
  This function creates a report with summary information of the
  cluster
.NOTES
  Source:  Automating vSphere Administration
  Authors: Luc Dekens, Brian Graf, Arnim van Lieshout,
           Jonathan Medd, Alan Renouf, Glenn Sizemore,
           Andrew Sullivan
.PARAMETER Cluster
  The cluster object to create a report on
.EXAMPLE
  Get-ClusterSummary -Cluster (Get-Cluster CL01)
.EXAMPLE
  Get-Cluster | Get-ClusterSummary
#>

  Param(
   [parameter(ValueFromPipeline = $true, Mandatory = $true, HelpMessage = "Enter a cluster entity")]
   [VMware.VimAutomation.ViCore.Impl.V1.Inventory.ClusterImpl] $cluster)

  process {
    $objCluster = "" | Select ClusterName, NumHost, NumVM, NumDatastore, NumNetwork, AssignedCpu, NumCores, vCpuPerCore, TotalCpuGHz, TotalMemGB, AssignedMemGB, MemUsagePct
    $vm = @($cluster | Get-VM) 
    $objCluster.ClusterName = $cluster.Name
    $objCluster.NumHost = $cluster.ExtensionData.Summary.NumHosts
    $objCluster.NumVM = $vm.Count
    $objCluster.NumDatastore = $cluster.ExtensionData.Datastore.Count
    $objCluster.NumNetwork = $cluster.ExtensionData.Network.Count
    $objCluster.AssignedCpu = ($vm | Where {$_.PowerState -eq "PoweredOn"} | Measure-Object -Property NumCpu -Sum).Sum
    $objCluster.NumCores = $cluster.ExtensionData.Summary.NumCpuCores
    $objCluster.vCpuPerCore = "{0:n2}" -f ($objCluster.AssignedCpu / $objCluster.NumCores)
    $objCluster.TotalCpuGhz = "{0:n2}" -f ($cluster.ExtensionData.Summary.TotalCpu / 1000)
    $objCluster.TotalMemGB = "{0:n2}" -f ($cluster.ExtensionData.Summary.TotalMemory / 1GB)
    $objCluster.AssignedMemGB = "{0:n2}" -f (($vm | Where {$_.PowerState -eq "PoweredOn"} | Measure-Object -Property MemoryMB -Sum).Sum / 1024)
    $objCluster.MemUsagePct = "{0:p2}" -f ( (($vm | Where {$_.PowerState -eq "PoweredOn"} | Measure-Object -Property MemoryMB -Sum).Sum / 1024) / ($cluster.ExtensionData.Summary.TotalMemory / 1GB))
    $objCluster 
   }
}