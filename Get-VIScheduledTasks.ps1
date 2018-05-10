##############################################
# Obtiene todas las tareas programadas del vcenter


	<#	
	
	Detalle: Funcion que realiza busqueda de tareas programadas de VMWare
	Detalle Ejemplo: 
	
	#>

Function Get-VIScheduledTasks {
	PARAM ( [switch]$Full )
	$date = get-date -f "ddMMyyyy"
	if ($Full) {
		# Note: When returning the full View of each Scheduled Task, all date times are in UTC
		$result = (Get-View ScheduledTaskManager).ScheduledTask | %{ (Get-View $_).Info }
	} else {
		# By default, lets only return common headers and convert all date/times to local values
		$result = (Get-View ScheduledTaskManager).ScheduledTask | %{ (Get-View $_ -Property Info).Info } |
		Select-Object Name, Description, Enabled, Notification, LastModifiedUser, State, Entity,
		@{N="EntityName";E={ (Get-View $_.Entity -Property Name).Name }},
		@{N="LastModifiedTime";E={$_.LastModifiedTime.ToLocalTime()}},
		@{N="NextRunTime";E={$_.NextRunTime.ToLocalTime()}},
		@{N="PrevRunTime";E={$_.LastModifiedTime.ToLocalTime()}}, 
		@{N="ActionName";E={$_.Action.Name}}
	}
	  
	  $result
	  
		Write-Host ""
		Write-Host "Se exporto el archivo C:\temp\"$date"TareaProgramadas.csv" -ForegroundColor Blue
		Write-Host ""
		$result | export-csv c:\temp\$date"TareaProgramadas.csv" -NoTypeInformation -Delimiter ";"
}