<script>
//----------------------------------------------------------------------------------------------------
var DashboardModule = (function () {

 //----------------------------------------------------------------------------------------------------
     function DashboardInitializeUI(){
        
        console.log("===== Display User Information")        
        document.getElementById("UserName").innerHTML = getUsername();

        $("#DashboardAccordion" ).accordion({
              heightStyle: "content",
              collapsible: true,
              activate: function(event, ui){
                 console.log(" activating accordion");
                 window.cwCuration.resize().fit(50);
               }
            });
        
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