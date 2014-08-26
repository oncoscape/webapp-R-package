<script>
//----------------------------------------------------------------------------------------------------
var ExperimentModule = (function () {

var button;
var selectionDisplay;
var selector;

function initializeUI(){
    button = $("#getSelectionButton");
    button.click(displaySelection);
    selectionDisplay = $("#selectionDisplay");
    selector = $("#testMultipleSelect");
    selector.chosen();
    };

displaySelection = function(msg){
   selectionDisplay.html("");
   selectionDisplay.append(selector.val());
   };

return{
   init: function(){
      onReadyFunctions.push(initializeUI);
      }
   };

}); // ExperimentModule
//----------------------------------------------------------------------------------------------------
exp = ExperimentModule();
exp.init();

</script>