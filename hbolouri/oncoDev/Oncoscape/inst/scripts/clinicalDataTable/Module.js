<script>
//----------------------------------------------------------------------------------------------------
var ClinicalTableModule = (function () {

var currentIDs;   // assign this to the full content in the tbl on startup
var tableRef;
var pcaButton;
var displayDiv;

   //--------------------------------------------------------------------------------------------
   function initializeUI(){
      pcaButton = $("#toPCAButton");
      pcaButton.click(function(){sendCurrentIDsToModule("PCA")});
      displayDiv = $("#clinicalDataTableDiv");
      $(window).resize(handleWindowResize);
      handleWindowResize();
      $("#ageAtDxMinSlider").slider({
         change: function(event, ui) {$("#ageAtDxMinSliderReadout").text (ui.value)},
         min: 10,
         max: 89,
         value: 10
         });
    $("#ageAtDxMinSliderReadout").text(10);

    $("#ageAtDxMaxSlider").slider({
       change: function(event, ui) {$("#ageAtDxMaxSliderReadout").text (ui.value)},
       min: 10,
       max: 89,
       value: 89
       });
    $("#ageAtDxMaxSliderReadout").text(89);

    $("#overallSurvivalMinSlider").slider({
       change: function(event, ui) {$("#overallSurvivalMinSliderReadout").text (ui.value)},
       min: 0,
       max: 11,
       value: 0
       });
    $("#overallSurvivalMinSliderReadout").text(0);

    $("#overallSurvivalMaxSlider").slider({
       change: function(event, ui) {$("#overallSurvivalMaxSliderReadout").text (ui.value)},
       min: 0,
       max: 11,
       value: 11
       });
    $("#overallSurvivalMaxSliderReadout").text(11);
    //$("#applyClinicalTablesFiltersSlidersButton").button();
    //$("#showAllClinicalTablesRowsButton").button()
    $("#showAllClinicalTablesRowsButton").click(showAllRows)
    $("#applyClinicalTablesFiltersSlidersButton").click(readAndApplyClinicalTableFilters);
    $("#toMarkersAndTissuesButton").prop("disabled",true);
    $("#toGBMPathwaysButton").prop("disabled",true);
    $("#toSurvivalStatsButton").prop("disabled",true);
    $("#toTimeLinesButton").prop("disabled",true);
    };

   //--------------------------------------------------------------------------------------------
   sendCurrentIDsToModule = function(moduleName) {
      console.log("entering sendCurrentIDsToModule");
      var rows = tableRef._('tr', {"filter":"applied"});   // cryptic, no?
      var currentIDs = []
      for(var i=0; i < rows.length; i++) 
          currentIDs.push(rows[i][0]);
      console.log(currentIDs.length + " patientIDs going to " + moduleName)
      callback = moduleName + "HandlePatientIDs";
      msg = {cmd:"sendPatientIDsToModule",
             callback: callback,
             status:"request",
             payload:{targetModule: moduleName,
                      ids: currentIDs}
             };
      msg.json = JSON.stringify(msg);
      //console.log(msg.json);
      socket.send(msg.json);
      } // sendTissueIDsToModule

//----------------------------------------------------------------------------------------------------
   function showAllRows() {
      tableRef.fnFilter("", 0);
      }

   //--------------------------------------------------------------------------------------------
   function readAndApplyClinicalTableFilters() {
      console.log("readAndApplyClinicalTableFilters")
      var ageAtDxMin = $("#ageAtDxMinSliderReadout").val()
      var ageAtDxMax = $("#ageAtDxMaxSliderReadout").val()
      var overallSurvivalMin = $("#overallSurvivalMinSliderReadout").val()
      var overallSurvivalMax = $("#overallSurvivalMaxSliderReadout").val()

      msg = {cmd:"filterPatientHistory", 
             callback: "handleFilterPatientHistory",
             status:"request",
             payload:{ageAtDxMin: ageAtDxMin,
                      ageAtDxMax: ageAtDxMax,
                      overallSurvivalMin: overallSurvivalMin,
                      overallSurvivalMax: overallSurvivalMax}};
      msg.json = JSON.stringify(msg);
      console.log(msg.json);
      socket.send(msg.json);
      } // readAndApplyClinicalTableFilters 


   //--------------------------------------------------------------------------------------------
   function handleFilterPatientHistory(msg) {
      console.log("=== handleFilterPatientHistory");
      console.log(msg);
      if(msg.status != "success"){
         alert("handleFilterClinicalDataTable error: " + msg.payload);
         return;
         }

      var count = msg.payload.count;
      var ids = msg.payload.ids;
      console.log("--- filtered ids returned by Oncoscape: " + ids);

        // having trouble getting visible tissueIDs from DataTable for now
        // an imperfect workaround:  save them to a global variable
        // TODO:  this does not work with direct in-browser filtering of the table

       // if tissueIDs is a single string, then 'length' returns the number
       // of characters in the string, not the number of elements in the array
       // protect against this.

     if(count == 1){
        currentIDs = [ids]
        filterString = ids
        }
     else{
        currentIDs =  ids
        filterString = ids[0];
        for(var i=1; i < ids.length; i++){
           filterString += "|" + ids[i]
           }
        } // if more than one id

      console.log("---- clinicalDataTable2.handleFilterClinicalDataTable");
      console.log(filterString)
      console.log("about to call fnFilter");
      tableRef.fnFilter(filterString, 0, true);
      $("#tabs").tabs( "option", "active", 0);
      } // handleFilterClinicalDataTable 


   //--------------------------------------------------------------------------------------------
  handleWindowResize = function(){
      displayDiv.width($(window).width() * 0.95);
      displayDiv.height($(window).height() * 0.95);
     }; // handleWindowResize

   //--------------------------------------------------------------------------------------------
  requestData = function(){
     console.log("cdt requests data");
     payload = ""; // demo/clinicalTable320.RData";
     msg = {cmd: "getPatientHistory", callback: "handlePatientHistory", status: "request", 
            payload: payload};
     msg.json = JSON.stringify(msg);
     socket.send(msg.json);
     };

   //--------------------------------------------------------------------------------------------
  function displayTable(msg){
     console.log("entering ctbl displayTable");
     tblColumnNames = msg.payload.colnames;
     columnTitles = [];
     for(var i=0; i < tblColumnNames.length; i++){
        columnTitles.push({sTitle: tblColumnNames[i]});
        }
     
     console.log(columnTitles);

     displayDiv.html('<table cellpadding="0" cellspacing="0" margin-left="10" border="1" class="display" id="clinicalTable"></table>');
     $("#clinicalTable").dataTable({
        "sDom": "Rlfrtip",
         sDom: 'C<"clear">lfrtip',
        "aoColumns": columnTitles,
	"sScrollX": "100px",
        "iDisplayLength": 25,
         bPaginate: true,
        "scrollX": true,
        "fnInitComplete": function(){
            $(".display_results").show();
            }
         }); // dataTable

     console.log("displayTable adding data to table");
     tableRef = $("#clinicalTable").dataTable();
     tableRef.fnAddData(msg.payload.mtx);
     }; // displayTable


  return{
    requestData: requestData,
    init: function(){
      onReadyFunctions.push(initializeUI);
      addJavascriptMessageHandler("handlePatientHistory", displayTable);
      addJavascriptMessageHandler("handleFilterPatientHistory", handleFilterPatientHistory);
      addJavascriptMessageHandler("PatientHistoryHandlePatientIDs", handleFilterPatientHistory);
      socketConnectedFunctions.push(requestData);
      }
    }; // returned object

  }); // DateAndTimeModule

//----------------------------------------------------------------------------------------------------
ctbl = ClinicalTableModule();
ctbl.init();

</script>