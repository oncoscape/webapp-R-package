<script>
//----------------------------------------------------------------------------------------------------
var cwMarkers;  // move this back inside module when debugging is done

var markersAndTissuesModule = (function () {

  var cyDiv;
  //var zoomSelectedButton;
  var searchBox;
  var edgeSelectionOn = false;
  //var edgesFromSelectedButton
  var hideEdgesButton, showEdgesButton, showAllEdgesButton, clearSelectionButton, sfnButton;
  var edgeTypeSelector;
  var mouseOverReadout;
  var graphOperationsMenu;
  var myModuleName = "Markers & Patients";

  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      cyDiv = $("#cyMarkersDiv");

      graphOperationsMenu = $("#cyMarkersOperationsMenu");
      graphOperationsMenu.change(doGraphOperation)
      graphOperationsMenu.empty()
      graphOperationsMenu.append("<option>Network Operations...</option>")

      var operations = ["Show All Edges",
                        "Show Edges from Selected Nodes",
                        "Hide All Edges",
                        "Select First Neighbors of Selected Nodes",
                        "Invert Node Selection"]

      for(var i=0;i< operations.length; i++){
         var optionMarkup = "<option>" + operations[i] + "</option>";
         graphOperationsMenu.append(optionMarkup);
         } // for 


      sendSelectionMenu = $("#cyMarkersSendSelectionMenu")
      sendSelectionMenu.change(sendSelection);
      sendSelectionMenu.empty();
       
      sendSelectionMenu.append("<option>Send Selection to...</option>")
      var moduleNames = ["dummy1", "dummy2"]; //getSelectionDestinations();
      for(var i=0;i< moduleNames.length; i++){
         if(moduleNames[i] != myModuleName){
            var optionMarkup = "<option>" + moduleNames[i] + "</option>";
            sendSelectionMenu.append(optionMarkup);
            } // if
         } // for 

      showEdgesButton = $("#cyMarkersShowEdgesButton");
      showEdgesButton.click(showEdges);
      showEdgesButton.qtip({
          content: "Display edges of the currently<br> selected type/s, between all<br>selected nodes.",
          show: {
              event: 'mouseover',
              delay: 1000
              },
          hide: "mouseout",
          position: {
              my: 'top center',
              at: 'bottom center'
              },
          style: {
            classes: 'qtip-bootstrap',
               tip: {
                 width: 12,
                 height: 12
                }
              }
          });


      showAllEdgesButton = $("#cyMarkersShowAllEdgesButton");
      showAllEdgesButton.click(showAllEdges);
      showAllEdgesButton.qtip({
          content: "Display edges of the currently<br>selected type/s, between all nodes.",
          show: {
              event: 'mouseover',
              delay: 1000
              },
          hide: "mouseout",
          position: {
              my: 'top center',
              at: 'bottom center'
              },
          style: {
            classes: 'qtip-bootstrap',
               tip: {
                 width: 12,
                 height: 12
                }
              }
          });

      sfnButton = $("#cyMarkersSFNButton");
      sfnButton.click(selectFirstNeighbors);
      sfnButton.qtip({
          content: "Select nodes which are<br>first neighbors of currently selected nodes.",
          show: { delay: 700, solo: true,effect: { length: 1000 }},
          hide: { event: "mouseout"},
          //show: {
          //    event: 'mouseover',
          //    delay: 1000
          //    },
          //hide: "mouseout",
          position: {
              my: 'top center',
              at: 'bottom center'
              },
          style: {
            classes: 'qtip-bootstrap',
               tip: {
                 width: 12,
                 height: 12
                }
              }
          });

      clearSelectionButton = $("#cyMarkersClearSelectionButton");
      clearSelectionButton.click(clearSelection);

      //edgesFromSelectedButton = $("#cyMarkersShowEdgesFromSelectedButton");
      //edgesFromSelectedButton.click(showEdgesFromSelectedNodes);

      hideEdgesButton = $("#cyMarkersHideEdgesButton");
      hideEdgesButton.click(hideAllEdges)


      //zoomSelectedButton  = $("#cyMarkersZoomSelectedButton");
      searchBox = $("#markersAndTissuesSearchBox");

      edgeTypeSelector = $("#markersEdgeTypeSelector");
      //edgeTypeSelector.change(newEdgeTypeSelection);

      mouseOverReadout = $("#markersAndTissuesMouseOverReadout");

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
      $("#markerpatientsAboutLink").click(showAbout_markerpatients)
    };

   //----------------------------------------------------------------------------------------------------
    function showAbout_markerpatients(){
  
          var   info ={Modulename: "Markers and Patients",
                    CreatedBy: "Hamid Boulori,\nPaul Shannon",
                    MaintainedBy: "Hamid Boulori,\nPaul Shannon",
                    Folder: "markersAndTissues"}

         about.OpenAboutWindow(info) ;
    }  

  //--------------------------------------------------------------------------------------------
  function sendSelection() {
     destinationModule = sendSelectionMenu.val();
     //broadcastSelection();
     sendSelectionMenu.val("Send Selection to:");
     }; // sendSelectionMenuChanged
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
        cwMarkers.on('mouseover', 'node', function(evt){
           var node = evt.cyTarget;
           mouseOverReadout.val(node.data().canonicalName)
           })
        cwMarkers.on('mouseout', 'node', function(evt){
           var node = evt.cyTarget;
           mouseOverReadout.val("");
           })
        cwMarkers.on('mouseover', 'edge', function(evt){
           var edge = evt.cyTarget;
           mouseOverReadout.val(edge.data().canonicalName)
           })

        /***************
        cwMarkers.elements().qtip({
            content: function() {
              return (this.data().canonicalName);
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
         **************/

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
   function doGraphOperation(){

      operation = graphOperationsMenu.val();

      switch(operation){
         case "Show All Edges":
            showAllEdges();
            break;
         case "Show Edges from Selected Nodes":
            showEdgesFromSelectedNodes();
            break;
         case "Hide All Edges":
            hideAllEdges();
            break;
         case "Select First Neighbors of Selected Nodes":
            selectFirstNeighbors();
            break;
         case "Invert Node Selection":
            invertSelection();
            break;
         default:
            console.log("unrecoginized graph operation requested from menu: " + operation)
         } // switch

         // restore menu to initial condition, with only title showing
      graphOperationsMenu.val("Network Operations...");

      } // doGraphOperation

   //----------------------------------------------------------------------------------------------------
   function clearSelection (){
     cwMarkers.elements().unselect()
     }

   //----------------------------------------------------------------------------------------------------
   function selectFirstNeighbors (){
     selectedNodes = cwMarkers.filter('node:selected');
     showEdgesForNodes(cwMarkers, selectedNodes);
     //selectedNodes.neighborhood().select();
     }

   //----------------------------------------------------------------------------------------------------
   function invertSelection (){
      selected = cwMarkers.filter("node:selected");
      unselected = cwMarkers.filter("node:unselected");
      selected.unselect();
      unselected.select();
      }

   //----------------------------------------------------------------------------------------------------
   function hideAllEdges (){
      cwMarkers.filter('edge').hide()
      }

   //----------------------------------------------------------------------------------------------------
   function showAllEdges (){
      //cwMarkers.filter('edge').show()

      var edgeTypesToDisplay = edgeTypeSelector.val();

      console.log("edgeTypeToDisplay: " + edgeTypesToDisplay);

      if(edgeTypesToDisplay == null){
         return;
         }

      for(var e=0; e < edgeTypesToDisplay.length; e++){
         var type =  edgeTypesToDisplay[e];
         selectionString = '[edgeType="' + type + '"]';
         //console.log(" showAllEdges selection string: " + selectionString);
         cwMarkers.edges(selectionString).show()
         } // for e


      } // showAllEdges

   //----------------------------------------------------------------------------------------------------
   function zoomSelected() {
      cwMarkers.fit(cwMarkers.$(':selected'), 100)
      }

   //----------------------------------------------------------------------------------------------------
   function allNodeIDs() {

      ids = [];
      allNodes = cwMarkers.nodes();

      for(i=0; i < allNodes.length; i++)
          ids.push(allNodes[i].data("id"))

      return(ids);

      } // allNodeIDs

   //----------------------------------------------------------------------------------------------------
   function showEdges(){

      hideAllEdges();   // is this wise?

      var edgeTypesToDisplay = edgeTypeSelector.val();
      if(edgeTypesToDisplay == null){
         hideAllEdges();
         return;
         }

      var selectedNodes = selectedNodeIDs(cwMarkers);

      //console.log(" newEdgeTypeSelection (" + edgeTypesToDisplay.length + 
      //            "), selectedNodes: " + selectedNodes.length);

      if(selectedNodes.length > 0) { // show edges to and from all selected nodes
        showEdgesForNodes(cwMarkers, selectedNodes);
        }
      } // showEdges


   //----------------------------------------------------------------------------------------------------
   function showEdgesFromSelectedNodes(){

      var selectedNodes = cwMarkers.filter('node:selected');
      if(selectedNodes.length == 0) {
         return;
         }

      showEdgesForNodes(cwMarkers, selectedNodes);

    /**********
      for(var n=0; n < selectedNodes.length; n++){
         node = selectedNodes[n];
         nodeID = node.data().id;
         filterString = "[target='" + nodeID + "']";
         cwMarkers.edges(filterString).show()
         filterString = "[source='" + nodeID + "']";
         cwMarkers.edges(filterString).show();
         node.neighborhood().select();
         } // for n
    ********/
      } // showEdgesFromSelectedNodes

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
   function selectSourceAndTargetNodesOfEdges(cw, edges){

     console.log("==== selectSourceAndTargetNodes, edges: " + edges.length)
     for(var i=0; i < edges.length; i++){
        edge = edges[i];
        edge.target().select();
        edge.source().select();
        //console.log("selecting source node: " + edge.source().data("name"))
        //console.log("selecting target node: " + edge.target().data("name"))
        } // for i

      } // selecteSourceAndTargetNodesOfEdge

   //----------------------------------------------------------------------------------------------------
   function showEdgesForNodes(cw, nodes){

      var edgeTypes = edgeTypeSelector.val();

      if(edgeTypes.length == 0)
         return;

     //nodeIDs = []
     //for(var i=0; i < nodes.length; i++)
     //  nodeIDs.push(nodes[i].data("id"))

     for(var e=0; e < edgeTypes.length; e++){
        edgeType = edgeTypes[e];

        for(var n=0; n < nodes.length; n++){

            nodeID = nodes[n].data("id")

            filterString = '[edgeType="' + edgeType + '"][source="' + nodeID + '"]';
            //console.log("source filter string: " + filterString);
            selectedEdges = cw.edges(filterString)
            //console.log("    edges found: " + selectedEdges.length);
            selectedEdges.show()
            selectSourceAndTargetNodesOfEdges(cw, selectedEdges);

            filterString = '[edgeType="' + edgeType + '"][target="' + nodeID + '"]';
            //console.log("target filter string: " + filterString);
            selectedEdges = cw.edges(filterString)
            //console.log("    edges found: " + selectedEdges.length);
            selectedEdges.show()
            selectSourceAndTargetNodesOfEdges(cw, selectedEdges);

            //debugger;
            } // for n
         } // for 3
      } // showEdgesForSelectedNodes

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
      //console.log("=== doSearch: " + searchBox.val());
      var keyCode = e.keyCode || e.which;
      if (keyCode == 13) {
         searchString = searchBox.val();
         //console.log("searchString: " + searchString);
         names = nodeNames()
         matches = []
         for(var i=0; i < names.length; i++){
            if(names[i].beginsWith(searchString)) {
               //console.log(searchString + " matched " + names[i]);
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
       //socketConnectedFunctions.push(runDemo);
       }
     };

   }); // markersAndTissuesModule
//----------------------------------------------------------------------------------------------------
markersModule = markersAndTissuesModule()
markersModule.init();

</script>
