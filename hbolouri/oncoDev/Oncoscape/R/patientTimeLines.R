#                   incoming message          function to call             return.cmd
#                   -------------------       ----------------            -------------
addRMessageHandler("fetchTblPtInfo",          "returnTblPtInfoString")   # tblPtInfoString
addRMessageHandler("fetchTimeLineMatrix",     "returnTimeLineMatrix")    # timeLineMatrix
addRMessageHandler("fetchPatientEventNames",  "returnPatientEventNames") # patientEventNames
addRMessageHandler("mapTissueIdsForTimeLines",  "returnPatientEventNames") # patientEventNames
addRMessageHandler("getPatientJSONevents",  "returnPatientJSONevents")   # timeLineMatrix
addRMessageHandler("getPatientJSONevents_fromFile",  "returnPatientFile")   # timeLineMatrix

#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
PatientDatesAndColors <- list(
                              RTx_StartDt = "red",
                              RTx_StopDt = "red",
                              ChemoStartDate = "darkgreen",
                              ChemoEndDate = "darkgreen",
                              ChemoStartDate2 = "darkolivegreen3",
                              ChemoEndDate2 = "darkolivegreen3",
                              ChemoStartDate3 = "greenyellow",
                              ChemoEndDate3 = "greenyellow",
                              ChemoStartDate4 = "yellow",
                              ChemoEndDate4 = "yellow",
                              ChemoStartDate5 = "darkorchid1",
                              ChemoEndDate5 = "darkorchid1",
                              ChemoStartDate6 = "darkorchid1",
                              ChemoEndDate6 = "darkorchid1",
                              PostOpMRIDate = "black",
                              FirstProgression = "blue",
                              SecondProgression = "blue",
                              ThirdProgression = "blue",
                              FourthProgression = "blue",
                              StatusDate = "orange",
                              DOB = "grey",
                              MSKEncounterDate = "brown",
                              DiagnosisDate = "aquamarine",
                              OR_Date = "cornflowerblue")

color.map <- new.env(parent=emptyenv())
color.map[["RTx_StartDt"]] <-  "red";
color.map[["RTx_StopDt"]] <-  "red";
color.map[["ChemoStartDate"]] <-  "darkgreen";
color.map[["ChemoEndDate"]] <-  "darkgreen";
color.map[["ChemoStartDate2"]] <-  "darkolivegreen3";
color.map[["ChemoEndDate2"]] <-  "darkolivegreen3";
color.map[["ChemoStartDate3"]] <-  "greenyellow";
color.map[["ChemoEndDate3"]] <-  "greenyellow";
color.map[["ChemoStartDate4"]] <-  "yellow";
color.map[["ChemoEndDate4"]] <-  "yellow";
color.map[["ChemoStartDate5"]] <-  "darkorchid1";
color.map[["ChemoEndDate5"]] <-  "darkorchid1";
color.map[["ChemoStartDate6"]] <-  "darkorchid1";
color.map[["ChemoEndDate6"]] <-  "darkorchid1";
color.map[["PostOpMRIDate"]] <-  "black";
color.map[["FirstProgression"]] <-  "blue";
color.map[["SecondProgression"]] <-  "blue";
color.map[["ThirdProgression"]] <-  "blue";
color.map[["FourthProgression"]] <-  "blue";
color.map[["StatusDate"]] <-  "orange";
color.map[["DOB"]] <-  "grey";
color.map[["MSKEncounterDate"]] <-  "brown";
color.map[["DiagnosisDate"]] <-  "aquamarine";
color.map[["OR_Date"]] <-  "cornflowerblue";
#----------------------------------------------------------------------------------------------------
if(!exists("tbl.pt")){
    filename <- system.file(package="Oncoscape", "extdata", "tbl.pt.RData")
    stopifnot(file.exists(filename))
    load(filename)
    Oncoscape:::.oldLoadData()
    }
