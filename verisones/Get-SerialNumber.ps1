function Get-SerialNumber() {

	Get-Vmhost | Get-View | Sort-object Name |
	select Name,
	@{N='Product';E={$_.Config.Product.FullName}},
	@{N='Build';E={$_.Config.Product.Build}},
	@{Name="Serial Number"; Expression={($_.Hardware.SystemInfo.OtherIdentifyingInfo | where {$_.IdentifierType.Key -eq "ServiceTag"}).IdentifierValue}}
}