$merged = cat .\merged.csv

[string] $mydataStr = $merged -replace '^', '[' -replace '$', '],' -replace ',,', ',"",' -replace ',,', ',"",' -replace ',]', ',""]'
$mydataStr = $mydataStr.TrimEnd(',')
$mydataStr = $mydataStr.Insert(0, '[') + "]"

$csv = Import-Csv .\merged.csv

[string[]] $checkboxMarkups = @()

$csv | % { $i = 1 } {
    $name = $_.Name
    $members = $_ | Get-Member -MemberType NoteProperty
    $lastPricePropName = $members[$members.length - 2].Name
    $lastprice = $_ | Select-Object -ExpandProperty $lastPricePropName
    $checkboxMarkups += @"
<tr>
    <td> <input type="checkbox" id="$i" class="checkbox" onclick="doHide(this)" >
    <td> <label for="$i">$name</label>
    <td> $lastprice
</tr>

"@

    $i++
}



$html = @"
<link rel="stylesheet" href="index.css">
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
google.charts.load('current', { 'packages': ['corechart'] });
google.charts.setOnLoadCallback(drawChart);


var options = {
    legend: { position: 'bottom' },
    interpolateNulls: false
};

var tada
var chart

function getShown() {
    var showids = [0]
    var shown = document.getElementsByClassName("checkbox")
    for (let i = 0; i < shown.length; i++) {
        const element = shown[i];
        if (element.checked) {
            showids[showids.length] = parseInt(element.id)
        }
    }

    return showids
}

function doHide(sender) {
    //shown[sender.id] = !shown[sender.id]
    console.log(getShown())
    tada.setColumns(getShown())
    chart.draw(tada, options);
    //this.checked = shown[sender.id]
}


function transposeDataTable(dataTable) {
    //step 1: let us get what the columns would be
    var rows = [];//the row tip becomes the column header and the rest become
    for (var rowIdx = 0; rowIdx < dataTable.getNumberOfRows(); rowIdx++) {
        var rowData = [];
        for (var colIdx = 0; colIdx < dataTable.getNumberOfColumns(); colIdx++) {
            rowData.push(dataTable.getValue(rowIdx, colIdx));
        }
        rows.push(rowData);
    }
    var newTB = new google.visualization.DataTable();
    newTB.addColumn('string', dataTable.getColumnLabel(0));
    newTB.addRows(dataTable.getNumberOfColumns() - 1);
    var colIdx = 1;
    for (var idx = 0; idx < (dataTable.getNumberOfColumns() - 1); idx++) {
        var colLabel = dataTable.getColumnLabel(colIdx);
        newTB.setValue(idx, 0, colLabel);
        colIdx++;
    }
    for (var i = 0; i < rows.length; i++) {
        var rowData = rows[i];
        console.log(rowData[0]);
        newTB.addColumn('number', rowData[0]); //assuming the first one is always a header
        var localRowIdx = 0;

        for (var j = 1; j < rowData.length; j++) {
            newTB.setValue(localRowIdx, (i + 1), rowData[j]);
            localRowIdx++;
        }
    }
    return newTB;
}

function drawChart() {

    var data = transposeDataTable(google.visualization.arrayToDataTable($mydataStr))

    tada = new google.visualization.DataView(data)
    tada.setColumns(getShown())

    chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

    chart.draw(tada, options);
}
</script>

<div id="curve_chart" class="chart"></div>

<table>
    <thead>
        <tr>
            <td>
            <td>Name
            <td>Price
            <td>Performance
            <td>PpP
        </tr>
    </thead>

    <tbody>
        $checkboxMarkups
    </tbody>
</table>
"@

$html > index.html