google.charts.load('current', { 'packages': ['corechart'] });
google.charts.setOnLoadCallback(drawChart);

function getRandomColor() {
    var letters = '0123456789ABCDEF';
    var color = '#';
    for (var i = 0; i < 3; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}

var options = {
    legend: { position: 'bottom' },
    interpolateNulls: true
};

var tada;
var chart;

function getShown() {
    var showids = [0];
    var shown = document.getElementsByClassName("checkbox");
    for (let i = 0; i < shown.length; i++) {
        const element = shown[i];
        if (element.checked) {
            showids[showids.length] = parseInt(element.id);
        }
    }

    return showids;
}

function doHide(sender) {
    console.log(getShown());
    tada.setColumns(getShown());
    chart.draw(tada, options);
    doCustDraw();
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
        // console.log(rowData[0]);
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

    var data = transposeDataTable(google.visualization.arrayToDataTable(sourceArr));

    tada = new google.visualization.DataView(data);
    tada.setColumns(getShown());

    chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

    chart.draw(tada, options);
}

function dataRow(name, points) {
    this.color = "#000";
    this.name = name;
    this.points = points;
}

function point(x, y) {
    this.x = x;
    this.y = y;
}

function doCustDraw() {
    const tableHeader = sourceArr[0];

    const showboxes = document.getElementsByClassName("checkbox");
    const legend = document.getElementById("legend");
    legend.innerHTML = "";

    const xmin = Date.parse(tableHeader[1]);
    const xmax = Date.parse(tableHeader[tableHeader.length - 1]);
    let ymin = 0;//Number.MAX_SAFE_INTEGER
    let ymax = Number.MIN_SAFE_INTEGER;

    let rows = [];

    for (let i = 1; i < sourceArr.length; i++) {
        const elem = sourceArr[i];

        var shown = showboxes[i - 1].checked;
        if (!shown) {
            continue;
        }

        let points = [];
        let row = new dataRow(elem[0], points);
        row.color = getRandomColor();
        rows.push(row);


        legend.innerHTML += "<div style=\"color: " + row.color + ";\">" + row.name + "</div>";


        for (let j = 1; j < elem.length; j++) {
            const elem2 = parseInt(elem[j]);

            let Tpoint = new point(Date.parse(tableHeader[j]), elem2);
            points.push(Tpoint);

            if (elem2 > ymax) {
                ymax = elem2;
            }
            if (elem2 < ymin && !(elem2 == 0)) {
                ymin = elem2;
            }
        }
    }

    // console.log(rows);
    // console.log(xmin);
    // console.log(xmax);
    // console.log(ymin);
    // console.log(ymax);


    const offsetx = -xmin;
    const offsety = -ymin;


    const canv = document.getElementById("canv");
    const ctx = canv.getContext("2d");

    canv.width = canv.getBoundingClientRect().width;
    canv.height = canv.getBoundingClientRect().height;

    const width = canv.width;
    const height = canv.height;

    const scalex = 1 / (xmax - xmin) * width;
    const scaley = 1 / (ymax - ymin) * height;


    ctx.lineWidth = 3;
    ctx.clearRect(0, 0, width, height);


    let incr = 25000;
    ctx.font = '20px sans-serif';
    ctx.beginPath();
    for (let i = 0; i < ymax; i += incr) {
        ;
        const x = 0;
        const y = height - (i + offsety) * scaley;
        ctx.fillText(i, 0, y);
        ctx.strokeStyle = "#AAA";
        ctx.moveTo(0, y);
        ctx.lineTo(width, y);
        // console.log(i);
        // console.log(y);
    }
    ctx.stroke();

    for (let i = 0; i < rows.length; i++) {

        const row = rows[i];
        const points = row.points;

        ctx.strokeStyle = row.color;

        ctx.beginPath();
        const bx = (points[0].x + offsetx) * scalex;
        const by = height - (points[0].y + offsety) * scaley;
        ctx.moveTo(bx, by);
        var newbegin = false;
        for (let j = 1; j < points.length; j++) {
            const p = points[j];
            const x = (p.x + offsetx) * scalex;
            const y = height - (p.y + offsety) * scaley;
            if (newbegin) {
                ctx.beginPath();
                ctx.moveTo(x, y);
                newbegin = false;
            }
            if (isNaN(p.y)) {
                ctx.stroke();
                newbegin = true;
            } else {
                ctx.lineTo(x, y);
            }
        }
        ctx.stroke();
    }

}

function checkboxClicked(sender) {
    console.log(`Clicked: `,  sender);
    doHide(sender)
    const prevStr = getCookie('prev')
    console.log(`prevStr is`, prevStr);
    let prev;
    if (prevStr) {
        prev = JSON.parse(prevStr)
        console.log(`prev is: `, prev);
    }
    else {
        console.log(`No prev found`);
        prev = new Object()
    }
    prev[sender.id] = sender.checked
    console.log(`new prev is: `, prev);
    setCookie('prev', JSON.stringify(prev))
}

function onLoad() {
    // Get cookies from previous session
    const prevStr = getCookie('prev')
    if (prevStr) {
        const prev = JSON.parse(prevStr)
        // Check appropriate boxes
        for (const key in prev) {
            const value = prev[key]
            document.getElementById(key).checked = value
        }
        drawChart()
        doHide()
    }
}

function getCookie(name) {
    let cookies = getAllCookies();
    if (cookies) {
        return cookies?.find(x => x[0] === name)?.[1] ?? undefined;
    }
}
function getAllCookies() {
    return document.cookie?.split(";")?.map(x => x.trim().split("="));
}
function setCookie(name, value, expires = new Date(new Date().getFullYear() + 10, 1, 1)) {
    const path = "/"
    document.cookie = `${name}=${value}; expires=${expires}; path=${path}; SameSite=None; Secure`;
}
function clearCookies() {
    getAllCookies()?.forEach(elem => setCookie(elem[0], "", new Date(1970, 0, 0)));
}