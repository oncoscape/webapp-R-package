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
  var popX = 0;
  var currentName;
  var currentPopulationForColor;
  var currentColor;
  var storage = [];
  var prevStorageLength = 0;
  var numberOfSelections = 0;
  var colorCounter = 0;
  var colors = ["green", "blue", "orange", "black", "purple"];
  var dataRequests = [];
  var itemRequesting = 0;
  var DistributionsSendSelectionMenu;
  var ThisModuleName = "Distributions";
  var d3pairedDistributionsDisplay;
  
  
  
  
  //--------------------------------------------------------------------------------------------
  function initializeUI (){
//       generatePairedDistributionsDataButton =  $("#generatePairedDistributionsDataButton");
//       generatePairedDistributionsDataButton.click(runBasicDemo);//runBasicDemo (run w/o server), runDemo (run w/ server)
      generatePairedDistributionsDataButton =  $("#clearPairedDistributionsButton");
      generatePairedDistributionsDataButton.click(clear);
//       pairedDistributionsBroadcastSelectionButton =  $("#pairedDistributionsBroadcastSelectionButton");
//       pairedDistributionsBroadcastSelectionButton.click(pairedDistributionsBroadcastSelection);

      pairedDistributionsDisplay = $("#pairedDistributionsDisplay");
      d3pairedDistributionsDisplay = d3.select("#pairedDistributionsDisplay");
      pairedDistributionsHandleWindowResize();
      $(window).resize(pairedDistributionsHandleWindowResize);
      $("#pairedDistributionAboutLink").click(showAbout_pairedDistribution);
      
      selectionDisplay = $("#pairedDistributionsDiv");
      selector = $("#attributeDropDown");
      selector.chosen({disable_search_threshold: 2,
                       width: "50%"});
      selector.chosen().change(replot);
      
      DistributionssendSelectionMenu = $("#DistributionSendSelectiontoModuleButton")
      DistributionssendSelectionMenu.change(sendToModuleChanged);
      DistributionssendSelectionMenu.empty();    
      DistributionssendSelectionMenu.append("<option>Send Selection to:</option>")
      var ModuleNames = getSelectionDestinations();
      console.log("MODULE NAMES:");
      console.log(ModuleNames);
      for(var i=0;i< ModuleNames.length; i++){
          if(ModuleNames[i] != ThisModuleName){
             console.log("adding next")
             var optionMarkup = "<option>" + ModuleNames[i] + "</option>";
             DistributionssendSelectionMenu.append(optionMarkup);
           }
        }  
        
      pValueSelect = $("#DistributionPValue");
      pValueSelect.chosen({max_selected_options: 2});
      pValueSelect.chosen().change(tTest);
      pValueDisplay = $("#pValueDisplay");
      
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
      	 numberOfSelections ++;
      	 '<option value="foo">Bar</option>'
      	 pValueSelect.append("<option value=pop" + numberOfSelections + ">Population " + numberOfSelections + "</option>");
      	 pValueSelect.trigger("chosen:updated");
         requestValues(msg.payload.ids);
      }else{
         console.log("handlePatientIDs about to call alert: " + msg)
         alert(msg.payload)
      }
     };
  //----------------------------------------------------------------------------------------------------
  function requestValues(patients){
      console.log("Module.pairedDistributions: requestValues");
      //var dropDown = document.getElementById("attributeDropDown");
  	  //var attribute = dropDown.value;
  	  var requests = ["ageAtDx", "FirstProgression", "survival"];
  	  //console.log("request: " + requests[itemRequesting]);
  	  //for (i=0;i<requests.length;i++){
          msg = {cmd: "getPatientHistoryDataVector",
                 callback:  "handlePatientData",
                 status: "request", 
                 payload: {colname: requests[itemRequesting], patients: patients}};
          socket.send(JSON.stringify(msg));
        //  }
     };
  //--------------------------------------------------------------------------------------------
  function handlePatientData(msg){
     console.log("Module.pairedDistributions: handlePatientData");
  	 var payload = JSON.parse(msg.payload);
  	 
  	 switch(itemRequesting){
        case 1:
           for(i=0;i<Object.keys(payload).length;i++){
  	 	      var patient = Object.keys(payload)[i];
  	          storage[i + prevStorageLength].FirstProgression = payload[patient];
  	       }
           break;
        case 2:
           for(i=0;i<Object.keys(payload).length;i++){
  	 	      var patient = Object.keys(payload)[i];
  	          storage[i + prevStorageLength].survival = payload[patient];
  	       }
           break;
     default:
        for(i=0;i<Object.keys(payload).length;i++){
  	 	   var patient = Object.keys(payload)[i];
  	       storage.push({ID: patient, ageAtDx: payload[patient], name: "pop" + numberOfSelections});
  	       }
  	    break;
        }
  	    
  	 if(itemRequesting<2){
  	    itemRequesting++;
  	    requestValues(Object.keys(payload));
  	 }else{
  	    itemRequesting = 0;
  	    prevStorageLength = storage.length;
  	    d3PairedDistributionsScatterPlot(storage);
  	    }
  	 };
  	 
  //--------------------------------------------------------------------------------------------
  function replot(){
     if(numberOfSelections>0){
        d3PairedDistributionsScatterPlot(storage);
        }
     };
  //--------------------------------------------------------------------------------------------
  function pairedDistributionsHandleWindowResize(){
     pairedDistributionsDisplay.width($(window).width() * 0.95);
     pairedDistributionsDisplay.height($(window).height() * 0.80);
     };
  //----------------------------------------------------------------------------------------------------
  function sendToModuleChanged() {
      ModuleName = DistributionssendSelectionMenu.val();
      DistributionsBroadcastSelection();
      DistributionssendSelectionMenu.val("Send Selection to:");
    }; // sendToModuleChanged
  //--------------------------------------------------------------------------------------------
  function DistributionsBroadcastSelection(){
      var dropDown = document.getElementById("attributeDropDown");
  	  var attribute = dropDown.value;
  	  
      console.log("pairedDistributionsBroadcastSelection: " + pairedDistributionsSelectedRegion);
      x1=pairedDistributionsSelectedRegion[0][0];
      y1=pairedDistributionsSelectedRegion[0][1];
      x2=pairedDistributionsSelectedRegion[1][0];
      y2=pairedDistributionsSelectedRegion[1][1];
          
      var ids = [];    
      for(var i=0; i < storage.length; i++){
         p = storage[i];
         if(p.x >= x1 & p.x <= x2 & p[attribute] >= y1 & p[attribute] <= y2)
            ids.push(p.ID);
         } // for i
      console.log(ids);
      
      var settings = {x: [x1, x2], y: [y1, y2]}
      var metadata = {"Tab": "Distributions",
                      "Settings": settings }
      if(ids.length > 0){
          sendSelectionToModule(ModuleName, ids, metadata);
      }
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
      prevStorageLength = 0;
      numberOfSelections = 0;
      colorCounter = 0;
      pValueSelect.find('option').remove().end();
      pValueSelect.trigger("chosen:updated");
      d3.select("#pairedDistributionsSVG").remove()
     };
  //--------------------------------------------------------------------------------------------
  function tTest(){
      console.log("Module.pairedDistributions: tTest");
      var select = document.getElementById("DistributionPValue");
      var tTestPopulations = Array.prototype.filter.call(select.options, function(el) {return el.selected;}).map(function(el) {return el.value;});
      if(tTestPopulations.length>1){
         var dropDown = document.getElementById("attributeDropDown");
  	     var attribute = dropDown.value;
  	     var pop1 = tTestPopulations[0];
  	     var pop2 = tTestPopulations[1];
  	     
  	     var pop1Values = [];
  	     var pop2Values = [];
  	     
  	     for(i=0;i<storage.length;i++){
  	        if (storage[i]["name"] == pop1){
  	           pop1Values.push(storage[i][attribute]);
  	           }
  	        if (storage[i]["name"] == pop2){
  	           pop2Values.push(storage[i][attribute]);
  	           }
  	        }
  	     
         msg = {cmd: "tTest",
                callback:  "handlePValue",
                status: "request", 
                payload: {pop1: pop1Values, pop2: pop2Values}
                };
         socket.send(JSON.stringify(msg));
            //get p value
         }
      };
  //--------------------------------------------------------------------------------------------
  function handlePValue(msg){
      console.log("Module.pairedDistributions: handlePValue");
      console.log(msg);
      pValueDisplay.text(msg.payload);
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
//      if(width > 1)
//         pairedDistributionsBroadcastButton.prop("disabled", false);
//      else
//         pairedDistributionsBroadcastButton.prop("disabled", true);
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
  function getX(data, i){
  	if(pop!=null&&pop!=data.name){
  		popX = popX + xMax/numberOfSelections
  		}
  	pop = data.name;
  	if(numberOfSelections>5){
  	   var x = ((Math.random() * (xMax/numberOfSelections-xMax/(4*numberOfSelections)))) + popX + xMax/(8*numberOfSelections);
  	}else if(numberOfSelections==5){
  	   var x = ((Math.random() * (xMax/numberOfSelections-xMax/(2.5*numberOfSelections)))) + popX + xMax/(6*numberOfSelections);
  	}else if(numberOfSelections==4){
  	   var x = ((Math.random() * (xMax/numberOfSelections-xMax/(1.75*numberOfSelections)))) + popX + xMax/(3.5*numberOfSelections);
  	}else if(numberOfSelections==3){
  	   var x = ((Math.random() * (xMax/numberOfSelections-xMax/(1.5*numberOfSelections)))) + popX + xMax/(3*numberOfSelections);
  	}else if(numberOfSelections==2){
  	   var x = ((Math.random() * (xMax/numberOfSelections-xMax/(1.25*numberOfSelections)))) + popX + xMax/(2.5*numberOfSelections);
  	}else if(numberOfSelections==1){
  	   var x = ((Math.random() * (xMax/numberOfSelections-xMax/(1.125*numberOfSelections)))) + popX + xMax/(2.25*numberOfSelections);
  	}else{
  	   var x = 0;
  	   }
  	storage[i].x = x;
  	return x;
  };
  //-------------------------------------------------------------------------------------------   
  function getNameX(){
  	popX = popX + xMax/numberOfSelections 
  	return (popX + xMax/(2*numberOfSelections));
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
    
    var dropDown = document.getElementById("attributeDropDown");
  	var attribute = dropDown.value;
  	
  	console.log("storage");
  	console.log(data);
  	
  	
    
    var padding = 50;
    var width = $("#pairedDistributionsDisplay").width();
    var height = $("#pairedDistributionsDisplay").height();

    var max = d3.max(data, function(d) { return +d[attribute];});
    xMax = 40
    xMin = 0
    yMax = max * 1.1
    yMin = 0
        // select our svg by identifier, remove it
    //d3pairedDistributionsDisplay.remove()
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
                    .range([height - padding/2, padding]); 


    var xAxis = d3.svg.axis()
                   .scale(xScale)
                   .orient("bottom")
                   .ticks(0);

    var yAxis = d3.svg.axis()
                   .scale(yScale)
                   .orient("left")
                   .ticks(10);

    var tooltip = d3.select("body")
                     .attr("class", "tooltip")
                     .append("div")
                     .style("position", "absolute")
                     .style("z-index", "10")
                     .style("visibility", "hidden")
                     .text("a simple tooltip");
                     
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
	
    var circle = svg.selectAll("circle")
        			.data(data)
   					.enter()
   					.append("circle")
   					.attr("cx", function(d, i) {return xScale(getX(d, i));})
   					.attr("cy", function(d) {return yScale(d[attribute]);})
   					.attr("r", 3)
                    .style("fill", function(d){if(d[attribute]==null){return "red"}else{return getColor(d)};})
                 	.on("mouseover", function(d){tooltip.text(d.ID);
                 	                             return tooltip.style("visibility", "visible");})
                	.on("mousemove", function(){return tooltip.style("top",
                           (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                	.on("mouseout", function(){return tooltip.style("visibility", "hidden");});
                	                	
    popX = -xMax/numberOfSelections;
    pop = null;
    currentPopulationForColor = null;
    currentColor = null;
    colorCounter = 0;
    

	for(i=0;i<numberOfSelections;i++){
		svg.append("text")
    		.text(getName(i + 1))
    		.attr("y",yNameScale(0))
        	.attr("x", xScale(getNameX()))
        	.attr("font-size",15)
        	.attr("text-anchor","middle")
        	.attr("fill","black");
        }
     
     currentName = null;
     popX = 0;

     };
   //--------------------------------------------------------------------------------------------
  return{
   init: function(){
      onReadyFunctions.push(initializeUI);
      addSelectionDestination("Distributions", "pairedDistributionsDiv");
      addJavascriptMessageHandler("DistributionsHandlePatientIDs", handlePatientIds);
      addJavascriptMessageHandler("handlePatientData", handlePatientData);
      addJavascriptMessageHandler("tTest", handlePValue);
      //socketConnectedFunctions.push(runDemo);
      }
   };

}); // PairedDistributionsModule
//----------------------------------------------------------------------------------------------------
pairedDistributions = PairedDistributionsModule();
pairedDistributions.init();

</script>