<script>
//----------------------------------------------------------------------------------------------------
var cwMarkers;  // move this back inside module when debugging is done

var markersAndTissuesModule = (function () {

  var cyDiv;
  var zoomSelectedButton;
  var searchBox;
  var mouseOverReadout;
  var edgeSelectionOn = false;
  var edgesFromSelectedButton, hideEdgesButton;
  var edgeTypeSelector;

  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      cyDiv = $("#cyMarkersDiv");
      edgesFromSelectedButton = $("#cyMarkersShowEdgesFromSelectedButton");
      edgesFromSelectedButton.click(showEdgesFromSelectedNodes);

      //hideEdgesButton = $("#cyMarkersHideEdgesButton");
      //hideEdgesButton.click(hideAllEdges)

      //showEdgesButton = $("#cyMarkersShowEdgesButton");
      //showEdgesButton.click(showAllEdges)

      zoomSelectedButton  = $("#cyMarkersZoomSelectedButton");
      searchBox = $("#markersAndTissuesSearchBox");

      edgeTypeSelector = $("#markersEdgeTypeSelector");
      edgeTypeSelector.change(newEdgeTypeSelection);

      mouseOverReadout = $("#markersAndSamplesMouseOverReadoutDiv")
      loadNetwork();
      var config = {
         '.chosen-select'           : {},
         '.chosen-select-deselect'  : {allow_single_deselect:true},
         '.chosen-select-no-single' : {disable_search_threshold:10},
         '.chosen-select-no-results': {no_results_text:'Oops, nothing found!'},
         '.chosen-select-width'     : {width:"95%"}
       }
      for (var selector in config) {
         $(selector).chosen(config[selector]);
         }
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
        cwMarkers.on('mouseover', 'node', function(evt){
           var node = evt.cyTarget;
           mouseOverReadout.text(node.data().label);
           })
        cwMarkers.on('mouseover', 'edge', function(evt){
           var edge = evt.cyTarget;
           mouseOverReadout.text(edge.data().canonicalName);
           });
        //cwMarkers.on('select', 'edge', function(evt){
        //   var edge = evt.cyTarget;
        //   console.log("selected edge");
        //   var pmid = edge.data().pmid;
        //   console.log("pmid: " + pmid);
        //   openCenteredBrowserWindow("http://www.ncbi.nlm.nih.gov/pubmed/?term=" + pmid, "pubmed abstract", 800, 600)
        //   });
        //$("#cwMarkersMovieButton").button()
        //zoomSelectedButton.button();
        //zoomSelectedButton.click(zoomSelection);
        searchBox.keydown(doSearch);
        //$("#cwMarkersMovieButton").click(cwMarkerstogglePlayMovie);
        //$("#gbmPathwaysSearchBox").keydown(readGbmPathwaysSearchBox);

        cwMarkers.edges().unselectify();
        console.log("cwMarkers.reset");
        cwMarkers.reset();
        handleWindowResize();
        //requestNanoStringExpressionData();
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
   function newEdgeTypeSelection (){

      var edgeTypesToDisplay = edgeTypeSelector.val()
      console.log("new edge types selected: " + edgeTypesToDisplay);

      if(edgeTypesToDisplay == null){
         hideAllEdges()
         return;
         }
      console.log("   checking for allEdges");

         // remove other options, so allEdges includes them
      if($.inArray("allEdges", edgeTypesToDisplay) >= 0){
         console.log('  "allEdges" found');
         showAllEdges();
         return;
         }

      var nodesOfInterest = cwMarkers.filter('node:selected');

      hideAllEdges();

      console.log(" now looping through " + edgeTypesToDisplay);
      for(var i=0; i < edgeTypesToDisplay.length; i++){
        edgeType = edgeTypesToDisplay[i];
        filterString = 'edge[edgeType="' + edgeType + '"]';
        console.log("filter string: " + filterString);
        cwMarkers.filter(filterString).show();
        //cwMarkers.filter('edge[edgeType="mutantIn"]').show()
        } // for edgeType
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
   function showEdgesFromSelectedNodes(){

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
