function last-reboot ($vm)
{
$Uptime = Get-Stat -Entity $vm -Stat sys.uptime.latest -Realtime -MaxSamples 1
$Timespan = New-Timespan -Seconds $Uptime.Value
#"" + $Timespan.Days + " Days, " + $Timespan.Hours + " Hours, " + $Timespan.Minutes + " Minutes"
write-host $Timespan.Days " Days, " $Timespan.Hours " Hours, " $Timespan.Minutes " Minutes"
}