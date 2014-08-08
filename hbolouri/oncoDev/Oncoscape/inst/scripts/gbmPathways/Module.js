<script>
//----------------------------------------------------------------------------------------------------
var cwGBM;

var gbmPathwaysModule = (function () {

  var cyDiv;
  var viewAbstractsButton, zoomSelectedButton;
  var searchBox;
  var mouseOverReadout;
  var edgeSelectionOn = false;

  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      cyDiv = $("#cyGbmPathways");
      viewAbstractsButton = $("#cwGBMViewAbstractsButton");
      zoomSelectedButton  = $("#cwGBMZoomSelectedButton");
      searchBox = $("#gbmPathwaysSearchBox");
      mouseOverReadout = $("#gbmPathwaysMouseOverReadoutDiv")
      loadNetwork();
      $(window).resize(handleWindowResize);
      };

  //--------------------------------------------------------------------------------------------
  function loadNetwork () {

       // the pathways graph is included explicitly by widget.html, so the
       // curatedGBMpathways is already defined
    console.log("loadGBMPathwaysNetwork, node count: " + curatedGBMpathways.elements.nodes.length);
    cwGBM = $("#cyGbmPathways");
    cwGBM.cytoscape({
       elements: curatedGBMpathways.elements,
       style: curatedGBMVizmap[0].style,
       showOverlay: false,
       minZoom: 0.01,
       maxZoom: 8.0,
       layout: {
         name: "preset",
         fit: true
         },
     ready: function() {
        console.log("cwGBM ready");
        cwGBM = this;
        cwGBM.on('mouseover', 'node', function(evt){
           var node = evt.cyTarget;
           mouseOverReadout.text(node.data().label);
           })
        cwGBM.on('mouseover', 'edge', function(evt){
           var edge = evt.cyTarget;
           mouseOverReadout.text(edge.data().canonicalName);
           })
        cwGBM.on('select', 'edge', function(evt){
           var edge = evt.cyTarget;
           console.log("selected edge");
           var pmid = edge.data().pmid;
           console.log("pmid: " + pmid);
           openCenteredBrowserWindow("http://www.ncbi.nlm.nih.gov/pubmed/?term=" + pmid, "pubmed abstract", 800, 600)
           });
        $("#cwGBMMovieButton").button()
        zoomSelectedButton.button();
        zoomSelectedButton.click(zoomSelection);
        viewAbstractsButton.button();
        viewAbstractsButton.click(toggleEdgeSelection);
        searchBox.keydown(doSearch);
        //$("#cwGBMMovieButton").click(cwGBMtogglePlayMovie);
        //$("#gbmPathwaysSearchBox").keydown(readGbmPathwaysSearchBox);

        cwGBM.edges().unselectify();
        console.log("cwGBM.reset");
        cwGBM.reset();
        handleWindowResize();
        //requestNanoStringExpressionData();
        } // cy.ready
       })
    .cytoscapePanzoom({ });   // need to learn about options

    } // loadGBMPathwaysNetwork

   //----------------------------------------------------------------------------------------------------
   function handleWindowResize () {
      console.log("gbmPathways window resize: " + $(window).width() + ", " + $(window).height());
      cyDiv.width(0.95 * $(window).width());
      cyDiv.height(0.8 * $(window).height());
      cwGBM.resize();
      cwGBM.fit(50);
      } // handleWindowResize


   //----------------------------------------------------------------------------------------------------
   function zoomSelection() {
      cwGBM.fit(cwGBM.$(':selected'), 50)
      }

   //----------------------------------------------------------------------------------------------------
   function toggleEdgeSelection () {
     if(edgeSelectionOn){
        cwGBM.edges().unselectify();
        edgeSelectionOn = false;
        viewAbstractsButton.button("option", "label", "Enable Abstracts");
        }
      else{
        cwGBM.edges().selectify();
        edgeSelectionOn = true;
        viewAbstractsButton.button("option", "label", "Disable Abstracts");
        }
      } // toggleEdgeSelection


   //----------------------------------------------------------------------------------------------------
   nodeNames = function(){
     nodes = cwGBM.filter("node:visible");
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
               s = "cwGBM.filter('node[name=\"" + names[i] + "\"]').select()";
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

   }); // gbmPathwaysModule
//----------------------------------------------------------------------------------------------------
gbmPathway = gbmPathwaysModule()
gbmPathway.init();

</script>