#----------------------------------------------------------------------------------------------------
# not sure how to correlate lisa's ids with those i have been using
# 
# match(tbl.pt$BTC_ID, tbl.idLookup$btc)
#   [1]  NA  NA  NA  NA  NA  NA  NA  NA  NA  70  NA  NA  NA  NA  NA  NA  NA  NA
#  [19]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#  [37]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
#  [55]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA 160 162 163 165  NA 166
#  [73] 167 168 169 170  NA 171 172 173 174 175 176 178 179 180 181  NA 183 184
#  [91] 185 186 187 188 189 190  NA  NA 191 192 193 195  NA 196 197 198 199 203
# [109] 206 207   1  NA 208   2 209  NA 210 211 212 213 215 217 218 219 220   3
# [127] 221   4  NA  NA  NA 222 223 224   7   8  NA  NA   9  NA  11  NA  12  NA
# [145] 225  13  14  NA  15  NA  NA  16 227  17  18  NA  19  NA  20  NA 228  NA
# [163]  NA  NA  23  NA  NA  NA  24  25  NA  26  NA  NA  27  28  29  30  NA  NA
# [181]  NA  NA  NA  31  32  33  NA  34  NA  36  37  38  NA  39  40  NA  41  42
# [199]  NA  43  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
# [217]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
# [235]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
# [253]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
# [271]  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA  NA
filterPatientTimeLineTable <- function(colnames=NA)
{
   if(!all(is.na(colnames)))
       tbl.pt <- tbl.pt[, colnames]

   #if(!all(is.na(tissueIDs)))
   #    tbl.pt <- subset(tbl.pt, SpecimenId %in% tissueIDs)
   
   return (tbl.pt)
   
} # filterPatientTimeLineTable
#----------------------------------------------------------------------------------------------------
getColorMap <- function()
{
  color.map
  
} # getColorMap
#----------------------------------------------------------------------------------------------------
timelineMapTissueIDs <- function(tissueIDs)
{
    # browser();
    hits <- match(tissueIDs, tbl.idLookup$specimen)
    btc <- tbl.idLookup$btc[hits]
    hits.2 <- match(btc, tbl.pt$BTC_ID)
    patients <- tbl.pt$PatientID[hits.2]
    deleters <- which(is.na(patients))
    if(length(deleters) > 0)
        patients <- patients[-deleters]

    if(length(patients) == 0)
        patients <- c()

    patients


} # timelineMapTissueIDs 
#----------------------------------------------------------------------------------------------------
# patients are, for now, identified by simple (and uncorrelated?) patientIDs: P1, P2, ...
createTimeMatrix <- function(patients=NA, events=NA, log2Transform=FALSE)
{
   if(all(is.na(patients)))
       patients <- tbl.pt$PatientID

   if(all(is.na(events)))
       events <- ls(color.map)
   else
       stopifnot(all(events %in% colnames(tbl.pt)))

   patient.identifiers <- intersect(patients, tbl.pt$PatientID)
   non.patient.identifiers <- setdiff(patients, tbl.pt$PatientID)
   if(length(non.patient.identifiers) > 0){
      mapped.patient.ids <- timelineMapTissueIDs(non.patient.identifiers);
      if(length(mapped.patient.ids) > 0)
          patient.identifiers <- unique(c(patient.identifiers, mapped.patient.ids))
      } # some non.patient.identifers, tissueIDs presumably

   patients <- patient.identifiers

   rows <- match(patients, tbl.pt$PatientID)              
   tbl.dates <- tbl.pt[rows, events]
   
   if(log2Transform)
      mtx <- sapply(tbl.dates, function(dates) {
                    t <- as.numeric(dates);
                    sign <- ifelse(t<0, -1, 1);
                    sign * log(abs(t)+1)})
   else
      mtx <- tbl.dates; #sapply(tbl.dates, function(dates) as.numeric(dates))

   if(is.null(dim(mtx))) return(NA)

   rownames(mtx) <- patients

   mtx

} # createTimeMatrix
#----------------------------------------------------------------------------------------------------
alignTimeMatrix <- function(mtx, column)
{
    stopifnot(column %in% colnames(mtx))
    shiftDate <- mtx[, column]
    mtx - shiftDate
    #browser()
    #x <- 99
              
} # alignTimeMatrix
#----------------------------------------------------------------------------------------------------
returnTblPtInfoString <- function(WS, msg)
{
    result <- sprintf("%d rows and %d columns", nrow(tbl.pt), ncol(tbl.pt))
    return.msg <- toJSON(list(cmd="tblPtInfoString", callback="", status="result", payload=result))
    sendOutput(DATA=return.msg, WS=WS)
   
} # returnTblPtInfoString
#---------------------------------------------------------------------------------------------------
returnPatientFile<- function(WS, msg)
{
    print(msg)
    #returns already loaded PatientData_json
    return.msg <- toJSON(list(cmd="timeLineMatrix",
                              callback="",
                              status="success",
                              payload=PatientData_json))
    websocket_write(DATA=return.msg, WS=WS)

	
} # returnPatientFile
#---------------------------------------------------------------------------------------------------
returnPatientJSONevents<- function(WS, msg)
{
    print(msg)

    patient.ids <- fromJSON(msg$payload)
    printf("returnTimeLineMatrix, patient.ids: %s", paste(patient.ids, collapse=","))
    printf("   patient.ids count: %d", length(patient.ids))


	JSONevents <- getEventsMtx(tbl.clinical2, patient.ids)
	print(paste("returnPatientJSONevents, JSONevents: ", JSONevents, collapse="; "));
#	JSONevents <- toJSON(JSONevents)
#	print("returnPatientJSONevents, JSONevents: %s", JSONevents);
		
	   return.msg <- toJSON(list(cmd="timeLineMatrix",
                             callback="",
                             status="success",
                             payload=JSONevents))
      websocket_write(DATA=return.msg, WS=WS)
 	
}
#---------------------------------------------------------------------------------------------------
getEventsMtx <- function(DataTable, subset=NULL){

  printf("getEventsMtx, DataTable: %s", paste(DataTable[1:5,], collapse=", "))

  printf("getEventsMtx, colnames: %s", paste(colnames(DataTable), collapse=", "))
  printf("getEventsMtx, DataSubset1: %s", DataTable[DataTable$tissueID == subset[1],1:3])

	IDcolumn = "tissueID"

	Chemo = c("ChemoStartDate",	"ChemoEndDate","ChemoStartDate2",	"ChemoEndDate2","ChemoStartDate3",	"ChemoEndDate3",
			  "ChemoStartDate4",	"ChemoEndDate4","ChemoStartDate5",	"ChemoEndDate5","ChemoStartDate6",	"ChemoStopDate6")
	ChemoAgent = c("ChemoAgent", "ChemoAgent2", "ChemoAgent3", "ChemoAgent4", "ChemoAgent5", "ChemoAgent6")
	#	sort(unique(unlist(DataTable[,ChemoAgent])))

	EventNames = c("PostOpMRIDate","FirstProgression", "SecondProgression", "ThirdProgression", "StatusDate")
	EventLegend = c("MRI", "Progression", "Progression", "Progression", "Death")
	EventType = c("PostOpMRIResult",NA,NA,NA, "Vital")

	#EventNames = c("DOB","MSKEncounterDate", "DiagnosisDate", "OR_Date",  "PostOpMRIDate", "FirstProgression", "SecondProgression", "ThirdProgression", "FourthProgression", "StatusDate")
	#EventLegend = c("DOB","Encounter", "Diagnosis", "OR",  "MRI", "Progression", "Progression", "Progression", "Progression", "Death")
	#EventType = c(NA,NA, "Grade", "Surgeon",  "PostOpMRIResult",NA,NA,NA,NA, "Vital")



#	if(missing(subset)){ subset = rownames(DataTable)}
#	if(missing(subset)){ subset = 1:nrow(DataTable)}
	if(missing(subset)){ subset = DataTable[, IDcolumn]}
	Events <- list()
	for(i in 1:length(subset)){		
		for(j in 1:6){
			if(!any(is.na(c(DataTable[DataTable[,IDcolumn]==subset[i], Chemo[2*j-1]], DataTable[DataTable[,IDcolumn]==subset[i], Chemo[2*j]])))){
				Events[[length(Events)+1]] <- list(PatientID = DataTable[DataTable[,IDcolumn]==subset[i], "ID"],PtNum =  i, Name = "Chemo",
						 date= c(DataTable[DataTable[,IDcolumn]==subset[i], Chemo[2*j-1]], DataTable[DataTable[,IDcolumn]==subset[i], Chemo[2*j]]),
						 Type =  DataTable[DataTable[,IDcolumn]==subset[i], ChemoAgent[j]])
			} 
		}
		RadiationEvent = c()
		if(!any(is.na(c(DataTable[DataTable[,IDcolumn]==subset[i], "RTx_StartDt"], DataTable[DataTable[,IDcolumn]==subset[i], "RTx_StopDt"])))){
				Events[[length(Events)+1]] <- list(PatientID = DataTable[DataTable[,IDcolumn]==subset[i], "ID"],PtNum =  i, Name = "Radiation",
						 date=  c(DataTable[DataTable[,IDcolumn]==subset[i], "RTx_StartDt"],DataTable[DataTable[,IDcolumn]==subset[i], "RTx_StopDt"]),
						 Type =  DataTable[DataTable[,IDcolumn]==subset[i], "Type"])
		}
	for(j in 1:length(EventNames)){
			Colname = EventNames[j]
			if(!any(is.na(DataTable[DataTable[,IDcolumn]==subset[i], Colname]))){
				if (!is.na(EventType[j]) && !is.na(DataTable[DataTable[,IDcolumn]==subset[i],EventType[j]])){
					Events[[length(Events)+1]] <- list(PatientID= DataTable[DataTable[,IDcolumn]==subset[i], "ID"], PtNum= i,Name= EventLegend[j],
														date= c(DataTable[DataTable[,IDcolumn]==subset[i], Colname]), Type=DataTable[DataTable[,IDcolumn]==subset[i],EventType[j]])
				} else {Events[[length(Events)+1]] <- list(PatientID= DataTable[DataTable[,IDcolumn]==subset[i], "ID"], PtNum= i,Name= EventLegend[j],
														date= c(DataTable[DataTable[,IDcolumn]==subset[i], Colname])) }
			}
		}
	 }

	return(Events)
}

