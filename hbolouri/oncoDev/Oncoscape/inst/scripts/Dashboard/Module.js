<script>
//----------------------------------------------------------------------------------------------------
var DashboardModule = (function () {

     function initializeUI(){

      };

     function requestMsg = function(){
        msg = {cmd: "fetch", status: "request", payload: ""}
        msg.json = JSON.stringify(msg);
       socket.send(msg.json);
     };

return{

   init: function(){
      onReadyFunctions.push(initializeUI);
//      addJavascriptMessageHandler("String", displayTime);
      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
Dashboard = DashboardModule();
Dashboard.init();

</script>