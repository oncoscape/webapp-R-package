<script>
//----------------------------------------------------------------------------------------------------
var DashboardModule = (function () {

     function DashboardInitializeUI(){

      };

     
return{

   init: function(){
      onReadyFunctions.push(DashboardInitializeUI);
//      addJavascriptMessageHandler("String", displayTime);
      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
Dashboard = DashboardModule();
Dashboard.init();

</script>