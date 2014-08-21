<script>
//----------------------------------------------------------------------------------------------------
var DashboardModule = (function () {

 //----------------------------------------------------------------------------------------------------
     function DashboardInitializeUI(){
        
        console.log("===== Display User Information")        
        document.getElementById("UserName").innerHTML = getUsername();

        
        document.getElementById("DashboardAcknowledgement").style.fontSize = "x-small"
        
    };
    
//----------------------------------------------------------------------------------------------------
    function UpdateUserInfo(){
        console.log("===== Display User Information")        
        document.getElementById("UserName").innerHTML = getUsername();

      }

//----------------------------------------------------------------------------------------------------
    function SetModifiedDate(){

        msg = {cmd:"getModuleModificationDate",
             callback: "DisplayDashboardModifiedDate",
             status:"request",
             payload:"Dashboard"
             };
        msg.json = JSON.stringify(msg);
        socket.send(msg.json);
    }
//----------------------------------------------------------------------------------------------------
    function DisplayDashboardModifiedDate(msg){

        console.log("==== Dashboard Date: ", msg.payload)
        DateModified = document.getElementById("DashboardDateModified");
        DateModified.innerHTML = msg.payload;
        DateModified.style.fontSize = "x-small"
    }
     
//----------------------------------------------------------------------------------------------------
return{

   init: function(){
      onReadyFunctions.push(DashboardInitializeUI);
      socketConnectedFunctions.push(SetModifiedDate);
      addJavascriptMessageHandler("DisplayDashboardModifiedDate", DisplayDashboardModifiedDate);
      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
Dashboard = DashboardModule();
Dashboard.init();

</script>