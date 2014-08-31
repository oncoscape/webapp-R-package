<script>
var socket;
var dispatchOptions = {};
var socketConnectedFunctions = [];
var onReadyFunctions = [];

//
// Do not modify the following line.  If Oncoscape is launched from LabKey then a new labkey javascript
// object will be created with members {.mode, .reportSession, .filteredPatients}
//
//var labkey = {labkeyOncoscape};

var filteredPatients = [];
//----------------------------------------------------------------------------------------------------
addJavascriptMessageHandler = function(cmd, func)
{
   if(cmd in dispatchOptions){
      alert("javascript message handler for '" +  cmd + " already set");
      }
   else{
      dispatchOptions[cmd] = func
      }
}
//----------------------------------------------------------------------------------------------------
function getRandomFloat (min, max)
{
    return Math.random() * (max - min) + min;
}
//----------------------------------------------------------------------------------------------------
function getRandomInt (min, max) 
{
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
//----------------------------------------------------------------------------------------------------
String.prototype.beginsWith = function (string) 
{
    return(this.toLowerCase().indexOf(string.toLowerCase()) === 0);
};
//----------------------------------------------------------------------------------------------------
// if jQuery-style tabs are in use with Oncoscape, this function raised the named tab to the
// the front (visible) position in the tabset
// the argument, "tabIDString" is the tab id used in the module's widget.html, reproduced exactly
// in tabsApp/widget.html, with some current examples being
//  pcaDiv, patientTimeLinesDiv, gbmPathwaysDiv
function raiseTab(tabIDString)
{
  tabsWidget = $("#oncoscapeTabs");
  if(tabsWidget.length > 0){
     selectionString = '#oncoscapeTabs a[href="#' + tabIDString + '"]';
     tabIndex = $(selectionString).parent().JAVASCRIPT_INDEX ();
     tabsWidget.tabs( "option", "active", tabIndex);
     } // if tabs exist

} // raiseTab
//----------------------------------------------------------------------------------------------------
// from http://stackoverflow.com/questions/4068373/center-a-popup-window-on-screen
function openCenteredBrowserWindow(url, title, w, h) {
    // Fixes dual-screen position                         Most browsers      Firefox
    var dualScreenLeft = window.screenLeft != undefined ? window.screenLeft : screen.left;
    var dualScreenTop = window.screenTop != undefined ? window.screenTop : screen.top;

    width = window.innerWidth ? window.innerWidth : document.documentElement.clientWidth ? document.documentElement.clientWidth : screen.width;
    height = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : screen.height;

    var left = ((width / 2) - (w / 2)) + dualScreenLeft;
    var top = ((height / 2) - (h / 2)) + dualScreenTop;
    var newWindow = window.open(url, title, 'scrollbars=yes, width=' + w + ', height=' + h + ', top=' + top + ', left=' + left);

    if (window.focus) {
       newWindow.focus();
       }

} // openCenteredBrowserWindow
//----------------------------------------------------------------------------------------------------
dispatchMessage = function(msg)
{
   console.log("--- webapp, index.common, dispatchMessage: " + msg.cmd);

   if (dispatchOptions[msg.cmd])
       dispatchOptions[msg.cmd](msg)
   else
      console.log("unrecognized socket request: " + msg.cmd);
} 
//--------------------------------------------------------------------------------------------------
setupSocket = function (socket)
{
  try {
     socket.onopen = function() {
        console.log("websocket connection now open");
        for(var f=0; f < socketConnectedFunctions.length; f++){
           console.log("calling the next sockectConnectedFunction");
           socketConnectedFunctions[f]();
           } // for f
        } 
     socket.onmessage = function got_packet(msg) {
        msg = JSON.parse(msg.data)
        console.log("index.common onmessage sees " + msg.cmd);
        dispatchMessage(msg)
        } // socket.onmessage, got_packet
     socket.onclose = function(){
        //$("#status").text(msg.cmd)
        console.log("socket closing");
        } // socket.onclose
    } // try
  catch(exception) {
    $("#status").text("Error: " + exception);
    }

} // setupSocket
//----------------------------------------------------------------------------------------------------
function invokeSuccess(r)
{
    socket.rserveExecuting = false;

    if (r.errors.length > 0)
    {
        for (var i=0; i < r.errors.length; i++)
        {
        $("#status").text("Error: " + r.errors[i]);
        }
    }
    else
    if (r.outputParams.length > 0)
    {
        // note that LabKey has handled the JSON parsing already
        var msg = r.outputParams[0].value;
        console.log("index.common onmessage sees " + msg.cmd);
        dispatchMessage(msg);
    }

    //
    // call the next pending command if available
    //
    if (socket.rservePendingCommands.length > 0)
    {
        // note that M4 macro language uses 'shift' so quote it below
        executeRserveCommand(socket.rservePendingCommands.`shift'());
    }
}
//----------------------------------------------------------------------------------------------------
function invokeFailure(error)
{
    $("#status").text("Error: " + error.exception);
}
//----------------------------------------------------------------------------------------------------
function executeRserveCommand(data)
{
    if (socket.rserveExecuting)
    {
        //
        // put this command on our pending list and execute when the server has responded.
        //

        //console.log("in executeRserveCommand - pending:" + data);
        socket.rservePendingCommands.push(data);
    }
    else
    {
        //
        // execute immediately
        //
        socket.rserveExecuting = true;

        //console.log("in executeRserveCommand - executing:" + data);
        LABKEY.Report.execute( {
            success: invokeSuccess,
            failure: invokeFailure,
            script : 'invokeCommand',
            reportSessionId : socket.rserveSession,
            inputParams : { DATA : data }
        });
    }
}
//----------------------------------------------------------------------------------------------------
// todo: investigate why json returned by LabKey is creating array[1] in some cases.
// both JSON.parse and the LabKey util decode function do this
//----------------------------------------------------------------------------------------------------
function flattenArrays(d)
{
    for (var key in d)
    {
        if (d.hasOwnProperty(key))
        {
            var val = d[key];
            if ((val instanceof Array) && val.length == 1)
            {
                d[key] = val[0];
            }
        }
    }
}
//----------------------------------------------------------------------------------------------------
setupLabKey = function(socket)
{
    // replace socket send for LabKey
    socket.send = executeRserveCommand;
    socket.rservePendingCommands = [];
    socket.rserveExecuting = false;
    socket.rserveSession = labkey.reportSession;
    console.log("rserveSession:  " + labkey.reportSession);

    // kick off init functions
    for(var f=0; f < socketConnectedFunctions.length; f++)
    {
        console.log("calling the next sockectConnectedFunction");
        socketConnectedFunctions[f]();
    }
}

function setupFilteredPatients()
{
    if (typeof labkey != "undefined" && labkey.filteredPatients)
    {
        filteredPatients = labkey.filteredPatients.split(';');
        console.log("==== filteredPatients: " + filteredPatients.length)
    }
}
//--------------------------------------------------------------------------------------------------
// the nginx proxy server, used by fhcrc IT for the publicly-visible version of Oncoscape
// times out web sockets at 90 seconds.
// this function, when called more often that that, will keep the websocket open.
keepAlive = function()
{   
    console.log("keep alive"); 
    msg = {cmd: "keepAlive", callback: "", status:"request", payload:""}
    socket.send(JSON.stringify(msg));

} // keepAlive
//--------------------------------------------------------------------------------------------------
$(document).ready(function()
{
    console.log("==== index.common document.ready #1");

    for (var f = 0; f < onReadyFunctions.length; f++)
    {
        console.log("calling on ready function");
        onReadyFunctions[f]();
    }

    //
    // labkeyMode has three states:
    // undefined - labkey not involved
    // labkeyWS - labkey launched Oncoscape; local R must be run with WS
    // labkeyRS - labkey launched oncoscape; Rserve is used
    //
    if (typeof labkey == "undefined") {
        socket = new WebSocket("ws://" + window.location.host);
        setupSocket(socket);
        setInterval(keepAlive, 30000);
        }
    else
    if (labkey.mode == "WS")
    {
        socket = new WebSocket("ws://localhost:7777/");
        setupSocket(socket);
    }
    else
    if (labkey.mode == "RS")
    {
        socket = {};
        setupLabKey(socket);
    }
    else
    {
        console.log("unrecognized labkey.mode was provided: " + labkey.mode);
    }

    // todo: probably a better place to put this
    setupFilteredPatients();
})
//--------------------------------------------------------------------------------------------------


</script>
