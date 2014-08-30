<script>
//----------------------------------------------------------------------------------------------------
var ClinicalTableModule = (function () {

var currentIDs;   // assign this to the full content in the tbl on startup
var tableRef;
//var pcaButton;
//var timeLinesButton;
var ClTblsendSelectionMenu;
var PatientMenu;
var displayDiv;
var ClinicalTableTabNum=1;
var ThisModuleName = "ClinicalTable"
      
   //--------------------------------------------------------------------------------------------
   function initializeUI(){

      displayDiv = $("#clinicalDataTableDiv");
      $(window).resize(handleWindowResize);
      handleWindowResize();

      SaveSelectedButton = $("#toSavedSelectionButton");
      SaveSelectedButton.click(function(){sendCurrentIDsToSelection()});

      PatientMenu = d3.select("#useSavedSelectionButton")
            .append("g")
            .append("select")
            .on("focus",function(d){ ctbl.UpdateSelectionMenu()})
            .on("change", function() {
                   getSelectionbyName(this.value, callback="ChangeTablePatientSelection"); 
            })
            ;
 
        ClTblsendSelectionMenu = $("#ClTblsendSelectiontoModuleButton")
        ClTblsendSelectionMenu.change(sendToModuleChanged);
        ClTblsendSelectionMenu.empty();
        
        ClTblsendSelectionMenu.append("<option>Send Selection to:</option>")
        ModuleNames = getSelectionDestinations()
        for(var i=0;i< ModuleNames.length; i++){
           var SendToModule = ModuleNames[i]
           if(SendToModule !== ThisModuleName){
              optionMarkup = "<option>" + SendToModule + "</option>";
              ClTblsendSelectionMenu.append(optionMarkup);
           }
        }  

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
    $("#toTimeLinesButton").prop("disabled",false);
    };

    //----------------------------------------------------------------------------------------------------
     function sendToModuleChanged() {

       ModuleName = ClTblsendSelectionMenu.val()
       SelectedPatientIDs = currentSelectedIDs()
       if(ModuleName == "Save Selection"){
          
       }
       if(validSelectionToSend(ModuleName, SelectedPatientIDs)){
         console.log(SelectedPatientIDs.length + " patientIDs going to " + ModuleName)    
         sendSelectionToModule(ModuleName, SelectedPatientIDs);
       }
       ClTblsendSelectionMenu.val("Send Selection to:")
    } // sendToModuleChanged


  //--------------------------------------------------------------------------------------------
   function sendCurrentIDsToSelection () {
      console.log("entering sendCurrentIDsToSelection");

      var selectionname = PromptForSelectionName()
           if(typeof(selectionname) !== "string")  
           return;

      var currentIDs = currentSelectedIDs()
       console.log(currentIDs.length + " patientIDs going to SavedSelection")

      var NewSelection = {   
                    "selectionname": selectionname,
         			"PatientIDs" : currentIDs,
         			"Tab": "ClinicalTable",
         			"Settings": {ageAtDxMin: $("#ageAtDxMinSliderReadout").val(),
                      ageAtDxMax: $("#ageAtDxMaxSliderReadout").val(),
                      overallSurvivalMin: $("#overallSurvivalMinSliderReadout").val(),
                      overallSurvivalMax: $("#overallSurvivalMaxSliderReadout").val()}
         		}
 
       addSelection(NewSelection);
       
      } // sendTissueIDsToModule
  //--------------------------------------------------------------------------------------------
   function validSelectionToSend(modulename, ids){
       if(modulename == "PCA") 
          return checkBeforeSendSelectionsToPCA(ids)
       return true;
    }
   //--------------------------------------------------------------------------------------------
   function checkBeforeSendSelectionsToPCA(ids){
      var minimumPatientsForPCA = 8;
      if(ids.length < minimumPatientsForPCA){
         alert("Error! " + minimumPatientsForPCA + " or more patients needed to calculate PCA");
         return false;
         }
      return true;
      } // checkBeforeSendSelectionsToPCA

   //----------------------------------------------------------------------------------------------------
   function currentSelectedIDs(){
      var rows = tableRef._('tr', {"filter":"applied"});   // cryptic, no?
      var currentIDs = []
      for(var i=0; i < rows.length; i++) 
          currentIDs.push(rows[i][0]);

      return(currentIDs)

      } // currentSelectedIDS

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
    function SendSelectionToFilterTable(msg){
       console.log("==== Send Selection IDs to Filter Table")
       
      if(msg.status != "success"){
         alert("SendSelectioToFilterTable error: " + msg.payload);
         return;
         }

       patientIDs = []
       selections = msg.payload;
       d3.values(selections).forEach(function(d){ 
            d.patientIDs.forEach(function(id){
               if(patientIDs.indexOf(id) == -1) patientIDs.push(id)
            })
        })
  
       var payload = {
           ids: patientIDs,
           count: patientIDs.length
         }

	var	msg = {
		   cmd: "handleFilterPatientHistory",
		   callback: "",
		   status: "success",
		   payload : payload
		}
       handleFilterPatientHistory(msg);
    }
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
      //console.log(filterString)
      console.log("about to call fnFilter");
      tableRef.fnFilter(filterString, 0, true);
      $("#tabs").tabs( "option", "active", ClinicalTableTabNum);
      } // handleFilterClinicalDataTable 


   //--------------------------------------------------------------------------------------------
  function handleWindowResize(){
      displayDiv.width($(window).width() * 0.95);
      displayDiv.height($(window).height() * 0.95);
      $("#clinicalDataTableControlsDiv").width($(window).width() * 0.95);
     }; // handleWindowResize

   //--------------------------------------------------------------------------------------------
  function requestData (){
     console.log("cdt requests data");
     payload = ""; // demo/clinicalTable320.RData";
     msg = {cmd: "getTabularPatientHistory", callback: "handlePatientHistory", status: "request", 
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
        "scrollY": true,
        "fnInitComplete": function(){
            $(".display_results").show();
            }
         }); // dataTable

     console.log("displayTable adding data to table");
     tableRef = $("#clinicalTable").dataTable();
     tableRef.fnAddData(msg.payload.mtx);
     }; // displayTable

