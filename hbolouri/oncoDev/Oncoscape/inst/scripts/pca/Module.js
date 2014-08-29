<script>
//----------------------------------------------------------------------------------------------------
var PCAModule = (function () {

  var broadcastButton;
  var pcaDisplay;
  var pcaScores;
  var patientClassification;
  var firstTime = true;
  var pcaSelectedRegion;    // from brushing
  var d3PlotBrush;
  var pcaTabNumber = 2;
  var d3pcaDisplay;
  var pcaTextDisplay;
  
  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      pcaDisplay = $("#pcaDisplay");
      d3pcaDisplay = d3.select("#pcaDisplay");
      pcaHandleWindowResize();
      broadcastButton = $("#pcaBroadcastSelectionToClinicalTable");
      //broadcastButton.button();
      broadcastButton.click(pcaBroadcastSelection);
      $(window).resize(pcaHandleWindowResize);
      broadcastButton.prop("disabled",true);
      pcaTextDisplay = $("#pcaTextDisplayDiv");
      };

  //--------------------------------------------------------------------------------------------
  function runDemo (){
     payload = "";
     msg = {cmd: "calculate_mRNA_PCA", callback: "pcaPlot", status: "request", 
            payload: payload};
     socket.send(JSON.stringify(msg));
     };

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
     console.log(msg);
     if(msg.status == "success"){
        patientClassification = JSON.parse(msg.payload)
        console.log("got classification, length " + patientClassification.length);
        console.log(patientClassification.payload);
        drawLegend();
        }
     else{
       alert("error!" + msg.payload)
       }
      }; // handlePatientIDs
 //-------------------------------------------------------------------------------------------- 
  function drawLegend () {

   console.log("==== draw legend: ") 

   for(var i=0; i<patientClassification.length; i++){
      if(patientClassification[i].gbmDzSubType[0] == null | patientClassification[i].gbmDzSubType[0] == ""){ 
          patientClassification[i].gbmDzSubType[0]= "undefined" } }

        Classifications = d3.nest()
              .key(function(d) { return d.gbmDzSubType[0]; })
              .map(patientClassification, d3.map);


   var Legendsvg = d3.select("#pcaLegend").append("svg").attr("id", "pcaLegendSVG")
                      .attr("width", $("#pcaDisplay").width())

    var LegendLabels = d3.values(Classifications.keys())
 
//     var TextOffSet =  [0, 70, 82, 87, 85, 80, 78, 75, 80];
//     var TextOffset = d3.scale.ordinal()
//               .range(TextOffset)
//               .domain(Classifications.keys());
        
    var legend =    Legendsvg
                   .append("g")
                   .attr("class", "legend")
                   .attr("transform", "translate(" + 10 + "," + 10 + ")")  
                   .selectAll(".legend")
                     .data(LegendLabels)
                     .enter().append("g")
                ;

    var text = legend.append("text")
            .attr("y", 10)
            .attr("x", 0)
            .style("font-size", 12)
            .text(function(d) { return d})
           ;

    var TextOffset = []
    var xPosition = 0

   text.attr("transform", function(d, i){
        TextOffset.push(xPosition)
        console.log(i, xPosition)
        xPosition = xPosition + this.getBBox().width +20
     return "translate(" + (TextOffset[i]+10) +",0)"
   })
   
   console.log(TextOffset)
     legend.append("circle")
            .attr("cx", 0)
            .attr("cy", 5)
            .attr("r", function(d) { return 6;})
            .style("fill", function(d) { return Classifications.get(d)[0].color[0]})
            .attr("transform", function(d, i){
               return "translate(" + (TextOffset[i]) +",0)"
             })


  }
  
  //--------------------------------------------------------------------------------------------
  function highlightPoints(data){
     selectPoints(data, true);
  };
  
  //--------------------------------------------------------------------------------------------
  function selectPoints(listOfPoints, clearExistingSelectionFirst){
      if(clearExistingSelectionFirst){
          clearSelection();
      }
      var ids = [];
      for(i=0;i<listOfPoints.length;i++){
          ids.push(listOfPoints[i].ID);
      }
      d3.selectAll("circle")
          .filter(function(d, i) {return ids.indexOf(d.ID) > -1;})
          .classed("highlighted", true)
          .transition()
          .attr("r", 5)
          .duration(500);
      };
  
  //--------------------------------------------------------------------------------------------
  function clearSelection(){
      d3.selectAll("circle")
          .classed("highlighted", false)
          .attr("r", 3);
      };
  
  //--------------------------------------------------------------------------------------------
  function pcaHandleWindowResize () {
     pcaDisplay.width($(window).width() * 0.95);
     pcaDisplay.height($(window).height() * 0.80);
     if(!firstTime) {d3PcaScatterPlot(pcaScores);}
     };

   //--------------------------------------------------------------------------------------------
  function pcaBroadcastSelection (){
      console.log("pcaBroadcastSelection: " + pcaSelectedRegion);
      x1=pcaSelectedRegion[0][0];
      y1=pcaSelectedRegion[0][1];
      x2=pcaSelectedRegion[1][0];
      y2=pcaSelectedRegion[1][1];
      ids = [];
      for(var i=0; i < pcaScores.length; i++){
         p = pcaScores[i];
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
         pcaScores = JSON.parse(msg.payload.tbl);
         d3PcaScatterPlot(pcaScores);
         console.log(msg.payload.importance)
//         pcaData = JSON.parse(msg.payload.importance);
//         pcaDataTable(pcaData);
         
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
      console.log(msg)
      if(msg.status == "success"){
         patientIDs = msg.payload;
         //console.log("pca handlePatientIds: " + patientIDs);
         payload = patientIDs;
         console.log(payload);
         if(payload.Higlight == "Highlight"){
            console.log("HIGHLIGHTED!!!!!!");
            highlightPoints(payload);
        }else{
            console.log("NOT HIGHLIGHTED!!!!!!");
            msg = {cmd: "calculate_mRNA_PCA", callback: "pcaPlot", status: "request",
                payload: payload};
            socket.send(JSON.stringify(msg));
            }
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
   function pcaDataTable(pcaData){
        var pcaText = d3.select("#pcaTextDisplay")
        console.log("!!!!!!!!!!!!!pcaData=========")
        console.log(pcaData)
        var tblColumnNames = ["A", "B", "C"];
        columnTitles = [];
        for(var i=0; i < tblColumnNames.length; i++){
          columnTitles.push({sTitle: tblColumnNames[i]});
        }

     displayDiv.html('<table cellpadding="0" cellspacing="0" margin-left="10" border="1" class="display" id="pcaTable"></table>');
     $("#pcaTable").dataTable({
        "sDom": "Rlfrtip",
         sDom: 'C<"clear">lfrtip',
        "aoColumns": columnTitles,
	    "sScrollX": "100px",
        "iDisplayLength": 25,
         bPaginate: true,
        "scrollX": true,
        "fnInitComplete": function(){
            $(".display_results").show();
            }
         }); // dataTable

     console.log("displayTable adding data to table");
     tableRef = $("#pcaTable").dataTable();
//     tableRef.fnAddData(pcaData);

        
   }
 //-------------------------------------------------------------------------------------------
  function d3PcaScatterPlot(dataset) {
                 console.log(dataset);
     broadcastButton.prop("disabled",true);
     var padding = 50;
     var width = $("#pcaDisplay").width();
     var height = $("#pcaDisplay").height();

     var xMax = d3.max(dataset, function(d) { return +d.PC1;} );
     var xMin = d3.min(dataset, function(d) { return +d.PC1;} );
     var yMax = d3.max(dataset, function(d) { return +d.PC2;} );
     var yMin = d3.min(dataset, function(d) { return +d.PC2;} );
 
       // todo:  after finding min and max, determine largest of each axis in abs value
       // todo:  then find next larger even number, use that throughout
     
     xMax = xMax * 1.1
     xMin = xMin * 1.1
     yMax = yMax * 1.1
     yMin = yMin * 1.1
//     xMax = 40
//     xMin = -40
//     yMax = 30
//     yMin = -30

     //console.log("xMax: " + xMax);   console.log("xMin: " + xMin);
     //console.log("yMax: " + yMax);   console.log("yMin: " + yMin);


     d3pcaDisplay.select("#pcaSVG").remove();  // so that append("svg") is not cumulative
 
     var xScale = d3.scale.linear()
                    .domain([xMin,xMax])
                    .range([padding, width - padding]);

     var yScale = d3.scale.linear()
                    .domain([yMin, yMax])
                    .range([height - padding, padding]); // note inversion 

     var xTranslationForYAxis = xScale(0);
     var yTranslationForXAxis = yScale(0);

     var xAxis = d3.svg.axis()
                   .scale(xScale)
                   .orient("top")
                   .ticks(5);

     var yAxis = d3.svg.axis()
                   .scale(yScale)
                   .orient("left")
                   .ticks(5);

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

     var svg = d3pcaDisplay.append("svg")
                 .attr("id", "pcaSVG")
                 .attr("width", width)
                 .attr("height", height)
                 .call(d3PlotBrush);

     svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0, " + yTranslationForXAxis + ")")
        .call(xAxis)
        .append("text")
        .style("font-size", 14)
        .text("PC1");

     svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate(" + xTranslationForYAxis + ", 0)")
        .call(yAxis)
        .append("text")
//            .attr("transform", "rotate(-90)")
              .attr("y", 10)
              .attr("dy", ".71em")
             .style("font-size", 14)
            .style("text-anchor", "end") //start, middle
            .text("PC2");

     var circle = svg.append("g").selectAll("circle")
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
      
 
     } // d3PcaScatterPlot

//----------------------------------------------------------------------------------------------------
    function SetModifiedDate(){

        msg = {cmd:"getModuleModificationDate",
             callback: "DisplayPCAModifiedDate",
             status:"request",
             payload:"pca"
             };
        msg.json = JSON.stringify(msg);
        socket.send(msg.json);
    }
//----------------------------------------------------------------------------------------------------
    function DisplayPCAModifiedDate(msg){
        document.getElementById("pcaDateModified").innerHTML = msg.payload;
    }
      
//--------------------------------------------------------------------------------------------
  return{
   init: function(){
      onReadyFunctions.push(initializeUI);
      addJavascriptMessageHandler("pcaPlot", pcaPlot);
      addJavascriptMessageHandler("PCAHandlePatientIDs", handlePatientIDs);
      addJavascriptMessageHandler("handlePatientClassification", handlePatientClassification)
      addJavascriptMessageHandler("DisplayPCAModifiedDate", DisplayPCAModifiedDate);
      socketConnectedFunctions.push(SetModifiedDate);
      socketConnectedFunctions.push(getPatientClassification);
      socketConnectedFunctions.push(runDemo);
      }
   };

}); // PCAModule
//----------------------------------------------------------------------------------------------------
pca = PCAModule();
pca.init();

</script>