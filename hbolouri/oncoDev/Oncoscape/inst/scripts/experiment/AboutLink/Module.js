<script>
//----------------------------------------------------------------------------------------------------
var AboutModule = (function () {

    initializeUI = function(){     
 
       $("#AboutDiv").dialog({  
           autoOpen: false,
        });
 
 //       ClearAboutInfo()      
    };

//----------------------------------------------------------------------------------------------------
    function ClearAboutInfo(){
       document.getElementById("ModuleNameSlot").innerHTML = "";
       document.getElementById("CreatorSlot").innerHTML =      "Created by:    ";
       document.getElementById("MaintainerSlot").innerHTML =   "Maintained by: ";
       document.getElementById("LastModifiedSlot").innerHTML = "Last Modified: ";
    }
//----------------------------------------------------------------------------------------------------
    function SetModifiedDate(ModuleFolderName){

        msg = {cmd:"getModuleModificationDate",
             callback: "DisplayModifiedDate",
             status:"request",
             payload:ModuleFolderName
             };
        msg.json = JSON.stringify(msg);
        socket.send(msg.json);
    }
//----------------------------------------------------------------------------------------------------
    function DisplayModifiedDate(msg){
        
        console.log("Date Modified: ", msg)
        
        document.getElementById("LastModifiedSlot").innerHTML = 
        document.getElementById("LastModifiedSlot").innerHTML + "\t" + msg.payload;
    }

 return{

   init: function(){
      onReadyFunctions.push(initializeUI);
//      socketConnectedFunctions.push(SetModifiedDate)
      addJavascriptMessageHandler("DisplayModifiedDate", DisplayModifiedDate);
      },
      
      //----------------------------------------------------------------------------------------------------
     OpenAboutWindow: function(info){
       
       ClearAboutInfo()  
       $("#AboutDiv").dialog('option', 'title',info.Modulename )
       document.getElementById("CreatorSlot").innerHTML = 
         document.getElementById("CreatorSlot").innerHTML + "\t"+info.CreatedBy;
       document.getElementById("MaintainerSlot").innerHTML = 
              document.getElementById("MaintainerSlot").innerHTML + "\t"+info.MaintainedBy;
       SetModifiedDate(info.Folder)

         $( "#AboutDiv" ).dialog( "open" )
    }
    
 }; // return

}); // SelectionExample
//----------------------------------------------------------------------------------------------------
about = AboutModule();
about.init();

</script>