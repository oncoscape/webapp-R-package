<script>
//----------------------------------------------------------------------------------------------------
var SelectionExample = (function () {

    var PatientMenu;
    var PtIDs = ["TCGA.02.0001", "TCGA.02.0003", "TCGA.02.0004", "TCGA.02.0006", 
                 "TCGA.02.0007", "TCGA.02.0009", "TCGA.02.0010", "TCGA.02.0011", 
                 "TCGA.02.0014", "TCGA.02.0015", "TCGA.02.0016", "TCGA.02.0021", 
                 "TCGA.02.0023", "TCGA.02.0024", "TCGA.02.0025", "TCGA.02.0026", 
                 "TCGA.02.0027", "TCGA.02.0028", "TCGA.02.0033", "TCGA.02.0034", 
                 "TCGA.02.0037", "TCGA.02.0038", "TCGA.02.0039", "TCGA.02.0043"]

    initializeUI = function(){
     
       $("#toSavedSelectionButton").click(addRandomSelectionData);
       
        PatientMenu = d3.select("#useSavedSelectionButton")
            .append("g")
            .append("select")
            .on("focus",function(d){ sel.UpdateSelectionMenu()})
            .on("change", function() {
                   getSelectionbyName(this.value, callback="ShowNewPatientSelection"); 
            });
    };


    //--------------------------------------------------------------------------------------------
     function addRandomSelectionData(){

        randomsubset = [];
        NumToGet = 6
        for(i=0;i<NumToGet;i++){ 
           randomsubset.push(PtIDs[getRandomInt (0, PtIDs.length) ])
        }

        var NewSelection = {   
                    selectionname: "test",
         			PatientIDs : randomsubset,
         			Tab: "savedExplorations",
         			Settings: "randomsubset"
         		}
           
          addSelection(NewSelection)
          
        var SelectionString = "Adding Selection: <br><br>" 
             + "Name: "     + NewSelection.selectionname + "<br>" 
             + "Tab: "      + NewSelection.Tab + "<br>" 
             + "Settings: " + NewSelection.Settings + "<br>" 
             + "IDs: "  + JSON.stringify(NewSelection.PatientIDs) + "<br>";
        

        document.getElementById("showNewSelection").innerHTML = SelectionString


     } // addRandomSelectionData

//--------------------------------------------------------------------------------------------
     function ShowNewPatientSelection(msg){
       
      if(msg.status != "success"){
         alert("error: " + msg.payload);
         return;
         }

       patientIDs = []
       selections = msg.payload;
       // returns an array of selections including metadata: 
       //    selectionname, settings, tab, and patientIDs
 
       //console.log(selections)
       
       d3.values(selections).forEach(function(d){ 
            d.patientIDs.forEach(function(id){
               if(patientIDs.indexOf(id) == -1) patientIDs.push(id)
            })
        })  //collapses all selections into a list of unique patients
        
        var SelectionString = "Changing Selection to: <br><br>"
        d3.values(selections).forEach(function(d){
           SelectionString = SelectionString
           + "Name: "     + d.selectionname + "<br>"
           + "Tab: "      + d.tab + "<br>" 
           + "Settings: " + d.settings + "<br>" 
           + "IDs: "  + JSON.stringify(d.patientIDs) + "<br>";
        })

        document.getElementById("showNewSelection").innerHTML = SelectionString
       
//        settings = msg.payload.settings;
  //                   if(typeof settings !== "string"){
    //                    settings=  JSON.stringify(settings)
      //               }
        //             N = msg.payload.patientIDs.length
          //           AsRow = [msg.payload.selectionname,N, msg.payload.tab,settings, msg.payload.patientIDs]
 
  
     } // addRandomSelectionData

 return{

   init: function(){
      onReadyFunctions.push(initializeUI);
      socketConnectedFunctions.push(addRandomSelectionData)
      addJavascriptMessageHandler("ShowNewPatientSelection", ShowNewPatientSelection);
      },
    //---------don't forget the comma-----------------------------------------------------------------------------------
    UpdateSelectionMenu: function(){           
                  
      PatientMenu.selectAll("option")
                 .data(getSelectionNames(), function(d){return d;})
                 .enter()
                        .append("option")
                        .attr("value", function(d){return d})
                        .text(function(d) { return d})
                ;
     }
 }; // return

}); // SelectionExample
//----------------------------------------------------------------------------------------------------
sel = SelectionExample();
sel.init();

</script>