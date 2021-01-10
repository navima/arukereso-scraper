# Get files
$files = Get-ChildItem -path "." | Where-Object { $_.name -match "prices-....-..-..\.csv" } 

# Get all possible names
$dnames = @()

$files | % {
    $csv = Import-Csv $_
    $dnames += $csv.Name
}
$names = $dnames | Sort-Object -Unique
$objs = @()
$names | % {
    $t = [PSCustomObject]@{
        Name = $_
    }
    $objs += $t
}

# Import data
$files | % {
    $file = $_
    $nicename = ($_.Name | Select-String -Pattern "prices-(....-..-..)\.csv" ).Matches.Groups[1].Value
    $csv = Import-Csv $_
    $csv | % {
        $csvRecord = $_
        $objs | Where-Object { $_.Name -eq $csvRecord.Name }[0] | Add-Member $nicename $csvRecord.Value
    }
}

Write-Host $objs
Write-Output $objs | ConvertTo-Csv