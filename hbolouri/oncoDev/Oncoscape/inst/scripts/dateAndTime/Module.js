<script>
//----------------------------------------------------------------------------------------------------
var DateAndTimeModule = (function () {

var _button;
var _timeDisplay;

_initializeUI = function(){
    _button = $("#requestDateButton");
    _button.click(_requestTime);
    _timeDisplay = $("#dateDisplay");
    };

_requestTime = function(){
   msg = {cmd: "fetchDateAndTimeString", status: "request", payload: "empty"}
   msg.json = JSON.stringify(msg);
   socket.send(msg.json);
   };

_displayTime = function(msg){
   result = msg.payload;
   _timeDisplay.text(result);
   };

return{

   getTime: function(){
      return _timeDisplay.text()
      },

   requestTime: _requestTime,

   init: function(){
      onReadyFunctions.push(_initializeUI);
      addJavascriptMessageHandler("dateAndTimeString", _displayTime);
      }
   };

}); // DateAndTimeModule
//----------------------------------------------------------------------------------------------------
dtm = DateAndTimeModule();
dtm.init();

</script>