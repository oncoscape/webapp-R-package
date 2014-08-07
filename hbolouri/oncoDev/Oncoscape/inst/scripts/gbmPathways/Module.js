<script>
//----------------------------------------------------------------------------------------------------
var gbmPathwaysModule = (function () {

  var cyDiv;

  //--------------------------------------------------------------------------------------------
  function initializeUI () {
      cyDiv = $("cyGbmPathways");
      pcaDisplay = $("#pcaDisplay");
      pcaHandleWindowResize();
      broadcastButton = $("#pcaBroadcastSelectionToClinicalTable");
      //broadcastButton.button();
      broadcastButton.click(pcaBroadcastSelection);
      $(window).resize(pcaHandleWindowResize);
      broadcastButton.prop("disabled",true);
      };

  //--------------------------------------------------------------------------------------------
