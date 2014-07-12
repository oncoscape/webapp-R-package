<script>

var refnetColumns = [
         {sTitle: "A", sWidth: "12%"},
         {sTitle: "B", sWidth: "12%"},
         {sTitle: "type", sWidth: "12%"},
         {sTitle: "detectionMethod", sWidth: "12%"},
         {sTitle: "publicationID", sWidth: "12%"},
         {sTitle: "provider", sWidth: "12%"},
         {sTitle: "A.id", sWidth: "12%"},
         {sTitle: "B.id", sWidth: "12%"}
         ];

//--------------------------------------------------------------------------------------------------
onReadyFunctions.push(function() {

    console.log("==== refnet code.js document.ready");
    $("#requestInteractionsButton").click(requestRefNetInteractions);
    $("#clearInteractionsDataTableButton").click(clearInteractionsDataTable);
    $("#sendInteractionsToCyjsButton").click(sendInteractionsToCytoscape);
    $("#clearCyNetworkCurationButton").click(deleteCuratedNetworkCytoscapeGraph);

    window.interactionsShowAbstracts = false;
    window.interactions = [];

    $("#abstractSelectToggleButton").click(function() {
        if(window.interactionsShowAbstracts){
           window.interactionsShowAbstracts = false;
           $("#abstractSelectToggleButton").text("  Select Row   ")
           }
        else {
           $("#abstractSelectToggleButton").text("Show Abstracts")
           window.interactionsShowAbstracts = true;
           }
        console.log("toggling abstractSelectToggleButton: " + window.interactionsShowAbstracts);
        });

    $("#refnetResults").html('<table cellpadding="0" cellspacing="0" border="0" class="display" id="refnetTable"></table>');
    $("#refnetAccordion" ).accordion({
          heightStyle: "content",
          collapsible: true,
          activate: function(event, ui){
             console.log(" activating accordion");
             if(typeof(window.cwCuration != "undefined")){
                window.cwCuration.resize().fit(50);
                }
              }
            });

       // these two providers buttons are in widget.html, so handlers can be set
       // up now, even though the provider checkboxes do not yet exist

   $("#selectAllProvidersButton").click(function(){
        $("#refnetProvidersDiv  input[type=checkbox]").each(function(){this.checked = true})
        });

   $("#deselectAllProvidersButton").click(function(){
        $("#refnetProvidersDiv  input[type=checkbox]").each(function(){this.checked = false})
        });

    socketConnectedFunctions.push(initializeNetworkCurationServices);
    socketConnectedFunctions.push(createCuratedNetworkCytoscapeDisplay);
    socketConnectedFunctions.push(createRefNetProvidersUI);

    console.log("about to call .dataTable");
  
    $("#refnetTable").DataTable({
        "sDom": "Rlfrtip",
        "sDom": "Clfrtip",
        "bPaginate": false,
        "aoColumns": refnetColumns,
	"sScrollX": "100px",
        "iDisplayLength": 10,
        "fnInitComplete": function(){
            $(".display_results").show();
          }
         }); // dataTable

   
   $('#refnetTable tbody').on('click', 'tr', function () {
        var tblRef = $("#refnetTable").DataTable();
        //var name = $('td', this).eq(0).text();
        rowElement = $('td', this);
        var pmid = $('td', this).eq(4).text();
        var interaction = {};
        interaction["A"] = rowElement.eq(0).text();
        interaction["B"] = rowElement.eq(1).text();
        interaction["type"] = rowElement.eq(2).text();
        interaction["detectionMethod"] = rowElement.eq(3).text();
        interaction["pmid"] = rowElement.eq(4).text();
        interaction["provider"] = rowElement.eq(5).text();
        interaction["A.id"] = rowElement.eq(6).text();
        interaction["B.id"] = rowElement.eq(7).text();
        console.log(" show abstracts? " + window.interactionsShowAbstracts);
        console.log("pmid: " + pmid);
        console.log("selected row count: " + $("#refnetTable").DataTable().$("tr.row_selected").length);
        if(window.interactionsShowAbstracts){
           popupPubmedAbstract(pmid);
           }
        else{
           $(this).toggleClass('row_selected');
           window.interactions.push(interaction)
           }
        });
    console.log("leaving networkCreation onReadyFunction");
    });
