Function Get-Capacidades(){

	#Detalle: Funcion que calcula las capacidades de computo y vSAN (si aplica) -- "Get-Capacidades"
	#Detalle Ejemplo: Get-Capacidades
	
	#----- EXCEL ------ CREA ARCHIVO EXCEL
	$excel = New-Object -ComObject Excel.Application
	$excel.Visible = $true
	$workbook = $excel.Workbooks.Add()
	
	Get-Capacidades_Excel
	Get-CapacidadesVSAN_Excel
	
	
}