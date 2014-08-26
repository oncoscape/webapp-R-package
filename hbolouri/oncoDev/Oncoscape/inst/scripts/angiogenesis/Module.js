<script>
//----------------------------------------------------------------------------------------------------
var cwAngio;   // move this into module when debugging settles down

var angioPathwaysModule = (function () {

  var cyDiv;
  var viewAbstractsButton, zoomSelectedButton, demoVizChangesButton;
  var tissueMenu, movieButton;
  var searchBox;
  var mouseOverReadout;
  var edgeSelectionOn = false;
  var expressionData;   // consists of a gene list, a tissue list, and the data (a list of 
                        // gene/value pairs, each list named by a tissue (patient) id

  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      cyDiv = $("#cwAngiogenesisDiv");
      //viewAbstractsButton = $("#cwAngioViewAbstractsButton");
      //zoomSelectedButton  = $("#cwAngioZoomSelectedButton");

      tissueMenu = $("#hypoxiaSampleSelector");
      tissueMenu.change(tissueSelectorChanged);

      movieButton = $("#hypixaMovieButton");
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
        } // cy.ready
       })
    .cytoscapePanzoom({ });   // need to learn about options
    } // loadNetwork

   //----------------------------------------------------------------------------------------------------
   function handleWindowResize () {
      console.log("angioPathways window resize: " + $(window).width() + ", " + $(window).height());
      cyDiv.width(0.95 * $(window).width());
      cyDiv.height(0.9 * $(window).height());
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
   function transformMatrixToPatientOrientedNamedList(mtx) {

        // geneNames are repeated in each element; grab them from the first one
      //debugger;
      var geneNames = Object.keys(mtx[0]);
        // the last element was originally (in R) the row name -- the tissue
        // gene1: expression, gene2: expession, ... rowname: 0445.T.1
      geneCount = geneNames.length - 1;
      geneNames = geneNames.slice(0,geneCount);
      var tissueNames = [];
      max = mtx.length;
      namedList={};

      for(var r=0; r < max; r++){
         row = mtx[r]
         tissueName = row["rowname"][0];
         tissueNames.push(tissueName);
         namedList[tissueName] = row;
         } // for r

      result = {genes: geneNames, tissues: tissueNames, values: namedList};
      return(result);

      } // transformMatrixToPatientOrientedNamedList

   //----------------------------------------------------------------------------------------------------

   
   // initially, a random set of patient, tissue of sample ids.  soon set by humans
   // these five are those from   fivenum(matrix[, "KDR"])
   //   TCGA.02.0058  TCGA.06.0132  TCGA.02.0034  TCGA.12.0657  TCGA.06.0155 
   //    -3.10414205   -0.62431669    0.05214659    0.60673149    4.43374413 
   function demoTissues() {
      which = getRandomInt(1,4);
      patients = ["TCGA.02.0058", "TCGA.06.0132", "TCGA.02.0034", "TCGA.12.0657", "TCGA.06.0155",
                  "TCGA.06.0155", "TCGA.06.0162", "TCGA.06.1087", "TCGA.12.0778", 
                  "TCGA.14.0871", "TCGA.06.0192"];
      return(patients);
      }
   //----------------------------------------------------------------------------------------------------
   function angiogenesisDemoVizChanges() {
      console.log("===== entering angiogenesisDemoVizChanges");
      request_mRNA_data(demoTissues(), geneSymbols());   // entities: patient, tissue or sample ids
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
   function nodeNames() {

     nodes = cwAngio.filter("node:visible");
     result = [];
     for(var i=0; i < nodes.length; i++){
       result.push(nodes[i].data().label)
       } // for i
     return(result)
     } // nodeNames

   //----------------------------------------------------------------------------------------------------
   function geneSymbols() {

     nodes = cwAngio.filter("node");
     result = [];
     for(var i=0; i < nodes.length; i++){
       sym = nodes[i].data().geneSymbol
       if(typeof(sym) != "undefined")
          result.push(sym)
       } // for i
     return(result)
     } // geneSymbols

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
    function request_mRNA_data(entities, features) {

      msg = {cmd:"get_mRNA_data",
              callback: "handle_mRNA_data",
              status:"request",
              payload:{entities: entities, features: features}
              };
       msg.json = JSON.stringify(msg);
       socket.send(msg.json);
       }

    //----------------------------------------------------------------------------------------------------
    function addTissueIDsToSelector (tissueIDs) {
      tissueMenu.empty();
      if(tissueIDs.length == 0) {
         alert("angiogenesis received empty tissueIDs list")
         return;
         }
      
      // every set of tissueIDs needs an aggregate, or average tissue

      //optionMarkup = "<option> average (of " + tissueIDs.length + ") </option>";
      optionMarkup = "<option>average</option>";
      tissueMenu.append(optionMarkup);
        // msg = {cmd: "requestAverageExpression", status: "request", payload: tissueIDs};
        // console.log(msg)
        //   msg.json = JSON.stringify(msg);
        //   console.log(msg.json)
        //   socket.send(msg.json);

      for(var i=0; i < tissueIDs.length; i++){
         tissueName = tissueIDs[i]
         optionMarkup = "<option>" + tissueName + "</option>";
         tissueMenu.append(optionMarkup);
         } // for i

     } // addTissueIDsToSelector
    //----------------------------------------------------------------------------------------------------
    function handle_mRNA_data(msg) {

       console.log("handling mRNA data");
       var mtx = JSON.parse(msg.payload.mtx);
       expressionData = transformMatrixToPatientOrientedNamedList(mtx);
       addTissueIDsToSelector(expressionData.tissues);

       } // handle_mRNA_data

    //----------------------------------------------------------------------------------------------------
    function tissueSelectorChanged() {

       tissueID = tissueMenu.val()
       displayTissue(tissueID);

       } // tissueSelectorChanged

    //----------------------------------------------------------------------------------------------------
    function displayTissue(tissueID) {

       if(expressionData.tissues.indexOf(tissueID) < 0){
          alert(tissueId + " not found in current expressionData");
          return;
          }
       mRNA = expressionData.values
       genes = expressionData.genes;
       tissues = expressionData.tissues;
       console.log("expr for " + genes.length + " genes, and " + tissues.length + " tissues");
       var noa = {};  // new node attributes to assign in the network

       for(var g=0; g < genes.length; g++){
          gene = genes[g];
          newScore = mRNA[tissueID][gene][0];
          console.log("  set score of " + gene + " to " + newScore);
          filterString = '[geneSymbol="' + gene + '"]'
          console.log("  finding id for geneSymbol: " + gene);
          nodeID = cwAngio.nodes(filterString)[0].data("id");
          noa[nodeID] = {score: newScore};
          } // for g

      // cwAngio.nodes('[geneSymbol="KDR"]')[0].data()
      // nodeIds = nodeIDs();
      // var noa = {};
      // for(var i=0; i < nodeIds.length; i++){
      //   debugger;
      //   newScore = getRandomFloat(-8, 8);
      //   newCopyNumberIndex = getRandomInt(0,3);
      //   newCopyNumber = ["-2", "-1", "0", "1", "2"][newCopyNumberIndex]
      //   noa[nodeIds[i]] = {score: newScore, copyNumber: newCopyNumber};
      //   } // for i

       cwAngio.batchData(noa);

       } 

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
       addJavascriptMessageHandler("handle_mRNA_data", handle_mRNA_data);
       socketConnectedFunctions.push(SetModifiedDate);
       if(typeof(window.tabsAppRunning) == "undefined") {
          socketConnectedFunctions.push(angiogenesisDemoVizChanges)
          }
       } // init
     }; 

   }); // angioPathwaysModule
//----------------------------------------------------------------------------------------------------
angioPathway = angioPathwaysModule()
angioPathway.init();

</script>
