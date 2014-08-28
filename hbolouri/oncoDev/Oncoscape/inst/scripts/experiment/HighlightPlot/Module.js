<script>
// task:  establish how existing points in a d3 plot can be selected and highlighted programmatically.
//   a) create minimal d3 xy plot, from data hard-coded into your Module.js
//   b) that hard-coded data should be defined within a function call, "getRandomPoints(count)"
//   c) write a function "selectPoints(listOfPoints, clearExistingSelectionFirst)"
//      the listOfPoints needs to be a proper subset of the current points you have displayed, but
//      since someone could send you bad data, always check these points, and use only the 
//      intersection of listOfPoints with the points currently displayed
//   d) add a button which calls this selectPoints function.  this simulates the json message coming in from Oncoscape
//   3) add a button which clears any existing selection
//
// Note that the button in d, and the "clearExistingSelectionFirst" (if true) will call the same function,
// "clearSelection()"
//
// Make it clean, make it simple, make it a little bit handsome.  Once it checks out, your next step will be to add
// this capability to the PCA module, and to register a new function to handle a message like "selectPatientsInPCAModule".
//
//  one technique for highlighting d3 points is seen here:
//     http://bl.ocks.org/bycoffe/5871227
//  the points to be highlighted are painted a different color -- orange in this example.  this example
//  only highlights interactively selected points, where in your code, instead, you need to highligh
//  programmatically selected points.  but the d3 technique can be the same.
//----------------------------------------------------------------------------------------------------
var highlightPlotModule = (function () {
                           
  var randomPointsButton;
  var clearSelectionButton;
  var highlightPlotDisplay;
  var firstTime = true;
  var highlightPlotSelectedRegion;    // from brushing
  var d3PlotBrush;
  var d3HighlightPlotDisplay;
  var highlightPlotTextDisplay;
  var numberOfPoints = 100;
  var listOfPoints;
  var clearExistingSelectionFirst = true;
  var data = [];
                           
  //--------------------------------------------------------------------------------------------

  function initializeUI () {
      highlightPlotDisplay = $("#HighlightPlotDisplay");
      d3HighlightPlotDisplay = d3.select("#HighlightPlotDisplay");
      highlightPlotHandleWindowResize();
      getRandomPoints(numberOfPoints);
      randomPointsButton = $("#HighlightPlotRandomPoints");
      randomPointsButton.click(updateSubset);
      clearSelectionButton = $("#HighlightPlotClearSelection");
      clearSelectionButton.click(clearSelection);
      $(window).resize(highlightPlotHandleWindowResize);
      highlightPlotTextDisplay = $("#HighlightPlotTextDisplay");
      };
      
  //--------------------------------------------------------------------------------------------
  function updateSubset(){
      getRandomSubset(20);
      };
                           
  //--------------------------------------------------------------------------------------------
  function getRandomSubset(count){
      console.log("called");
      var subset = [];
      var dataCopy = $.extend(true, [], data);
      for(i=0;i<count;i++){
          index = Math.floor(Math.random()*(dataCopy.length));
          subset.push(dataCopy.splice(index, 1)[0]);
          }
      selectPoints(subset, clearExistingSelectionFirst);
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
          .attr("r", 5);
      };
                           
  //--------------------------------------------------------------------------------------------
  function clearSelection(){
      d3.selectAll("circle")
          .classed("highlighted", false)
          .attr("r", 3);
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
      d3HighlightPlotScatterPlot(data);
      };


  //--------------------------------------------------------------------------------------------
  function highlightPlotHandleWindowResize () {
      highlightPlotDisplay.width($(window).width() * 0.95);
      highlightPlotDisplay.height($(window).height() * 0.80);
      };

  //--------------------------------------------------------------------------------------------
  function d3PlotBrushReader () {
      console.log("plotBrushReader 1037a 22jul2014");
      highlightPlotSelectedRegion = d3PlotBrush.extent();
      x0 = highlightPlotSelectedRegion[0][0];
      x1 = highlightPlotSelectedRegion[1][0];
      width = Math.abs(x0-x1);
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
          .attr("r", 3)
          .on("mouseover", function(d){tooltip.text(d.ID);return tooltip.style("visibility", "visible");})
          .on("mousemove", function(){return tooltip.style("top",(d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
          .on("mouseout", function(){return tooltip.style("visibility", "hidden");});
       } // d3PcaScatterPlot
                           
  //--------------------------------------------------------------------------------------------
  return{
    init: function(){
       onReadyFunctions.push(initializeUI);
       }
    };
                           
  });
  //--------------------------------------------------------------------------------------------
exp = highlightPlotModule();
exp.init();

</script>