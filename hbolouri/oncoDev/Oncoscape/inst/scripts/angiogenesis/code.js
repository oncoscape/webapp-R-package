<script>

var cwAngio;

//----------------------------------------------------------------------------------------------------
angiogenesisHandleWindowResize = function()
{
   console.log("angiogenesis window resize: " + $(window).width() + ", " + $(window).height());
   $("#cwAngiogenesisDiv").width(0.95 * $(window).width());
   $("#cwAngiogenesisDiv").height(0.8 * $(window).height());
   cwAngio.resize();
   cwAngio.fit(50);
   //debugger;

} // angiogenesisHandleWindowResize
//----------------------------------------------------------------------------------------------------
angiogenesisDemoVizChanges = function()
{
   console.log("===== entering angiogenesisDemoVizChanges");

   var nodes = cwAngio.elements("node:visible")
   var nodeIds = [];

   for(var n=0; n < nodes.length; n++) { 
      id = nodes[n].data()['id'];
      nodeIds.push(id);
      }

   var noa = {};

   for(var i=0; i < nodeIds.length; i++){
      newScore = getRandomFloat(-8, 8);
      newCopyNumberIndex = getRandomInt(0,3);
      newCopyNumber = ["-2", "-1", "0", "1", "2"][newCopyNumberIndex]
      noa[nodeIds[i]] = {score: newScore, copyNumber: newCopyNumber};
      } // for i

   cwAngio.batchData(noa);
   cwAngio.elements("node:visible").select().unselect()

} // angiogenesisDemoVizChanges
//----------------------------------------------------------------------------------------------------
loadAngioNetwork = function() {

   console.log("loadAngioNetwork, node count: " + angiogenesisNetwork.elements.nodes.length);
   cwAngio = $("#cwAngiogenesisDiv");
   cwAngio.cytoscape({
       elements: angiogenesisNetwork.elements,
       style: angiogenesisVizmap[0].style,
       showOverlay: false,
       minZoom: 0.01,
       maxZoom: 8.0,
       layout: {
         name: "preset",
         fit: true
         },
    ready: function() {
        console.log("cwAngio ready");
        cwAngio = this;
        window.cwAngio = cwAngio
        //cwAngio.filter('edge').hide();  // no edges at first
        cwAngio.on('mouseover', 'node', function(evt){
           var node = evt.cyTarget;
           $("#angiogenesisMouseOverReadoutDiv").text(node.data().label);
           });
        cwAngio.on('mouseover', 'edge', function(evt){
           var edge = evt.cyTarget;
           $("#angiogenesisMouseOverReadoutDiv").text(edge.data().canonicalName);
           })

        console.log("cwAngio.reset");
        cwAngio.reset();
        angiogenesisHandleWindowResize();
        } // cy.ready
       })
    .cytoscapePanzoom({ });   // need to learn about options

} // loadAngioNetwork
//----------------------------------------------------------------------------------------------------
onReadyFunctions.push(function() {
   console.log("==== markersAndTissues code.js document ready");
   $("#angiogenesisDemoVizUpdateButton").click(angiogenesisDemoVizChanges);
   console.log("about to push loadNetwork");
   socketConnectedFunctions.push(loadAngioNetwork);
   $(window).resize(angiogenesisHandleWindowResize);
   }); // document.ready
</script>

