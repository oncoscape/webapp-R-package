
<script>
//----------------------------------------------------------------------------------------------------
var SavedSelectionModule = (function (){
     
    var SelectionTableRef;
    var SaveSelectedDisplay;
    var CurrentSelection;
//    var SelectionNames= [];
  
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
     tblColumnNames = ["Name","N","FromTab", "Settings", "PatientIDs"];
     columnTitles = [];
     for(var i=0; i < tblColumnNames.length; i++){
        columnTitles.push({sTitle: tblColumnNames[i]});
        }
     
     console.log(columnTitles);

     SaveSelectedDisplay.html('<table cellpadding="0" cellspacing="0" margin-left="10" border="1" class="display" id="SelectionTable"></table>');
     $("#SelectionTable").dataTable({
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
     SelectionTableRef = $("#SelectionTable").dataTable();
     
      $('#SelectionTable tbody')
            .on( 'click', 'tr', function () {
               $(this).toggleClass('selected'); })
            
               ;
   
   
      //http://datatables.net/examples/api/select_row.html
 
//    $('#button').click( function () {
//        alert( table.rows('.selected').data().length +' row(s) selected' );
//    } );
     
     
     
     }; // displayTable

      


//----------------------------------------------------------------------------------------------------
function make_editable(d, field)
{
// code from https://gist.github.com/GerHobbelt/2653660

    console.log("make_editable", arguments);
 
    this
      .on("mouseover", function() {
        d3.select(this).style("fill", "red");
      })
      .on("mouseout", function() {
        d3.select(this).style("fill", null);
      })
      .on("click", function(d) {
        var p = this.parentNode;
        console.log(this, arguments);
 
        // inject a HTML form to edit the content here...
 
        // bug in the getBBox logic here, but don't know what I've done wrong here;
        // anyhow, the coordinates are completely off & wrong. :-((
        var xy = this.getBBox();
        var p_xy = p.getBBox();
 
        xy.x -= p_xy.x;
        xy.y -= p_xy.y;
 
        var el = d3.select(this);
        var p_el = d3.select(p);
 
        var frm = p_el.append("foreignObject");
 
        var inp = frm
            .attr("x", xy.x)
            .attr("y", xy.y)
            .attr("width", 300)
            .attr("height", 25)
            .append("xhtml:form")
                    .append("input")
                        .attr("value", function() {
                            // nasty spot to place this call, but here we are sure that the <input> tag is available
                            // and is handily pointed at by 'this':
                            this.focus();
 
                            return d[field];
                        })
                        .attr("style", "width: 294px;")
                        // make the form go away when you jump out (form looses focus) or hit ENTER:
                        .on("blur", function() {
                            console.log("blur", this, arguments);
 
                            var txt = inp.node().value;
 
                            d[field] = txt;
                            el
                                .text(function(d) { return d[field]; });
 
                            // Note to self: frm.remove() will remove the entire <g> group! Remember the D3 selection logic!
                            p_el.selectAll(function() { return this.getElementsByTagName("foreignObject"); }).remove();
                        })
                        .on("keydown", function() {
                            console.log("keypress", this, arguments);
 
                            // IE fix
                            if (!d3.event)
                                d3.event = window.event;
 
                            var e = d3.event;
                            if (e.keyCode == 13)
                            {
                                if (typeof(e.cancelBubble) !== 'undefined') // IE
                                  e.cancelBubble = true;
                                if (e.stopPropagation)
                                  e.stopPropagation();
                                e.preventDefault();
 
                                var txt = inp.node().value;
 
                                d[field] = txt;
                                el
                                    .text(function(d) { return d[field]; });
 
                                // odd. Should work in Safari, but the debugger crashes on this instead.
                                // Anyway, it SHOULD be here and it doesn't hurt otherwise.
                                p_el.selectAll(function() { return this.getElementsByTagName("foreignObject"); }).remove();
                            }
                        });
      });
}

//----------------------------------------------------------------------------------------------------
    function loadPatientData(){

       console.log("==== SavedSelection  get all PatientIDs from ClinicalTable");
       cmd = "getCaisisPatientHistory"; //sendCurrentIDsToModule
       status = "request"
       callback = "SetupSavedSelection"
          filename = "" // was 'BTC_clinicaldata_6-18-14.RData', now learned from manifest file
          msg = {cmd: cmd, callback: callback, status: "request", payload: filename};
          socket.send(JSON.stringify(msg));
      
//       cmd = "getCaisisPatientHistory"; //sendCurrentIDsToModule
  //     status = "request"
    //   callback = "testingAddSavedSelection"
      //    filename = "" // was 'BTC_clinicaldata_6-18-14.RData', now learned from manifest file
        //  msg = {cmd: cmd, callback: callback, status: "request", payload: filename};
          //socket.send(JSON.stringify(msg));
       
        
       } // loadPatientDemoData

//----------------------------------------------------------------------------------------------------
     function SetupSavedSelection(msg){			     

		console.log("===== Setup SavedSelection")
         console.log(msg)
         InitialLoad = false;

         var AllData = msg.payload
         var PtIDs = []; 
         for(var i=0;i<AllData.length; i++){
         	if(PtIDs.indexOf(AllData[i].PatientID) === -1)
         		PtIDs.push(AllData[i].PatientID)
         }
         console.log("All Patients: ", PtIDs)

         var NewSelection = {   
                    userID: getUserID(),
                    selectionname: "All Patients",
         			PatientIDs : PtIDs,
         			Tab: "ClinicalTable",
         			Settings: "None"
         		}
           
        cmd = "addNewUserSelection"
        status = "request"
        callback = "addSelectionToTable"

       msg = {cmd: cmd, callback: callback, status: status, payload: NewSelection};
       
       console.log(JSON.stringify(msg.payload.userID))
       socket.send(JSON.stringify(msg));
 
       
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

    console.log("Subset Patients: ",randomsubset)      

         var NewSelection = {   
                    userID: getUserID(),
                    selectionname: "test",
         			PatientIDs : randomsubset,
         			Tab: "ClinicalTable",
         			Settings: "randomsubset"
         		}
           
        cmd = "addNewUserSelection"
        status = "request"
        callback = "addSelectionToTable"

       msg = {cmd: cmd, callback: callback, status: status, payload: NewSelection};

      msg.json = JSON.stringify(msg);
           console.log(msg.json);
      socket.send(msg.json);
 
}

//----------------------------------------------------------------------------------------------------
    function addSelectionToTable(msg){
    
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
       }
    
    }

    //--------------------------------------------------------------------------------------------
     getSelectionbyName = function(selectionname, callback){
               
               msg = {cmd:"getUserSelectPatientHistory",
              callback: callback,
              status:"request",
              payload:{userID: getUserID(),
                       selectionname: value}
             };
     
        socket.send(JSON.stringify(msg));
               
    }
        //--------------------------------------------------------------------------------------------
     getSelectionNames = function(){
             
        var rows = SelectionTableRef._('tr', {"filter":"applied"});   // cryptic, no?
        var currentNames = []
        for(var i=0; i < rows.length; i++) 
          currentNames.push(rows[i][0]);
      console.log(currentNames.length + " selection names being reported")

        currentNames;
}
//getSelectionNames = function(callback){
//  msg = {cmd:"getUserSelectionnames",
//   callback: callback,
//   status:"request",
//   payload:{userID: getUserID()}
//  };
//  socket.send(JSON.stringify(msg));         
//}
  
//--------------------------------------------------------------------------------------------
 //    function HandleWindowResize(){
 //         Display.width($(window).width() * 0.95);
 //         Display.height($(window).height() * 0.80);
 //         if(!InitialLoad) {updateSavedSelection(root);}
 //    };
  
//----------------------------------------------------------------------------------------------------
     
       return{
     
        init: function(){
           onReadyFunctions.push(initializeSelectionUI);
           addJavascriptMessageHandler("SetupSavedSelection", SetupSavedSelection);
   		   addJavascriptMessageHandler("addSelectionToTable", addSelectionToTable);
  		   addJavascriptMessageHandler("testingAddSavedSelection", testingAddSavedSelection);
          socketConnectedFunctions.push(loadPatientData);
           }
        };
     
}); // SavedSelectionModule
 
//----------------------------------------------------------------------------------------------------
SavedSelection = SavedSelectionModule();
SavedSelection.init();

</script>