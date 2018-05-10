function Evalua-Datastore(){
	
	#Detalle: Funcion que calcula el espacio disponible del datastore indicado incluyendo el porcentaje de reserva para VMware (Evalua-Datastore -> porcentaje Penalizado -> Nombre Datastore)
	#Detalle	 Ejemplo: Evalua-Datastore
	#Detalle	: Introduce el valor de porcentaje libre a calcular (Por defecto: 20):
	#Detalle	: Ingresa el nombre del DataStore #1: NOMBRE_DATASTORE
	
	
	$ds = @()
	$c = 1
	
	[int]$valor = read-host "Introduce el valor de porcentaje libre a calcular (Por defecto: 20)"
	if(!$valor){
		$valor = 20
	}	

	do 
	{
		$input = (Read-Host "Ingresa el nombre del DataStore #$c")
		if ($input -ne '') 
		{
			$ds += $input
			$c++
			}
	}until ($input -eq '')

	
	<#
	Get-Datastore -name $ds | %{$provision = [math]::round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2); $_} | select name, CapacityGB, FreeSpaceGB, 
									@{N="PercentFree%";E={[math]::Round($provision * 100/$_.CapacityGB)}},
									@{N="ReservaVMWareGB";E={($valor * $_.CapacityGB)/100}}, 
									@{N="EspacioDisponibleGB";E={[math]::Round($_.FreeSpaceGB - ($valor*$_.CapacityGB/100),2)}},
									@{N="ProvisionedGB"; E={[math]::round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2)}}
	#>								
									
	Get-Datastore -name $ds | select name, CapacityGB, FreeSpaceGB, 
									@{N="PercentFree%";E={[math]::Round($_.FreeSpaceGB * 100/$_.CapacityGB)}},
									@{N="ReservaVMWareGB";E={($valor * $_.CapacityGB)/100}}, 
									@{N="EspacioDisponibleGB";E={[math]::Round($_.FreeSpaceGB - ($valor*$_.CapacityGB/100),2)}},
									@{N="ProvisionedGB"; E={[math]::round(($_.ExtensionData.Summary.Capacity - $_.ExtensionData.Summary.FreeSpace + $_.ExtensionData.Summary.Uncommitted)/1GB,2)}}
}