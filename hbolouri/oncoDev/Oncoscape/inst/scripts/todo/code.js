<script>
//--------------------------------------------------------------------------------------------------
onReadyFunctions.push(function() {
    console.log("==== dataAndTime code.js document.ready");
    $("#requestDateButton").click(requestTime);
    // socketConnectedFunctions.push(xxx) // not needed yet.
    });
//--------------------------------------------------------------------------------------------------
requestTime = function() {

   msg = {cmd: "fetchDateAndTimeString", status: "request", payload: "empty"}
   msg.json = JSON.stringify(msg);
   console.log(msg.json)
   socket.send(msg.json);

} // requestDate
//--------------------------------------------------------------------------------------------------
myTimeFunction = function(msg) {

  result = msg.payload;
  console.log("dispatchOptions: " + result)
  $("#dateDisplay").text(result);

} // myTimeFunction
//--------------------------------------------------------------------------------------------------
addJavascriptMessageHandler("dateAndTimeString", myTimeFunction);
//addDispatchOption('time',  myTimeFunction);
//--------------------------------------------------------------------------------------------------
</script>
