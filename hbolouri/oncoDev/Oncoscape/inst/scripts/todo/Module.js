<script>
//----------------------------------------------------------------------------------------------------
var todoModule = (function () {

var ToDoURL = "https://docs.google.com/spreadsheets/d/1Rqqpma1M8aF5bX4BM2cYYgDd5hazUysqzCxLhGUwldo/edit?usp=sharing"
var ToDobutton;

initializeUI = function(){
    ToDobutton = $("#ToDoLink");
    ToDobutton.on("click",function(d){window.open(ToDoURL) }   )
    };

//----------------------------------------------------------------------------------------------------
    function SetModifiedDate(){

        msg = {cmd:"getModuleModificationDate",
             callback: "DisplaytodoModifiedDate",
             status:"request",
             payload:"todo"
             };
        msg.json = JSON.stringify(msg);
        socket.send(msg.json);
    }
//----------------------------------------------------------------------------------------------------
    function DisplaytodoModifiedDate(msg){
        document.getElementById("todoDateModified").innerHTML = msg.payload;
    }


return{

   init: function(){
      onReadyFunctions.push(initializeUI);
      addJavascriptMessageHandler("DisplaytodoModifiedDate", DisplaytodoModifiedDate);
      socketConnectedFunctions.push(SetModifiedDate);

      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
todo = todoModule();
todo.init();

</script>