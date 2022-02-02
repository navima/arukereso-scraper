# Insert CSV data into data.js
$merged = cat .\merged.csv

[string] $mydataStr = $merged -replace '^', '[' -replace '$', '],' -replace ',,', ',"",' -replace ',,', ',"",' -replace ',]', ',""]'
$mydataStr = $mydataStr.TrimEnd(',')
$mydataStr = $mydataStr.Insert(0, '[') + "]"
$sourceArr = $mydataStr

$templateDataJs = cat ./dataTemplate.js -raw
$dataJs = $ExecutionContext.InvokeCommand.ExpandString($templateDataJs)

$dataJs > data.js



# Insert data into index.html

$csv = Import-Csv .\merged.csv

# Valid html elements.
# Will be inserted into template.
[string] $tableBody = @()

$csv | % { $i = 1 } {
    $name = $_.Name
    $members = $_ | Get-Member -MemberType NoteProperty
    $lastPricePropName = $members[$members.length - 2].Name
    $lastprice = $_ | Select-Object -ExpandProperty $lastPricePropName
    $tableBody += @"
<tr>
    <td> <input type="checkbox" id="$i" class="checkbox" onclick="checkboxClicked(this)" >
    <td> <label for="$i">$name</label>
    <td> $lastprice
</tr>

"@
    $i++
}

$templateHtml = cat ./indexTemplate.html -raw
$html = $ExecutionContext.InvokeCommand.ExpandString($templateHtml)

$html > index.html
