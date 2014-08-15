<script>
//----------------------------------------------------------------------------------------------------
var DashboardModule = (function () {

     var username = "Guest"
     var userID = null

//----------------------------------------------------------------------------------------------------
      function CreateNewUser(){
      
         console.log("======= creating new guest user")
  
            userID = Math.random().toString(36).substring(7)
           console.log(userID);

 //         msg = {cmd:"createNewUserID",
 //                callback: "addNewUserSettings",
 //                status:"request",
 //                payload:""
 //               };
 //         socket.send(JSON.stringify(msg));
       
      }
//----------------------------------------------------------------------------------------------------
     function DashboardInitializeUI(){

           CreateNewUser();
       };
//----------------------------------------------------------------------------------------------------
      getUserID = function(){
           console.log("Sending User ID: ", userID)
           return userID;
      }      

//----------------------------------------------------------------------------------------------------
     function addNewUser(){
              
            msg = {cmd:"addNewUserToList",
                 callback: "DisplayUserInfo",
                 status:"request",
                 payload: { userID: userID, username: username}
                };
                console.log(JSON.stringify(msg))
          socket.send(JSON.stringify(msg));
 
       
    }
 
//----------------------------------------------------------------------------------------------------
     function addNewUserSettings(msg){
     
         console.log("===== adding User Settings to ID")
         console.log(msg)

         if(msg.status === "success"){
           userID = msg.payload.userID
         console.log("created userID: ", userID)
         
            msg = {cmd:"addNewUserToList",
                 callback: "DisplayUserInfo",
                 status:"request",
                 payload: { userID: userID, username: username}
                };
                console.log(JSON.stringify(msg))
          socket.send(JSON.stringify(msg));
 
         }
    }
         
//----------------------------------------------------------------------------------------------------
    function DisplayUserInfo(msg){
    
        console.log("===== Display User Information")
        console.log(msg)
         
         if(msg.status === "success"){
           userID = msg.payload.userID
           username = msg.payload.username
        
           document.getElementById("UserName").innerHTML = username;
        }
    }
     
//----------------------------------------------------------------------------------------------------
return{

   init: function(){
      onReadyFunctions.push(DashboardInitializeUI);
      socketConnectedFunctions.push(addNewUser);
      addJavascriptMessageHandler("addNewUserSettings", addNewUserSettings);
      addJavascriptMessageHandler("DisplayUserInfo", DisplayUserInfo);
      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
Dashboard = DashboardModule();
Dashboard.init();

</script>