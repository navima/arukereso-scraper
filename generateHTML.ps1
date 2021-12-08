$merged = cat .\merged.csv

[string] $mydataStr = $merged -replace '^', '[' -replace '$', '],' -replace ',,', ',"",' -replace ',,', ',"",' -replace ',]', ',""]'
$mydataStr = $mydataStr.TrimEnd(',')
$mydataStr = $mydataStr.Insert(0, '[') + "]"
$sourceArr = $mydataStr

$csv = Import-Csv .\merged.csv

[string] $tableBody = @()

$csv | % { $i = 1 } {
    $name = $_.Name
    $members = $_ | Get-Member -MemberType NoteProperty
    $lastPricePropName = $members[$members.length - 2].Name
    $lastprice = $_ | Select-Object -ExpandProperty $lastPricePropName
    $tableBody += @"
<tr>
    <td> <input type="checkbox" id="$i" class="checkbox" onclick="doHide(this)" >
    <td> <label for="$i">$name</label>
    <td> $lastprice
</tr>

"@
    $i++
}

$templateHtml = cat ./indexTemplate.html -raw
$html = $ExecutionContext.InvokeCommand.ExpandString($templateHtml)

$html > index.html
