<script>
//----------------------------------------------------------------------------------------------------
var ClinicalTableModule = (function () {

var currentIDs;   // assign this to the full content in the tbl on startup
var tableRef;
var ClTblsendSelectionMenu;
var PatientMenu;
var displayDiv;
var ThisModuleName = "ClinicalTable"
      
   //--------------------------------------------------------------------------------------------
   function initializeUI(){

      displayDiv = $("#clinicalDataTableDiv");
      $(window).resize(handleWindowResize);
      handleWindowResize();

      PatientMenu = d3.select("#useSavedSelectionButton")
            .append("g")
            .append("select")
            .on("focus",function(d){ ctbl.UpdateSelectionMenu()})
            .on("change", function() {
                if(this.value !== "Load Selection")
                   getSelectionbyName(this.value, callback="ChangeTablePatientSelection"); 
            })
            ;

        ClTblsendSelectionMenu = $("#ClTblsendSelectiontoModuleButton")
        ClTblsendSelectionMenu.change(sendToModuleChanged);
        ClTblsendSelectionMenu.empty();
        
        ClTblsendSelectionMenu.append("<option>Send Selection to:</option>")
        var ModuleNames = getSelectionDestinations()
        console.log("=== ClinicalTable::initializeUI, modules: " + ModuleNames);
        for(var i=0;i< ModuleNames.length; i++){
           var SendToModule = ModuleNames[i]
           if(SendToModule !== ThisModuleName){
              optionMarkup = "<option>" + SendToModule + "</option>";
              ClTblsendSelectionMenu.append(optionMarkup);
           }
        }  

      $("#ageAtDxSlider").slider({
         slide: function(event, ui) {
            if(ui.values[0] > ui.values[1]){
               return false;
            }          
            $("#ageAtDxMinSliderReadout").text (ui.values[0])
            $("#ageAtDxMaxSliderReadout").text (ui.values[1])
                      tableRef.fnDraw()
         },
         min: 10,
         max: 89,
         values: [10,89]
         });
    $("#ageAtDxMinSliderReadout").text(10);
    $("#ageAtDxMaxSliderReadout").text(89);

    $("#overallSurvivalSlider").slider({
       slide: function(event, ui) {
           if(ui.values[0] > ui.values[1]){
               return false;
            }  
          $("#overallSurvivalMinSliderReadout").text (ui.values[0])
          $("#overallSurvivalMaxSliderReadout").text (ui.values[1])
                    tableRef.fnDraw()},
       min: 0,
       max: 11,
       values: [0,11]
       });
    $("#overallSurvivalMinSliderReadout").text(0);
    $("#overallSurvivalMaxSliderReadout").text(11);

    $("#showAllClinicalTablesRowsButton").click(showAllRows)    
    $("#cltblAboutLink").click(showAbout_ClTbl)
    };

   //----------------------------------------------------------------------------------------------------
    function showAbout_ClTbl(){
  
          var   info ={Modulename: ThisModuleName,
                    CreatedBy: "Oncoscape Core",
                    MaintainedBy: "Paul Shannon",
                    Folder: "clinicalDataTable"}

         about.OpenAboutWindow(info) ;
    }

    //----------------------------------------------------------------------------------------------------
     function sendToModuleChanged() {

       ModuleName = ClTblsendSelectionMenu.val()
       SelectedPatientIDs = currentSelectedIDs()
       metadata =  {"Tab": "ClinicalTable",
         			"Settings": {ageAtDxMin: $("#ageAtDxMinSliderReadout").val(),
                                 ageAtDxMax: $("#ageAtDxMaxSliderReadout").val(),
                                 overallSurvivalMin: $("#overallSurvivalMinSliderReadout").val(),
                                 overallSurvivalMax: $("#overallSurvivalMaxSliderReadout").val()}
                   }
       sendSelectionToModule(ModuleName, SelectedPatientIDs, metadata);
       
       ClTblsendSelectionMenu.val("Send Selection to:")
    } // sendToModuleChanged
 
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
      $("#ageAtDxSlider").slider("values", [10,89])
      $("#overallSurvivalSlider").slider("values", [0,11])
     
      $("#ageAtDxMinSliderReadout").text(10);
      $("#ageAtDxMaxSliderReadout").text(89);

      $("#overallSurvivalMinSliderReadout").text(0);
      $("#overallSurvivalMaxSliderReadout").text(11);

      }

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
      var tabIndex = $('#tabs a[href="#clinicalDataModuleDiv"]').parent().index();
      $("#tabs").tabs( "option", "active", tabIndex);
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
        "scrollY":  (0.75*displayDiv.height),
        "scrollCollapse": true,
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

     var allowFilter = ['clinicalTable'];

    $.fn.dataTableExt.afnFiltering.push(
      function( oSettings, aData, iDataIndex ) {
          if ( $.inArray( oSettings.nTable.getAttribute('id'), allowFilter ) == -1 )
          {// if not table should be ignored
              return true;
          }
   
          var agemin = parseInt( $("#ageAtDxMinSliderReadout").val(), 10 );
          var agemax = parseInt( $("#ageAtDxMaxSliderReadout").val(), 10 );
          var age = parseFloat( aData[1] ) || 0; // use data for the age column

          var survmin = parseInt( $("#overallSurvivalMinSliderReadout").val(), 10 );
          var survmax = parseInt( $("#overallSurvivalMaxSliderReadout").val(), 10 );
          var surv= parseFloat( aData[3] ) || 0; // use data for the age column
 
        if ((( isNaN( agemin ) && isNaN( agemax) ) ||
             ( isNaN( agemin ) && age <= agemax  ) ||
             ( agemin <= age   && isNaN( agemax) ) ||
             ( agemin <= age   && age <= agemax) ) &&
            (( isNaN( survmin )  && isNaN(  survmax) ) ||
             ( isNaN( survmin )  && surv <= survmax  ) ||
             ( survmin <= surv   && isNaN(  survmax) ) ||
             ( survmin <= surv   && surv <= survmax) )
             )
        {
            return true;
        }
        return false;
    }
);
     }; // displayTable

//----------------------------------------------------------------------------------------------------
  return{
    requestData: requestData,
    init: function(){
      addSelectionDestination(ThisModuleName, "clinicalDataModuleDiv")   
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
                 .data(["Load Selection", getSelectionNames()], function(d){return d;})
                 .enter()
                        .append("option")
                        .attr("value", function(d){return d})
                        .text(function(d) { return d});
     }


    }; // returned object

  }); // ClinicalTableModule

//----------------------------------------------------------------------------------------------------
ctbl = ClinicalTableModule();
ctbl.init();

</script>