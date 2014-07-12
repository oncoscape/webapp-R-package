<script>
onReadyFunctions.push(function() {
    console.log("====== tabapps document ready");
    window.tabsAppRunning = true
    $("#tabs").tabs({
         // todo: distinguish between tabs, only do needed resets
       activate: function(event, ui) {
            console.log("tabs.activate");
            console.log(" ==== tab.activate, tableRef.fnAdjustColumnSizing");
            var tableRef = $("#clinicalTable").dataTable();
            if (tableRef.length > 0) {
               tableRef.fnAdjustColumnSizing();
              } // if
            console.log(" ==== tab.activate, possible cyjs resize and fit");
            if(typeof(cwMarkers) != "undefined") {
               cwMarkers.resize(); 
               cwMarkers.fit(50);
               }
            if(typeof(cwGBM) != "undefined") {
                cwGBM.resize();
                cwGBM.fit(50);
                }
            if(typeof(cwAngio) != "undefined") {
                cwAngio.resize();
                cwAngio.fit(50);
                }
            } // activate
        }); // tabs
    });  // ready

</script>

