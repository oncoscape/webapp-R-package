<script>

//----------------------------------------------------------------------------------------------------
var PLSRModule = (function () {

   var plsrDisplay
   var d3plsrDisplay;

      // these are reported by the server, from an inspection of the data
   var ageAtDxMin, ageAtDxMax, survivalMin, survivalMax;

      // 4 sliders and their readout
   var ageAtDxMinSlider, ageAtDxMinSliderReadout;
   var ageAtDxMaxSlider, ageAtDxMaxSliderReadout;
   var survivalMinSlider, survivalMinSliderReadout;
   var survivalMaxSlider, survivalMaxSliderReadout;

      // the current values specifying the subsets
      // set as 1/3 from min and max initially, subsequently read
      // from the sliders
   var ageAtDxMinThreshold, ageAtDxMaxThreshold, survivalMinThreshold, survivalMaxThreshold;

   var calculateButton;

  //--------------------------------------------------------------------------------------------
  function initializeUI () {

      plsrDisplay = $("#plsrDisplay");
      d3plsrDisplay = d3.select("#plsrDisplay");
      console.log("== intiailizeUI, plsrDisplay: " + plsrDisplay);
      console.log("== intiailizeUI, d3plsrDisplay: " + d3plsrDisplay);

      ageAtDxMinSlider = $("#plsrAgeAtDxMinSlider");
      ageAtDxMinSliderReadout = $("#plsrAgeAtDxMinSliderReadout");

      ageAtDxMaxSlider = $("#plsrAgeAtDxMaxSlider");
      ageAtDxMaxSliderReadout = $("#plsrAgeAtDxMaxSliderReadout");

      survivalMinSlider = $("#plsrSurvivalMinSlider");
      survivalMinSliderReadout = $("#plsrSurvivalMinSliderReadout");

      survivalMaxSlider = $("#plsrSurvivalMaxSlider");
      survivalMaxSliderReadout = $("#plsrSurvivalMaxSliderReadout");

      calculateButton = $("#plsrCalculateButton");
      calculateButton.button();
      calculateButton.click(requestPLSRByOnsetAndSurvival)

      handleWindowResize();
      //broadcastButton = $("#pcaBroadcastSelectionToClinicalTable");
      //broadcastButton.click(pcaBroadcastSelection);
      $(window).resize(handleWindowResize);
      //broadcastButton.prop("disabled",true);
      };

  //--------------------------------------------------------------------------------------------
  function getAgeAtDxAndSurvialInputRanges () {
     msg = {cmd: "getAgeAtDxAndSurvivalRanges", callback: "handleAgeAtDxAndSurvivalRanges",
            status: "request", payload:""};
     msg.json = JSON.stringify(msg);
     console.log("sending cmd " + msg)
     socket.send(msg.json);
     } // getAgeAtDxAndSurvialInputRanges 

   //----------------------------------------------------------------------------------------------
   function handleAgeAtDxAndSurvivalRanges(msg) {

      console.log("==== handleAgeAtDxAndSurvivalRanges");
      console.log(msg);
      console.log(msg.payload);
      ageAtDxMin = Math.floor(msg.payload.ageAtDxLow);
      ageAtDxMax = Math.floor(msg.payload.ageAtDxHigh + 1);
      survivalMin = Math.floor(msg.payload.survivalLow);
      survivalMax = Math.floor(msg.payload.survivalHigh + 1);
      console.log("ageAtDxMin: " + ageAtDxMin);
      console.log("ageAtDxMax: " + ageAtDxMax);
      console.log("survivalMin: " + survivalMin);
      console.log("survivalMax: " + survivalMax);
      setupSliders();
      } // handleAgeAtDxAndSurvivalRanges 

   //--------------------------------------------------------------------------------------------------
   requestPLSRByOnsetAndSurvival = function() {
   

     ageAtDxMinThreshold = Number(ageAtDxMinSliderReadout.val()); 
     ageAtDxMaxThreshold = Number(ageAtDxMaxSliderReadout.val());
     survivalMinThreshold = Number(survivalMinSliderReadout.val());
     survivalMaxThreshold = Number(survivalMaxSliderReadout.val());

     console.log("=== requesting plsr, ageAtDx: " + ageAtDxMinThreshold + " - " + ageAtDxMaxThreshold);
     console.log("=== requesting plsr, survival: " + survivalMinThreshold + " - " + survivalMaxThreshold);

     payload = {geneSet: "geneset1",
                ageAtDxThresholdLow: ageAtDxMinThreshold,
                ageAtDxThresholdHi:  ageAtDxMaxThreshold,
                overallSurvivalThresholdLow: survivalMinThreshold,
                overallSurvivalThresholdHi: survivalMaxThreshold};
   
      payload = JSON.stringify(payload)
      msg = {cmd: "calculatePLSR", callback: "handlePlsrResults", status: "request", payload: payload}
      msg.json = JSON.stringify(msg);
      console.log(msg.json)
      socket.send(msg.json);
      }  // requestPLSRByOnsetAndSurvival


   //--------------------------------------------------------------------------------------------------
   function setupSliders() {

      var ageAtDxSpan = ageAtDxMax - ageAtDxMin;
      var survivalSpan = survivalMax - survivalMin;

      ageAtDxMinThreshold = Math.floor(ageAtDxMin + (ageAtDxSpan/3));
      ageAtDxMaxThreshold = Math.floor(1 + ageAtDxMax - (ageAtDxSpan/3));
      survivalMinThreshold = survivalMin + (survivalSpan/3);
      survivalMaxThreshold = survivalMax - (survivalSpan/3);
    
      ageAtDxMinSlider.slider({
         slide: function(event, ui) {
            ageAtDxMin = Number(ui.value);
            ageAtDxMinSliderReadout.text (ui.value);
            },
         min: ageAtDxMin,
         max: ageAtDxMax,
         value: ageAtDxMinThreshold.toFixed(1)
         });
        ageAtDxMinSliderReadout.text(ageAtDxMinThreshold);
  
      ageAtDxMaxSlider.slider({
         slide: function(event, ui) {
            ageAtDxMax = Number(ui.value);
            ageAtDxMaxSliderReadout.text (ui.value)
            },
         min: ageAtDxMin,
         max: ageAtDxMax,
         value: ageAtDxMaxThreshold.toFixed(1)
         });
        ageAtDxMaxSliderReadout.text(ageAtDxMaxThreshold);
  
      survivalMinSlider.slider({
         slide: function(event, ui) {
            survivalMin = ui.value;
            currentValueFormattedString = survivalMin.toFixed(1)
            survivalMinSliderReadout.text(currentValueFormattedString);
            },
         min: survivalMin,
         max: survivalMax,
         step: 0.1,
         value: survivalMinThreshold.toFixed(1)
         });

      survivalMinSliderReadout.text(survivalMinThreshold.toFixed(1));
  
      survivalMaxSlider.slider({
         slide: function(event, ui){
            survivalMax = ui.value;
            currentValueFormattedString = survivalMax.toFixed(1)
            survivalMaxSliderReadout.text(currentValueFormattedString);
            },
         min: survivalMin,
         max: survivalMax,
         step: 0.1,
         value: survivalMaxThreshold.toFixed(1)
         });

      survivalMaxSliderReadout.text(survivalMaxThreshold.toFixed(1));
      } // setupSliders

   //--------------------------------------------------------------------------------------------------
   function handlePlsrResults (msg){

      console.log("=== handlePlsrResults");

      if(msg.status == "error"){
         alert(msg.payload);
         return;
         }
   
        //todo: investigate why labkey is returning array[1] for properties in some cases
        //flattenArrays will not affect JSON without array[1] members
     
      var genes = JSON.parse(msg.payload.genes);
      for (var i = 0; i < genes.length; i++)
          flattenArrays(genes[i]);
      console.log(genes[0]);
   
      var vectors = JSON.parse(msg.payload.vectors);
      for (var i = 0; i < vectors.length; i++)
           flattenArrays(vectors[i]);
      console.log(vectors[0]);
   
         // R figures out the largest absolute value in vectors + genes
         // so that the d3 plot can be easily scaled
      var absMaxValue = msg.payload.absMaxValue

      // genes = genes.slice(1,8);
      allObjs = genes.concat(vectors);
   
      console.log("=== calling d3PlsrscatterPlot");
      svg = d3PlsrScatterPlot(allObjs, absMaxValue);

      } // handlePlsrResults

   //--------------------------------------------------------------------------------------------
   function d3PlsrScatterPlot(dataset, absMaxValue) {

      var padding = 70;
      var width = plsrDisplay.width();
      var height = plsrDisplay.height();

      debugger;

      d3plsrDisplay.select("#plsrSVG").remove();  // so that append("svg") is not cumulative
   
      geneDataset = dataset.filter(function(x) {return(x.category=="gene")});
      vectorDataset = dataset.filter(function(x) {return(x.category=="vector")});
   
      window.plsrGeneDataset = geneDataset
      console.log("==== genes: " + geneDataset.length);
      console.log("==== vectors: " + vectorDataset.length);

      absMaxValue = 1.2 * absMaxValue
      var negAbsMaxValue = -1.0 * absMaxValue
   
      var xScale = d3.scale.linear()
                     .domain([negAbsMaxValue, absMaxValue])
                     .range([padding, width - padding * 2]);
   
      var yScale = d3.scale.linear()
                     .domain([negAbsMaxValue, absMaxValue])
                     .range([height - padding, padding]); // note inversion 
   
      var xAxis = d3.svg.axis()
                    .scale(xScale)
                    .orient("bottom")
                    .ticks(5);
   
      var yAxis = d3.svg.axis()
                    .scale(yScale)
                    .orient("left")
                    .ticks(5);
   
      var brush = d3.svg.brush()
                    .x(xScale)
                    .y(yScale)
                    .on("brushend", brushend);
   
     function brushend() {
       console.log("brushend");
       var extent = brush.extent();
       console.log("e: " + extent);
       window.selectedRegion = extent;
       } ;// brushend
   
   
      function transform(d) {
         return "translate(" + xScale(d.Comp1) + "," + yScale(d.Comp2) + ")";
         }; //transform
   
      var assignColor = d3.scale.ordinal()
                                .domain(["gene",     "vector"])
                                .range(["lightgray", "red"]);
   
      debugger;
      var svg = d3plsrDisplay.append("svg")
                  .attr("id", "plsrSVG")
                  .attr("width", width)
                  .attr("height", height)
                  .append("g");
                  //.attr("transform", "translate(" + padding + "," + padding + ")");
   
        svg.append("g")
           .attr("class", "brush")
           .call(brush);
    
       var tooltip = d3plsrDisplay.append("div")
                                  .attr("class", "tooltip")
                                  .style("position", "absolute")
                                  .style("z-index", "10")
                                  .style("visibility", "hidden")
                                  .text("a simple tooltip");
   
           // draw the genes
        console.log("=== drawing genes: " + geneDataset.length);

        var circle= svg.selectAll("circle")
          .data(geneDataset)
          .enter()
          .append("circle")
          .attr("cx", function(d,i) {return xScale(d["Comp 1"]);})
          .attr("cy", function(d,i) {return yScale(d["Comp 2"]);})
          .attr("r",  function(d) {
              //console.log("appending gene circle: " + d.rowname); 
              return 2;})
          .text(function(d) {
              return(d.rowname);
              })
          .style("fill", function(d) { return assignColor(d.category); })
          .on("mouseover", function(d,i){
              tooltip.text(d.rowname);
              return tooltip.style("visibility", "visible");
              })
          .on("mousemove", function(){return tooltip.style("top",
              (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
          .on("mouseout", function(){return tooltip.style("visibility", "hidden");});
          //.attr("transform", transform);
   
            //-----------------------
            // draw the vectors
            //-----------------------
      console.log("=== drawing vectors: " + vectorDataset.length);

      var line = svg.selectAll("line")
                     .data(vectorDataset)
                     .enter().append("line")
                                .attr("class", "line")
                                .style("stroke-width", 1)
                        .style("stroke", "red")
                        .attr("x1", xScale(0))
                        .attr("y1", yScale(0))
                        .attr("x2", function(v) { return xScale(v.x); })
                        .attr("y2", function(v) { return yScale(v.y); });
      var text = svg.selectAll("text")
                    .data(vectorDataset)
                    .enter().append("text")
                            .attr("class", "text")
                            .attr("x", function(v) { return xScale(v.x); })
                            .attr("y", function(v) { return yScale(v.y); })
                            .text( function(v) {return v.rowname})
                            .attr("text-anchor", "middle")
                            .style("fill", "black") ;
                                                    
        return(svg)

        } // d3PlsrScatterPlot

  //--------------------------------------------------------------------------------------------
   function runDemo (){
     payload = "";
     msg = {cmd: "calculate_mRNA_PCA", callback: "pcaPlot", status: "request", 
            payload: payload};
     socket.send(JSON.stringify(msg));
     };  // d3PlsrScatterPlot

  //--------------------------------------------------------------------------------------------
  function getPatientClassification (){
     payload = "";
     msg = {cmd: "getPatientClassification", callback: "handlePatientClassification", 
            status: "request", payload: payload};
     socket.send(JSON.stringify(msg));
     };

  //--------------------------------------------------------------------------------------------
  function handlePatientClassification (msg){
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
  function handleWindowResize () {
     console.log("=== Module.plsr handleWindowResize");
     plsrDisplay.width($(window).width() * 0.99);
     plsrDisplay.height($(window).height() * 0.90);
     };

   //--------------------------------------------------------------------------------------------
  function pcaBroadcastSelection (){
      console.log("pcaBroadcastSelection: " + pcaSelectedRegion);
      x1=pcaSelectedRegion[0][0];
      y1=pcaSelectedRegion[0][1];
      x2=pcaSelectedRegion[1][0];
      y2=pcaSelectedRegion[1][1];
      ids = [];
      for(var i=0; i < pcaResults.length; i++){
         p = pcaResults[i];
         if(p.PC1 >= x1 & p.PC1 <= x2 & p.PC2 >= y1 & p.PC2 <= y2)
            ids.push(p.id[0]);
         } // for i
      if(ids.length > 0)
         sendIDsToModule(ids, "PatientHistory", "HandlePatientIDs");
      };

  //--------------------------------------------------------------------------------------------
  function sendIDsToModule (ids, moduleName, title){
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
  function pcaPlot (msg){
      console.log("==== pcaPlot");
      //console.log(msg);
      if(msg.status == "success"){
         pcaResults = JSON.parse(msg.payload);
         d3PcaScatterPlot(pcaResults);
         if(!firstTime)  // first call comes at startup.  do not want to raise tab then.
             $("#tabs").tabs( "option", "active", pcaTabNumber);
         } // success
    else{
      console.log("pcaPlot about to call alert: " + msg)
      alert(msg.payload)
      }
     firstTime = false;
     };

  //--------------------------------------------------------------------------------------------
  function handlePatientIDs(msg){
      console.log("Module.pca: handlePatientIDs");
      //console.log(msg)
      if(msg.status == "success"){
         patientIDs = msg.payload
         //console.log("pca handlePatientIds: " + patientIDs);
         payload = patientIDs
         msg = {cmd: "calculate_mRNA_PCA", callback: "pcaPlot", status: "request", 
                payload: payload};
         socket.send(JSON.stringify(msg));
         }
    else{
      console.log("handlePatientIDs about to call alert: " + msg)
      alert(msg.payload)
      }
     }; // handlePatientIDs

  //--------------------------------------------------------------------------------------------
  function d3PlotBrushReader () {
     console.log("plotBrushReader 1037a 22jul2014");
     pcaSelectedRegion = d3PlotBrush.extent();
     //console.log("region: " + pcaSelectedRegion);
     x0 = pcaSelectedRegion[0][0];
     x1 = pcaSelectedRegion[1][0];
     width = Math.abs(x0-x1);
     //console.log("width: " + width);
     if(width > 1){
        broadcastButton.prop("disabled", false);
        console.log("width > 1, new button state, disabled?: " + broadcastButton.prop("disabled"));
        }
     else{
        broadcastButton.prop("disabled", true);
        console.log("width !> 1, new button state, disabled?: " + broadcastButton.prop("disabled"));
        }
     }; // d3PlotBrushReader

  //-------------------------------------------------------------------------------------------
  function chooseColor (d){
     id = d.id[0];
     for(var i=0; i<patientClassification.length; i++){
        if (id == patientClassification[i].rowname[0]){
          result = patientClassification[i].color[0]
          return(result)
          } // if match
        } // for i
     //console.log("chooseColor, no match for id " + id);
     return("black");
     }
  //-------------------------------------------------------------------------------------------

  //--------------------------------------------------------------------------------------------
  return{
   init: function(){
      onReadyFunctions.push(initializeUI);
      //addJavascriptMessageHandler('plsrPlot', displayPLSRresults);
      addJavascriptMessageHandler("handlePlsrResults", handlePlsrResults);
      //addJavascriptMessageHandler("tissueIDsForPLSR", plsrHandleIncomingTissueIDList);
      //addJavascriptMessageHandler('ageAtDxAndSurvivalRanges', handleAgeAtDxAndSurvivalRanges);
      addJavascriptMessageHandler("handleAgeAtDxAndSurvivalRanges", handleAgeAtDxAndSurvivalRanges);
      socketConnectedFunctions.push(getAgeAtDxAndSurvialInputRanges);
      //socketConnectedFunctions.push(requestPLSRByOnsetAndSurvival);
      }
   };

}); // PLSRModule
//----------------------------------------------------------------------------------------------------
plsr = PLSRModule();
plsr.init();

</script>