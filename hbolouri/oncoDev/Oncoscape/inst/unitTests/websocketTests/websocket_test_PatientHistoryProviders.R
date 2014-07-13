library(RUnit)
library(websockets)
library(RJSONIO)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
# before loading and running this script:
#
#  start R in another shell
#    library(Oncoscape); startWebApp(file=NA, port=7781L, openBrowser=FALSE, manifest="../../scripts/tabsApp/manifest.txt")
#
# this provides the web sockets server called by the client created here
#----------------------------------------------------------------------------------------------------
callbackFunction <- function(DATA, WS, ...)
{
    unparsed.msg <<- rawToChar(DATA)
    parsed.msg <- as.list(fromJSON(unparsed.msg))
    msg.incoming <<- parsed.msg

} # callbackFunction
#----------------------------------------------------------------------------------------------------
if(!exists("client")){
   client <- websocket("ws://localhost", port=7781L)
   }
setCallback("receive", callbackFunction, client);
#----------------------------------------------------------------------------------------------------
runTests = function (levels)
{
    test_ping()
    test_localFilePreparedTable()
    test_filterPatientHistory()
    test_getPatientClassification()
    explore_timeLinesData()
    
} # runTests
#----------------------------------------------------------------------------------------------------
test_ping <- function()
{
   print("--- test_ping")
   cmd <- "DataProviderBridge.ping"
   status <- "request"
   callback <- "handleDataProviderPing"
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload="")), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")
   checkEquals(head(msg.incoming$payload), "ping!")

} # test_ping
#----------------------------------------------------------------------------------------------------
test_localFilePreparedTable <- function()
{
   print("--- test_localFilePreparedTable")
   cmd <- "getPatientHistory"
   status <- "request"
   callback <- "handlePatientHistory"
   payload <- ""
   
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))

   checkEquals(msg.incoming$cmd, "handlePatientHistory")
   checkEquals(msg.incoming$status, "success")

   checkEquals(names(msg.incoming$payload), c("colnames", "mtx"))
   column.names <- msg.incoming$payload$colnames
   checkTrue(length(column.names) > 10)
   checkTrue("ID" %in% column.names)

   mtx.as.list <- msg.incoming$payload$mtx
   checkTrue(length(mtx.as.list) > 580)
   first.element <- mtx.as.list[[1]]
   checkEquals(length(first.element), length(column.names))
    
} # test_localFilePreparedTable
#----------------------------------------------------------------------------------------------------
test_filterPatientHistory <- function()
{
   print("--- test_filterPatientHistory")
   cmd <- "filterPatientHistory"
   status <- "request"
   callback <- "handlePatientHistory"
   payload <- list(ageAtDxMin="10", ageAtDxMax="20", overallSurvivalMin="1", overallSurvivalMax="3")
   
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))

   checkEquals(msg.incoming$cmd, "handlePatientHistory")
   checkEquals(msg.incoming$status, "success")

   checkEquals(names(msg.incoming$payload), c("count", "ids"))

   count <- msg.incoming$payload$count
   ids <- msg.incoming$payload$ids
   checkEquals(count, 5)
   checkEquals(sort(ids), c("TCGA.02.0010", "TCGA.02.0011", "TCGA.02.0266", "TCGA.08.0516", "TCGA.12.1091"))

} # test_filterPatientHistory 
#----------------------------------------------------------------------------------------------------
# this should be moved to a websockets_test_DataProviderBridge file
test_getPatientClassification <- function()
{
   print("--- test_getPatientClassification")
   cmd <- "getPatientClassification"
   status <- "request"
   callback <- "handlePatientClassification"
   payload <- ""
   
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))

   checkEquals(msg.incoming$cmd, "handlePatientClassification")
   checkEquals(msg.incoming$status, "success")

   x <- fromJSON(msg.incoming$payload)
   checkTrue(length(x) > 400)
   checkEquals(names(x[[1]]), c ("gbmDzSubType", "color", "rowname"))

} # test_getPatientClassification
#----------------------------------------------------------------------------------------------------
# grok lisa's patient timelines data input
explore_timeLinesData <- function()
{
   print("--- explore_timeLinesData")

   cmd <- "getCaisisPatientHistory";
   status <- "request"
   callback <- "handleCaisisPatientHistory"
   sample.file.1 <- "demo/caisis.RData"
   
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=sample.file.1)), client)
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))

   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")

   all.events <- fromJSON(msg.incoming$payload)
   checkTrue(length(all.events) == 73)
   x <- all.events[[1]]
   checkEquals(x$PatientID, "FC5PKZ244GQOB098PB2IH2C7X33XO1OT765X")
   checkEquals(x$PtNum, 1)
   checkEquals(x$Name, "Death")
   checkEquals(x$date, "06/05/2000")
   checkEquals(x$StatusQuality, "STD")


   cmd <- "getCaisisPatientHistory";
   status <- "request"
   callback <- "handleCaisisPatientHistory"
   sample.file.2 <- "BTC_clinicaldata_6-18-14.RData" # no subdirectory
   
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=sample.file.2)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))

   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")

   all.events <- fromJSON(msg.incoming$payload)
   checkTrue(length(all.events) == 2581)
   checkEquals(all.events[[1]],
               list(PatientID="P1",
                    PtNum=1,
                    Name="Chemo",
                    date=c("7/12/2006", "8/22/2006"),
                    Type="Temozolomide"))

   all.event.names <- sort(unique(unlist(lapply(all.events, function(event) event$Name))))
   
} # explore_timeLinesData
#----------------------------------------------------------------------------------------------------
