<script>
//----------------------------------------------------------------------------------------------------
var PairedDistributionsModule = (function () {

  var generatePairedDistributionsDataButton
  var pairedDistributionsDisplay;
  var pairedDistributionsResults;
  var patientClassification;
  var pairedDistributionsSelectedRegion;    // from brushing
  var d3PlotBrush;
  var xMax;
  var pop;
  var x = 0;
  var currentName;
  var currentPopulationForColor;
  var currentColor;
  var storage = [];
  var numberOfSelections = 0;
  var colorCounter = 0;
  var colors = ["green", "blue", "orange", "black", "purple"];
  
  //--------------------------------------------------------------------------------------------
  function initializeUI (){
//       generatePairedDistributionsDataButton =  $("#generatePairedDistributionsDataButton");
//       generatePairedDistributionsDataButton.click(runBasicDemo);//runBasicDemo (run w/o server), runDemo (run w/ server)
      generatePairedDistributionsDataButton =  $("#clearPairedDistributionsButton");
      generatePairedDistributionsDataButton.click(clear);
      pairedDistributionsDisplay = $("#pairedDistributionsDisplay");
      pairedDistributionsHandleWindowResize();
      //pairedDistributionsBroadcastButton = $("#pairedDistributionsBroadcastSelectionToClinicalTable");
      //pairedDistributionsBroadcastButton.button();
      $(window).resize(pairedDistributionsHandleWindowResize);
      //pairedDistributionsBroadcastButton.prop("disabled",true);
      $("#pairedDistributionAboutLink").click(showAbout_pairedDistribution);
      selectionDisplay = $("#pairedDistributionsDiv");
      selector = $("#attributeDropDown");
      selector.chosen({disable_search_threshold: 10});
    };
  //----------------------------------------------------------------------------------------------------
  function showAbout_pairedDistribution(){
        var info = {Modulename: "Paired Distribution",
                     CreatedBy: "Clifford Rostomily",
                     MaintainedBy: "Clifford Rostomily",
                     Folder: "pairedDistributions"}
        about.OpenAboutWindow(info);
    }  
  //----------------------------------------------------------------------------------------------------
  function runBasicDemo(){
  	  console.log("Module.pairedDistributions: runBasicDemo");
  	  var patient = 0;
  	  numberOfSelections ++;
  	  var max = getRandomInt (0, 500);
  	  for(i=0;i<15;i++){
  	 	patient ++;
  	 	var value = Math.random()*max;
  	    storage.push({ID: patient, value: value, name: "pop" + numberOfSelections});
  	    }
  	 d3PairedDistributionsScatterPlot(storage);
      };
  //----------------------------------------------------------------------------------------------------
  function runDemo(){
  	  console.log("Module.pairedDistributions: runDemo");
      requestValues(demoTissues());
      };
  //--------------------------------------------------------------------------------------------
  function demoTissues() {

        // good for copy number and expression changes, but no mutations
      patients = ["TCGA.02.0058", "TCGA.06.0132", "TCGA.02.0034", "TCGA.12.0657", "TCGA.06.0155",
                  "TCGA.06.0155", "TCGA.06.0162", "TCGA.06.1087", "TCGA.12.0778", 
                  "TCGA.14.0871", "TCGA.06.0192"];

        // has about a dozen mutations, much richer than average, with good cn and expression variation too
      patients = ["neutral", "TCGA.06.0125", "TCGA.06.0126", "TCGA.06.0128", "TCGA.06.0130", "TCGA.06.0184",
                  "TCGA.06.0188", "TCGA.06.0221", "TCGA.06.0882", "TCGA.12.0692", "TCGA.76.6282",
                  "TCGA.81.5910"]

      return(patients);
      };
  //--------------------------------------------------------------------------------------------
  function handlePatientIds(msg){
      console.log("Module.pairedDistributions: handlePatientIDs");
      if(msg.status == "success"){
         requestValues(msg.payload.ids);
      }else{
         console.log("handlePatientIDs about to call alert: " + msg)
         alert(msg.payload)
      }
     };
  //----------------------------------------------------------------------------------------------------
  function requestValues(patients){
      console.log("Module.pairedDistributions: requestValues");
      var dropDown = document.getElementById("attributeDropDown");
  	  var attribute = dropDown.value;
      msg = {cmd: "getPatientHistoryDataVector",
             callback:  "handlePatientData",
             status: "request", 
             payload: {colname: attribute, patients: patients}};
      socket.send(JSON.stringify(msg));
     };
  //--------------------------------------------------------------------------------------------
  function handlePatientData(msg){
     console.log("Module.pairedDistributions: handlePatientData");
  	 numberOfSelections ++;
  	 var payload = JSON.parse(msg.payload);
  	 for(i=0;i<Object.keys(payload).length;i++){
  	 	var patient = Object.keys(payload)[i];
  	    storage.push({ID: patient, value: payload[patient], name: "pop" + numberOfSelections});
  	    }
  	 d3PairedDistributionsScatterPlot(storage);
  	 };
  //--------------------------------------------------------------------------------------------
  function pairedDistributionsHandleWindowResize(){
     pairedDistributionsDisplay.width($(window).width() * 0.95);
     pairedDistributionsDisplay.height($(window).height() * 0.80);
     };
  //--------------------------------------------------------------------------------------------
  function pairedDistributionsBroadcastSelection(){
//       console.log("pairedDistributionsBroadcastSelection: " + pairedDistributionsSelectedRegion);
//       x1=pairedDistributionsSelectedRegion[0][0];
//       y1=pairedDistributionsSelectedRegion[0][1];
//       x2=pairedDistributionsSelectedRegion[1][0];
//       y2=pairedDistributionsSelectedRegion[1][1];
//       ids = [];
//       for(var i=0; i < pairedDistributionsResults.length; i++){
//          p = pairedDistributionsResults[i];
//          if(p.PC1 >= x1 & p.PC1 <= x2 & p.PC2 >= y1 & p.PC2 <= y2)
//             ids.push(p.id[0]);
//          } // for i
//       if(ids.length > 0)
//          sendIDsToModule(ids, "PatientHistory", "HandlePatientIDs");
      };
  //--------------------------------------------------------------------------------------------
  function sendIDsToModule(ids, moduleName, title){
//        callback = moduleName + title;
//        msg = {cmd:"sendIDsToModule",
//               callback: callback,
//               status:"request",
//               payload:{targetModule: moduleName,
//                        ids: ids}
//              };
//       socket.send(JSON.stringify(msg));
      };
  //--------------------------------------------------------------------------------------------
  function addToStorage(msg){
      storage.push(msg);
      console.log("STORAGE ==== ")
      console.log(storage);
      d3PairedDistributionsScatterPlot(storage);
     };
  //--------------------------------------------------------------------------------------------
  function clear(){
      storage = [];
      numberOfSelections = 0;
      colorCounter = 0;
      d3.select("#pairedDistributionsSVG").remove()
     };
  //--------------------------------------------------------------------------------------------
  function d3PlotBrushReader(){
     console.log("plotBrushReader");
     pairedDistributionsSelectedRegion = d3PlotBrush.extent();
     //console.log("region: " + pairedDistributionsSelectedRegion);
     x0 = pairedDistributionsSelectedRegion[0][0];
     x1 = pairedDistributionsSelectedRegion[1][0];
     width = Math.abs(x0-x1);
     //console.log("width: " + width);
     if(width > 1)
        pairedDistributionsBroadcastButton.prop("disabled", false);
     else
        pairedDistributionsBroadcastButton.prop("disabled", true);
     };
  //-------------------------------------------------------------------------------------------
  function chooseColor(d){
     id = d;
     for(var i=0; i<patientClassification.length; i++){
        if (id == patientClassification[i].rowname[0]){
          result = patientClassification[i].color[0]
          return(result)
          } // if match
        } // for i
     console.log("chooseColor, no match for id " + id);
     return("black");
     };
  //-------------------------------------------------------------------------------------------   
  function getX(data){
  	if(pop!=null&&pop!=data.name){
  		x = x + xMax/numberOfSelections
  		}
  	pop = data.name;
  	return ((Math.random() * (xMax/numberOfSelections-xMax/(4*numberOfSelections)))) + x + xMax/(8*numberOfSelections);
  };
  //-------------------------------------------------------------------------------------------   
  function getNameX(){
  	x = x + xMax/numberOfSelections 
  	return (x + xMax/(2*numberOfSelections));
  };
  //-------------------------------------------------------------------------------------------   
  function getName(name){
  	return ("Population" + " " + name);
  };
  //------------------------------------------------------------------------------------------- 
  function getValues(data){
  	var values = [];
  	for(i = 0; i < data.values.length; i++){
		var array1 = data[i].values;
		values = values.concat(array1);
	}
	return values;
  };
  //-------------------------------------------------------------------------------------------   
  function getColor(population){
  	//console.log("called");
  	if(currentPopulationForColor!=(population.name)||currentPopulationForColor==null){
  		currentColor = colors[colorCounter];
  		if(colorCounter<4){
  		   colorCounter ++;
  		}else{
  		   colorCounter = 0;
        }
    	currentPopulationForColor = population.name;
    }
    return currentColor;
  };
  //-------------------------------------------------------------------------------------------
  function d3PairedDistributionsScatterPlot(data) {
    //pairedDistributionsBroadcastButton.prop("disabled",true);
    
    var padding = 50;
    var width = $("#pairedDistributionsDisplay").width();
    var height = $("#pairedDistributionsDisplay").height();

    var max = d3.max(data, function(d) { return +d.value;});
    xMax = 40
    xMin = 0
    yMax = max * 1.1
    yMin = 0
        // select our svg by identifier, remove it
    d3.select("#pairedDistributionsSVG").remove()

        //flip axis
    var xScale = d3.scale.linear()
                    .domain([xMin,xMax])
                    .range([padding, width - padding]);

    var yScale = d3.scale.linear()
                    .domain([yMin, yMax])
                    .range([height - padding, padding]); // note inversion
                     
    var yNameScale = d3.scale.linear()
                    .domain([yMin, yMax])
                    .range([height - padding/2, padding]); // note inversion 


    var xAxis = d3.svg.axis()
                   .scale(xScale)
                   .orient("bottom")
                   .ticks(0);

    var yAxis = d3.svg.axis()
                   .scale(yScale)
                   .orient("left")
                   .ticks(10);


    d3PlotBrush = d3.svg.brush()
        .x(xScale)
        .y(yScale)
        .on("brushend", d3PlotBrushReader);

    var svg = d3.select("#pairedDistributionsDisplay")
                 .append("svg")
                 .attr("id", "pairedDistributionsSVG")
                 .attr("width", width)
                 .attr("height", height)
                 .call(d3PlotBrush);

    var tooltip = d3.select("body")
                     .attr("class", "tooltip")
                     .append("div")
                     .style("position", "absolute")
                     .style("z-index", "10")
                     .style("visibility", "hidden")
                     .text("a simple tooltip");
	
    var circle = svg.selectAll("circle")
        			.data(data)
   					.enter()
   					.append("circle")
   					.attr("cx", function(d) {return xScale(getX(d));})
   					.attr("cy", function(d) {return yScale(d.value);})
   					.attr("r", 3)
                    .style("fill", function(d){if(d.value==null){return "red"}else{return getColor(d)};})
                 	.on("mouseover", function(d){tooltip.text(d.ID);
                 	                             return tooltip.style("visibility", "visible");})
                	.on("mousemove", function(){return tooltip.style("top",
                           (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                	.on("mouseout", function(){return tooltip.style("visibility", "hidden");});
                	
                	
    x = -xMax/numberOfSelections;
    pop = null;
    currentPopulationForColor = null;
    currentColor = null;
    colorCounter = 0;
    
    var texts = svg.selectAll("text")
                .data(data)
                .enter();

	for(i=0;i<numberOfSelections;i++){
		texts.append("text")
    		.text(getName(i + 1))
    		.attr("y",yNameScale(0))
        	.attr("x", xScale(getNameX()))
        	.attr("font-size",15)
        	.attr("text-anchor","middle")
        	.attr("fill","black");
        }
     
     currentName = null;
     x = 0;

      
     var xTranslationForYAxis = xScale(0);
     var yTranslationForXAxis = yScale(0);

     svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0, " + yTranslationForXAxis + ")")
        .call(xAxis);

     svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + xTranslationForYAxis + ", 0)")
        .call(yAxis);

     };
   //--------------------------------------------------------------------------------------------
  return{
   init: function(){
      onReadyFunctions.push(initializeUI);
      addSelectionDestination("Distributions", "pairedDistributionsDiv");
      addJavascriptMessageHandler("DistributionsHandlePatientIDs", handlePatientIds);
      addJavascriptMessageHandler("handlePatientData", handlePatientData);
      //socketConnectedFunctions.push(runDemo);
      }
   };

}); // PairedDistributionsModule
//----------------------------------------------------------------------------------------------------
pairedDistributions = PairedDistributionsModule();
pairedDistributions.init();

</script>