//--------------------------------------------------------------------------------------------------
clearInteractionsDataTable = function()
{
    var tableRef = $("#refnetTable").dataTable();
    tableRef.fnClearTable();

} //clearInteractionsDataTable
//--------------------------------------------------------------------------------------------------
requestRefNetInteractions = function()
{

   var selectedProviderElements = $("#refnetProvidersDiv input[type=checkbox]:checked");
   var providerNames = [];

   for (var i=0; i < selectedProviderElements.length; i++) {
      providerNames.push(selectedProviderElements[i].attributes["id"].value)
      } // for i

   // console.log("providerNames: " + providerNames);

   genesRawText = $("#interactingGenesInput").val()
   if(genesRawText.length == 0){
      alert("no genes specified")
      return;
      }

   genes = genesRawText.split(" ");

   msg = {cmd: "fetchInteractions", status: "request", payload: {genes: genes,
                                                                 providers: providerNames}};

   msg.json = JSON.stringify(msg);
    // grab the providers from the checkboxes, something like this:
    // $('#refnetProvidersDiv checkboxes input:checked').each(function() {console.log($(this).attr('name'))})

   console.log(msg.json)



   newCursorValue = "progress"
   $("body").css("cursor", newCursorValue)
   $("#requestMGMTNetworkButton").css("cursor", "progress");
   $("#refnetResults").css("cursor", "progress");

   socket.send(msg.json);

} // requestRefNetInteractions
//--------------------------------------------------------------------------------------------------
displayInteractions = function(msg) {

   result = msg.payload;
   console.log("displayInteractions: ");

   newCursorValue = "default";
   $("body").css("cursor", newCursorValue);
   $("#requestMGMTNetworkButton").css("cursor", newCursorValue);
   $("#refnetResults").css("cursor", newCursorValue);

   // $("#refnetResults").text(result);

   if(msg.status == "success"){
      var refnetTableAsJSON = msg.payload;
      var tableRef = $("#refnetTable").dataTable();
      tableRef.fnAddData(refnetTableAsJSON)
      }
   else{
      alert("RefNet error: " + msg.payload);
      }

} // displayInteractions
//--------------------------------------------------------------------------------------------------
displayRefNetProviders = function(msg)
{
   console.log("=== displayRefNetProviders");
   //debugger;
   // "<input type='checkbox' id='check1'><label for='check1'>B</label>")
   console.log("     leaving displayRefNetProviders");

   selectAllButtonText = "<button id='selectAllProvidersButton'>All</button>";
   deselectAllButtonText = "<button id='deselectAllProvidersButton'>None</button>";
   htmlText = ""; // selectAllButtonText + deselectAllButtonText + "<br>";

   providers = msg.payload.native.concat(msg.payload.PSICQUIC)

   for(var p=0; p < providers.length; p++) {
      provider = providers[p];
      newMarkup = "<input type='checkbox' id='" + provider + "'>" +
                   "<label for='" + provider + "'>" +
                     provider + "</label> &nbsp; ";
      if((p % 5) == 0) {
         console.log("adding br linebreak");
         htmlText += "<br>";
         }
      htmlText += newMarkup
      console.log(provider);
      } // for p

   $("#refnetProvidersDiv").html(htmlText);


} // displayRefNetProviders
//--------------------------------------------------------------------------------------------------
initializeNetworkCurationServices = function()
{
    console.log("about to request 'intializeNetworkCurationServices'")
    msg = {cmd:"initializeNetworkCurationServices", status:"request", payload:""};
    msg.json = JSON.stringify(msg);
    socket.send(msg.json);

} // initializeNetworkCurationServices
//--------------------------------------------------------------------------------------------------
// todo:  not really tissueIDs.  this will be generalized through oncoscape to be "idsForX"
idsForNetworkCuration = function(msg)
{
  geneSymbols = msg.payload

  s = "";

  for(var i=0; i < geneSymbols.length; i++){
     console.log("geneSymbol for networkCuration: " + geneSymbols[i]);
     s += geneSymbols[i] + " ";
     } // for i

   $("#interactingGenesInput").val(s);

} // idsForNetworkCuration
//--------------------------------------------------------------------------------------------------
createRefNetProvidersUI = function()
{
    console.log("about to request RefNet providers")

    msg = {cmd:"fetchRefNetProviders", status:"request", payload:""};
    msg.json = JSON.stringify(msg);
    socket.send(msg.json);

} // createRefNetProvidersUI
//--------------------------------------------------------------------------------------------------
displayPubmedAbstractDialog = function()
{
    console.log("about to request pubmed abstract text");
    pmid = "16226712"

    popupPubmedAbstract(pmid, pmid, 700, 600);

} // displayPubmedAbstractDialog
//--------------------------------------------------------------------------------------------------
displayPubmedAbstractText = function(msg)
{
   console.log("displayPubmedAbstractText");

   window.pmat = msg.payload;
   

} // displayPubmedAbstractText
//--------------------------------------------------------------------------------------------------
function popupPubmedAbstract(pmid)
{
    title = "pubmedAbstract"
    w = 700;
    h = 600
       // Fixes dual-screen position                         Most browsers      Firefox
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
    var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;

    width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
    var top = ((height / 2) - (h / 2)) + dualScreenTop;
    url = "http://www.ncbi.nlm.nih.gov/pubmed/?term=" + pmid;
    var newWindow = window.open(url, title, 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);

    // Puts focus on the newWindow
    if (window.focus) {
        newWindow.focus();
    }
}
//--------------------------------------------------------------------------------------------------
sendInteractionsToCytoscape = function()
{

   console.log("=== sendInteractionsToCytoscape");
   msg = {cmd:"prepNewCyjsInteractions", status:"request", payload:window.interactions}
   msg.json = JSON.stringify(msg);
   socket.send(msg.json);
    
} // sendInteractionsToCytoscape
//--------------------------------------------------------------------------------------------------
addInteractionsToNetworkCuratorCyjs = function(msg)
{

   console.log("addInteractionsToNetworkCuratorCyjs: " + msg)
   window.msg = msg
   cync = window.cwCuration;
   interactions = msg.payload
   for(var i=0; i < interactions.length; i++) {
      nodeA = interactions[i]["A"];
      cync.add([{group: "nodes", data:{id: nodeA}, position:{x:220, y:220}}])
      nodeB = interactions[i]["B"];
      cync.add([{group: "nodes", data:{id: nodeB}, position:{x:280, y:280}}])
      cync.add([{group: "edges", data:{id: "e" + i, 
                                       source: nodeA,
                                       target: nodeB}}])
      } // for i

   cync.resize().fit(50)   
   options = {
      name: 'breadthfirst',
      fit: true, // whether to fit the viewport to the graph
      ready: undefined, // callback on layoutready
      stop: undefined, // callback on layoutstop
      directed: false, // whether the tree is directed downwards (or edges can point in any direction if false)
      padding: 30, // padding on fit
      circle: false, // put depths in concentric circles if true, put depths top down if false
      roots: undefined, // the roots of the trees
      maximalAdjustments: 0 // how many times to try to position the nodes in a maximal way (i.e. no backtracking)
      };

   cync.layout(options);
   $("#refnetAccordion").accordion('option', 'active' , 3);

} // addInteractionsToNetworkCuratorCyjs
//--------------------------------------------------------------------------------------------------
createCuratedNetworkCytoscapeDisplay = function()
{

   var minimalGraph = [{group: "nodes", data: { id: "n0" }, position: { x: 100, y: 100 } },
                       {group: "nodes", data: { id: "n1" }, position: { x: 200, y: 200 } },
                       {group: "edges", data: { id: "e0", source: "n0", target: "n1" } }
                      ];

   var simpleStyle =  cytoscape.stylesheet().selector('node').css({
           'content': 'data(id)',
           'text-valign': 'center',
           'color': 'white',
           'text-outline-width': 2,
           'text-outline-color': '#888'
       }).selector('edge').css({
           'target-arrow-shape': 'triangle',
           'content': 'data(type)',
           'text-outline-color': '#FFFFFF',
           'text-outline-opacity': '1',
           'text-outline-width': 2,
           'text-valign': 'center',
           'color': '#777777',
           'width': '2px'
       }).selector(':selected').css({
           'background-color': 'black',
           'line-color': 'black',
           'target-arrow-color': 'black',
           'source-arrow-color': 'black',
           'color': 'black'
       });


   cwCuration = $("#cyNetworkCuration");
   cwCuration.cytoscape({
       // elements: minimalGraph,
       style: simpleStyle,
       showOverlay: false,
       minZoom: 0.01,
       maxZoom: 8.0,
       layout: {
         name: "preset",
         fit: true
         },
    ready: function() {
        console.log("cwCuration ready");
        cwCuration = this;
        window.cwCuration = cwCuration;
        window.cwCurationEdgeSelectionOn = false;
        cwCuration.on('mouseover', 'node', function(evt){
           var node = evt.cyTarget;
           //$("#gbmPathwaysMouseOverReadoutDiv").text(node.data().label);
           })
        cwCuration.on('mouseover', 'edge', function(evt){
           var edge = evt.cyTarget;
           //$("#gbmPathwaysMouseOverReadoutDiv").text(edge.data().canonicalName);
           })
        cwCuration.on('select', 'edge', function(evt){
           var edge = evt.cyTarget;
           console.log("selected edge");
           //var pmid = edge.data().pmid;
           //console.log("pmid: " + pmid);
           //window.open("http://www.ncbi.nlm.nih.gov/pubmed/?term=" + pmid,
           //            "pubmed abstract", "height=600,width=800");
           });
        $("#cwCurationMovieButton").button()
        $("#cwCurationZoomSelectedButton").button();
        $("#cwCurationViewAbstractsButton").button();
        //$("#cwCurationViewAbstractsButton").click(toggleEdgeSelection);
        //$("#cwCurationMovieButton").click(cwCurationtogglePlayMovie)

        cwCuration.edges().unselectify();
        //window.cwCurationEdgeSelectionOn = false;
        console.log("cwCuration.reset");
        cwCuration.reset();
        cwCuration.fit(20);
        cwCuration.resize().fit(50)   
        } // cy.ready
       })
    // .cytoscapePanzoom({ });   // need to learn about options

} // createCuratedNetworkCytoscapeDisplay
//--------------------------------------------------------------------------------------------------
deleteCuratedNetworkCytoscapeGraph = function()
{
   cync = window.cwCuration;
   cync.remove(cync.edges());
   cync.remove(cync.nodes());

} // deleteCuratedNetworkCytoscapeGraph
//--------------------------------------------------------------------------------------------------
addJavascriptMessageHandler("displayInteractions", displayInteractions);
addJavascriptMessageHandler("displayRefNetProviders", displayRefNetProviders);
addJavascriptMessageHandler("displayPubmedAbstractText", displayPubmedAbstractText);
addJavascriptMessageHandler("addInteractionsToNetworkCuratorCyjs", addInteractionsToNetworkCuratorCyjs);
addJavascriptMessageHandler("idsForNetworkCuration", idsForNetworkCuration);
//----------------------------------------------------------------------------------------------------
</script>

