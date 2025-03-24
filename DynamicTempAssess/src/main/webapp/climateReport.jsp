<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>

<%-- java.sun.com --%>
<%@ taglib prefix="f"  uri="http://java.sun.com/jsf/core"%>
<%@ taglib prefix="h"  uri="http://java.sun.com/jsf/html"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="buttonStyles.css" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.9.4/Chart.js"></script>
<title>Cities Climate Diversities</title>

<style>
body{
background-image: url('https://images.pexels.com/photos/1831234/pexels-photo-1831234.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1');
background-attachment: fixed;
background-size: 100% 100%;
}

.topBar{
width:1300px;
height:50px;
margin-left:auto;
margin-right:auto;
background-color:rgba(90, 34, 139, 0.45);
border-top-left-radius:10px;
border-top-right-radius:10px;
}
.topBar > .rgtSubBar{
float:right;
width:60%;
height:70%;
margin-top:0.6%;
background-color:rgba(57, 46, 74, 0.15);
}
.topBar .rgtSubBar .txtBox{
height:70%;
width:30%;
margin-left:100px;
margin-right:0.6%;
border:1px soild grey;
outline:none;
}

.twoPanel{
width:1300px;
height:560px;
margin-left:auto;
margin-right:auto;
background-color:rgba(90, 34, 139, 0.35);
border-bottom-left-radius:10px;
border-bottom-right-radius:10px;
border-top:2px dashed green;
}
.twoPanel > .pGraph, .twoPanel > .wInfo{
width:48%;
height:96%;
background-color:transparent;
margin-top:1%;
}
.twoPanel > .pGraph{
float:left;
}
.twoPanel > .wInfo{
float:right;
background-color:transparent;
overflow-y: hidden;
}
.twoPanel > .wInfo div, .twoPanel > .wInfo #stsCard{
width:100%;
height:75%;
background-color:lightgreen;
border-radius:15px;
overflow-y: auto;
}
.twoPanel > .wInfo div{
background-color:transparent;
}
.twoPanel > .wInfo #stsCard{
height:23%;
background-color:rgba(90, 34, 139, 0.25);
margin-top:1.5%;
overflow: hidden;
}

#tempInfo {
  font-family: Arial, Helvetica, sans-serif;
  border-collapse: collapse;
  width: 100%;
}
#tempInfo td, #tempInfo th {
  border: 1px solid #ddd;
  padding: 8px;
}
#tempInfo tr:nth-child(odd){background-color: #ecd9dd;}
#tempInfo tr:hover {background-color: rgba(236, 217, 221, 0.35);}
#tempInfo th {
  padding-top: 12px;
  padding-bottom: 12px;
  text-align: left;
  background-color: #0b7fab;
  color: white;
} 
</style>
<!-- <script src="https://cdn.jsdelivr.net/npm/chart.js"></script> -->
<script type="text/javascript">

function setup(){
	const getCanvas = document.getElementById("myChart").getContext("2d");
	xItems = [];	yItems = [];	timeSlot = [];
	lstData = document.getElementById('tempInfo');
	
	for(let t=0; t<lstData.rows.length; t++){
		xItems[t]=(t+1);		yItems[t]=parseFloat(lstData.rows[t].cells[3].innerText);
		timeSlot[t]=lstData.rows[t].cells[2].innerText;
	}
	let xyValues = xItems.map((x, index) => ({
		  x: x,
		  y: yItems[index]
	}));
	//[{x:1, y:2},{x:2, y:10},{x:3, y:18},{x:4, y:30},{x:5, y:26},{x:6, y:8},{x:7, y:2}]
	
	new Chart(getCanvas, {
		  type: "line",
		  data: {
			labels: timeSlot,
		    datasets: [{
		      label: 'Temperature Over Time',
		      data: xyValues,
		      pointRadius: 4,
		      pointBackgroundColor: 'blue',
		      pointBorderColor: 'transparent',
		      backgroundColor: 'transparent',
		      borderColor: 'darkcyan',
		      borderWidth: 1
		    }]
		  },
		  options: {
		    legend: {display: true},
		    scales: {},
		    plugins: {
	            legend: {
	                labels: {
	                    color: 'black' // Color for legend text
	                }
	            }
	        }
		  }
		});
}

window.addEventListener('load', setup);
</script>
</head>
<body>

<f:view>
	<h:form id="frm">
	<div class="topBar">
	<div class="rgtSubBar">
	<h:inputText styleClass="txtBox" value="#{GetTemperature.putInfo}"/>
	<h:commandButton value="SEARCH" styleClass="srcItem" action="#{GetTemperature.getSimulated}"/>
	<h:commandButton styleClass="btn1" value="24 Hours" action="#{GetTemperature.getSimulated}"><f:setPropertyActionListener target="#{GetTemperature.limit}" value="6"/></h:commandButton>
	<h:commandButton styleClass="btn1" value="48 Hours" action="#{GetTemperature.getSimulated}"><f:setPropertyActionListener target="#{GetTemperature.limit}" value="5"/></h:commandButton>
	<h:commandButton styleClass="btn1" value="72 Hours" action="#{GetTemperature.getSimulated}"><f:setPropertyActionListener target="#{GetTemperature.limit}" value="4"/></h:commandButton>
	</div>
	
	<h2 align="left" style="line-height:45px;font-family:arial;margin-left:0.6%;">Weather Report</h2>
	</div>
	
	<div class="twoPanel">
	<div class="pGraph">
	<canvas id="myChart" style="width:100%;height:90%;"></canvas>
	</div>
	
	<div class="wInfo">
	<div>
	<table id="tempInfo">
	<tr>
	<th>Index</th>
	<th>Date</th>
	<th>Time</th>
	<th>Value (<sup>o</sup>C)</th>
	<th>Condition</th>
	</tr>
	
	<c:forEach items="#{GetTemperature.report}" var="item">
	<tr>
	<td>1</td>
	<td><h:outputText value="#{item.date}"/></td>
	<td><h:outputText value="#{item.time}"/></td>
	<td><h:outputText value="#{item.tmp}"/></td>
	<td><h:outputText value="#{item.state}"/></td>
	</tr>
	</c:forEach>
	</table>
	</div>
	<!-- Status Card for Weather Overview -->
	<div id="stsCard">
	<h2 align="center" style="line-height:30%;font-family:verdana;">Weather Card</h2>
	<h:outputLabel>
	<pre style="font-family:comic sans ms;">
	Temperature: <h:outputText value="#{GetTemperature.tempCard}"/><sup>o</sup>C	Humidity: <h:outputText value="#{GetTemperature.humidCard}"/>%    Location:<h:outputText value="#{GetTemperature.putInfo}"/>
	Wind Speed: <h:outputText value="#{GetTemperature.windCard}"/>km/h	Pressure: <h:outputText value="#{GetTemperature.pressCard}"/> hPa
	</pre>
	</h:outputLabel>
	</div>
	</div>
	</div>
	</h:form>
</f:view>
</body>
</html>