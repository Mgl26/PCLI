function Add-Tarea{
 <#
.Example
Add-Tarea -time "08/30/2017 12:15"
This example will remind you to clean your kitchen on 1/1/2016 at 12:00 PM
#>
	Param(
		[string]$User,
		[string]$Role,
		[datetime]$Time,
		[string]$vCenter,
		[string]$Usuario,
		[string]$Pass
		
	)
	#$Task = New-ScheduledTaskAction -Execute Send-MailMessage -Argument "-Body 'test' -From 'mjsoto@entel.cl' -SmtpServer '10.81.180.214' -To 'mjsoto@entel.cl' -Subject 'shupalo'"
	#$Task = New-ScheduledTaskAction -Execute msg -Argument "* $Reminder"
	$Task = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "Connect-viServer -Server $vCenter -User $Usuario -Password $Pass; Cambia-Roles -TaskUser $User -TaskRole $Role; pause"
	$trigger =  New-ScheduledTaskTrigger -Once -At $Time
	$Random = (Get-random)
	Register-ScheduledTask -Action $task -Trigger $trigger -TaskName "CambioRole_$Random" -Description "Tarea que ejecuta para revertir cambios de role realizado $Time"
}