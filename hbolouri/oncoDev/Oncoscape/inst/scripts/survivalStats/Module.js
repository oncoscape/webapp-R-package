<script>
//----------------------------------------------------------------------------------------------------
var SurvivalModule = (function () {

     function demoTissueSet()
     {
//       return ["0525.T.2", "0598.T.1", "0622.T.1", "0636.T.1", "0664.T.1", "0761.T.1", "135.1.T.1", 
//               "249.T.1", "270X.T.1", "286X.T.1", "349.T.1", "392.1.T.1", "443.1.T.1", "450.T.1", 
//               "480.T.1", "821.T.1", "891.T.1", "929.T.1", "958.T.1"];
        return ["TCGA.02.0058", "TCGA.06.0132", "TCGA.02.0034", "TCGA.12.0657", "TCGA.06.0155",
                  "TCGA.06.0155", "TCGA.06.0162", "TCGA.06.1087", "TCGA.12.0778", 
                  "TCGA.14.0871", "TCGA.06.0192"];
     } // demoTissueSet
     //--------------------------------------------------------------------------------------------
       function SurvivalInitializeUI(){
           console.log("==== survivalStats code.js document.ready");
  
           if(typeof(window.tabsAppRunning) == "undefined") {
              socketConnectedFunctions.push(analyzeSelectedTissuesWithDemoData);
           }
           
           $("#survivalAboutLink").click(showAbout_survival)
           $("#survivalInstruction").append("Send a selection to 'survival' to generate a Kaplan Meier plot.")
     }
     //--------------------------------------------------------------------------------------------------
     function handlePatientIDs(msg)
     {
         console.log("--- handlePatientIDs SurvivalStats");
         console.log(msg)
          patientIDs = msg.payload.ids
 
         analyzeSelectedTissues(patientIDs);

     } // handleTissueIDsForSurivalStats
     //--------------------------------------------------------------------------------------------------
     function analyzeSelectedTissuesWithDemoData(){
              analyzeSelectedTissues(demoTissueSet());
     }  
     //--------------------------------------------------------------------------------------------------
     function analyzeSelectedTissues(patientIDs)
     {
         return_msg = {cmd:"calculateSurvivalCurves", callback: "displaySurvivalCurves", status: "request", payload: {patients:patientIDs}};
         socket.send(JSON.stringify(return_msg));

//        msg = {cmd: "getPatientHistoryDataVector", callback: "getSurvivalPlot", status:"request", 
//               payload: {colname: ["FirstProgression", "Death"], patients:patientIDs} }
//        socket.send(JSON.stringify(msg))
     
     }
     //--------------------------------------------------------------------------------------------------
     function getSurvivalPlot(msg){
        
         console.log(" create Survival Plot for: ", msg)
     	 var payload = JSON.parse(msg.payload);
     	 var storage = [];
//  	     var patientIDs = Object.keys(payload)
  	     for(i=0;i<Object.keys(payload).length;i++){
  	 	     var patient = Object.keys(payload)[i];
  	         storage.push({ID: patient, value: payload[patient]});
  	     }

     
 //        return_msg = {cmd:"calculateSurvivalCurves", callback: "displaySurvivalCurves", status: "request", payload: tissueIDs};
 //        socket.send(JSON.stringify(return_msg));

     } // analyzeSelectedTissues
    //--------------------------------------------------------------------------------------------------
     function displaySurvivalCurves(msg)
    {
        console.log("about to add survival curve image to survivalCurve div");
        encodedImage = msg.payload;
        document.getElementById("survivalCurveImage").src = encodedImage;
     }

   //----------------------------------------------------------------------------------------------------
    function showAbout_survival(){
  
          var   info ={Modulename: "Survival",
                    CreatedBy: "Oncoscape Core",
                    MaintainedBy: "Oncoscape Core",
                    Folder: "survivalStats"}

         about.OpenAboutWindow(info) ;
    }  

     //----------------------------------------------------------------------------------------------------
     return{

        init: function(){
           addSelectionDestination("Survival", "survivalStatsDiv")   
           onReadyFunctions.push(SurvivalInitializeUI);
           addJavascriptMessageHandler("displaySurvivalCurves", displaySurvivalCurves);
           addJavascriptMessageHandler("SurvivalHandlePatientIDs", handlePatientIDs);
           addJavascriptMessageHandler("getSurvivalPlot", getSurvivalPlot);
//           socketConnectedFunctions.push(analyzeSelectedTissues);

        }
     };

}); // SurvivalModule
//----------------------------------------------------------------------------------------------------
survival = SurvivalModule();
survival.init();

</script>
