<script>

onReadyFunctions.push(function() {
    console.log("====== tabapps document ready");
    $("#tabs").tabs({
         // todo: distinguish between tabs, only do needed resets
       activate: function(event, ui) {
            console.log("tabs.activate");
            var tableRef = $("#clinicalTable").dataTable();
            if (tableRef.length > 0) {
               tableRef.fnAdjustColumnSizing();
              } // if
            console.log("cw functions");
            cw.reset()
            cw.fit(50);   // 50 px padding
            //window.cwGBM.reset();
            //window.cwGBM.fit(50);
            } // activate
        }); // tabs
    });  // ready

</script>

