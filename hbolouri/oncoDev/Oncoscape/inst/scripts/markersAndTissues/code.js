<script>

var cwMarkers;

cyMarkersHideEdges = function(){
   cwMarkers.filter('edge').hide()
   }

cyMarkersShowEdges = function(){
   cwMarkers.filter('edge').show()
   }

cyMarkersZoomSelected = function() {
   cwMarkers.fit(cwMarkers.$(':selected'), 100)
   }

cyMarkersShowEdgesFromSelectedNodes = function(){
   var selectedNodes = cwMarkers.filter('node:selected');
   for(var n=0; n < selectedNodes.length; n++){
      node = selectedNodes[n];
      nodeID = node.data().id;
      filterString = "[target='" + nodeID + "']";
      cwMarkers.edges(filterString).show()
      filterString = "[source='" + nodeID + "']";
      cwMarkers.edges(filterString).show();
      node.neighborhood().select();
     } // for n
   } // addEdgesBetweenSelectedNodes


//----------------------------------------------------------------------------------------------------
markersAndTissuesHandleWindowResize = function()
{
   console.log("markersAndTissues window resize: " + $(window).width() + ", " + $(window).height());

   $("#cyMarkersDiv").width(0.95 * $(window).width());
   $("#cyMarkersDiv").height(0.8 * $(window).height());

   cwMarkers.resize();
   cwMarkers.fit(50);

} // markersAndTissuesHandleWindowResize
//----------------------------------------------------------------------------------------------------
handleTissueIDsForMarkersAndTissues = function(msg)
{
   console.log("=== entering handleTissueIDsForMakersAndTissues");
   console.log("status: " + msg.status);
   tissueIDCount = msg.payload.count;
   tissueIDs = msg.payload.tissueIDs;
   console.log("count: " + tissueIDCount + "  ids: " + tissueIDs);

   if(tissueIDCount == 1)
      tissueIDs = [tissueIDs];

define(JAVASCRIPT_EVAL, eval)

   for(var i=0; i < tissueIDs.length; i++){
      nodeName = tissueIDs[i];
      s = "cwMarkers.filter('node[name=\"" + nodeName + "\"]').select()"; 
      console.log("-- about to run: " + s);
      JAVASCRIPT_EVAL (s);
      } // for i

    $("#tabs").tabs( "option", "active", 1);

} // handleTissueIDsForMarkersAndTissues
//----------------------------------------------------------------------------------------------------
loadMarkersAndTissuesNetwork = function() {

   console.log("loadMarkersAndTissuesNetwork, node count: " + network.elements.nodes.length);
   cwMarkers = $("#cyMarkersDiv");
   cwMarkers.cytoscape({
       elements: network.elements,
       style: vizmap[0].style,
       showOverlay: false,
       minZoom: 0.01,
       maxZoom: 8.0,
       layout: {
         name: "preset",
         fit: true
         },
    ready: function() {
        console.log("cwMarkers ready");
        cwMarkers = this;
        cwMarkers.filter('edge').hide();  // no edges at first
        cwMarkers.on('mouseover', 'node', function(evt){
           var node = evt.cyTarget;
           $("#markersAndSamplesMouseOverReadoutDiv").text(node.data().canonicalName)
           })
        console.log("cwMarkers.reset")
        cwMarkers.reset()
        cwMarkers.fit(50);
        markersAndTissuesHandleWindowResize();
        }, // cy.ready

    stylehidden: cytoscape.stylesheet()
      .selector('node')
         .css({'background-color': 'blue'})
      .selector('edge')
         .css({'line-color': 'green',
               'source-arrow-shape': 'circle',
               'source-arrow-color': 'red',
               'curve-style': 'bezier'
              })
       })
    .cytoscapePanzoom({ });   // need to learn about options

} // loadMarkersAndTissuesNetwork
//----------------------------------------------------------------------------------------------------
onReadyFunctions.push(function() {
   console.log("==== markersAndTissues code.js document ready");
   $("#cyMarkersHideEdgesButton").click(cyMarkersHideEdges);
   $("#cyMarkersShowEdgesButton").click(cyMarkersShowEdges);
   $("#cyMarkersShowEdgesFromSelectedButton").click(cyMarkersShowEdgesFromSelectedNodes);
   $("#cyMarkersZoomSelectedButton").click(cyMarkersZoomSelected);
   console.log("about to push loadNetwork");
   socketConnectedFunctions.push(loadMarkersAndTissuesNetwork)
   addJavascriptMessageHandler("tissueIDsForMarkersAndTissues", handleTissueIDsForMarkersAndTissues);
   $(window).resize(markersAndTissuesHandleWindowResize);
   }); // document.ready
//----------------------------------------------------------------------------------------------------

</script>


