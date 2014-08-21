<script>
//----------------------------------------------------------------------------------------------------
var UserSettingsModule = (function () {

     var username = "Guest"
     var userID = null
     var SelectionNames = [];
     
//----------------------------------------------------------------------------------------------------
//======= PUBLIC FUNCTIONS ==========
//----------------------------------------------------------------------------------------------------
      getUserID = function(){
           console.log("Sending User ID: ", userID)
           return userID;
      }      
//----------------------------------------------------------------------------------------------------
      getUsername = function(){
           console.log("Sending Username: ", username)
           return username;
      }      

//----------------------------------------------------------------------------------------------------
      setUsername = function(msg){
           console.log("Set username: ", msg.payload.username)
           username = msg.payload.username
      }      

    //--------------------------------------------------------------------------------------------
     addSelection = function(NewSelection){
  
           //Check NewSelection values for completeness/accuracy
           // should have selectionnames, patientIDs, Tab, and Settings
           
           NewSelection.userID = getUserID() 
     
           msg = {cmd: "addNewUserSelection",
                  callback: "UpdateSelectionListeners",
                  status:"request",
                  payload: NewSelection 
                 };
 
           msg.json = JSON.stringify(msg);
//           console.log(msg.json);
           socket.send(msg.json);
     }
    //--------------------------------------------------------------------------------------------
     getSelectionbyName = function(selectionname, callback){
               
			if(SelectionNames.indexOf(selectionname) == -1){
   			     alert("Error: ",selectionname, " not in list")
                  return;
			} else{
  
                msg = {cmd:"getUserSelection",
                  callback: callback,
                  status:"request",
                  payload:{userID: getUserID(),
                           selectionname: selectionname}
                  };
     
                 console.log(JSON.stringify(msg));
                  socket.send(JSON.stringify(msg));
          }     
    }

   //--------------------------------------------------------------------------------------------
     getSelectionNames = function(){

            return SelectionNames;
     }

//----------------------------------------------------------------------------------------------------
//======= PRIVATE FUNCTIONS ==========
//----------------------------------------------------------------------------------------------------
      function CreateNewUser(){
      
         console.log("======= creating new guest user")
  
            userID = Math.random().toString(36).substring(7)
            console.log(userID);
      }
//----------------------------------------------------------------------------------------------------
     function UserSettingsInitializeUI(){

           CreateNewUser();
       };

//----------------------------------------------------------------------------------------------------
     function addNewUser(){
              
            msg = {cmd:"addNewUserToList",
                 callback: "UpdateUserInfo",
                 status:"request",
                 payload: { userID: userID, username: username}
                };
                console.log(JSON.stringify(msg))
          socket.send(JSON.stringify(msg));
     }
 
         

//----------------------------------------------------------------------------------------------------
    function UpdateSelectionListeners(msg){
    
        console.log("===== Updating JS Selection Lists")
        console.log(msg)
         
         if(msg.status === "success"){
           SelectionNames.push(msg.payload.selectionname)  
           
           if(typeof(SavedSelection) != "undefined")  SavedSelection.addSelectionToTable(msg);
           if(typeof(PatientTimeLine) != "undefined") PatientTimeLine.RefreshSelectionMenu()
           if(typeof(ctbl) != "undefined") ctbl.UpdateSelectionMenu()
         }
     }
  
 
     
//----------------------------------------------------------------------------------------------------
return{

   init: function(){
      onReadyFunctions.push(UserSettingsInitializeUI);
      socketConnectedFunctions.push(addNewUser);
     addJavascriptMessageHandler("UpdateSelectionListeners", UpdateSelectionListeners);
     addJavascriptMessageHandler("UpdateUserInfo", setUsername);

      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
UserSettings = UserSettingsModule();
UserSettings.init();

</script>