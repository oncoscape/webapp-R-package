
<script>
//----------------------------------------------------------------------------------------------------
var SavedSelectionModule = (function (){
     
    var SelectionTableRef;
    var SaveSelectedDisplay;
    var CurrentSelection;
  
//--------------------------------------------------------------------------------------------
  function handleWindowResize(){
      SaveSelectedDisplay.width($(window).width() * 0.95);
      SaveSelectedDisplay.height($(window).height() * 0.95);
     }; // handleWindowResize

   
//----------------------------------------------------------------------------------------------------
	function initializeSelectionUI(){			     
	 console.log("====== Initializing Selection UI")

         var margin = {top: 10, right: 15, bottom: 30, left: 20};
 	    SaveSelectedDisplay = $("#SavedSelectionTableDiv");
        handleWindowResize();
        
        var height = SaveSelectedDisplay.height(); //200;      
        var width = SaveSelectedDisplay.width(); //200;       
         

         $(window).resize(handleWindowResize);
         displaySelectionTable();

     $("#addRandomSelection").click(addRandomSelectionData);

//        if(typeof(window.tabsAppRunning) == "undefined") {
//      		$("#ModuleDate").text(fetchHeader("Module.js") );
//        } else {
//            $("#ModuleDate").text(fetchHeader("../../tabsApp/Module.js") );
//        }
		// if date modified needs updated
		//http://www.dynamicdrive.com/forums/archive/index.php/t-63637.html

       };

//----------------------------------------------------------------------------------------------------
  function displaySelectionTable(){
     console.log("----displaySelectionTable");
     SelectionTblColumnNames = ["Name","N","FromTab", "Settings", "PatientIDs"];
     SelectionColumnTitles = [];
     for(var i=0; i < SelectionTblColumnNames.length; i++){
        SelectionColumnTitles.push({sTitle: SelectionTblColumnNames[i]});
        }
     
//     console.log(columnTitles);

     SaveSelectedDisplay.html('<table cellpadding="0" cellspacing="0" margin-left="10" border="1" class="display" id="SelectionTable"></table>');
     $("#SelectionTable").dataTable({
        "sDom": "Rlfrtip",
         sDom: 'C<"clear">lfrtip',
        "aoColumns": SelectionColumnTitles,
	    "sScrollX": "100px",
        "iDisplayLength": 25,
         bPaginate: true,
        "scrollX": true,
        "fnInitComplete": function(){
            $(".display_results").show();
            }
         }); // dataTable

     console.log("displayTable adding data to table");
     SelectionTableRef = $("#SelectionTable").dataTable();
     
      $('#SelectionTable tbody')
            .on( 'click', 'tr', function () {
               $(this).toggleClass('selected'); })         
               ;
 
      SelectionTableRef.fnSetColumnVis( 4, false );

      //http://datatables.net/examples/api/select_row.html
//    $('#button').click( function () {
//        alert( table.rows('.selected').data().length +' row(s) selected' );
//    } );
     
     }; // displayTable


//----------------------------------------------------------------------------------------------------
    function loadPatientData(){

       console.log("==== SavedSelection  get all PatientIDs from ClinicalTable");
       cmd = "getCaisisPatientHistory"; //sendCurrentIDsToModule
       status = "request"
       callback = "SetupSavedSelection"
          filename = "" // was 'BTC_clinicaldata_6-18-14.RData', now learned from manifest file
          msg = {cmd: cmd, callback: callback, status: "request", payload: filename};
          socket.send(JSON.stringify(msg));      
        
       } // loadPatientDemoData
//----------------------------------------------------------------------------------------------------
    function addRandomSelectionData(){

       cmd = "getCaisisPatientHistory"; //sendCurrentIDsToModule
       status = "request"
       callback = "testingAddSavedSelection"
          filename = "" // was 'BTC_clinicaldata_6-18-14.RData', now learned from manifest file
          msg = {cmd: cmd, callback: callback, status: "request", payload: filename};
          socket.send(JSON.stringify(msg));
       } // loadPatientDemoData

//----------------------------------------------------------------------------------------------------
     function SetupSavedSelection(msg){			     

		console.log("===== Setup SavedSelection")
//         console.log(msg)
         InitialLoad = false;

         var AllData = msg.payload
         var PtIDs = []; 
         for(var i=0;i<AllData.length; i++){
         	if(PtIDs.indexOf(AllData[i].PatientID) === -1)
         		PtIDs.push(AllData[i].PatientID)
         }
//         console.log("All Patients: ", PtIDs)
 
         var NewSelection = {   
                    selectionname: "All Patients",
         			PatientIDs : PtIDs,
         			Tab: "ClinicalTable",
         			Settings: "None"
         		}
           
         addSelection(NewSelection)
 
       
     }     
 //----------------------------------------------------------------------------------------------------
     function testingAddSavedSelection(msg) {

		console.log("===== testing Add Saved Selection")
         console.log(msg)

         var AllData = msg.payload
         var PtIDs = []; 
         for(var i=0;i<AllData.length; i++){
         	if(PtIDs.indexOf(AllData[i].PatientID) === -1)
         		PtIDs.push(AllData[i].PatientID)
         }
 
      randomsubset = [];
      for(i=0;i<6;i++){ randomsubset.push(PtIDs[getRandomInt (0, PtIDs.length) ])}

 //   console.log("Subset Patients: ",randomsubset)      

         var NewSelection = {   
                    selectionname: "test",
         			PatientIDs : randomsubset,
         			Tab: "ClinicalTable",
         			Settings: "randomsubset"
         		}
           
          addSelection(NewSelection)
}

        //--------------------------------------------------------------------------------------------
//     getSelectionNames = function(){
           
//        if(typeof(SelectionTableRef) == "undefined") return ""
             
//        var rows = SelectionTableRef._('tr', {"filter":"applied"});   // cryptic, no?
//       var rows = SelectionTableRef.rows().data()
//        var currentNames = []
//        for(var i=0; i < rows.length; i++) 
//          currentNames.push(rows[i][0]);
      
//        console.log(currentNames.length + " selection names being reported")

//       return currentNames;
//      }
  
 //----------------------------------------------------------------------------------------------------
    function SetModifiedDate(){

        msg = {cmd:"getModuleModificationDate",
             callback: "DisplaySavedSelectionModifiedDate",
             status:"request",
             payload:"SavedSelection"
             };
        msg.json = JSON.stringify(msg);
        socket.send(msg.json);
    }
//----------------------------------------------------------------------------------------------------
    function DisplaySavedSelectionModifiedDate(msg){
        document.getElementById("SavedSelectionDateModified").innerHTML = msg.payload;
    }
//----------------------------------------------------------------------------------------------------
    
       return{
     
        //----------------------------------------------------------------------------------------------------
        addSelectionToTable: function(msg){
    
        		console.log("===== Add Selection To Table")
                console.log(msg)
  
                if(msg.status !== "error"){
                     settings = msg.payload.settings;
                     if(typeof settings !== "string"){
                        settings=  JSON.stringify(settings)
                     }
                     N = msg.payload.patientIDs.length
                     AsRow = [msg.payload.selectionname,N, msg.payload.tab,settings, msg.payload.patientIDs]
 
                     SelectionTableRef.fnAddData(AsRow);            
                     SelectionTableRef.fnAdjustColumnSizing();
                     SelectionTableRef.fnDraw();
               } 
        },
        //----------------------------------------------------------------------------------------------------
        init: function(){
           onReadyFunctions.push(initializeSelectionUI);
           addJavascriptMessageHandler("SetupSavedSelection", SetupSavedSelection);
   		   addJavascriptMessageHandler("addSelectionToTable", SavedSelection.addSelectionToTable);
  		   addJavascriptMessageHandler("testingAddSavedSelection", testingAddSavedSelection);
           addJavascriptMessageHandler("DisplaySavedSelectionModifiedDate", DisplaySavedSelectionModifiedDate);

           socketConnectedFunctions.push(SetModifiedDate);
           socketConnectedFunctions.push(loadPatientData);
        }
        
       
         
      };
     
}); // SavedSelectionModule
 
//----------------------------------------------------------------------------------------------------
SavedSelection = SavedSelectionModule();
SavedSelection.init();

</script>