//----------------------------------------------------------------------------------------------------
//    function DisplayAboutModule(){
        
//        var ThisModuleName = "Clinical DataTable"
//        var Folder = "clinicalDataTable"
//        var CreatedBy= ["Paul Shannon"]
//        var MaintainedBy = "Paul Shannon"
//        var Contact = 

//        var info = {Modulename: ThisModuleName, Folder: Folder, CreatedBy: CreatedBy, MaintainedBy: MaintainedBy}
//        about.SetAboutInfo(info)

//    }
//----------------------------------------------------------------------------------------------------
 //   function DisplayModuleTooltip(){
       
//    }

//----------------------------------------------------------------------------------------------------
  return{
    requestData: requestData,
    init: function(){
      addSelectionDestination(ThisModuleName)   
      onReadyFunctions.push(initializeUI);
      addJavascriptMessageHandler("handlePatientHistory", displayTable);
      addJavascriptMessageHandler("handleFilterPatientHistory", handleFilterPatientHistory);
      addJavascriptMessageHandler("PatientHistoryHandlePatientIDs", handleFilterPatientHistory);
      addJavascriptMessageHandler("ChangeTablePatientSelection", SendSelectionToFilterTable)
      addJavascriptMessageHandler("ClinicalTableHandlePatientIDs", handleFilterPatientHistory)

      socketConnectedFunctions.push(requestData);
      },
    
    //--------------------------------------------------------------------------------------------
    UpdateSelectionMenu: function(){           
                  
      PatientMenu.selectAll("option")
                 .data(getSelectionNames(), function(d){return d;})
                 .enter()
                        .append("option")
                        .attr("value", function(d){return d})
                        .text(function(d) { return d})
                ;
     }


    }; // returned object

  }); // DateAndTimeModule

//----------------------------------------------------------------------------------------------------
ctbl = ClinicalTableModule();
ctbl.init();

</script>