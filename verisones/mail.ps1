Function mail(){

	param(
		[string]$From,
		[string]$To,
		[string]$Cc,
		[string]$Subject,
		[string]$Body,
		[string]$Name,
		[string]$Tipo,
		[string]$capacity,
		[string]$FreeSpace,
		[string]$PercFreeSpace,
		[string]$LUN,
		[string]$WWPN,
		[string]$Identificador,
		[string]$vHost,
		[string]$Share,
		[string]$vCenter,
		[string]$Tipificacion,
		[string]$Naa
		
	)
	
	
	$body = @("
Buen dia.

Estimados, favor generar $Tipificacion para el area de virtualizacion para atender evento relacionado al poco espacio en DataStore. A continuacion los datos:

Nombre DataStore: $Name
Tipo: $Tipo
Capacidad: $capacity
Espacio Libre: $FreeSpace
Espacio Libre (%): $PercFreeSpace
vCenter: $vCenter
LUN: $LUN
WWPN: $WWPN
Identificador: $Identificador
Host: $vHost
Share: $Share
Naa: $Naa


Saludos.		

")

	$Parameters = @{
		From = $From
		To = $To
		Cc= $Cc
		Subject = $Subject
		Body = $Body
		SmtpServer = '10.81.180.214'
		#Attachment = 'C:\Produccion\temp\Out_Revision_Hardware_hosts.htm'
	}
	Send-MailMessage @Parameters

}