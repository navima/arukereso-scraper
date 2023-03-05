# Get files
$files = Get-ChildItem -path "." | Where-Object { $_.name -match "prices-....-..-..( .._..)?\.csv" } 

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
    # the date as a string
    $nicename = ($file.Name | Select-String -Pattern "prices-(....-..-..( .._..)?)\.csv" ).Matches.Groups[1].Value -replace "_", ":"
    $csv = Import-Csv $file
    $csv | % {
        $csvRecord = $_
        $objs | Where-Object { $_.Name -eq $csvRecord.Name }[0] | Add-Member $nicename $csvRecord.Value
    }
    if (($objs | Get-Member $nicename) -eq $null) {
        $objs[0] | Add-Member $nicename 0
    }

}

Write-Output $objs | ConvertTo-Csv