Function Import-CSVCustom ($csvTemp) {
    $StreamReader = New-Object System.IO.StreamReader -Arg $csvTemp
    [array]$Headers = $StreamReader.ReadLine() -Split "," | % { "$_".Trim() } | ? { $_ }
    $StreamReader.Close()

    $a=@{}; $Headers = $headers|%{
        if($a.$_.count) {"$_$($a.$_.count)"} else {$_}
        $a.$_ += @($_)
    }

    Import-Csv $csvTemp -Header $Headers
}