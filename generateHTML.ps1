$merged = cat .\merged.csv

[string] $mydataStr = $merged -replace '^', '[' -replace '$', '],' -replace ',,', ',"",' -replace ',,', ',"",' -replace ',]', ',""]'
$mydataStr = $mydataStr.TrimEnd(',')
$mydataStr = $mydataStr.Insert(0, '[') + "]"

$csv = Import-Csv .\merged.csv
$names = $csv.Name

[string[]] $checkboxScripts = @()
[string[]] $checkboxMarkups = @()

$names | % {$i = 0} {
    $pname = $_ -replace "-","_"
    $checkboxScripts += @"
    var hide$pname = document.getElementById("$_");
    hide$pname.onclick = function () {
    view = new google.visualization.DataView(data);
    view.hideColumns([$i]);
    chart.draw(view, options);
    };

"@
    $checkboxMarkups += @"
    <button type="button" id="$_"  >$_</button>
"@

$i++
}



$html = @"
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
<script type="text/javascript">
    google.charts.load('current', { 'packages': ['corechart'] });
    google.charts.setOnLoadCallback(drawChart);


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

        var mydata = google.visualization.arrayToDataTable($mydataStr)

        var transposed = transposeDataTable(mydata)

        var data = transposed;

        var options = {
            title: 'Company Performance',
            //curveType: 'function',
            legend: { position: 'bottom' }
        };

        var chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

        chart.draw(data, options);

        $checkboxScripts
    }
</script>

<div id="curve_chart" style="width: 100%; height: 90%"></div>
$checkboxMarkups
"@

$html > index.html