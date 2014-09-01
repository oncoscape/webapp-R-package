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
            
          $("#dashboardAboutLink").click(showAbout_dashboard)
    };

   //----------------------------------------------------------------------------------------------------
    function showAbout_dashboard(){
  
          var   info ={Modulename: "Dashboard",
                    CreatedBy: "Oncoscape Core",
                    MaintainedBy: "Lisa McFerrin",
                    Folder: "Dashboard"}

         about.OpenAboutWindow(info) ;
    }  
//----------------------------------------------------------------------------------------------------
    function UpdateUserInfo(){
        console.log("===== Display User Information")        
        document.getElementById("UserName").innerHTML = getUsername();

      }    
//----------------------------------------------------------------------------------------------------
return{

   init: function(){
      onReadyFunctions.push(DashboardInitializeUI);
      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
Dashboard = DashboardModule();
Dashboard.init();

</script>