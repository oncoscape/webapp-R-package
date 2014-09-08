<script>
//----------------------------------------------------------------------------------------------------
var DashboardModule = (function () {

  var HIDRAlink = "<a href='http://www.fhcrc.org/en/labs/hidra.html'>HIDRA</a>"
  var TCGAdatalink = "<a href='https://tcga-data.nci.nih.gov/tcga/tcgaCancerDetails.jsp?diseaseType=GBM&diseaseName=Glioblastoma%20multiforme'>TCGA portal</a>"
  var GBM2013paper = "<a href='http://www.ncbi.nlm.nih.gov/pubmed/24120142'>(Brennan et al, Cell 2013)</a>"

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
               
        var ToDobutton = $("#ToDoLink");
        var ToDoURL = "https://docs.google.com/spreadsheets/d/1Rqqpma1M8aF5bX4BM2cYYgDd5hazUysqzCxLhGUwldo/edit?usp=sharing"

        ToDobutton.on("click",function(d){window.open(ToDoURL) }   )

    };

   //----------------------------------------------------------------------------------------------------
    function LoadDatainfo(){
 
      var TCGAdata =  $("#TCGAdataInfo")
      TCGAdata.append("<p><h4 align=center>Glioblastoma multiforme (GBM) Pilot demo</h4></p>")
      TCGAdata.append("<p>Copy Number Alterations, Single Nucleotide Alterations, indels and patient histories were downloaded from the " +
                      TCGAdatalink + ", based off the 2013 publication "+GBM2013paper+" and supplemented by in-house data.</p>")          
          
      TCGAdata.append("<div id='TCGArnadata'><p>The TCGA GBM expression data included in Oncoscape is for 304 patients that meet the following criteria:<br>" +
           "<ol type='A'><li>TCGA clinical data has (529 GBM samples) <ul> <li>'GBM' by 'histologic type'</li><li>'primary' by 'sample type'</li><li>an assigned subtype (ie != '')</li></ul>"+
           "<li>TCGA expression data within unified (Agilent + Affymetrix) set defined in comparative paper (PMID:21436879)  (323 GBM samples).</li></ol>"+
           "</p></div>")
 
      var UWMSCCAdata =  $("#UWMSCCAdataInfo")
      UWMSCCAdata.append("<p>Access to information regarding <a href='http://www.uwmedicine.org/'>University of Washington Medicine</a> and <a href='http://www.seattlecca.org/'>SCCA</a> patients is restricted by IRB approval.  Please contact <a href='http://www.fhcrc.org/en/diseases/featured-researchers/fearn-paul.html'>Paul Fearn</a> for questions regarding access.</p>")
//      UWMSCCAdata.append("<div id='UWMSCCApatientdata'>UWM and SCCA patient information is accessed through "+HIDRAlink+", which centralizes records for thousands of patients in a common <a href='http://www.caisis.org/'>Caisis</a> table format.</div>")
//      UWMSCCAdata.append("<div id='UWMSCCAcnvdata'><h4><u>CNV: Oncoplex</u></h4><br></div>")

      var TableContents = $("#TableContentsDiv")
      TableContents.append("<p><h4>Clinical Table:</h4> Table view of patient information.  Filter data by Age of Diagnosis & survival sliders or by specific search terms.</p>")
      TableContents.append("<p><h4>Patient Timelines:</h4> Visual representation of patient histories.  Align or Order patient histories by clinical events.  Couple calculated features with patient timelines. </p>")
      TableContents.append("<p><h4>Principle Component Analysis (PCA):</h4> Transform RNA expression levels to cluster patients by patterns of variation.</p>")
      TableContents.append("<p><h4>Partial Least Squares Regression (PLSR):</h4> Use linear regression to correlate genes with clinical features using RNA expression </p>")
      TableContents.append("<p><h4>GBM Pathways:</h4> Map patient specific expression levels on a hand curated network of genes associated with GBM.  Click on edges to view the abstracts defining the relationship. </p>")   
      TableContents.append("<p><h4>Angiogenesis:</h4> Map patient specific expression levels on a small network of genes associated with angiogenesis.  Click on edges to view the abstracts defining the relationship. </p>")   
      TableContents.append("<p><h4>Markers & Patients:</h4> Link copy number variation and mutation data to patients grouped by GBM classification: mesenchymal, classicial, neural, proneural, and G-CIMP </p>")
      TableContents.append("<p><h4>Distributions:</h4> Plot clinical features of defined populations. </p>")
      TableContents.append("<p><h4>Survival:</h4> Compare survival rates of selected patients against the remaining population in a Kaplan Meier plot.</p>")
   }

   //----------------------------------------------------------------------------------------------------
    function showAbout_dashboard(){
  
          var   info ={Modulename: "Dashboard",
                    CreatedBy: "Oncoscape Core",
                    MaintainedBy: "Oncoscape Core",
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