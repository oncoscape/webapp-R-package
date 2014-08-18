<script>
//----------------------------------------------------------------------------------------------------
var cwMarkers;  // move this back inside module when debugging is done

var markersAndTissuesModule = (function () {

  var cyDiv;
  //var zoomSelectedButton;
  var searchBox;
  var edgeSelectionOn = false;
  //var edgesFromSelectedButton
  var hideEdgesButton, showEdgesButton, showAllEdgesButton, clearSelectionButton;
  var edgeTypeSelector;

  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      cyDiv = $("#cyMarkersDiv");

      showEdgesButton = $("#cyMarkersShowEdgesButton");
      showEdgesButton.click(showEdges);

      showAllEdgesButton = $("#cyMarkersShowAllEdgesButton");
      showAllEdgesButton.click(showAllEdges);

      clearSelectionButton = $("#cyMarkersClearSelectionButton");
      clearSelectionButton.click(clearSelection);

      //edgesFromSelectedButton = $("#cyMarkersShowEdgesFromSelectedButton");
      //edgesFromSelectedButton.click(showEdgesFromSelectedNodes);

      hideEdgesButton = $("#cyMarkersHideEdgesButton");
      hideEdgesButton.click(hideAllEdges)

      //showEdgesButton = $("#cyMarkersShowEdgesButton");
      //showEdgesButton.click(showAllEdges)

      //zoomSelectedButton  = $("#cyMarkersZoomSelectedButton");
      searchBox = $("#markersAndTissuesSearchBox");

      edgeTypeSelector = $("#markersEdgeTypeSelector");
      //edgeTypeSelector.change(newEdgeTypeSelection);

      loadNetwork();
      $(".chosen-select").chosen();
      //var config = {
      //   '.chosen-select'           : {},
      //   '.chosen-select-deselect'  : {allow_single_deselect:true},
      //   '.chosen-select-no-single' : {disable_search_threshold:10},
      //   '.chosen-select-no-results': {no_results_text:'Oops, nothing found!'},
      //   '.chosen-select-width'     : {width:"95%"}
      // }
      //for (var selector in config) {
      //   $(selector).chosen(config[selector]);
      //   }
      $(window).resize(handleWindowResize);
      };

  //--------------------------------------------------------------------------------------------
  function loadNetwork () {

       // the pathways graph is included explicitly by widget.html, so the
       // network and vizmap are already defined
    console.log("loadnetwork, node count: " + markersAndTissuesNetwork.elements.nodes.length);
    cwMarkers = $("#cyMarkersDiv");
    cwMarkers.cytoscape({
       elements: markersAndTissuesNetwork.elements,
       style: markersAndTissuesVizmap[0].style,
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
        cwMarkers.elements().qtip({
            content: function() {
              return (this.data().canonicalName);
              //return ('Example qTip on ele ' + this.id() + ": ");
              },
            position: {
              my: 'top center',
              at: 'bottom center'
              },
            show: {
              event: 'mouseover'
              },
            hide: {
              event: 'mouseout'
              },
            style: {
              classes: 'qtip-bootstrap',
              tip: {
                 width: 16,
                 height: 8
                }
              }
            }); // qtip

        searchBox.keydown(doSearch);

        cwMarkers.edges().unselectify();
        console.log("cwMarkers.reset");
        cwMarkers.reset();
        handleWindowResize();
        hideAllEdges();
        } // cy.ready
       })
    .cytoscapePanzoom({ });   // need to learn about options

    } // loadNetwork

   //----------------------------------------------------------------------------------------------------
   function handleWindowResize () {
      console.log("markers & tissues window resize: " + $(window).width() + ", " + $(window).height());
      cyDiv.width(0.95 * $(window).width());
      cyDiv.height(0.8 * $(window).height());
      cwMarkers.resize();
      cwMarkers.fit(50);
      } // handleWindowResize


   //----------------------------------------------------------------------------------------------------
   function hiddennewEdgeTypeSelection (){
 
      var edgeTypesToDisplay = edgeTypeSelector.val();
      if(edgeTypesToDisplay == null){
         hideAllEdges();
         return;
         }

      var selectedNodes = selectedNodeIDs(cwMarkers);

      console.log(" newEdgeTypeSelection (" + edgeTypesToDisplay.length + 
                  "), selectedNodes: " + selectedNodes.length);

      if(edgeTypesToDisplay.length == 0){
          hideAllEdges()
          console.log("no edgeTypes selected")
          return;
          }

      if(selectedNodes.length == 0) { // show edges to and from all nodes
        for(var i=0; i < edgeTypesToDisplay.length; i++){
          edgeType = edgeTypesToDisplay[i];
          filterString = 'edge[edgeType="' + edgeType + '"]';
          //console.log("filter string: " + filterString);
          cwMarkers.filter(filterString).show();
          } // for edgeType
        } // no selected nodes
      else{
        showEdgesForSelectedNodes(cwMarkers, edgeTypesToDisplay);
        }


      } // newEdgeTypeSelection

   //----------------------------------------------------------------------------------------------------
   function clearSelection (){
     cwMarkers.elements().unselect()
     }

   //----------------------------------------------------------------------------------------------------
   function hideAllEdges (){
      cwMarkers.filter('edge').hide()
      }

   //----------------------------------------------------------------------------------------------------
   function showAllEdges (){
      cwMarkers.filter('edge').show()
      }

   //----------------------------------------------------------------------------------------------------
   function zoomSelected() {
      cwMarkers.fit(cwMarkers.$(':selected'), 100)
      }

   //----------------------------------------------------------------------------------------------------
   function showEdges(){

      hideAllEdges();   // is this wise?

      var edgeTypesToDisplay = edgeTypeSelector.val();
      if(edgeTypesToDisplay == null){
         hideAllEdges();
         return;
         }

      var selectedNodes = selectedNodeIDs(cwMarkers);

      console.log(" newEdgeTypeSelection (" + edgeTypesToDisplay.length + 
                  "), selectedNodes: " + selectedNodes.length);

      if(edgeTypesToDisplay.length == 0){
          hideAllEdges()
          console.log("no edgeTypes selected")
          return;
          }

      if(selectedNodes.length > 0) { // show edges to and from all selected nodes
        showEdgesForSelectedNodes(cwMarkers, edgeTypesToDisplay);
        }
      } // showEdges


   //----------------------------------------------------------------------------------------------------
   function showEdgesFromSelectedNodes(){

      var selectedNodes = cwMarkers.filter('node:selected');
      var edgeTypesToDisplay = edgeTypeSelector.val();

      if(selectedNodes.length == 0) {
         return;
         }

      for(var n=0; n < selectedNodes.length; n++){
         node = selectedNodes[n];
         nodeID = node.data().id;
         filterString = "[target='" + nodeID + "']";
         cwMarkers.edges(filterString).show()
         filterString = "[source='" + nodeID + "']";
         cwMarkers.edges(filterString).show();
         node.neighborhood().select();
         } // for n
      }

   //----------------------------------------------------------------------------------------------------
   function zoomSelection() {
      cwMarkers.fit(cwMarkers.$(':selected'), 50)
      }

   //----------------------------------------------------------------------------------------------------
   function toggleEdgeSelection () {
     if(edgeSelectionOn){
        cwMarkers.edges().unselectify();
        edgeSelectionOn = false;
        viewAbstractsButton.button("option", "label", "Enable Abstracts");
        }
      else{
        cwMarkers.edges().selectify();
        edgeSelectionOn = true;
        viewAbstractsButton.button("option", "label", "Disable Abstracts");
        }
      } // toggleEdgeSelection


   //----------------------------------------------------------------------------------------------------
    function selectedNodeIDs(cw){
      ids = [];
      noi = cw.filter('node:selected');
      for(var n=0; n < noi.length; n++){
        ids.push(noi[n].data()['id']);
        }
     return(ids);
     } // selectedNodeIDs

   //----------------------------------------------------------------------------------------------------
   function showEdgesForSelectedNodes(cw, edgeTypes){
      var nodeIDs = selectedNodeIDs(cw);
      for(var n=0; n < nodeIDs.length; n++){
         nodeID = nodeIDs[n];
         for(var e=0; e < edgeTypes.length; e++){
            edgeType = edgeTypes[e];
            filterString = '[edgeType="' + edgeType + '"][source="' + nodeID + '"]';
            //console.log("filter string: " + filterString);
            cw.edges(filterString).show();
            filterString = '[edgeType="' + edgeType + '"][target="' + nodeID + '"]';
            //console.log("filter string: " + filterString);
            cw.edges(filterString).show();
            } // for e
         } // for n
      } // showEdgesForSelectedNodes


   //----------------------------------------------------------------------------------------------------
   function nodeNames (){
     nodes = cwMarkers.filter("node:visible");
     result = [];
     for(var i=0; i < nodes.length; i++){
       result.push(nodes[i].data().label)
       } // for i
     return(result)
     } // nodeNames

   //----------------------------------------------------------------------------------------------------
   function doSearch(e) {
      var keyCode = e.keyCode || e.which;
      if (keyCode == 13) {
         searchString = searchBox.val();
         console.log("searchString: " + searchString);
         names = nodeNames()
         matches = []
         for(var i=0; i < names.length; i++){
            if(names[i].beginsWith(searchString)) {
               console.log(searchString + " matched " + names[i]);
               s = "cwMarkers.filter('node[name=\"" + names[i] + "\"]').select()";
               JAVASCRIPT_EVAL (s);
               } // if searchString matched beginning of node
            } // for i
         } // if 13 (return key)
      } // doSearch

   //----------------------------------------------------------------------------------------------------
   return{
     init: function(){
       onReadyFunctions.push(initializeUI);
       //addJavascriptMessageHandler("pairedDistributionsPlot", pairedDistributionsPlot);
       //socketConnectedFunctions.push(runDemo);
       }
     };

   }); // markersAndTissuesModule
//----------------------------------------------------------------------------------------------------
markersModule = markersAndTissuesModule()
markersModule.init();

</script>
