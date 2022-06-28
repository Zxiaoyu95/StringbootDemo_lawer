<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@include file="../../include/publicMeta.jsp"%>
<%@include file="../../include/publicHeader.jsp"%>
<%@include file="../../include/publicMenu.jsp"%>

<%@include file="../../include/publicFooter.jsp"%>

<head>
    <meta charset="utf-8"><link rel="icon" href="https://static.jianshukeji.com/highcharts/images/favicon.ico">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="https://static.jianshukeji.com/hcode/images/favicon.ico">
    <link rel="stylesheet" type="text/css" href="https://code.highcharts.com.cn/libs/font-awesome/css/font-awesome.min.css"/>
    <style>
        #container, #buttonGroup {
            max-width: 1200px;
            min-width: 320px;
            margin: 1em auto;
        }
        .hidden {
            display: none;
        }
        .main-container button {
            font-size: 12px;
            border-radius: 2px;
            border: 0;
            background-color: #ddd;
            padding: 13px 18px;
        }
        .main-container button[disabled] {
            color: silver;
        }
        .button-row button {
            display: inline-block;
            margin: 0;
        }
        .overlay {
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(0, 0, 0, 0.3);
            transition: opacity 500ms;
        }
        .popup {
            margin: 70px auto;
            padding: 20px;
            background: #fff;
            border-radius: 5px;
            width: 300px;
            position: relative;
        }
        .popup input, .popup select {
            width: 100%;
            margin: 5px 0 15px;
        }
        .popup button {
            float: right;
            margin-left: 0.2em;
        }
        .popup .clear {
            height: 50px;
        }
        .popup input[type=text], .popup select {
            height: 2em;
            font-size: 16px;
        }
    </style>
    <script src="https://cdn.highcharts.com.cn/gantt/highcharts-gantt.js"></script>
    <script src="https://cdn.highcharts.com.cn/highcharts/modules/draggable-points.js"></script>
    <script src="https://cdn.highcharts.com.cn/highcharts/modules/exporting.js"></script>
</head>
<body>
<div class="main-container">
    <div id="container"></div>
    <div id="buttonGroup" class="button-row">
        <button id="btnShowDialog">
            <i class="fa fa-plus"></i>
            Add task
        </button>
        <button id="btnRemoveSelected" disabled="disabled">
            <i class="fa fa-remove"></i>
            Remove selected
        </button>
    </div>
    <div id="addTaskDialog" class="hidden overlay">
        <div class="popup">
            <h3>Add task</h3>
            <label>Task name <input id="inputName" type="text" /></label>
            <label>Department
                <select id="selectDepartment">
                    <option value="0">Tech</option>
                    <option value="1">Marketing</option>
                    <option value="2">Sales</option>
                </select>
            </label>
            <label>Dependency
                <select id="selectDependency">
                    <!-- Filled in by Javascript -->
                </select>
            </label>
            <label>
                Milestone
                <input id="chkMilestone" type="checkbox" />
            </label>
            <div class="button-row">
                <button id="btnAddTask">Add</button>
                <button id="btnCancelAddTask">Cancel</button>
            </div>
            <div class="clear"></div>
        </div>
    </div>
