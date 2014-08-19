<script>
//----------------------------------------------------------------------------------------------------
var TimeLineModule = (function () {

     define(JAVASCRIPT_FORMAT, format)

     //--------------------------------------------------------------------------------------------------
     var TimelineTabNumber = 3;
     var TimeLineMargin = {top: 10, right: 15, bottom: 30, left: 20};
     var AlignBy = "--";
     var OrderBy = "--";
     var SidePlotEvent = "--";
     var TimeLineDisplay;
     var MainEvents = ["DOB","Encounter", "Diagnosis", "OR",  "MRI","Radiation", "Chemo","Progression",  "Status"]
     var MainEventColors = ["#17becf", "#d62728", "#8c564b","#ff7f0e", "#7f7f7f","#9467bd","#1f77b4","#2ca02c", "#bcbd22"]
     var MainEventTextSpacing = [0, 70, 82, 87, 75, 80, 78, 75, 80];
     var TimeLineSelectedRegion;    // from brushing
     var TimeLined3PlotBrush;
     var dialog;
     var TimeLinebroadcastButton;
     var TimeLineSelectionButton;
     var CalculatedEvents =[{Name:"Survival", Event1: "Diagnosis", Event2: "Status", TimeScale: "Months"},
                            {Name:"AgeDx",Event1: "DOB", Event2: "Diagnosis", TimeScale: "Years"},
                            {Name:"TimeToProgression",Event1: "Diagnosis", Event2: "Progression", TimeScale: "Days"},
                            {Name:"FirstProgressionToDeath",Event1: "Progression", Event2: "Status", TimeScale: "Days"} ];
         CalculatedEvents = d3.nest()
              .key(function(d) { return d.Name; })
              .map(CalculatedEvents, d3.map);
              
     var OneDay = 1000 *60 * 60*24;
     var TimeLineColor = d3.scale.ordinal().range(MainEventColors).domain(MainEvents);
     var PatientHeight = 3;

     var Events,EventsByID, FormatDate, EventTypes, ShowEvents;
     var dispatch = d3.dispatch("load","LoadOptions", "DisplayPatients", "Update", "UpdateMenuOptions");
     var TimeLineInitialLoad=true;
       
        //--------------------------------------------------------------------------------------------
       function initializeUI(){
             console.log("========== initializing Timeline UI")
           TimeLineDisplay = $("#TimeLineDisplay");
           TimeLineHandleWindowResize();
           TimeLinebroadcastButton = $("#SendSelectionToClinicalTable");
              TimeLinebroadcastButton.click(timelineSelectionToClinicalTable);
          TimeLineSelectionButton = $("#timelineSaveSelection");
              TimeLineSelectionButton.click(function(){
                  var selectionname = prompt("Please enter a selection name", "e.g. high survival")
                  if (selectionname != null & selectionname !== "e.g. high survival") 
                      timelineBroadcastSelection(selectionname);
              });
           $(window).resize(TimeLineHandleWindowResize);
           TimeLinebroadcastButton.prop("disabled",true);
           TimeLineSelectionButton.prop("disabled",true);
          
           dispatch.load();
      };

     //--------------------------------------------------------------------------------------------------     
     function getDateDiff(Name, Event1, Event2, TimeScale){
          console.log("Date Difference of " +Event2+ " - " + Event1 + " in " + TimeScale)          
          var DateDiff = []; var TimeScaleValue=1
          if(TimeScale==="Days"){TimeScaleValue=OneDay;}
          else if(TimeScale ==="Months"){TimeScaleValue=OneDay*30.425}
          else if(TimeScale==="Years"){ TimeScaleValue = OneDay*365.25}
               
          EventsByID.forEach(function(ID, Patient){
               var dateDiff = 0; var date1, date2;
                if( Name=== "Survival" & (!Patient.has("Status") | Patient.get("Status")[0].Type !== "Dead")) {
                     dateDiff = null;
                } else{
                  if(Patient.has(Event1) && Patient.has(Event2) ){
                     if(Patient.get(Event1)[0].date.length >1){
                         date1 = Patient.get(Event1).sort(AscendingStartDate)[0].date[0] }
                     else{ date1 = Patient.get(Event1).sort(AscendingDate)[0].date         }
                     if(Patient.get(Event2)[0].date.length >1){
                        date2 = Patient.get(Event2).sort(AscendingStartDate)[0].date[0] }
                     else{ date2 = Patient.get(Event2).sort(AscendingDate)[0].date         }
                    
                     dateDiff = (date2 - date1 )/TimeScaleValue
//                    DateDiff.push( {ID: ID,PtNum: Patient.get(Event1)[0].PtNum, value: dateDiff, Scale: TimeScale})
                   }else{ dateDiff=null;}
               }

            DateDiff.push( {ID: ID,PtNum: Patient.get(Patient.keys()[0])[0].PtNum, value: dateDiff, Scale: TimeScale})
          })
          return DateDiff;
     }
     
     //--------------------------------------------------------------------------------------------------     
     function getHorizontalBarSize(Patient){
     
//          console.log("Creating Horizontal BarPlot: ", Patient)
          var BarSizes = []
          Patient.forEach(function(d){
               xBar = 0; barWidth = ~~d.value
               if(d.value < 0){ xBar = ~~d.value; barWidth = Math.abs(d.value);  }
               BarSizes.push( {ID: d.ID, info: ~~d.value, Scale: d.Scale, xBar: xBar, yBar: d.PtNum,  width: barWidth})
          })     
          return BarSizes;
     }
     
      //--------------------------------------------------------------------------------------------
     function TimeLineHandleWindowResize(){
//       	console.log("===== resizing Timeline window")
          TimeLineDisplay.width($(window).width() * 0.95);
           TimeLineDisplay.height($(window).height() * 0.80);
          if(!TimeLineInitialLoad) {dispatch.DisplayPatients();}
     };

   //--------------------------------------------------------------------------------------------
   function timelineBroadcastSelection(selectionname){
 //     console.log("broadcastSelection: " + TimeLineSelectedRegion);
      x1=TimeLineSelectedRegion[0][0];
      y1=TimeLineSelectedRegion[0][1];
      x2=TimeLineSelectedRegion[1][0];
      y2=TimeLineSelectedRegion[1][1];
      ids = [];
      
      function LogTime(t){
                     if(AlignBy === "--"){ 
                               return t;
                     } else{ var Dir = (t<0 ? -1 : 1); 
                         return Dir * Math.log(Math.abs(t/OneDay)+1)/Math.log(2)
                    }
               }     
  
      for(var i=0; i < Events.length; i++){
         event = Events[i];
         if(event.PtNum >= y1/PatientHeight & event.PtNum <= y2/PatientHeight){
			// Patient within range
            
            if(event.date.length>1 ){
                 if( (LogTime(event.date[0]-event.offset) >=x1 & LogTime(event.date[0]-event.offset) <= x2) ||
	                 (LogTime(event.date[1]-event.offset) >=x1 & LogTime(event.date[1]-event.offset) <= x2) ){
	                  // date endpoints within range
	                
                      if(ids.indexOf(event.PatientID) === -1)
                        	ids.push(event.PatientID);
                }
            } else{
                 if (LogTime(event.date-event.offset) >=x1 & LogTime(event.date-event.offset) <= x2) {
	                  // date within range
                      if(ids.indexOf(event.PatientID) === -1)
                        	ids.push(event.PatientID);
                }
            }
         }
      } // for i
    
    if(ids.length > 0)
 //        sendIDsToModule(ids, "PatientHistory", "HandlePatientIDs");
         if(AlignBy === "--") {x1 = FormatDate(x1); x2 = FormatDate(x2)}
         settings = {AlignBy: AlignBy, OrderBy: OrderBy, x: [x1, x2], y: [y1, y2]}
         sendTimelineCurrentIDsToSelection(ids,selectionname, settings);
    };
   //--------------------------------------------------------------------------------------------
   function timelineSelectionToClinicalTable(){
//      console.log("broadcastSelection: " + TimeLineSelectedRegion);
      x1=TimeLineSelectedRegion[0][0];
      y1=TimeLineSelectedRegion[0][1];
      x2=TimeLineSelectedRegion[1][0];
      y2=TimeLineSelectedRegion[1][1];
      ids = [];
      
      function LogTime(t){
                     if(AlignBy === "--"){ 
                               return t;
                     } else{ var Dir = (t<0 ? -1 : 1); 
                         return Dir * Math.log(Math.abs(t/OneDay)+1)/Math.log(2)
                    }
               }     
  
      for(var i=0; i < Events.length; i++){
         event = Events[i];
         if(event.PtNum >= y1/PatientHeight & event.PtNum <= y2/PatientHeight){
			// Patient within range
            
            if(event.date.length>1 ){
                 if( (LogTime(event.date[0]-event.offset) >=x1 & LogTime(event.date[0]-event.offset) <= x2) ||
	                 (LogTime(event.date[1]-event.offset) >=x1 & LogTime(event.date[1]-event.offset) <= x2) ){
	                  // date endpoints within range
	                
                      if(ids.indexOf(event.PatientID) === -1)
                        	ids.push(event.PatientID);
                }
            } else{
                 if (LogTime(event.date-event.offset) >=x1 & LogTime(event.date-event.offset) <= x2) {
	                  // date within range
                      if(ids.indexOf(event.PatientID) === -1)
                        	ids.push(event.PatientID);
                }
            }
         }
      } // for i
    
    if(ids.length > 0)
         sendIDsToModule(ids, "PatientHistory", "HandlePatientIDs");
//         if(AlignBy === "--") {x1 = FormatDate(x1); x2 = FormatDate(x2)}
  //       settings = {AlignBy: AlignBy, OrderBy: OrderBy, x: [x1, x2], y: [y1, y2]}
    //     sendTimelineCurrentIDsToSelection(ids,selectionname, settings);
    };

//--------------------------------------------------------------------------------------------
  function timelineD3PlotBrushReader(){
     console.log("plotBrushReader");
     TimeLineSelectedRegion = TimeLined3PlotBrush.extent();
     //console.log("region: " + pcaSelectedRegion);
     y0 = TimeLineSelectedRegion[0][1];
     y1 = TimeLineSelectedRegion[1][1];
     selectHeight = Math.abs(y0-y1);
     if(selectHeight > 1){
        TimeLineSelectionButton.prop("disabled", false);
        TimeLinebroadcastButton.prop("disabled", false);
     } else {
        TimeLineSelectionButton.prop("disabled", true);
        TimeLinebroadcastButton.prop("disabled", true);
     }
     }; // d3PlotBrushReader

   //--------------------------------------------------------------------------------------------
  function sendIDsToModule(ids, moduleName, title){
       callback = moduleName + title;
       msg = {cmd:"sendIDsToModule",
              callback: callback,
              status:"request",
              payload:{targetModule: moduleName,
                       ids: ids}
             };
     socket.send(JSON.stringify(msg));
      } // sendTissueIDsToModule

  //--------------------------------------------------------------------------------------------
   function sendTimelineCurrentIDsToSelection (ids,selectionname, settings) {
      console.log("entering sendTimelineCurrentIDsToSelection");
       console.log(ids.length + " patientIDs going to SavedSelection")
      
      var NewSelection = {   
                    "userID": getUserID(),
                    "selectionname": selectionname,
         			"PatientIDs" : ids,
         			"Tab": "Timeline",
         			"Settings": settings
         		}
 
 
      msg = {cmd:"addNewUserSelection",
             callback: "addSelectionToTable",
               status:"request",
              payload: NewSelection 
             };
      msg.json = JSON.stringify(msg);
//           console.log(msg.json);
      socket.send(msg.json);
      } // sendTissueIDsToModule

   //--------------------------------------------------------------------------------------------------     
   function handlePatientIDs(msg){
      console.log("Module.TimeLine: handlePatientIDs");
      console.log(msg)
    $("#tabs").tabs( "option", "active", TimelineTabNumber);
 //       TimeLineInitialLoad=true;
     if(msg.status == "success"){
         patientIDs = msg.payload
//         console.log("TimeLine handlePatientIds: " + patientIDs);
         payload = patientIDs
         msg = {cmd: "getCaisisPatientHistory", callback: "DisplayPatientTimeLine", status: "request", 
                payload: payload};
         socket.send(JSON.stringify(msg));
         }
      else{
         console.log("handlePatientIDs about to call alert: " + msg)
         alert(msg.payload)
         }
      }; // handlePatientIDs


    //----------------------------------------------------------------------------------------------------
    function loadPatientDemoData(){

       console.log("==== patientTimeLines  get Events from File");
//       TimeLineInitialLoad=true;
       cmd = "getCaisisPatientHistory";
       status = "request"
       callback = "DisplayPatientTimeLine"
          filename = "" // was 'BTC_clinicaldata_6-18-14.RData', now learned from manifest file
          msg = {cmd: cmd, callback: callback, status: "request", payload: filename};
        // console.log(JSON.stringify(msg))
       socket.send(JSON.stringify(msg));
              
       } // loadPatientDemoData

     //--------------------------------------------------------------------------------------------------
     function DisplayPatientTimeLine(msg) {
         console.log("==== DisplayPatientTimeLine  Module.js document.ready");
          console.log(msg);

         console.log("==== DisplayPatientTimeLine  Events");     
          Events = msg.payload;
          console.log("Event count: " + Events.length);
         
          parseDate = d3.time.JAVASCRIPT_FORMAT ("%m/%d/%Y").parse;
          FormatDate = d3.time.JAVASCRIPT_FORMAT ("%x");
     
            Events.forEach(function(d) {
               d.Keep=true;
               if(d.date instanceof Array){
                    for(var i=0;i<d.date.length;i++){ 
                         if(parseDate(d.date[i])===null || !isValidDate(d.date[i])){ 
                              console.log("Flag "+ d.date[i]); d.Keep = false;
                         }else{  d.date[i] = parseDate(d.date[i]); }
               }}else{
                    if(parseDate(d.date)===null || !isValidDate(d.date)){ console.log("Flag "+ d.date); d.Keep=false;
                    } else{d.date = parseDate(d.date); }
               }
               if(d.Name === "Death") d.Name="Status"
               d.disabled = false;
              if(ShowEvents){
               if(ShowEvents.indexOf(d.Name) === -1){  d.disabled = true;} }

             d.showPatient = true;
              d.offset = 0    });
     
          console.log("Remove Invalid Dates")
          Events = Events.filter(function(d) {if(!d.Keep){ console.log(d.date)}
               return d.Keep })

           EventsByID = d3.nest()
              .key(function(d) { return d.PatientID; })
               .key(function(d) { return d.Name; })
              .map(Events, d3.map);
 
          EventTypes = d3.map()
          Events.forEach(function(d){
               if(EventTypes.has(d.Name)){
                    if(EventTypes.get(d.Name).indexOf(d.Type) === -1){
                         EventTypes.get(d.Name).push(d.Type)            }
               } else {
                    EventTypes.set(d.Name, [d.Type])
               }
          });          
     
 
          CalculatedEvents.forEach(function(key, entry){
               var value = entry[0];
               if(!EventTypes.has(value.Event1) ||  !EventTypes.has(value.Event2) ){
                    console.log("Removing Calculated Event: " + key)
                    CalculatedEvents.remove(key)
               }
          })

//          console.log("CaculatedEvents stored:", CalculatedEvents)
//          console.log("Events stored:", Events)
//          console.log("EventsByID stored:", EventsByID)

          if(TimeLineInitialLoad){
               ShowEvents = EventTypes.keys();
               dispatch.LoadOptions();
               TimeLineInitialLoad=false;
          }
          dispatch.DisplayPatients();
     }

     //--------------------------------------------------------------------------------------------------
     dispatch.on("LoadOptions.AllDisplays", function(){

          console.log("======== LoadOptions.AllDisplays")
          
          var width = $("#TimeLineDisplay").width();
          var height = $("#TimeLineDisplay").height();
          
          var   TimeLineSize = {width: (0.8*width - TimeLineMargin.left - TimeLineMargin.right), height: (0.95*height - TimeLineMargin.top - TimeLineMargin.bottom)},
                SideBarSize = {width: (0.2*width - TimeLineMargin.left - TimeLineMargin.right),  height: (0.95*height - TimeLineMargin.top - TimeLineMargin.bottom)},
                legendSize = {height: 0.05*height, width: TimeLineSize.width};

          var svg = d3.select("#TimeLineDisplay").append("svg")
                   .attr("id", "timelineSVG")
                   .attr("width", TimeLineSize.width + SideBarSize.width + 2*TimeLineMargin.left + 2*TimeLineMargin.right )
                   .attr("height", SideBarSize.height + TimeLineMargin.top + TimeLineMargin.bottom + legendSize.height)
                       ;

          var SidePlot = svg.append("g").attr("id", "SidePlotSVG")
                  .attr("transform", "translate(" + TimeLineMargin.left + "," + TimeLineMargin.top + ")");     
             
          var TimeLine = svg.append("g").attr("id", "TimeLineSVG")
                  .attr("transform", "translate(" + (SideBarSize.width+2*TimeLineMargin.left + TimeLineMargin.right) + "," + TimeLineMargin.top + ")");
          
          
          var TextOffSet = d3.scale.ordinal()
               .range(MainEventTextSpacing)
               .domain(MainEvents);

          console.log("==== Event Types")
          var legend = svg
                     .append("g")
                   .attr("class", "legend")
                   .attr("transform", "translate(" + (SideBarSize.width+2* TimeLineMargin.left + TimeLineMargin.right) + "," + (TimeLineSize.height+ TimeLineMargin.top + TimeLineMargin.bottom) + ")")
                    .selectAll(".legend")
                     .data(TimeLineColor.domain().filter(function(d){
                          return EventTypes.keys().indexOf(d) !== -1 })  )
              .enter().append("g")
            .attr("transform", function(d, i) { 
                      return "translate(" + i*TextOffSet(d) + ",0)" })
               ;
            legend.append("rect")
           .attr("width", 10)
           .attr("height", 10)
           .style("fill", function(d) { return TimeLineColor(d)})
           .on("click", ToggleVisibleEvent);

            legend.append("text")
            .attr("y", 9)
            .attr("x", 12)
            .style("font-size", 12)
           .text(function(d) { return d; });

          //--------------------------------------------------------------------------------------------------
          dispatch.on("DisplayPatients.SidePlotDisplay",  function(){

               console.log("======== DisplayPatients.SidePlotDisplay")
          
               SidePlot.selectAll("g").remove();

                   width = $("#TimeLineDisplay").width();
                    height = $("#TimeLineDisplay").height();
          
                 TimeLineSize = {width: (0.8*width - TimeLineMargin.left - TimeLineMargin.right), height: (0.95*height - TimeLineMargin.top - TimeLineMargin.bottom)}
                SideBarSize = {width: (0.2*width - TimeLineMargin.left - TimeLineMargin.right),  height: (0.95*height - TimeLineMargin.top - TimeLineMargin.bottom)}
                legendSize = {height: 0.05*height, width: TimeLineSize.width};
          
               svg.select(".legend")
                   .attr("transform", "translate(" + (SideBarSize.width+2* TimeLineMargin.left+TimeLineMargin.right) + "," + (TimeLineSize.height+ TimeLineMargin.top + TimeLineMargin.bottom) + ")")
          
               svg.attr("width", TimeLineSize.width + SideBarSize.width + 2*TimeLineMargin.left + 2*TimeLineMargin.right )
                   .attr("height", SideBarSize.height + TimeLineMargin.top + TimeLineMargin.bottom + legendSize.height)
                       ;
               TimeLine.attr("transform", "translate(" + (SideBarSize.width+2*TimeLineMargin.left + TimeLineMargin.right) + "," + TimeLineMargin.top + ")");
  
          
               var y = d3.scale.linear().range([SideBarSize.height, 0]), 
                    yAxis = d3.svg.axis().scale(y).orient("left").ticks(0),          
                    x = d3.scale.linear().range([0, SideBarSize.width]),
                    xAxis = d3.svg.axis().scale(x).orient("bottom");
                    
                    y.domain([d3.min(Events,function(d) { return PatientHeight*d.PtNum; })-PatientHeight,d3.max(Events,function(d) { return PatientHeight*d.PtNum; })+PatientHeight]);
//                  y.domain(d3.extent(Events, function(d) { return PatientHeight*d.PtNum; }));
//                   y.domain([d3.min(Events,function(d) { return d.PtNum; }),d3.max(Events,function(d) { return PatientHeight*d.PtNum; })]);
                             
               var PatientOrderBy = []
               var Categories = []

               
               console.log("Display Current Side Plot Event: " + SidePlotEvent)

               if(SidePlotEvent === "--"){     return;     
               } else if (CalculatedEvents.has(SidePlotEvent) ){
                    var event = CalculatedEvents.get(SidePlotEvent)[0]
                     console.log("Using event: ", event)
                     PatientOrderBy =  getHorizontalBarSize(getDateDiff(SidePlotEvent, event.Event1,event.Event2,event.TimeScale)); 
                    
               } else if(["Chemo", "Radiation", "Diagnosis", "OR", "Status", "MRI"].indexOf(SidePlotEvent) !== -1){
                    //get number of categories
                    EventsByID.forEach(function(ID, Patient){
                         if(Patient.has(SidePlotEvent) && Patient.get(SidePlotEvent)[0].showPatient){
                              Patient.get(SidePlotEvent).forEach(function(k){
                              if(Categories.indexOf(k.Type) == -1){ Categories.push(k.Type)} })
                         }
                    })
                    Categories.sort();
//                    console.log(Categories)
//                    console.log(Categories.length)
                    var xWidth = 1/Categories.length;
                    EventsByID.forEach(function(ID, Patient){
                         if(!Patient.has(SidePlotEvent)){
                         } else if(Patient.get(SidePlotEvent)[0].showPatient){               
                              var xPos = Categories.indexOf(Patient.get(SidePlotEvent)[0].Type)
                              PatientOrderBy.push( {ID: ID,info:Patient.get(SidePlotEvent)[0].Type, yBar: Patient.get(SidePlotEvent)[0].PtNum,
                                              xBar: xPos * xWidth , width: xWidth})
                         }
                    })
                    xAxis.ticks(Categories.length)
                         .tickValues(makeArray(Categories.length,  function(i) { return i/Categories.length; }))
                         .tickFormat(function (d) {return Categories[d*Categories.length]     })
               } 

               console.log("PatientOrderBy")
               console.log(PatientOrderBy)

                x.domain([d3.min([d3.min(PatientOrderBy, function(d){return d.width}),d3.min(PatientOrderBy, function(d){return d.xBar})]),
                               d3.max(PatientOrderBy, function(d){ return d.xBar + d.width})]).nice();

//               console.log("SidePlotDomain: ", d3.min([d3.min(PatientOrderBy, function(d){return d.width}),d3.min(PatientOrderBy, function(d){return d.xBar})]),
//               d3.max(PatientOrderBy, function(d){ return d.xBar + d.width}) )

 //            d3PlotBrush = d3.svg.brush()
   //            .x(x)
     //          .y(y)
       //        .on("brushend", d3PlotBrushReader);

          //     SidePlot.call(d3PlotBrush);

//			var HorizLine = svg.append("g").attr("class", "rect")

             var tooltip = d3.select("body")
                .attr("class", "tooltip")
                .append("div")
                .style("position", "absolute")
                .style("z-index", "10")
                .style("visibility", "hidden")
                .text("a simple tooltip");
     
                 SidePlot.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + (SideBarSize.height+TimeLineMargin.top) + ")")
                .call(xAxis)
                .selectAll("text")  
                    .style("text-anchor", "end")
                    .style("font-size", 12)
                      .attr("dy", ".55em")
                      .attr("dx", "-.45em")
                     .attr("transform", function(d) {
                         return "rotate(-75)" 
                        });
 
                 SidePlot.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                .on("mouseover", function(d){
                        tooltip.text("click to reorder by SidePlot value");
                     return tooltip.style("visibility", "visible"); })
                 .on("mousemove", function(){return tooltip.style("top",
                         (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
               .on("mouseout", function(){return tooltip.style("visibility", "hidden");})
                 .on("click", function(){
                           OrderBySidePlot(); 
                           dispatch.Update();
                           dispatch.DisplayPatients();})
                .attr("transform", "rotate(-90)")
                .attr("y", 2)
                .attr("dy", "-.71em")
                .style("font-size", 12)
                .style("text-anchor", "end")
                .text(SidePlotEvent)
                ;
            
               var BarPlot_Horiz = SidePlot.append("g").selectAll("rect")
                    .data(PatientOrderBy)
                    .enter()
                         .append("rect")
                         .attr("x", function(d) { return x(d.xBar);  })
                         .attr("y", function(d) { return y(PatientHeight*d.yBar); })
                         .attr("width", function(d) { return Math.abs(x(d.width) - x(0));  })
                         .attr("height", function(d) { return PatientHeight; })
                         .attr("fill", function(d){ 
                              var ColorShade =  d3.rgb(TimeLineColor(SidePlotEvent)); //d3.rgb("grey"); //
                              if(Categories.length>0){ 
                                   return ColorShade.brighter((Categories.indexOf(d.info) % 5)/2) };
                              return ColorShade;
                              })
                         .on("mouseover", function(d,i){
                          tooltip.text(d.ID + ": " + d.info);
                     return tooltip.style("visibility", "visible");
                     })
                          .on("mousemove", function(){return tooltip.style("top",
                         (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                          .on("mouseout", function(){return tooltip.style("visibility", "hidden");})
                         ;
          })

          //--------------------------------------------------------------------------------------------------
          dispatch.on("DisplayPatients.TimeLineDisplay",  function(){

               console.log("======== DisplayPatients.TimeLineDisplay")
               TimeLine.selectAll("g").remove();


                var tooltip = d3.select("body")
                .attr("class", "tooltip")
                .append("div")
                .style("position", "absolute")
                .style("z-index", "10")
                .style("visibility", "hidden")
                .text("a simple tooltip");

 
                var x,TimeScale, xTitle, xAxis, 
                    y = d3.scale.linear().range([TimeLineSize.height, 0]), 
                    yAxis = d3.svg.axis().scale(y).orient("left").ticks(0)
                    ;
               function LogTime(t){
                     if(AlignBy === "--"){ 
                               return t;
                     } else{ var Dir = (t<0 ? -1 : 1); 
                         return Dir * Math.log(Math.abs(t)+1)/Math.log(2) 
                    }
               }     
          
               if(OrderBy !== "--"){ OrderEvents();}
               if(AlignBy === "--"){ 
                     x = d3.time.scale().range([0, TimeLineSize.width]); TimeScale =1;
                     Xtitle="Year";
                     xAxis = d3.svg.axis().scale(x).orient("bottom")
               } else{
                    AlignEvents();
                     x =  d3.scale.linear().range([0, TimeLineSize.width])
                     TimeScale = OneDay
                     Xtitle = "Days"
                     xAxis = d3.svg.axis().scale(x).orient("bottom")
                         .ticks(10)
                         .tickFormat(function (d) { 
                              var Dir = (d<0 ? -1 : 1); 
                              return Math.round(Dir * (Math.pow(2, (Math.abs(d)))-1) *100)/100})
                    }

               var EventMin      = d3.min(Events.filter(function(d){ return d.showPatient && !d.disabled}), function(d){ 
                                        var date = (d.date instanceof Array ? d.date.sort(DescendingDate)[0] : d.date);  return LogTime((date - d.offset)/TimeScale);})
               var EventMax      = d3.max(Events.filter(function(d){ return d.showPatient && !d.disabled}), function(d){ 
                                        var date = (d.date instanceof Array ? d.date.sort(DescendingDate)[d.date.length-1] : d.date);  return LogTime((date - d.offset)/TimeScale);})

               x.domain([EventMin, EventMax]);
               y.domain([d3.min(Events,function(d) { return PatientHeight*d.PtNum; })-PatientHeight,d3.max(Events,function(d) { return PatientHeight*d.PtNum; })+PatientHeight]);
               console.log(y.domain())
      
               var EventOffset = d3.map({"Radiation": 1/3*(1/y.domain()[1]), "Chemo": -1/3*(1/y.domain()[1])})
 

             TimeLined3PlotBrush = d3.svg.brush()
               .x(x)
               .y(y)
               .on("brushend", timelineD3PlotBrushReader);

               TimeLine.call(TimeLined3PlotBrush);


            TimeLine.append("g")
                .attr("class", "x axis")
                .attr("transform", "translate(0," + TimeLineSize.height + ")")
                .call(xAxis)
               .append("text")
               .style("font-size", 12)
                .text(Xtitle);
 
            TimeLine.append("g")
                .attr("class", "y axis")
                .call(yAxis)
              .append("text")
                     .attr("transform", "rotate(-90)")
                .attr("y", 2)
                .attr("dy", ".71em")
                .style("text-anchor", "end")
                .style("font-size", 12)
                .text("Patients");
      
              var Hoverbar = TimeLine.append("g")
                .attr("class", "hoverbar")

 
                var TimeSeries = TimeLine.append("g").selectAll("path")
                    .data(Events.filter(function(d){ return (d.date instanceof Array) && !d.disabled && d.showPatient}))
               ;

      //         console.log("TimeSeries", TimeSeries)

               TimeSeries.enter()
                    .append("line")
                    .attr("class", "path")
                    .attr("x1", function(d) { return x(LogTime((d.date[0] - d.offset)/TimeScale));  })
                    .attr("y1", function(d) { return y(PatientHeight*(d.PtNum + EventOffset.get(d.Name))); })
                    .attr("x2", function(d) { return x(LogTime((d.date[1] - d.offset)/TimeScale));  })
                    .attr("y2", function(d) { return y(PatientHeight*(d.PtNum+ EventOffset.get(d.Name))); })
                    .attr("stroke", function(d){ 
                         var ColorShade = d3.rgb(TimeLineColor(d.Name)); 
                         if(d3.keys(d).indexOf("Type") !== -1){ 
                              return ColorShade.brighter((EventTypes.get(d.Name).indexOf(d.Type) % 5)/2) };
                         return ColorShade;
                         })
                    .attr("stroke-width", PatientHeight*0.75)
                    .attr("data-legend",function(d) { return d.Name})
                    .on("mouseover", function(d,i){
                        Hoverbar.append("rect")
                            .attr("x", 0)
                            .attr("y", y(d.PtNum*PatientHeight))
                            .attr("width", TimeLineSize.width)
                            .attr("height", PatientHeight)
                            .style("fill", "grey").style("opacity", 0.3);
                           
                         var Type = ""; if(d3.keys(d).indexOf("Type") !== -1){ Type = d.Type}
                     tooltip.text(d.PatientID + ": " + d.Name + " (" + FormatDate(d.date[0]) + ", "+ FormatDate(d.date[1]) + ") " + Type);
                     return tooltip.style("visibility", "visible");
                     })
                     .on("mousemove", function(){return tooltip.style("top",
                    (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                     .on("mouseout", function(){
                        Hoverbar.select("rect").remove();
                        return tooltip.style("visibility", "hidden");})
                    ;

               TimeSeries.exit().remove();

               var TimePoint = TimeLine.append("g").selectAll("circle")
                    .data(Events.filter(function(d){ return !(d.date instanceof Array) && !d.disabled && d.showPatient}));

      //         console.log("TimePoint", TimePoint)
                    
               TimePoint.enter()
                    .append("circle")
                    .attr("class", "circle")
                    .style("fill", function(d){ return TimeLineColor(d.Name) })
                    .attr("cx", function(d) {return x(LogTime((d.date -d.offset)/TimeScale)); })
                    .attr("cy", function(d) { return y(PatientHeight*d.PtNum); })
                    .attr("r", function(d) { return PatientHeight;})
                    .attr("data-legend",function(d) { return d.Name})
                    .on("mouseover", function(d,i){
                         Hoverbar.append("rect")
                            .attr("x", 0)
                            .attr("y", y(d.PtNum*PatientHeight))
                            .attr("width", TimeLineSize.width)
                            .attr("height", PatientHeight)
                            .style("fill", "grey").style("opacity", 0.3);

                         var Type = ""; if(d3.keys(d).indexOf("Type") !== -1){ Type = d.Type}
                      tooltip.text(d.PatientID + ": " + d.Name + " (" + FormatDate(d.date) +") " + Type);
                      return tooltip.style("visibility", "visible");
                     })
                     .on("mousemove", function(){return tooltip.style("top",
                    (d3.event.pageY-10)+"px").style("left",(d3.event.pageX+10)+"px");})
                     .on("mouseout", function(){ Hoverbar.select("rect").remove();return tooltip.style("visibility", "hidden");})
               ;

               TimePoint.exit().remove();                    

               })
          })

          //--------------------------------------------------------------------------------------------------
          dispatch.on("load.Menu", function(){
         
              var width = $("#TimeLineDisplay").width();
               var height = $("#TimeLineDisplay").height();
          
               var   TimeLineSize = {width: (0.8*width - TimeLineMargin.left - TimeLineMargin.right), height: (0.95*height - TimeLineMargin.top - TimeLineMargin.bottom)},
                     SideBarSize = {width: (0.2*width - TimeLineMargin.left - TimeLineMargin.right),  height: (0.95*height - TimeLineMargin.top - TimeLineMargin.bottom)},
                     legendSize = {height: 0.05*height, width: TimeLineSize.width};

               console.log("======== load.Menu")
  //             var PatientMenu = d3.select("#PatientSetDiv")
    //               .attr("transform", "translate(" + (3*TimeLineMargin.left+SideBarSize.width+TimeLineMargin.right) + ",0)")
      //              .append("g")
        //             .append("select")
   //                  .attr("multiple", "multiple")
          //           .on("click",function(d){
            //             UpdateSelectionMenu()})
              //       .on("change", function() {
                //        getSelectionbyName(this.value, callback="FilterTimelinePatients"); 
                  //       })
                // ;
                 
 //                 PatientMenu.selectAll("option")
   //                     .data(getSelectionNames())
     //                   .enter()
       //                  .append("option")
         //                .attr("value", function(d){return d})
           //              .text(function(d) { return d})
             //   ;
                 //--------------------------------------------------------------------------------------------
//               function UpdateSelectionMenu(){           
//                }
 
 //d3.select("input").property("checked", true).each(change);
//<label><input type="checkbox"> Sort values</label>

//  <label><input type="radio" name="dataset" value="apples" checked> Apples</label>
//  <label><input type="radio" name="dataset" value="oranges"> Oranges</label>


                 var  AlignByMenu = d3.select("#AlignByDiv")
                   .attr("transform", "translate(" + (3*TimeLineMargin.left+SideBarSize.width+TimeLineMargin.right) + ",0)")
                    .append("g")
                     .append("select")
                    .on("change", function() {
                         AlignBy = this.value; 
                         AlignEvents(); 
                         dispatch.DisplayPatients()});
                 ;
               AlignByMenu.selectAll("option")
                    .data(["--"])
                    .enter()
                         .append("option")
                         .attr("value", function(d){return d})
                         .text(function(d) { return d})
                ;

                 var  OrderByMenu = d3.select("#OrderByDiv")
                   .attr("transform", "translate(" + (TimeLineMargin.left+SideBarSize.width+TimeLineMargin.left+TimeLineMargin.right) + ",0)")
                     .append("g")
                   .append("select")
                    .on("change", function() {
                         OrderBy = this.value; 
                         if(OrderBy === "+Add"){
                              console.log("== changing OrderBy with ", OrderBy)
                              OpenDialogForAddedEvents("OrderBy");
                         } else{
                              console.log("== changing OrderBy ", OrderBy)
                         OrderEvents();      
                              dispatch.DisplayPatients();
//                              dialog.dialog("destroy");
                         }
                    })
                 ;
               OrderByMenu.selectAll("option")
                    .data(["--", "+Add"])
                    .enter()
                         .append("option")
                         .attr("value", function(d){return d})
                         .text(function(d) { return d})
                ;
               var  AddSideBarMenu = d3.select("#AddSideBar")
                    .style("display", "inline-block") 
                    .style("width", (SideBarSize.width + 2*TimeLineMargin.left + TimeLineMargin.right) +"px" )
                    .append("g")
                    .append("select")
                    .on("change", function() {SidePlotEvent = this.value; 
                         if(SidePlotEvent === "+Add"){
                              console.log("== changing SideBar with ", SidePlotEvent)
                              OpenDialogForAddedEvents("SidePlot");
                         } else{ 
                              console.log("== changing SideBar", SidePlotEvent)
                                                  dispatch.DisplayPatients(); 
//                         dialog.dialog("destroy");
                         }
                                                  });
               AddSideBarMenu.selectAll("option")
                    .data(["--", "+Add"])
                    .enter()
                         .append("option")
                         .attr("value", function(d){return d})
                         .text(function(d) { return d})
                ;
                var  SaveImage = d3.select("#SaveImageDiv")
                    .on("click", function() {
                         console.log("========Save Image: ")
          
                         var html = d3.select("svg")
                                      .attr("version", 1.1)
                                  .attr("xmlns", "http://www.w3.org/2000/svg")
                                      .node().parentNode.innerHTML;
                        var imgsrc = 'data:image/svg+xml;base64,'+ btoa(html);
                         var img = '<img src="'+imgsrc+'">';
                    
                         var canvas = document.querySelector("canvas"),
                             context = canvas.getContext("2d");

                         var image = new Image;
                         image.src = imgsrc;
                         image.onload = function() {
                                context.drawImage(image, 0, 0);
          
                              var canvasdata = canvas.toDataURL("image/png");
                              var pngimg = '<img src="'+canvasdata+'">'; 

                                var a = document.createElement("a");
                                   a.download = "test.png"
                                     a.href = canvasdata;
                                a.click();
                         }
                    })
     
         //--------------------------------------------------------------------------------------------------
         dispatch.on("UpdateMenuOptions.Menu", function(){
     
            console.log("======== UpdateMenuOptions")
//            console.log("CalculatedEvents keys: ", CalculatedEvents.keys())
  //          console.log("EventTypes keys: ",EventTypes.keys())
    //        console.log("OrderByMenu: ", OrderByMenu)
     
          OrderByMenu.selectAll("option").remove()     
          AlignByMenu.selectAll("option").remove()
          AddSideBarMenu.selectAll("option").remove()
              
           OrderByMenu.selectAll("option")
                    .data(d3.merge([["--", "+Add"], CalculatedEvents.keys() ,EventTypes.keys()]))
                    .enter()
                         .append("option")
                         .attr("value", function(d){return d})
                         .text(function(d) { return d})
                ;
       
                 AlignByMenu.selectAll("option")
                    .data(d3.merge([["--"],EventTypes.keys()]))
                    .enter()
                         .append("option")
                         .attr("value", function(d){return d})
                         .text(function(d) { return d})
           ;
           
           AddSideBarMenu.selectAll("option")
                    .data(d3.merge([["--", "+Add"], CalculatedEvents.keys(), ["Radiation", "Chemo", "Diagnosis", "OR", "MRI", "Status"].filter(function(d){ return EventTypes.has(d) })]))
                    .enter()
                         .append("option")
                         .attr("value", function(d){return d})
                         .text(function(d) { return d})
           ;
           
     
        })
        //--------------------------------------------------------------------------------------------------
          dispatch.on("LoadOptions.Menu",  function(){
               console.log("======== LoadOptions.Menu")     
               dispatch.UpdateMenuOptions()
          })
     
          
          //--------------------------------------------------------------------------------------------------
          dispatch.on("Update.Menu", function(){
               console.log("======== Update.Menu")
                
               OrderByMenu.selectAll("option")
                         .each(function(d){if(d === OrderBy) return d3.select(this).attr("selected", "selected")})
               AddSideBarMenu.selectAll("option")
                         .each(function(d){if(d === SidePlotEvent) return d3.select(this).attr("selected", "selected")})				
               AlignByMenu.selectAll("option")
                         .each(function(d){if(d === AlignBy) return d3.select(this).attr("selected", "selected")})
          })
     })
                          
    //--------------------------------------------------------------------------------------------
     function FilterTimelinePatients(msg){
    
        console.log("=======Updating Patient Selection")
        console.log(msg)
        
        selections = msg.payload
        
         patientIDs = selections.patientIDs
        // console.log("TimeLine Filter PatientIds: " + patientIDs);
         payload = patientIDs
         msg = {cmd: "getCaisisPatientHistory", callback: "DisplayPatientTimeLine", status: "request", 
                payload: payload};
         socket.send(JSON.stringify(msg));
     }
    //--------------------------------------------------------------------------------------------
     function UpdateCalculatedEvent(value){
               
          }
        //--------------------------------------------------------------------------------------------
       function CreateCalculatedEvent() {
                          var Name = $( "#Name" ).val();
                          var Event1 = $( "#Event1" ).val();
                          var Event2 = $( "#Event2" ).val();
                          var TimeScale = $( "#TimeScale").val();
  //                       console.log("Calculated Event: ")
//                         console.log(Name, Event1 , Event2, TimeScale);

                          var valid = true;
      
                          valid = valid && EventTypes.has(Event1);
                          valid = valid && EventTypes.has(Event2);
                           valid = valid && ["Days", "Months", "Years"].indexOf(TimeScale) !== -1;
  
                          if ( valid ) {
                            CalculatedEvents.set(Name, [{Name: Name, Event1: Event1, Event2: Event2,  TimeScale: TimeScale}])
                            console.log("Calculated Events Added: " + Name)
                            console.log(CalculatedEvents);
                             dialog.dialog( "close" );
                             return(Name);
                          } else {
                                 console.log("Invalid Calculated Event");
                               return("--");
                          }
                   }

      
      //--------------------------------------------------------------------------------------------
       function OpenDialogForAddedEvents(MenuType) {
          console.log("======== Dialog for Adding Events")
          dialog = $( "#AddCalculatedEvent" ).dialog({
                autoOpen: false,
                title: "Calculate Event",
                height: 300,
                width: 400,
                buttons: {
                  "Create": function(){
                            var value = CreateCalculatedEvent()
                            
                            if(MenuType == "OrderBy"){
                                   OrderBy = value;
                                   console.log("OrderBy is now: " + OrderBy);
                                   OrderEvents();
                              } else if (MenuType == "SidePlot"){
                                   SidePlotEvent = value;
                                   console.log("SidePlotEvent is now: " + SidePlotEvent);
                              }
                              dialog.dialog("close")
                               dispatch.UpdateMenuOptions();
                               dispatch.Update(); 
                               dispatch.DisplayPatients();
                       },
                  Cancel: function() { dialog.dialog( "close" ); UpdateCalculatedEvent("--");}
                },
                close: function() {}
                
         });
           dialog.dialog( "open" );
 
     }

     //--------------------------------------------------------------------------------------------------
     function AlignEvents(){
     
          console.log("========Align Event: "+ AlignBy);
          Events.forEach(function(d){ d.offset = 0; d.showPatient=true;})
          EventsByID.forEach(function(ID, Patient){
                         Patient.forEach(function(id, event){event.showPatient = true; event.offset=0;})})

          if (AlignBy === "AgeDx"){ 
          } else if(EventTypes.keys().indexOf(AlignBy) !== -1){
               EventsByID.forEach(function(ID, Patient){
                    if( Patient.has(AlignBy)){
                         var MinPatientAlignBy = d3.min(Patient.get(AlignBy), function(d) {var date = (d.date instanceof Array ? d3.min(d.date) : d.date);  return date})
                         Events.filter(function(d){return d.PatientID === ID})
                              .forEach(function(d){ d.offset = MinPatientAlignBy;})
                    }
                    else{          // hide Patients that can't be aligned
                         Events.filter(function(d){return d.PatientID === ID})
                                   .forEach(function(d){ d.showPatient = false; d.offset=0;})
                         Patient.forEach(function(id, event){event.showPatient = false; event.offset=0;})
                    }
               })
          }
     }     

     //--------------------------------------------------------------------------------------------------
     function OrderEvents(){
     
          console.log("========Order Event: "+ OrderBy);
          var PatientOrderBy = []


          if(CalculatedEvents.has(OrderBy) ){
                var event = CalculatedEvents.get(OrderBy)[0]
//                console.log(event)
                PatientOrderBy = getDateDiff(OrderBy, event.Event1,event.Event2,""); 
          } else if(EventTypes.keys().indexOf(OrderBy) !== -1){
               EventsByID.forEach(function(ID, Patient){
                    if( Patient.has(OrderBy)){
                         PatientOrderBy.push(d3.min(Patient.get(OrderBy), function(d) 
                              {var date = (d.date instanceof Array ? d3.min(d.date) : d.date);   
                                   return {ID: ID, value: date} }))
                    } else{
                         PatientOrderBy.push({ID: ID, value: 0} )
                    }   })
          } 
     
          PatientOrderBy.sort(DescendingValues).forEach(function(Ordered, i){
                         Events.filter(function(d){return d.PatientID === Ordered.ID})
                                   .forEach(function(d){ d.PtNum = i})
                         if(EventsByID.has(Ordered.ID)){EventsByID.get(Ordered.ID)
                                   .forEach(function(d){ d.PtNum = i})}
               })
          console.log("Reordered")
          console.log(PatientOrderBy)
     }     
     //--------------------------------------------------------------------------------------------------
     function OrderBySidePlot(){
     
          console.log("========Order by SidePlot: "+ SidePlotEvent);
          var PatientOrderBy = [], Categories = [];

          OrderBy = "--";
          if(CalculatedEvents.has(SidePlotEvent) ){
                var event = CalculatedEvents.get(SidePlotEvent)[0]
//                console.log(event)
                PatientOrderBy = getDateDiff(SidePlotEvent, event.Event1,event.Event2,""); OrderBy=SidePlotEvent;
          
          } else if(EventTypes.keys().indexOf(SidePlotEvent) !== -1){

               EventsByID.forEach(function(ID, Patient){
                    if(Patient.has(SidePlotEvent) && Patient.get(SidePlotEvent)[0].showPatient){
                         Patient.get(SidePlotEvent).forEach(function(k){
                              if(Categories.indexOf(k.Type) == -1){ Categories.push(k.Type)}
                         })
                         PatientOrderBy.push({ID:ID, value: Patient.get(SidePlotEvent)[0].Type})
                    }
               })
               
               Categories.sort();
  //             console.log(Categories)
  //             console.log(Categories.length)
          
               PatientOrderBy.forEach(function(d,i){
                    d.value = Categories.indexOf(d.value)
               })
               
          }
          
          PatientOrderBy.sort(DescendingValues).forEach(function(Ordered, i){
                         Events.filter(function(d){return d.PatientID === Ordered.ID})
                                   .forEach(function(d){ d.PtNum = i})
                         if(EventsByID.has(Ordered.ID)){EventsByID.get(Ordered.ID)
                                   .forEach(function(d){ d.PtNum = i})}
               })
          
          
          console.log("Reordered")
          console.log(PatientOrderBy)
     }     

     //--------------------------------------------------------------------------------------------------
     function DescendingDate(a,b) {
       if (a.date > b.date)
          return -1;
       if (a.date < b.date)
         return 1;
       return 0;
     }
    //--------------------------------------------------------------------------------------------------
     function DescendingStartDate(a,b) {
       if (a.date[0] > b.date[0])
          return -1;
       if (a.date[0] < b.date[0])
         return 1;
       return 0;
     }
     //--------------------------------------------------------------------------------------------------
     function AscendingDate(a,b) {
       if (a.date < b.date)
          return -1;
       if (a.date > b.date)
         return 1;
       return 0;
     }
    //--------------------------------------------------------------------------------------------------
     function AscendingStartDate(a,b) {
       if (a.date[0] < b.date[0])
          return -1;
       if (a.date[0] > b.date[0])
         return 1;
       return 0;
     }
     //--------------------------------------------------------------------------------------------------
     function DescendingValues(a,b) {
       if (a.value > b.value)
          return -1;
       if (a.value < b.value)
         return 1;
       return 0;
     }
     //--------------------------------------------------------------------------------------------------
     function makeArray(count, content) {
        var result = [];
        if(typeof(content) == "function") {
           for(var i=0; i<count; i++) {
              result.push(content(i));
           }
        } else {
           for(var i=0; i<count; i++) {
              result.push(content);
           }
        }
        return result;
     }
     //--------------------------------------------------------------------------------------------------
     function isValidDate(text) {
          //eg text = '2/30/2011';
     
          var comp = text.split('/');
          var m = parseInt(comp[0], 10);
          var d = parseInt(comp[1], 10);
          var y = parseInt(comp[2], 10);
          var date = new Date(y,m-1,d);
     
          if (date.getFullYear() !== y || date.getMonth() + 1 !== m || date.getDate() !== d){
               console.log("Invalid Format Month/Day/Year " + text + ": " + m + "/" + d+ "/" + y)
             return false;
          }
               
          // check month and year
          if(y < 1000 || y > 3000 || m == 0 || m > 12){
               console.log("Invalid Month/Year: " + m + "/" + y)
             return false;
          }
         var monthLength = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];
     
         // Adjust Days for leap years
         if(y % 400 == 0 || (y % 100 != 0 && y % 4 == 0))
             monthLength[1] = 29;
     
         // Check the range of the day
         if( d <= 0 || d > monthLength[m - 1]){
               console.log("Invalid Day/Month: " + d+ "/" + m)    
               return false;
          }
          
          return true;
     }
     //--------------------------------------------------------------------------------------------------     
     function ToggleVisibleEvent(d){
         
         var hide = false;
         var newFilters = [];
      
         ShowEvents.forEach(function (f) {
           if (d === f) {  
                hide = true;
                console.log("Hiding " + d);
                Events.forEach(function(D){ 
                     if(D.Name === d) {D.disabled=true}});
           } else { newFilters.push(f);}
         });
     
          // Hide the shape or show it
          if (hide) {  d3.select(this).style("opacity", 0.2);
         } else {
           d3.select(this).style("opacity", 1);
           newFilters.push(d);
           Events.forEach(function(D){ 
                     if(D.Name === d) {D.disabled=false}});
          }
          ShowEvents = newFilters;
          dispatch.DisplayPatients();
     }
     //--------------------------------------------------------------------------------------------------
     
     //--------------------------------------------------------------------------------------------------

  return{
   init: function(){
          onReadyFunctions.push(initializeUI);
          
          addJavascriptMessageHandler("DisplayPatientTimeLine", DisplayPatientTimeLine);
         addJavascriptMessageHandler("timeLinesHandlePatientIDs", handlePatientIDs);
//         addJavascriptMessageHandler("UpdateSelectionList", UpdateSelectionMenu);
         addJavascriptMessageHandler("FilterTimelinePatients", FilterTimelinePatients);
         socketConnectedFunctions.push(loadPatientDemoData);
   }
  };

}); // TimeLineModule
//----------------------------------------------------------------------------------------------------
PatientTimeLine = TimeLineModule();
PatientTimeLine.init();
</script>