#---------------------------------------------------------------------------------------------------
returnTimeLineMatrix <- function(WS, msg)
{
    print(msg)

    patient.ids <- msg$payload$patientIDs
    printf("returnTimeLineMatrix, patient.ids: %s", paste(patient.ids, collapse=","))
    printf("   patient.ids count: %d", length(patient.ids))
    events <- msg$payload$events

   unknown.patientIDs <- setdiff(patient.ids, tbl.pt$PatientID)
    printf("unknown.patientIDs:  %d", length(unknown.patientIDs))
    
    unknown.events     <- setdiff(events, colnames(tbl.pt))
    printf("unknown.events:  %d", length(unknown.events))

    error.msg <- ""
     if(length(unknown.events) > 0)
        error.msg <- paste(error.msg, "unrecognized events: ", paste(unknown.events, collapse=", "))

    if(nchar(error.msg) > 0){
        return.msg <- toJSON(list(cmd="timeLineMatrix", callback="", status="error", payload="tissueIDs not mapped"))
        websocket_write(DATA=return.msg, WS=WS)
        return()
        } # if error

   printf("calling createTimeMatrix, patient.ids: %s",
           paste(patient.ids, collapse=","));

   printf("calling createTimeMatrix, events: %s",
           paste(events, collapse=","));
   mtx <- createTimeMatrix(patient.ids, events)

   if(is.na(mtx)) {
       printf("failed to create time matrix, unmapped patient IDs?")
       return.msg <- toJSON(list(cmd="timeLineMatrix",
                             callback="",
                             status="error",
                             payload="found no entries for patient/tissueIDs"))
      websocket_write(DATA=return.msg, WS=WS)
      return();
      } # is.na(mtx)
                                                  
       
      # reformat the matrix so that it will appear in javascript as
      # an array of objects, of this form:
      # '[{event: "DOB",              value: "-24138, patientNumber: "1", patientID: "P10"},
      #   {event: "MSKEncounterDate", value: -4,      patientNumber: "1", patientID: "P10"}, ... ]

  
   events.json <- timelineMatrixAsEvents(mtx, returnJSON=TRUE)
   timelines.json <- timelineMatrixExtractLines(mtx, returnJSON=TRUE)

   return.msg <- toJSON(list(cmd="timeLineMatrix",
                             callback="",
                             status="success",
                             payload=list(table=mtx)))
                                          
   websocket_write(DATA=return.msg, WS=WS)

} # returnTimeLineMatrix
#---------------------------------------------------------------------------------------------------
returnTimeLineMatrix_original <- function(WS, msg)
{
    print(msg)

    patient.ids <- msg$payload$patientIDs
    printf("returnTimeLineMatrix, patient.ids: %s", paste(patient.ids, collapse=","))
    printf("   patient.ids count: %d", length(patient.ids))
    events <- msg$payload$events

    alignmentEvent <- ""
    if("alignmentEvent" %in% names (msg$payload))
        alignmentEvent <- msg$payload$alignmentEvent

    log2Transform = FALSE
    if("log2Transform" %in% names(msg$payload))
        log2Transform = msg$payload$log2Transform
    

    unknown.patientIDs <- setdiff(patient.ids, tbl.pt$PatientID)
    printf("unknown.patientIDs:  %d", length(unknown.patientIDs))
    
    unknown.events     <- setdiff(events, colnames(tbl.pt))
    printf("unknown.events:  %d", length(unknown.events))

    error.msg <- ""
    #if(length(unknown.patientIDs) > 0)
    #    error.msg <- paste(error.msg, "unrecognized patientIDs: ", paste(unknown.patientIDs, collapse=", "))
    if(length(unknown.events) > 0)
        error.msg <- paste(error.msg, "unrecognized events: ", paste(unknown.events, collapse=", "))

    if(nchar(error.msg) > 0){
        return.msg <- toJSON(list(cmd="timeLineMatrix", callback="", status="error", payload="tissueIDs not mapped"))
        sendOutput(DATA=return.msg, WS=WS)
        return()
        } # if error

   printf("calling createTimeMatrix, patient.ids: %s",
           paste(patient.ids, collapse=","));

   printf("calling createTimeMatrix, events: %s",
           paste(events, collapse=","));
   mtx <- createTimeMatrix(patient.ids, events, log2Transform=log2Transform)

   if(is.na(mtx)) {
       printf("failed to create time matrix, unmapped patient IDs?")
       return.msg <- toJSON(list(cmd="timeLineMatrix",
                             callback="",
                             status="error",
                             payload="found no entries for patient/tissueIDs"))
      sendOutput(DATA=return.msg, WS=WS)
      return();
      } # is.na(mtx)
                                                  
       
   if(alignmentEvent %in% events)
       mtx <- alignTimeMatrix(mtx, alignmentEvent)
    
      # reformat the matrix so that it will appear in javascript as
      # an array of objects, of this form:
      # '[{event: "DOB",              value: "-24138, patientNumber: "1", patientID: "P10"},
      #   {event: "MSKEncounterDate", value: -4,      patientNumber: "1", patientID: "P10"}, ... ]

  
   events.json <- timelineMatrixAsEvents(mtx, returnJSON=TRUE)
   timelines.json <- timelineMatrixExtractLines(mtx, returnJSON=TRUE)

   return.msg <- toJSON(list(cmd="timeLineMatrix",
                             callback="",
                             status="success",
                             payload=list(timelines=timelines.json,
                                          events=events.json,
                                          xMin=min(mtx, na.rm=TRUE),
                                          xMax=max(mtx, na.rm=TRUE),
                                          yMin=0,
                                          yMax=nrow(mtx))))
                                          
   sendOutput(DATA=return.msg, WS=WS)

} # returnTimeLineMatrix
#---------------------------------------------------------------------------------------------------
returnPatientEventNames <- function(WS, msg)
{
                                        # patientEventNames

   return.msg <- toJSON(list(cmd="patientEventNames",
                             callback="",
                             status="success",
                             payload=names(PatientDatesAndColors)));

   sendOutput(DATA=return.msg, WS=WS)

} # returnPatientEventNames
#---------------------------------------------------------------------------------------------------
# out of the many dated events available for each patient, find the earliest and latest,
# to provide the x-coordinates for drawing the patient's timeline
#
timelineMatrixExtractLines <- function(mtx, returnJSON=FALSE)
{
   result <- data.frame(min=apply(mtx,1,function(row) min(row, na.rm=TRUE)),
                        max=apply(mtx,1,function(row) max(row, na.rm=TRUE)))
   
   lineNumber <- 1:nrow(result)
   result$lineNumber <- lineNumber

   if(returnJSON){
       result$patiendID <- rownames(result)
       rownames(result) <- NULL
       array.of.lists <- apply(result, 1, as.list)
          # names create a json hash, not an array.  we need the latter
       names(array.of.lists) <- NULL
       result <- toJSON(array.of.lists, collapse="")
       }

   result

} # timelineMatrixExtractLines
#---------------------------------------------------------------------------------------------------
timelineMatrixAsEvents <- function(mtx, returnJSON=FALSE)
{
   mtx.1 <- t(mtx)
   count = nrow(mtx.1) * ncol(mtx.1)

   event <- vector("character", length=count)
   value <- vector("numeric", length=count)
   patientNumber <- vector("numeric", length=count)
   patientID <- vector("character", length=count)

   i <- 1

   for(c in 1:ncol(mtx.1)){
      patient.id <- colnames(mtx.1)[c]
      for(r in 1:nrow(mtx.1)){
         event[i] <- rownames(mtx.1)[r]
         value[i] <- mtx.1[r,c]
         patientNumber[i] <- c
         patientID[i] <- patient.id
         i = i + 1
         } # for r
       }# for c

   result <- data.frame(event=event, value=value, patientNumber=patientNumber, patientID=patientID,
                    stringsAsFactors=FALSE)
   deleters <- which(is.na(result$value))
   if(length(deleters) > 0)
       result <- result[-deleters,]

   if(returnJSON){
      array.of.lists <- apply(result, 1, as.list)
         # names create a json hash, not an array.  we need the latter
      names(array.of.lists) <- NULL
      result <- toJSON(array.of.lists, collapse="")
      }

   result
   
} # timelineMatrixAsEvents 
#----------------------------------------------------------------------------------------------------   
plotTimeline <- function(DateData, RemoveDate=c(), ShiftDate=NULL, OrderDate=ShiftDate,
                        IncludeDates=NULL, DateColors=NULL, Vital=NULL, legendPos="topleft",
                        TimeScale=c("days", "log"), Lined=FALSE, ...)
{

   if(missing(IncludeDates)) IncludeDates <- colnames(DateData)
   if(missing(DateColors)) {DateColors <- rainbow(length(IncludeDates)); names(DateColors)<- IncludeDates}
   
   subTitle <- paste("Remove: ", RemoveDate, "; Align by: ", ShiftDate, "; Order: ", OrderDate, sep="")
   
   if(length(RemoveDate)>0){
      DateData <- DateData[,-which(colnames(DateData) %in% RemoveDate)]
      IncludeDates <- IncludeDates[-which(IncludeDates %in% RemoveDate)]
      DateColors <- DateColors[-which(names(DateColors) %in% RemoveDate)]
      }

   NumPatients <- nrow(DateData)
   PatientOrder <- 1:nrow(DateData)   
   if(!missing(OrderDate)){PatientOrder <- order(DateData[,OrderDate])}

   if(!missing(ShiftDate)){ 
      Offset <-  DateData[,ShiftDate] 
      for(i in 1:length(IncludeDates)){ DateData[,IncludeDates[i]] <- DateData[,IncludeDates[i]] - Offset} }

   if(TimeScale=="log") DateData[,IncludeDates]  <- sapply(DateData[,IncludeDates],
          function(dates){ t<-as.numeric(dates); Dir<-ifelse(t<0,-1,1); Dir*log(abs(t)+1) })
      
   AllDates<-do.call("c", DateData[,IncludeDates])
   DateRange <- range(AllDates, na.rm=T)

   plot(x=DateRange, y=c(1, NumPatients), cex=0, xlab="Time", ylab="Patient",
        main=paste("Patient Event Timeline",subTitle, sep="\n"), sub=TimeScale)

   for(i in 1:NumPatients){
      if(Lined) segments(x0=min(DateData[PatientOrder[i], IncludeDates], na.rm=T),
                         x1=max(DateData[PatientOrder[i], IncludeDates], na.rm=T), y0=i, col="grey")
      points(DateData[PatientOrder[i], IncludeDates],rep(i, length(IncludeDates)),  col=DateColors, ...)
      if(!missing(Vital) & Vital[PatientOrder[i]]=="Dead") points(DateData[PatientOrder[i], "StatusDate"],i, pch=4)
      }

   if(legendPos != "none")legend(x=legendPos, y=100, legend=IncludeDates, fill=DateColors, ncol=2,
          bty="n", cex=0.8, ...)

} # plotTimeLine
#----------------------------------------------------------------------------------------------------
plotTimeline_simple <- function(DateData, IncludeDates=NULL, DateColors=NULL)
{

   if(missing(IncludeDates)) IncludeDates <- colnames(DateData)
   if(missing(DateColors)) {
       DateColors <- rainbow(length(IncludeDates));
       names(DateColors)<- IncludeDates
       }
   
   NumPatients <- nrow(DateData)
   PatientOrder <- 1:nrow(DateData)   

   DateData[,IncludeDates]  <- sapply(DateData[,IncludeDates],
                                      function(dates){ t<-as.numeric(dates);
                                                       Dir<-ifelse(t<0,-1,1); Dir*log(abs(t)+1) })
      
   AllDates<-do.call("c", DateData[,IncludeDates])
   DateRange <- range(AllDates, na.rm=T)

   plot(x=DateRange, y=c(1, NumPatients), cex=0, xlab="Time", ylab="Patient",
        main="Patient Event Timeline")
   
   for(i in 1:NumPatients){
      segments(x0=min(DateData[PatientOrder[i], IncludeDates], na.rm=T),
               x1=max(DateData[PatientOrder[i], IncludeDates], na.rm=T), y0=i, col="grey")
      points(DateData[PatientOrder[i], IncludeDates],rep(i, length(IncludeDates)),  col=DateColors, pch=19)
      }
   #legend(x="topleft", y=100, legend=IncludeDates, fill=DateColors, ncol=2, bty="n", cex=0.8)
   legend(x=7, y=2.5, legend=IncludeDates, fill=DateColors, ncol=2, bty="n", cex=0.8)

} # plotTimeline_simple
#----------------------------------------------------------------------------------------------------
