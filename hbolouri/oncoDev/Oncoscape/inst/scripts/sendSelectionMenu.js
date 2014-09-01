<script>
var ActiveModules = {};

//----------------------------------------------------------------------------------------------------
addSelectionDestination = function(modulename, modulediv)
{
   if(modulename in ActiveModules){
        alert("Selection Destination message handler for '" + modulediv +": "+ modulename + " already set");
   } else{  ActiveModules[modulename] = modulediv  }
}

//----------------------------------------------------------------------------------------------------
getSelectionDestinations = function(){
    var keys = [];
    for(var k in ActiveModules) keys.push(k);
    return keys;
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
function sendSelectionToModule(moduleName, currentIDs, metadata, raiseDiv){
    
       raiseDiv = true;
       if(moduleName == "Save Selection"){
          var selectionname = PromptForSelectionName()
          if(typeof(selectionname) !== "string")  
             return;
          metadata.selectionname = selectionname;
          raiseDiv = false;
        }
    
       if(validSelectionToSend(moduleName, currentIDs)){    
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

         if(raiseDiv == true)
           raiseTab(ActiveModules[moduleName])
        }
    }

</script>

 