<script>
//----------------------------------------------------------------------------------------------------
var cwAngio;   // move this into module when debugging settles down

var angioPathwaysModule = (function () {

  var cyDiv;
  var viewAbstractsButton, zoomSelectedButton, demoVizChangesButton;
  var searchBox;
  var mouseOverReadout;
  var edgeSelectionOn = false;

  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      cyDiv = $("#cwAngiogenesisDiv");
      //viewAbstractsButton = $("#cwAngioViewAbstractsButton");
      //zoomSelectedButton  = $("#cwAngioZoomSelectedButton");
      demoVizChangesButton = $("#angiogenesisDemoVizUpdateButton")
      demoVizChangesButton.click(angiogenesisDemoVizChanges);
      searchBox = $("#angiogenesisSearchBox");
      mouseOverReadout = $("#angioPathwaysMouseOverReadoutDiv")
      loadNetwork();
      $(window).resize(handleWindowResize);
      };

  //--------------------------------------------------------------------------------------------
  function loadNetwork () {

       // the pathways graph is included explicitly by widget.html, so the
       // angiogenesisNetwork is already defined
    console.log("loadANGIOPathwaysNetwork, node count: " + angiogenesisNetwork.elements.nodes.length);
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
        cwAngio.on('mouseover', 'node', function(evt){
           var node = evt.cyTarget;
           mouseOverReadout.text(node.data().label);
           })
        cwAngio.on('mouseover', 'edge', function(evt){
           var edge = evt.cyTarget;
           mouseOverReadout.text(edge.data().canonicalName);
           })
        cwAngio.on('select', 'edge', function(evt){
           var edge = evt.cyTarget;
           console.log("selected edge");
           var pmid = edge.data().pmid;
           console.log("pmid: " + pmid);
           openCenteredBrowserWindow("http://www.ncbi.nlm.nih.gov/pubmed/?term=" + pmid, "pubmed abstract", 800, 600)
           });
        //$("#cwAngioMovieButton").button()
        //zoomSelectedButton.button();
        //zoomSelectedButton.click(zoomSelection);
        //viewAbstractsButton.button();
        //viewAbstractsButton.click(toggleEdgeSelection);
        searchBox.keydown(doSearch);
        //$("#cwAngioMovieButton").click(cwAngiotogglePlayMovie);
        //$("#angioPathwaysSearchBox").keydown(readAngioPathwaysSearchBox);

        cwAngio.edges().unselectify();
        console.log("cwAngio.reset");
        cwAngio.reset();
        handleWindowResize();
        //requestNanoStringExpressionData();
        } // cy.ready
       })
    .cytoscapePanzoom({ });   // need to learn about options
    } // loadNetwork

   //----------------------------------------------------------------------------------------------------
   function handleWindowResize () {
      console.log("angioPathways window resize: " + $(window).width() + ", " + $(window).height());
      cyDiv.width(0.95 * $(window).width());
      cyDiv.height(0.8 * $(window).height());
      cwAngio.resize();
      cwAngio.fit(50);
      } // handleWindowResize


   //----------------------------------------------------------------------------------------------------
   function zoomSelection() {
      cwAngio.fit(cwAngio.$(':selected'), 50)
      }

   //----------------------------------------------------------------------------------------------------
   function toggleEdgeSelection () {
     if(edgeSelectionOn){
        cwAngio.edges().unselectify();
        edgeSelectionOn = false;
        viewAbstractsButton.button("option", "label", "Enable Abstracts");
        }
      else{
        cwAngio.edges().selectify();
        edgeSelectionOn = true;
        viewAbstractsButton.button("option", "label", "Disable Abstracts");
        }
      } // toggleEdgeSelection

   //----------------------------------------------------------------------------------------------------
   angiogenesisDemoVizChanges = function() {
      console.log("===== entering angiogenesisDemoVizChanges");

     nodeIds = nodeIDs()
     var noa = {};

     for(var i=0; i < nodeIds.length; i++){
        newScore = getRandomFloat(-8, 8);
        newCopyNumberIndex = getRandomInt(0,3);
        newCopyNumber = ["-2", "-1", "0", "1", "2"][newCopyNumberIndex]
        noa[nodeIds[i]] = {score: newScore, copyNumber: newCopyNumber};
       } // for i
     cwAngio.batchData(noa);
     } // angiogenesisDemoVizChanges

   //----------------------------------------------------------------------------------------------------
   function nodeIDs(){
     nodes = cwAngio.filter("node:visible");
     result = [];
     for(var i=0; i < nodes.length; i++){
       id = nodes[i].data()['id'];
       result.push(id);
       } // for i
     return(result)
     } // nodeIDs

   //----------------------------------------------------------------------------------------------------
   function nodeNames(){
     nodes = cwAngio.filter("node:visible");
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
               s = "cwAngio.filter('node[label=\"" + names[i] + "\"]').select()";
               console.log("select cmd: " + s);
               JAVASCRIPT_EVAL (s);
               } // if searchString matched beginning of node
            } // for i
         } // if 13 (return key)
      } // doSearch
//----------------------------------------------------------------------------------------------------
    function SetModifiedDate(){

        msg = {cmd:"getModuleModificationDate",
               callback: "DisplayAngioPathwaysModifiedDate",
               status:"request",
               payload:"angioPathways"
               };
        msg.json = JSON.stringify(msg);
        socket.send(msg.json);
    }
//----------------------------------------------------------------------------------------------------
    function DisplayAngioPathwaysModifiedDate(msg){
       document.getElementById("angioPathwaysDateModified").innerHTML = msg.payload;
       }

   //----------------------------------------------------------------------------------------------------
   return{
     init: function(){
       onReadyFunctions.push(initializeUI);
       addJavascriptMessageHandler("DisplayAngioPathwaysModifiedDate", DisplayAngioPathwaysModifiedDate);
       socketConnectedFunctions.push(SetModifiedDate);
       }
     };

   }); // angioPathwaysModule
//----------------------------------------------------------------------------------------------------
angioPathway = angioPathwaysModule()
angioPathway.init();

</script>
