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

  //--------------------------------------------------------------------------------------------
  initializeUI = function(){
      generateRandomPairedDistributionsDataButton =  $("#generateRandomPairedDistributionsDataButton");
      generateRandomPairedDistributionsDataButton.click(requestRandomPairedDistributions);

      pairedDistributionsDisplay = $("#pairedDistributionsDisplay");
      pairedDistributionsHandleWindowResize();
      pairedDistributionsBroadcastButton = $("#pairedDistributionsBroadcastSelectionToClinicalTable");
      //pairedDistributionsBroadcastButton.button();
      $(window).resize(pairedDistributionsHandleWindowResize);
      pairedDistributionsBroadcastButton.prop("disabled",true);
      };

  //--------------------------------------------------------------------------------------------
  requestRandomPairedDistributions = function(){
     msg = {cmd: "calculatePairedDistributionsOfPatientHistoryData",
            callback:  "pairedDistributionsPlot",
            status: "request", 
            payload: {mode:"test", attribute:"FirstProgression"}};

     socket.send(JSON.stringify(msg));
     };

  //--------------------------------------------------------------------------------------------
  runDemo = function(){
     requestRandomPairedDistributions();
     };

  //--------------------------------------------------------------------------------------------
  getPatientClassification = function(){
     payload = "";
     msg = {cmd: "getPatientClassification", callback: "handlePatientClassification", 
            status: "request", payload: payload};
     socket.send(JSON.stringify(msg));
     };

  //--------------------------------------------------------------------------------------------
  handlePatientClassification = function(msg){
     console.log("=== handlePatientClassification");
     //console.log(msg)
     if(msg.status == "success"){
        patientClassification = JSON.parse(msg.payload)
        console.log("got classification, length " + patientClassification.length);
        }
     else{
       alert("error!" + msg.payload)
       }
      }; // handlePatientIDs

  //--------------------------------------------------------------------------------------------
  pairedDistributionsHandleWindowResize = function(){
     pairedDistributionsDisplay.width($(window).width() * 0.95);
     pairedDistributionsDisplay.height($(window).height() * 0.80);
     if(!firstTime) {d3PairedDistributionsScatterPlot(pairedDistributionsResults);}
     };

   //--------------------------------------------------------------------------------------------
   pairedDistributionsBroadcastSelection = function(){
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
  sendIDsToModule = function(ids, moduleName, title){
       callback = moduleName + title;
       msg = {cmd:"sendIDsToModule",
              callback: callback,
              status:"request",
              payload:{targetModule: moduleName,
                       ids: ids}
             };
      socket.send(JSON.stringify(msg));
      } // sendTissueIDsToModule


  //--------------------------------------------------------------------------------------------
  pairedDistributionsPlot = function(msg){
      console.log("==== pairedDistributionsPlot");
      console.log(msg);
      //if(msg.status == "success"){
      //   pairedDistributionsResults = JSON.parse(msg.payload);
      //   d3PairedDistributionsScatterPlot(pairedDistributionsResults);
      //   if(!firstTime)  // first call comes at startup.  do not want to raise tab then.
      //       $("#tabs").tabs( "option", "active", 1);
      //   } // success
    //else{
    //  console.log("pairedDistributionsPlot about to call alert: " + msg)
    //  alert(msg.payload)
    //  }
    // firstTime = false;
     };

  //--------------------------------------------------------------------------------------------
  handlePatientIDs = function(msg){
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
  d3PlotBrushReader = function(){
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
  chooseColor = function(d){
     id = d.id[0];
     for(var i=0; i<patientClassification.length; i++){
        if (id == patientClassification[i].rowname[0]){
          result = patientClassification[i].color[0]
          return(result)
          } // if match
        } // for i
     console.log("chooseColor, no match for id " + id);
     return("black");
     }
  //-------------------------------------------------------------------------------------------
  d3PairedDistributionsScatterPlot = function(dataset) {

     pairedDistributionsBroadcastButton.prop("disabled",true);
     var padding = 50;
     var width = $("#pairedDistributionsDisplay").width();
     var height = $("#pairedDistributionsDisplay").height();

     var xMax = d3.max(dataset, function(d) { return +d.PC1;} );
     var xMin = d3.min(dataset, function(d) { return +d.PC1;} );
     var yMax = d3.max(dataset, function(d) { return +d.PC2;} );
     var yMin = d3.min(dataset, function(d) { return +d.PC2;} );
 
       // todo:  after finding min and max, determine largest of each axis in abs value
       // todo:  then find next larger even number, use that throughout
     
     xMax = xMax * 1.1
     xMin = xMin * 1.1
     xMax = 40
     xMin = -40
     yMax = 30
     yMin = -30

     //console.log("xMax: " + xMax);   console.log("xMin: " + xMin);
     //console.log("yMax: " + yMax);   console.log("yMin: " + yMin);

     d3.select("svg").remove();  // so that append("svg") is not cumulative

     var xScale = d3.scale.linear()
                    .domain([xMin,xMax])
                    .range([padding, width - padding]);

     var yScale = d3.scale.linear()
                    .domain([yMin, yMax])
                    .range([height - padding, padding]); // note inversion 

     var xAxis = d3.svg.axis()
                   .scale(xScale)
                   .orient("bottom")
                   .ticks(5);

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
                     .data(dataset)
                     .enter()
                     .append("circle")
                     .attr("cx", function(d,i) {return xScale(d.PC1);})
                     .attr("cy", function(d,i) {return yScale(d.PC2);})
                     .attr("r", function(d) { return 3;})
                     .style("fill", function(d) {return(chooseColor(d))})
                     //.style("fill", function(d) { return "blue"})
                     .on("mouseover", function(d,i){
                         tooltip.text(d.id);
                         return tooltip.style("visibility", "visible");
                         })
                    .on("mousemove", function(){return tooltip.style("top",
                           (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                    .on("mouseout", function(){return tooltip.style("visibility", "hidden");});
      
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

     //svg.append("g")
     //   .attr("class", "brush")
     //   .call(d3PlotBrush);

     } // d3PairedDistributionsScatterPlot


  //--------------------------------------------------------------------------------------------
  return{
   init: function(){
      onReadyFunctions.push(initializeUI);
      addJavascriptMessageHandler("pairedDistributionsPlot", pairedDistributionsPlot);
      //addJavascriptMessageHandler("PairedDistributionsHandlePatientIDs", handlePatientIDs);
      //addJavascriptMessageHandler("handlePatientClassification", handlePatientClassification)
      //socketConnectedFunctions.push(getPatientClassification);
      socketConnectedFunctions.push(runDemo);
      }
   };

}); // PairedDistributionsModule
//----------------------------------------------------------------------------------------------------
pairedDistributions = PairedDistributionsModule();
pairedDistributions.init();

</script>