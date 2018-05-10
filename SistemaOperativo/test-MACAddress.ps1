#function Test-MACAddress ([string]$macAddress)
function Test-MACAddress ($valor)
{
    # RegEx pattern to match
    #$regexMAC = '((\d|([a-f]|[A-F])){2}){6}'
    $regexMAC = '^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$'
    #$regex = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
	
    # Remove spaces before / after, remove :, -, and .
    #$valor = $valor.Trim().Replace(':','').Replace('.','').Replace('-','')

    # Validate the length--less expensive than a RegEx match
    #if ($valor.Length -eq 12) {
        # Check against RegEx pattern
        if ($valor -match $regexMAC) {
            # Valid MAC
            return $true
        }
   # }
    # Invalid MAC
    return $false
}

function Test-IP ($IP)
{
    # RegEx pattern to match
    $regex = "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
				

    # Remove spaces before / after, remove :, -, and .
    #$macAddress = $macAddress.Trim().Replace(':','').Replace('.','').Replace('-','')

    # Validate the length--less expensive than a RegEx match
    #if ($macAddress.Length -eq 12) {
        # Check against RegEx pattern
        if ($IP -match $regex) {
            # Valid MAC
            return $true
        }
    #}
    # Invalid MAC
    return $false
}