<script>
//----------------------------------------------------------------------------------------------------
var PairedDistributionsModule = (function () {

  var generateRandomPairedDistributionsDataButton
  var pairedDistributionsDisplay;
  var pairedDistributionsResults;
  var patientClassification;
  var firstTime = true;
  var pairedDistributionsSelectedRegion;    // from brushing
  var d3PlotBrush;
  var numberOfPopulations;
  var xMax;
  var pop;
  var x = 0;
  var currentName;
  var nameCount = 0;
  var currentPopulationForColor;
  var currentColor;
  

  //--------------------------------------------------------------------------------------------
  function initializeUI (){
      generateRandomPairedDistributionsDataButton =  $("#generateRandomPairedDistributionsDataButton");
      generateRandomPairedDistributionsDataButton.click(requestRandomPairedDistributions);

      pairedDistributionsDisplay = $("#pairedDistributionsDisplay");
      pairedDistributionsHandleWindowResize();
      pairedDistributionsBroadcastButton = $("#pairedDistributionsBroadcastSelectionToClinicalTable");
      //pairedDistributionsBroadcastButton.button();
      $(window).resize(pairedDistributionsHandleWindowResize);
      pairedDistributionsBroadcastButton.prop("disabled",true);
      $("#pairedDistributionAboutLink").click(showAbout_pairedDistribution)
    };

   //----------------------------------------------------------------------------------------------------
    function showAbout_pairedDistribution(){
  
          var   info ={Modulename: "Paired Distribution",
                    CreatedBy: "Cliff Rostomily",
                    MaintainedBy: "Cliff Rostomily",
                    Folder: "pairedDistributions"}

         about.OpenAboutWindow(info) ;
    }  

  //--------------------------------------------------------------------------------------------
  function requestRandomPairedDistributions(){
  	 var dropDown = document.getElementById('numberOfPopulationDropDown');
  	 numberOfPopulations = dropDown.options[dropDown.selectedIndex].text;
  	 console.log("Number of Populations: " + numberOfPopulations);
     msg = {cmd: "calculatePairedDistributionsOfPatientHistoryData",
            callback:  "pairedDistributionsPlot",
            status: "request", 
            payload: {mode:"test", attribute:"FirstProgression", popCount: numberOfPopulations}};

     socket.send(JSON.stringify(msg));
     };

  //--------------------------------------------------------------------------------------------
  function runDemo(){
     requestRandomPairedDistributions();
     };

  //--------------------------------------------------------------------------------------------
  function getPatientClassification(){
     payload = "";
     msg = {cmd: "getPatientClassification", callback: "handlePatientClassification", 
            status: "request", payload: payload};
     socket.send(JSON.stringify(msg));
     };

  //--------------------------------------------------------------------------------------------
  function handlePatientClassification(msg){
     console.log("=== handlePatientClassification");
     if(msg.status == "success"){
        patientClassification = JSON.parse(msg.payload)
        console.log("got classification, length " + patientClassification.length);
        }
     else{
       alert("error!" + msg.payload)
       }
      }; // handlePatientIDs

  //--------------------------------------------------------------------------------------------
  function pairedDistributionsHandleWindowResize(){
     pairedDistributionsDisplay.width($(window).width() * 0.95);
     pairedDistributionsDisplay.height($(window).height() * 0.80);
     if(!firstTime) {d3PairedDistributionsScatterPlot(pairedDistributionsResults);}
     };

   //--------------------------------------------------------------------------------------------
   function pairedDistributionsBroadcastSelection(){
      console.log("pairedDistributionsBroadcastSelection: " + pairedDistributionsSelectedRegion);
      x1=pairedDistributionsSelectedRegion[0][0];
      y1=pairedDistributionsSelectedRegion[0][1];
      x2=pairedDistributionsSelectedRegion[1][0];
      y2=pairedDistributionsSelectedRegion[1][1];
      ids = [];
      for(var i=0; i < pairedDistributionsResults.length; i++){
         p = pairedDistributionsResults[i];
         if(p.PC1 >= x1 & p.PC1 <= x2 & p.PC2 >= y1 & p.PC2 <= y2)
            ids.push(p.id[0]);
         } // for i
      if(ids.length > 0)
         sendIDsToModule(ids, "PatientHistory", "HandlePatientIDs");
      };

  //--------------------------------------------------------------------------------------------
  function sendIDsToModule(ids, moduleName, title){
       callback = moduleName + title;
       msg = {cmd:"sendIDsToModule",
              callback: callback,
              status:"request",
              payload:{targetModule: moduleName,
                       ids: ids}
             };
      socket.send(JSON.stringify(msg));
      }; // sendTissueIDsToModule


  //--------------------------------------------------------------------------------------------
  function pairedDistributionsPlot(msg){
      console.log("==== pairedDistributionsPlot");
      console.log(msg.payload);
      if(msg.status == "success"){
         pairedDistributionsResults = msg.payload;
         d3PairedDistributionsScatterPlot(pairedDistributionsResults);
         // tab activation not needed here - pshannon (7 aug 2014)
         //tabIndex = $('#tabs a[href="#pairedDistributionsDiv"]').parent().index();
         //if(!firstTime)  // first call comes at startup.  do not want to raise tab then.
         //    $("#tabs").tabs( "option", "active", tabIndex);
         } // success
    else{
      console.log("pairedDistributionsPlot about to call alert: " + msg)
      alert(msg.payload)
      }
     firstTime = false;
     };

  //--------------------------------------------------------------------------------------------
  function handlePatientIDs(msg){
      console.log("Module.pairedDistributions: handlePatientIDs");
      //console.log(msg)
      if(msg.status == "success"){
         patientIDs = msg.payload
         //console.log("pairedDistributions handlePatientIds: " + patientIDs);
         payload = patientIDs
         msg = {cmd: "calculate_mRNA_PairedDistributions", callback: "pairedDistributionsPlot", status: "request", 
                payload: payload};
         socket.send(JSON.stringify(msg));
         }
    else{
      console.log("handlePatientIDs about to call alert: " + msg)
      alert(msg.payload)
      }
     }; // handlePatientIDs

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
     }; // d3PlotBrushReader

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
  getX = function(data){
  	if(pop!=null&&pop!=data.name){
  		x = x + xMax/numberOfPopulations
  		}
  	pop = data.name;
  	return ((Math.random() * (xMax/numberOfPopulations-xMax/(4*numberOfPopulations)))) + x + xMax/(8*numberOfPopulations);
  };
  //-------------------------------------------------------------------------------------------   
  getNameX = function(){
  	x = x + xMax/numberOfPopulations 
  	return (x + xMax/(2*numberOfPopulations));
  };
  //-------------------------------------------------------------------------------------------   
  getName = function(name){
  	return ("Population" + " " + name);
  };
  //------------------------------------------------------------------------------------------- 
  getValues = function(data){
  	var values = [];
  	for(i = 0; i < data.values.length; i++){
		var array1 = data[i].values;
		values = values.concat(array1);
	}
	return values;
  };
  //-------------------------------------------------------------------------------------------   
  getColor = function(population){
  	//console.log("called");
  	if(currentPopulationForColor!=(population.name)||currentPopulationForColor==null){
  		var letters = '0123456789ABCDEF'.split('');
    	currentColor = '#';
    	for (var i = 0; i < 6; i++ ) {
        currentColor += letters[Math.floor(Math.random() * 16)];
    	}
    	//console.log("switched color");
    	currentPopulationForColor = population.name;
    }
    return currentColor;
  };
  //-------------------------------------------------------------------------------------------
  function d3PairedDistributionsScatterPlot(data) {

    pairedDistributionsBroadcastButton.prop("disabled",true);
    var padding = 50;
    var width = $("#pairedDistributionsDisplay").width();
    var height = $("#pairedDistributionsDisplay").height();

	var max = d3.max(data, function(d) { return +d.value;} );
    xMax = 40
    xMin = 0
    yMax = max * 1.1
    yMin = -10

        // select our svg by identifier, remove it
    d3.select("#pairedDistributionsSVG").remove()

        //flip axis
    var xScale = d3.scale.linear()
                    .domain([xMin,xMax])
                    .range([padding, width - padding]);

    var yScale = d3.scale.linear()
                    .domain([yMin, yMax])
                    .range([height - padding, padding]); // note inversion 

    var xAxis = d3.svg.axis()
                   .scale(xScale)
                   .orient("bottom")
                   .ticks(0);

    var yAxis = d3.svg.axis()
                   .scale(yScale)
                   .orient("left")
                   .ticks(5);


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

    var tooltip = svg
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
                    .style("fill", function(d){return getColor(d);})
                 	.on("mouseover", function(d,i){tooltip.text(d.ID); return tooltip.style("visibility", "visible");})
                	.on("mousemove", function(){return tooltip.style("top",
                           (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                	.on("mouseout", function(){return tooltip.style("visibility", "hidden");});
                	
                	
    x = -xMax/numberOfPopulations;
    pop = null;
    currentPopulationForColor = null;
    currentColor = null;
    
    var texts = svg.selectAll("text")
                .data(data)
                .enter();

	for(i=0;i<numberOfPopulations;i++){
		texts.append("text")
    		.text(getName(i + 1))
    		.attr("y",yScale(-5))
        	.attr("x", xScale(getNameX()))
        	.attr("font-size",15)
        	.attr("font-family","serif")
        	.attr("text-anchor","middle");
        }
     
     currentName = null;
     nameCount = 0;
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

     }; // d3PairedDistributionsScatterPlot

//----------------------------------------------------------------------------------------------------
    function SetModifiedDate(){

        msg = {cmd:"getModuleModificationDate",
             callback: "DisplaypairedDistributionsModifiedDate",
             status:"request",
             payload:"pairedDistributions"
             };
        msg.json = JSON.stringify(msg);
        socket.send(msg.json);
    }
//----------------------------------------------------------------------------------------------------
    function DisplaypairedDistributionsModifiedDate(msg){
        document.getElementById("pairedDistributionsDateModified").innerHTML = msg.payload;
    }



  //--------------------------------------------------------------------------------------------
  return{
   init: function(){
      onReadyFunctions.push(initializeUI);
      addJavascriptMessageHandler("pairedDistributionsPlot", pairedDistributionsPlot);
      //addJavascriptMessageHandler("PairedDistributionsHandlePatientIDs", handlePatientIDs);
      //addJavascriptMessageHandler("handlePatientClassification", handlePatientClassification)
      //socketConnectedFunctions.push(getPatientClassification);
      addJavascriptMessageHandler("DisplaypairedDistributionsModifiedDate", DisplaypairedDistributionsModifiedDate);
      socketConnectedFunctions.push(SetModifiedDate);

      socketConnectedFunctions.push(runDemo);
      }
   };

}); // PairedDistributionsModule
//----------------------------------------------------------------------------------------------------
pairedDistributions = PairedDistributionsModule();
pairedDistributions.init();

</script>