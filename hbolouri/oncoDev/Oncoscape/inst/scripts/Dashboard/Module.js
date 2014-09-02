<script>
//----------------------------------------------------------------------------------------------------
var DashboardModule = (function () {

 //----------------------------------------------------------------------------------------------------
     function DashboardInitializeUI(){
        
        console.log("===== Display User Information")        
        document.getElementById("UserName").innerHTML = getUsername();

        $("#DashboardAccordion" ).accordion({
              active: false,
              heightStyle: "content",
              collapsible: true,
              });
            
        $("#AvailableDataAccordian" ).accordion({
              active: false,
              heightStyle: "content",
              collapsible: true,
              });

        LoadDatainfo();
     
          $("#dashboardAboutLink").click(showAbout_dashboard)
          
        var ToDobutton = $("#ToDoLink");
        var ToDoURL = "https://docs.google.com/spreadsheets/d/1Rqqpma1M8aF5bX4BM2cYYgDd5hazUysqzCxLhGUwldo/edit?usp=sharing"

        ToDobutton.on("click",function(d){window.open(ToDoURL) }   )

    };

   //----------------------------------------------------------------------------------------------------
    function LoadDatainfo(){
 
      var TCGAdata =  $("#TCGAdataInfo")
     console.log(TCGAdata)
      TCGAdata.append("<p>The Cancer Genome Atlas (TCGA)</p>")
          
          TCGAdata.append("<div id='TCGApatientdata'><h4><u>Patients</u></h4>Publication? Download site?</div>")
          TCGAdata.append("<div id='TCGArnadata'><h4><u>RNA</u></h4><b>Subtypes: </b> Defined by centroid genes <p>304patients-1375genes</p></div>")
          TCGAdata.append("<div id='TCGAcnvdata'><h4><u>CNV</u></h4></div>")
          TCGAdata.append("<div id='TCGAmutdata'><h4><u>Mutation</u></h4></div>")

   }

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