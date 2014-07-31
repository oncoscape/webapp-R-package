
<script>
//----------------------------------------------------------------------------------------------------
var SavedSelectionModule = (function (){
     
     var nodecount_i;
     var height;
     var root;
    
    var	tree, diagonal;
	var SaveSelectedDisplay;
    var InitialLoad;
    var SaveSelectedsvg;
    var CurrentSelection;
    var SelectionNames= [];
  
//--------------------------------------------------------------------------------------------
  function handleWindowResize(){
      SaveSelectedDisplay.width($(window).width() * 0.95);
      SaveSelectedDisplay.height($(window).height() * 0.95);
     }; // handleWindowResize

   
//----------------------------------------------------------------------------------------------------
	function initializeSelectionUI(){			     
	 console.log("====== Initializing Selection UI")

        nodecount_i=0;
         var margin = {top: 10, right: 15, bottom: 30, left: 20};
        InitialLoad = true;
	    SaveSelectedDisplay = $("#SavedSelectionTreeDiv");
        handleWindowResize();
        
        height = SaveSelectedDisplay.height(); //200;      
        var width = SaveSelectedDisplay.width(); //200;       
         
        tree = d3.layout.tree()
         .size([(height-margin.top-margin.bottom), (width-margin.left-margin.right)]);
     
        diagonal = d3.svg.diagonal()
         .projection(function(d) { return [d.y, d.x]; });
          
        SaveSelectedsvg = d3.select("#SavedSelectionTreeDiv").append("svg")
         .attr("width", width)
         .attr("height", height)
         .append("g")
             .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

         $(window).resize(handleWindowResize);

		// if date modified needs updated
		//http://www.dynamicdrive.com/forums/archive/index.php/t-63637.html

       };
       
//----------------------------------------------------------------------------------------------------
     function testingAddSavedSelection() {
       msg = {cmd:"test",
              callback: "",
              status:"request",
              payload:{  name: "test set",
         			PatientIDs : "random set of IDs here",
         			Tab: "None",
         			Settings: "gibberish"
         		}
             };
        addSavedSelection(msg);

}
//----------------------------------------------------------------------------------------------------
     function addSavedSelection(msg) {
       
       console.log("=== Saving Selection", msg)
 
 		var i=0;
 		var nameSuffix = ""
 		var nodeName =msg.payload.name 
        while(SelectionNames.indexOf(nodeName.concat(nameSuffix)) !== -1){
		    i++;
		    nameSuffix = "_".concat(i)	
		}
       newNode = msg.payload
       newNode.name = nodeName.concat(nameSuffix)
       SelectionNames.push(newNode.name)
       
       if(CurrentSelection.children){ 
            CurrentSelection.children.push(newNode);
       } else { CurrentSelection.children = [newNode] }
       
       var currentNode = CurrentSelection
       var update_id = CurrentSelection.id
       while(currentNode.parent){ 
          currentNode.parent.children[ currentNode.parent.children.indexOf(function(d) {  d.id ===update_id})] = currentNode;
          currentNode = currentNode.parent
        }
        root = currentNode;
       updateSavedSelection(root);
       
       CurrentSelection = CurrentSelection.children.filter(function(d){ return d.id === nodecount_i })[0]
    console.log("new tree: ", root)
    console.log("CurrentSelection: ", CurrentSelection)
	}       


//----------------------------------------------------------------------------------------------------
function make_editable(d, field)
{
// code from https://gist.github.com/GerHobbelt/2653660

    console.log("make_editable", arguments);
 
    this
      .on("mouseover", function() {
        d3.select(this).style("fill", "red");
      })
      .on("mouseout", function() {
        d3.select(this).style("fill", null);
      })
      .on("click", function(d) {
        var p = this.parentNode;
        console.log(this, arguments);
 
        // inject a HTML form to edit the content here...
 
        // bug in the getBBox logic here, but don't know what I've done wrong here;
        // anyhow, the coordinates are completely off & wrong. :-((
        var xy = this.getBBox();
        var p_xy = p.getBBox();
 
        xy.x -= p_xy.x;
        xy.y -= p_xy.y;
 
        var el = d3.select(this);
        var p_el = d3.select(p);
 
        var frm = p_el.append("foreignObject");
 
        var inp = frm
            .attr("x", xy.x)
            .attr("y", xy.y)
            .attr("width", 300)
            .attr("height", 25)
            .append("xhtml:form")
                    .append("input")
                        .attr("value", function() {
                            // nasty spot to place this call, but here we are sure that the <input> tag is available
                            // and is handily pointed at by 'this':
                            this.focus();
 
                            return d[field];
                        })
                        .attr("style", "width: 294px;")
                        // make the form go away when you jump out (form looses focus) or hit ENTER:
                        .on("blur", function() {
                            console.log("blur", this, arguments);
 
                            var txt = inp.node().value;
 
                            d[field] = txt;
                            el
                                .text(function(d) { return d[field]; });
 
                            // Note to self: frm.remove() will remove the entire <g> group! Remember the D3 selection logic!
                            p_el.selectAll(function() { return this.getElementsByTagName("foreignObject"); }).remove();
                        })
                        .on("keydown", function() {
                            console.log("keypress", this, arguments);
 
                            // IE fix
                            if (!d3.event)
                                d3.event = window.event;
 
                            var e = d3.event;
                            if (e.keyCode == 13)
                            {
                                if (typeof(e.cancelBubble) !== 'undefined') // IE
                                  e.cancelBubble = true;
                                if (e.stopPropagation)
                                  e.stopPropagation();
                                e.preventDefault();
 
                                var txt = inp.node().value;
 
                                d[field] = txt;
                                el
                                    .text(function(d) { return d[field]; });
 
                                // odd. Should work in Safari, but the debugger crashes on this instead.
                                // Anyway, it SHOULD be here and it doesn't hurt otherwise.
                                p_el.selectAll(function() { return this.getElementsByTagName("foreignObject"); }).remove();
                            }
                        });
      });
}
//----------------------------------------------------------------------------------------------------
     function updateSavedSelection(source) {
       var duration = d3.event && d3.event.altKey ? 5000 : 500;
     
     var tooltip = d3.select("body")
                .attr("class", "tooltip")
                .append("div")
                .style("position", "absolute")
                .style("z-index", "20")
                .style("visibility", "hidden")
                ;
     
       // Compute the new tree layout.
       var nodes = tree.nodes(root).reverse();
       console.log("Nodes", nodes);
       
       // Normalize for fixed-depth.
       nodes.forEach(function(d) { d.y = d.depth * 180; });
     
       // Update the nodes…
       var node =  SaveSelectedsvg.selectAll("g.node")
           .data(nodes, function(d) { return d.id || (d.id = ++nodecount_i); });
     
       // Enter any new nodes at the parent's previous position.
       var nodeEnter = node.enter().append("g")
           .attr("class", "node")
           .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
            .on("click", function(d) { toggle(d); updateSavedSelection(d); });
     
       nodeEnter.append("circle")
           .attr("r", 1e-6)
           .style("fill", function(d) { return d._children ? "lightsteelblue" : "grey"; })
           .on("mouseover", function(d){
                  var settings = getSettingsString(d);
                    tooltip.html(d.PatientIDs.length + " Patients from " + d.Tab + "<br></br>Settings: " + settings)
                     return tooltip.style("visibility", "visible"); })
           .on("mousemove", function(){return tooltip.style("top",
                         (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
           .on("mouseout", function(){return tooltip.style("visibility", "hidden");})
           ;
     
       nodeEnter.append("text")
           .attr("class", "NodeName")
           .attr("x", function(d) { return d.children || d._children ? -10 : 10; })
           .attr("dy", "1em")
           .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
           .text(function(d) { return d.name; })
           .style("fill-opacity", 1e-6)
           .call(make_editable, "NodeName");
     
       // Transition nodes to their new position.
       var nodeUpdate = node.transition()
           .duration(duration)
           .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });
     
       nodeUpdate.select("circle")
           .attr("r", 4.5)
           .style("fill", function(d) { return d._children ? "lightsteelblue" : "grey"; });
     
       nodeUpdate.select("text")
           .style("fill-opacity", 1);
     
       // Transition exiting nodes to the parent's new position.
       var nodeExit = node.exit().transition()
           .duration(duration)
           .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
           .remove();
     
       nodeExit.select("circle")
           .attr("r", 1e-6);
     
       nodeExit.select("text")
           .style("fill-opacity", 1e-6);
     
       // Update the links…
       var link = SaveSelectedsvg.selectAll("path.link")
           .data(tree.links(nodes), function(d) { return d.target.id; });
     
       // Enter any new links at the parent's previous position.
       link.enter().insert("path", "g")
           .attr("class", "link")
           .attr("d", function(d) {
             var o = {x: source.x0, y: source.y0};
             return diagonal({source: o, target: o});
           })
         .transition()
           .duration(duration)
           .attr("d", diagonal);
     
       // Transition links to their new position.
       link.transition()
           .duration(duration)
           .attr("d", diagonal);
     
       // Transition exiting nodes to the parent's new position.
       link.exit().transition()
           .duration(duration)
           .attr("d", function(d) {
             var o = {x: source.x, y: source.y};
             return diagonal({source: o, target: o});
           })
           .remove();
     
       // Stash the old positions for transition.
       nodes.forEach(function(d) {
         d.x0 = d.x;
         d.y0 = d.y;
       });
     }
     
//----------------------------------------------------------------------------------------------------
     // Toggle children.
     function toggle(d) {
       if (d.children) {
         d._children = d.children;
         d.children = null;
       } else {
         d.children = d._children;
         d._children = null;
       }
     }
//----------------------------------------------------------------------------------------------------
    function getSettingsString(d){
		console.log("change setting string: ",  d)
		var SettingsString = d.Settings;
		if(d.Tab === "ClinicalTable"){
		   if(d.Settings.ageAtDxMin){
		       SettingsString = "AgeDx [" + d.Settings.ageAtDxMin + ", " + d.Settings.ageAtDxMax + "] <br>"
		                  + "Survival [" + d.Settings.overallSurvivalMin + ", " + d.Settings.overallSurvivalMax + "]";
		    }
		}
		return SettingsString;
		
}
//----------------------------------------------------------------------------------------------------
    function loadPatientData(){

       console.log("==== SavedSelection  get all PatientIDs from ClinicalTable");
       cmd = "getCaisisPatientHistory"; //sendCurrentIDsToModule
       status = "request"
       callback = "SetupSavedSelectionTree"
          filename = "" // was 'BTC_clinicaldata_6-18-14.RData', now learned from manifest file
          msg = {cmd: cmd, callback: callback, status: "request", payload: filename};
        // console.log(JSON.stringify(msg))
       socket.send(JSON.stringify(msg));
       } // loadPatientDemoData

//----------------------------------------------------------------------------------------------------
     function SetupSavedSelectionTree(msg){			     

		console.log("===== Setup SavedSelection Tree")
         console.log(msg)

         var AllData = msg.payload
         var PtIDs = []; 
         for(var i=0;i<AllData.length; i++){
         	if(PtIDs.indexOf(AllData[i].PatientID) === -1)
         		PtIDs.push(AllData[i].PatientID)
         }
         console.log("All Patients: ", PtIDs)
         root = {   "name": "All Patients",
         			"PatientIDs" : PtIDs,
         			"Tab": "ClinicalTable",
         			"Settings": "None"
         		}
         
         root.x0 = height / 2;
         root.y0 = 0;
             	
         function toggleAll(d) {
           if (d.children) {
             d.children.forEach(toggleAll);
             toggle(d);
           }
         }
         
       InitialLoad = false;
       updateSavedSelection(root); 
       CurrentSelection = root;
       SelectionNames.push(root.name);
  
       console.log("root: ", root)
      
 //      testingAddSavedSelection()
       
     }     
  
//--------------------------------------------------------------------------------------------
 //    function HandleWindowResize(){
 //         Display.width($(window).width() * 0.95);
 //         Display.height($(window).height() * 0.80);
 //         if(!InitialLoad) {updateSavedSelection(root);}
 //    };
  
//----------------------------------------------------------------------------------------------------
     
       return{
     
        init: function(){
           onReadyFunctions.push(initializeSelectionUI);
           addJavascriptMessageHandler("SetupSavedSelectionTree", SetupSavedSelectionTree);
 		   addJavascriptMessageHandler("addSelectionToTree", addSavedSelection);
          socketConnectedFunctions.push(loadPatientData);
           }
        };
     
}); // SavedSelectionModule
 

//----------------------------------------------------------------------------------------------------
SavedSelection = SavedSelectionModule();
SavedSelection.init();

</script>