</div>
<script>
    /*
    Simple demo showing some interactivity options of Highcharts Gantt. More
    custom behavior can be added using event handlers and API calls. See
    http://api.highcharts.com/gantt.
*/
    var today = new Date(),
        day = 1000 * 60 * 60 * 24,
        each = Highcharts.each,
        reduce = Highcharts.reduce,
        btnShowDialog = document.getElementById('btnShowDialog'),
        btnRemoveTask = document.getElementById('btnRemoveSelected'),
        btnAddTask = document.getElementById('btnAddTask'),
        btnCancelAddTask = document.getElementById('btnCancelAddTask'),
        addTaskDialog = document.getElementById('addTaskDialog'),
        inputName = document.getElementById('inputName'),
        selectDepartment = document.getElementById('selectDepartment'),
        selectDependency = document.getElementById('selectDependency'),
        chkMilestone = document.getElementById('chkMilestone'),
        isAddingTask = false;
    // Set to 00:00:00:000 today
    today.setUTCHours(0);
    today.setUTCMinutes(0);
    today.setUTCSeconds(0);
    today.setUTCMilliseconds(0);
    today = today.getTime();
    // Update disabled status of the remove button, depending on whether or not we
    // have any selected points.
    function updateRemoveButtonStatus() {
        var chart = this.series.chart;
        // Run in a timeout to allow the select to update
        setTimeout(function () {
            btnRemoveTask.disabled = !chart.getSelectedPoints().length ||
                isAddingTask;
        }, 10);
    }
    // Create the chart
    var chart = Highcharts.ganttChart('container', {
        chart: {
            spacingLeft: 1
        },
        title: {
            text: 'Interactive Gantt Chart'
        },
        subtitle: {
            text: 'Drag and drop points to edit'
        },
        plotOptions: {
            series: {
                animation: false, // Do not animate dependency connectors
                dragDrop: {
                    draggableX: true,
                    draggableY: true,
                    dragMinY: 0,
                    dragMaxY: 2,
                    dragPrecisionX: day / 3 // Snap to eight hours
                },
                dataLabels: {
                    enabled: true,
                    format: '{point.name}',
                    style: {
                        cursor: 'default',
                        pointerEvents: 'none'
                    }
                },
                allowPointSelect: true,
                point: {
                    events: {
                        select: updateRemoveButtonStatus,
                        unselect: updateRemoveButtonStatus,
                        remove: updateRemoveButtonStatus
                    }
                }
            }
        },
        yAxis: {
            type: 'category',
            categories: ['Tech', 'Marketing', 'Sales'],
            min: 0,
            max: 2
        },
        xAxis: {
            currentDateIndicator: true
        },
        tooltip: {
            xDateFormat: '%a %b %d, %H:%M'
        },
        series: [{
            name: 'Project 1',
            data: [{
                start: today + 2 * day,
                end: today + day * 5,
                name: 'Prototype',
                id: 'prototype',
                y: 0
            },  {
                start: today + day * 6,
                name: 'Prototype done',
                milestone: true,
                dependency: 'prototype',
                id: 'proto_done',
                y: 0
            }, {
                start: today + day * 7,
                end: today + day * 11,
                name: 'Testing',
                dependency: 'proto_done',
                y: 0
            }, {
                start: today + day * 5,
                end: today + day * 8,
                name: 'Product pages',
                y: 1
            }, {
                start: today + day * 9,
                end: today + day * 10,
                name: 'Newsletter',
                y: 1
            }, {
                start: today + day * 9,
                end: today + day * 11,
                name: 'Licensing',
                id: 'testing',
                y: 2
            }, {
                start: today + day * 11.5,
                end: today + day * 12.5,
                name: 'Publish',
                dependency: 'testing',
                y: 2
            }]
        }]
    });
    /* Add button handlers for add/remove tasks */
    btnRemoveTask.onclick = function () {
        var points = chart.getSelectedPoints();
        each(points, function (point) {
            point.remove();
        });
    };
    btnShowDialog.onclick = function () {
        // Update dependency list
        var depInnerHTML = '<option value=""></option>';
        each(chart.series[0].points, function (point) {
            depInnerHTML += '<option value="' + point.id + '">' + point.name +
                ' </option>';
        });
        selectDependency.innerHTML = depInnerHTML;
        // Show dialog by removing "hidden" class
        addTaskDialog.className = 'overlay';
        isAddingTask = true;
        // Focus name field
        inputName.value = '';
        inputName.focus();
    };
    btnAddTask.onclick = function () {
        // Get values from dialog
        var series = chart.series[0],
            name = inputName.value,
            undef,
            dependency = chart.get(
                selectDependency.options[selectDependency.selectedIndex].value
            ),
            y = parseInt(
                selectDepartment.options[selectDepartment.selectedIndex].value,
                10
            ),
            maxEnd = reduce(series.points, function (acc, point) {
                return point.y === y && point.end ? Math.max(acc, point.end) : acc;
            }, 0),
            milestone = chkMilestone.checked || undef;
        // Empty category
        if (maxEnd === 0) {
            maxEnd = today;
        }
        // Add the point
        series.addPoint({
            start: maxEnd + (milestone ? day : 0),
            end: milestone ? undef : maxEnd + day,
            y: y,
            name: name,
            dependency: dependency ? dependency.id : undef,
            milestone: milestone
        });
        // Hide dialog
        addTaskDialog.className += ' hidden';
        isAddingTask = false;
    };
    btnCancelAddTask.onclick = function () {
        // Hide dialog
        addTaskDialog.className += ' hidden';
        isAddingTask = false;
    };
</script>
</body>
