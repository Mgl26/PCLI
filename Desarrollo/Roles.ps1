#$rootFolder = Get-Folder -NoRecursion
#$permission1 = New-VIPermission -Entity $rootFolder -Principal pcli_monitor -Role ReadOnly
#Set-VIPermission -Permission $permission1

function Cambia-Roles(){

	param(
		[string]$TaskUser,
		[string]$TaskRole
	)
		
	if($TaskUser)
	{
		$rootFolder = Get-Folder -NoRecursion
		$taskpermiso = New-VIPermission -Entity $rootFolder -Principal $TaskUser -Role $TaskRole
		Set-VIPermission -Permission $Taskpermiso
	}else
	{
		$vCenter = Read-Host "Introduce IP de vCenter"
		
		$validaIP = Test-IP $vCenter
		
		if($validaIP -eq $false){
			Write-Host "No se ingreso in direccion IP valida" -ForegroundColor Red
			Break
		}
		
		
		#$Usuario = Read-Host "Introduce nombre de usuario"
		$Usuario = "pcli_monitor"
		#$Pass = Read-Host "Contrseña" -AsSecureString
		$Pass = "!!p0w3rcli.!"
		
		#$srv = Connect-VIServer -Server $vCenter -User $Usuario -Password $Pass -ErrorActio "SilentlyContinue"
 
		#Connect-VIServer $vCenter -Session $srv.SessionId
		
		Connect-VIServer -Server $vCenter -User $Usuario -Password $Pass -ErrorActio "SilentlyContinue"
		
		if(!$global:defaultviserver){
			Write-Host "No se logro establecer conexion con el servidor $vCenter" -ForegroundColor Red
			Break
		}
		
		$rootFolder = Get-Folder -NoRecursion
		
		Write-Host ""
		Write-Host "================ Selecciona Usuario ================"
		Write-Host ""
		 
		$Accnts = Get-VIAccount
		$CountAccnt = 0
		foreach($Accnt in $Accnts)
		{
			Write-Host "     $CountAccnt --> $Accnt"
			$CountAccnt ++
		}
		
		Write-Host ""
		$user = Read-Host "Selecciona el usuario al que se le cambiara el Role"
		
		Write-Host ""
		$Accnts[$user].name
		Start-Sleep -s 2
		
		Write-Host ""
		Write-Host ""
		Write-Host "================ Selecciona Role ================"
		Write-Host ""
		Write-Host ""
		
		
		$Roles = Get-VIRole
		$CountRole = 0
		
		foreach($role in $Roles)
		{
			Write-Host "     $CountRole --> $role"
			$CountRole ++
		}
		
		Write-Host ""
		$rol = Read-Host "Selecciona el ROLE que se le asignara al usuario" $Accnts[$user]
		Write-Host ""
		$Roles[$rol].name
		Write-Host ""
		Start-Sleep -s 2
		
		write-host "New-VIPermission -Entity $rootFolder -Principal "$Accnts[$user].name "-Role" $Roles[$rol].name
		$permiso = New-VIPermission -Entity $rootFolder -Principal $Accnts[$user].name -Role $Roles[$rol].name
		Set-VIPermission -Permission $permiso
		
		Write-Host ""
		Write-Host ""
		Write-Host "Se asigno el role  "$Roles[$rol].name" al usuario "$Accnts[$user].name
		Write-Host ""
		Write-Host ""
		
		Write-Host "Ingresa la fecha en la que deseas revertir los cambios del Grupo a ReadOnly" -ForegroundColor green
		Write-Host ""
		Write-Host ""
		$fecha = Read-Host "Ingresa fecha Ej: 08/30/2017 14:00"
		
		Add-Tarea -Time $fecha -User $Accnts[$user].name -Role "ReadOnly" -vCenter $vCenter -Usuario $Usuario -Pass $Pass
	}
	
}