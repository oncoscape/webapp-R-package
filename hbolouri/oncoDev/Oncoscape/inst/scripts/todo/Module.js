<script>
//----------------------------------------------------------------------------------------------------
var todoModule = (function () {

var ToDoURL = "https://docs.google.com/spreadsheets/d/1Rqqpma1M8aF5bX4BM2cYYgDd5hazUysqzCxLhGUwldo/edit?usp=sharing"
var ToDobutton;

initializeUI = function(){
    ToDobutton = $("#ToDoLink");
    ToDobutton.on("click",function(d){window.open(ToDoURL) }   )
    };


return{

   init: function(){
      onReadyFunctions.push(initializeUI);
      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
todo = todoModule();
todo.init();

</script>