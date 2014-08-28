<script>
// task:  establish how existing points in a d3 plot can be selected and highlighted programmatically.
//   a) create minimal d3 xy plot, from data hard-coded into your Module.js
//   b) that hard-coded data should be defined within a function call, "getRandomPoints(count)"
//   b) write a function "selectPoints(listOfPoints, clearExistingSelectionFirst)"
//   c) add a button which calls a function creating a random subset from getRandomPoints:
//          getRandomSubset(count)
//   d) add a button which clears any existing selection
//
// Note that the button in d, and the "clearExistingSelectionFirst" (if true) will call the same function,
// "clearSelection()"
//
// Make it clean, make it simple, make it a little bit handsome.  Once it checks out, your next step will be to add
// this capability to the PCA module, and to register a new function to handle a message like "selectPatientsInPCAModule".

//----------------------------------------------------------------------------------------------------
var highlightPlotModule = (function () {
                           
						   var randomPointsButton;
                           var clearSelectionButton;
                           var highlightPlotDisplay;
                           //var HighlightPlotResults;
                           //var patientClassification;
                           var firstTime = true;
                           var highlightPlotSelectedRegion;    // from brushing
                           var d3PlotBrush;
                           //var HighlightPlotTabNumber = 2;
                           var d3HighlightPlotDisplay;
                           var highlightPlotTextDisplay;
                           var numberOfPoints = 100;
                           var listOfPoints;
                           var clearExistingSelectionFirst;
						   var data = [];
                           
                           //--------------------------------------------------------------------------------------------
                           function initializeUI () {
                           getRandomPoints(numberOfPoints);
                           highlightPlotDisplay = $("#HighlightPlotDisplay");
                           d3HighlightPlotDisplay = d3.select("#HighlightPlotDisplay");
                           highlightPlotHandleWindowResize();
                           randomPointsButton = $("#HighlightPlotRandomPoints");
                           randomPointsButton.click(getRandomSubset(20));
                           clearSelectionButton = $("#HighlightPlotClearSelection");
                           clearSelectionButton.click(clearSelection());
                           $(window).resize(highlightPlotHandleWindowResize);
                           highlightPlotTextDisplay = $("#HighlightPlotTextDisplay");
                           };
                           
                           //--------------------------------------------------------------------------------------------
                           function getRandomSubset(count){
                           //var subset = _.sample(data, count);
                           console.log("called");
                           var subset = [];
                           var dataCopy = data;
                           for(i=0;i<count;i++){
                           index = Math.floor(Math.random()*(dataCopy.length));
                           subset.push(dataCopy.splice(index, 1)[0]);
                           }
                           d3HighlightPlotScatterPlot(subset);
                           };
                           
                           //--------------------------------------------------------------------------------------------
                           function selectPoints(listOfPoints, clearExistingSelectionFirst){
                           
                           };
                           
                           //--------------------------------------------------------------------------------------------
                           function clearSelection(){
                           
                           };
                           //--------------------------------------------------------------------------------------------
                           function getRandomPoints(count){
                           points = [];
                           for(i=0;i<count;i++){
                           var x = Math.floor((Math.random()*(100)-50));
                           var y = Math.floor((Math.random()*(100)-50));
                           points.push({"x":x,"y":y,"ID":i})
                           }
                           console.log(points);
                           data = points;
                           };
                           
                           //--------------------------------------------------------------------------------------------
                           
                           // //--------------------------------------------------------------------------------------------
                           //   function drawLegend () {
                           //
                           //   console.log("==== draw legend: ")
                           //
                           //     var Legendsvg = d3.select("#HighlightPlotLegend").append("svg").attr("id", "pcaLegendSVG")
                           //                       .attr("width", $("#pcaDisplay").width())
                           //
                           //     var TextOffset =  [0, 70, 82, 87, 85, 80, 78, 75, 80];
                           //
                           //    for(var i=0; i<patientClassification.length; i++){
                           //       if(patientClassification[i].gbmDzSubType[0] == null | patientClassification[i].gbmDzSubType[0] == ""){
                           //           patientClassification[i].gbmDzSubType[0]= "undefined" } }
                           //
                           //         Classifications = d3.nest()
                           //               .key(function(d) { return d.gbmDzSubType[0]; })
                           //               .map(patientClassification, d3.map);
                           //
                           //     var TextOffSet = d3.scale.ordinal()
                           //                .range(TextOffset)
                           //                .domain(Classifications.keys());
                           //
                           //     var legend = Legendsvg
                           //                    .append("g")
                           //                    .attr("class", "legend")
                           //                    .attr("transform", "translate(" + 10 + "," + 10 + ")")
                           //                    .selectAll(".legend")
                           //                      .data(Classifications.keys())
                           //                      .enter().append("g")
                           //                      .attr("transform", function(d, i) {
                           //                         return "translate(" + i*TextOffSet(d) + ",0)" })
                           //                 ;
                           //     legend.append("circle")
                           //             .attr("cx", 12)
                           //             .attr("cy", 5)
                           //             .attr("r", function(d) { return 6;})
                           //             .style("fill", function(d) { return Classifications.get(d)[0].color[0]})
                           //
                           //     legend.append("text")
                           //             .attr("y", 10)
                           //             .attr("x", 20)
                           //             .style("font-size", 12)
                           //             .text(function(d) { return d});
                           //
                           //
                           //   }
                           //--------------------------------------------------------------------------------------------
                           function highlightPlotHandleWindowResize () {
                           highlightPlotDisplay.width($(window).width() * 0.95);
                           highlightPlotDisplay.height($(window).height() * 0.80);
                           //if(!firstTime) {d3HighlightPlotScatterPlot(dataset);}
                           };
                           
                           //--------------------------------------------------------------------------------------------
                           //   function HighlightPlotBroadcastSelection (){
                           //       console.log("pcaBroadcastSelection: " + pcaSelectedRegion);
                           //       x1=pcaSelectedRegion[0][0];
                           //       y1=pcaSelectedRegion[0][1];
                           //       x2=pcaSelectedRegion[1][0];
                           //       y2=pcaSelectedRegion[1][1];
                           //       ids = [];
                           //       for(var i=0; i < pcaResults.length; i++){
                           //          p = pcaResults[i];
                           //          if(p.PC1 >= x1 & p.PC1 <= x2 & p.PC2 >= y1 & p.PC2 <= y2)
                           //             ids.push(p.id[0]);
                           //          } // for i
                           //       if(ids.length > 0)
                           //          sendIDsToModule(ids, "PatientHistory", "HandlePatientIDs");
                           //       };
                           
                           //--------------------------------------------------------------------------------------------
                           function d3PlotBrushReader () {
                           console.log("plotBrushReader 1037a 22jul2014");
                           highlightPlotSelectedRegion = d3PlotBrush.extent();
                           //console.log("region: " + pcaSelectedRegion);
                           x0 = highlightPlotSelectedRegion[0][0];
                           x1 = highlightPlotSelectedRegion[1][0];
                           width = Math.abs(x0-x1);
                           //console.log("width: " + width);
                           //      if(width > 1){
                           //         broadcastButton.prop("disabled", false);
                           //         console.log("width > 1, new button state, disabled?: " + broadcastButton.prop("disabled"));
                           //         }
                           //      else{
                           //         broadcastButton.prop("disabled", true);
                           //         console.log("width !> 1, new button state, disabled?: " + broadcastButton.prop("disabled"));
                           //         }
                           }; // d3PlotBrushReader
                           
                           //-------------------------------------------------------------------------------------------
                           function chooseColor (d){
                           return("red");
                           }
                           //-------------------------------------------------------------------------------------------
                           function d3HighlightPlotScatterPlot(dataset) {
                           
                           var padding = 50;
                           var width = $("#HighlightPlotDisplay").width();
                           var height = $("#HighlightPlotDisplay").height();
                           
                           var xMax = d3.max(dataset, function(d) { return +d.x;} );
                           var xMin = d3.min(dataset, function(d) { return d.x;} );
                           var yMax = d3.max(dataset, function(d) { return +d.y;} );
                           var yMin = d3.min(dataset, function(d) { return d.y;} );
                           
                           xMax = xMax * 1.1
                           xMin = xMin * 1.1
                           
                           console.log("xMax: " + xMax);   console.log("xMin: " + xMin);
                           console.log("yMax: " + yMax);   console.log("yMin: " + yMin);
                           
                           
                           d3HighlightPlotDisplay.select("#HighlightPlotSVG").remove();  // so that append("svg") is not cumulative
                           
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
                           
                           var svg = d3HighlightPlotDisplay.append("svg")
                           .attr("id", "HighlightPlotSVG")
                           .attr("width", width)
                           .attr("height", height)
                           .call(d3PlotBrush);
                           
                           svg.append("g")
                           .attr("class", "x axis")
                           .attr("transform", "translate(0, " + yTranslationForXAxis + ")")
                           .call(xAxis)
                           .append("text")
                           .style("font-size", 14)
                           .text("x");
                           
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
                           .text("y");
                           
                           var circle = svg.append("g").selectAll("circle")
                           .data(dataset)
                           .enter()
                           .append("circle")
                           .attr("cx", function(d) {return xScale(d.x);})
                           .attr("cy", function(d) {return yScale(d.y);})
                           .attr("r", function(d) { return 3;})
                           .style("fill", function(d) {return(chooseColor(d))})
                           //.style("fill", function(d) { return "blue"})
                           .on("mouseover", function(d){
                               tooltip.text(d.ID);
                               return tooltip.style("visibility", "visible");
                               })
                           .on("mousemove", function(){return tooltip.style("top",
                                                                            (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                           .on("mouseout", function(){return tooltip.style("visibility", "hidden");});
                           
                           
                           } // d3PcaScatterPlot
                           
                           //--------------------------------------------------------------------------------------------
                           return{
                           init: function(){
                           onReadyFunctions.push(initializeUI);
                           }
                           };
                           
                           });
exp = highlightPlotModule();
exp.init();

</script>