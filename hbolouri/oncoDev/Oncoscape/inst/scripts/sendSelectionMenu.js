<script>
var ActiveModules = [];

//----------------------------------------------------------------------------------------------------
addSelectionDestination = function(module)
{
   if(module in ActiveModules){
        alert("Selection Destination message handler for '" +  module + " already set");
   } else{  ActiveModules.push(module)  }
}

//----------------------------------------------------------------------------------------------------
getSelectionDestinations = function(){
     return ActiveModules;
//   return tissueMenu.children().map(function() {return $(this).val();}).get();
}

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


//--------------------------------------------------------------------------------------------
function sendSelectionToModule(moduleName, currentIDs, metadata){
    
       if(moduleName == "Save Selection"){
          var selectionname = PromptForSelectionName()
          if(typeof(selectionname) !== "string")  
             return;
          metadata.selectionname = selectionname;
        }
    
       if(validSelectionToSend(ModuleName, currentIDs)){    
          console.log(currentIDs.length + " patientIDs going to " + moduleName)    
       
          callback = moduleName + "HandlePatientIDs";    // genralize to "HandleSelectedIDs"?
          msg = {cmd:"sendIDsToModule",                  // generalize to "sendIDsToModule"?
                 callback: callback,
                 status:"request",
                 payload:{targetModule: ModuleName,
                          ids: currentIDs,
                          metadata: metadata}
                 };
         socket.send(JSON.stringify(msg));
         }

    } // sendSelectionToModule
//--------------------------------------------------------------------------------------------

</script>

 