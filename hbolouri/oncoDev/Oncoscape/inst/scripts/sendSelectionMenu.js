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
function SendSelectionToModule(ModuleName, currentIDs){
    
      callback = ModuleName + "HandlePatientIDs";    // genralize to "HandleSelectedIDs"?
      msg = {cmd:"sendPatientIDsToModule",                  // generalize to "sendIDsToModule"?
             callback: callback,
             status:"request",
             payload:{targetModule: ModuleName,
                      ids: currentIDs}
             };
      socket.send(JSON.stringify(msg));
    }

</script>