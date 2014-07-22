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

    test_calculatePairedDistributionsOfPatientHistoryData()
    
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
   cmd <- "getTabularPatientHistory"
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

   all.events <- (msg.incoming$payload)
   checkTrue(length(all.events) == 1513)
   x <- all.events[[1]]
   checkEquals(x$PatientID, "TCGA.02.0001")
   checkEquals(x$PtNum, 1)
   checkEquals(x$Name, "DOB")
   checkEquals(x$date, "09/15/1957")

   
} # explore_timeLinesData
#----------------------------------------------------------------------------------------------------
test_calculatePairedDistributionsOfPatientHistoryData <- function()
{
   print("--- test_calculatePairedDistributionsOfPatientHistoryData")

        #----------------------
        # first do a test
        #----------------------

   cmd <- "calculatePairedDistributionsOfPatientHistoryData"
   status <- "request"
   callback <- "pairedDistributionsPlot"
   payload <- list(mode="test", attribute="FirstProgression")

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)
   system("sleep 1")
   service(client)

   pop1 <- msg.incoming$payload$pop1
   pop2 <- msg.incoming$payload$pop2
   checkTrue(length(pop1) > 10)
   checkTrue(length(pop2) > 10)
   checkEquals(length(intersect(names(pop1), names(pop2))), 0)

     # don't know what mean should be, in the general case, but the data should support
     # the calculation

   pop1.mean <- mean(unlist(pop1, use.names=FALSE))
   checkTrue(is.numeric(pop1.mean))
   checkTrue(pop1.mean > 0.0)
   pop2.mean <- mean(unlist(pop2, use.names=FALSE))
   checkTrue(is.numeric(pop2.mean))
   checkTrue(pop2.mean > 0.0)

      #----------------------------------------------------------------------------------
      # now do a 'real' run.  begin by getting some patientIDs from the currently loaded
      # patientHistoryTable.  in test mode, this should be
      # patientHistoryTable: tbl://tcgaGBM/tbl.ptHistory.RData
      #----------------------------------------------------------------------------------
   
   pop1 <- c("TCGA.02.0001", "TCGA.02.0003", "TCGA.02.0006", "TCGA.02.0007", "TCGA.02.0009", "TCGA.02.0010",
             "TCGA.02.0011", "TCGA.02.0014", "TCGA.02.0021", "TCGA.02.0024")
   pop2 <- c("TCGA.12.0703", "TCGA.12.0707", "TCGA.12.0769", "TCGA.12.0772", "TCGA.12.0773", "TCGA.12.0775",
             "TCGA.12.0776", "TCGA.12.0778", "TCGA.12.0780",  "TCGA.15.0742")

   checkEquals(length(intersect(pop1, pop2)), 0)

   cmd <- "calculatePairedDistributionsOfPatientHistoryData"
   status <- "request"
   callback <- "pairedDistributionsPlot"
   payload <- list(attribute="FirstProgression", pop1=pop1, pop2=pop2)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)
   system("sleep 1")
   service(client)

       #----------------------------------------
       # check the results
       #----------------------------------------

   pop1.vals <- msg.incoming$payload$pop1
   pop2.vals <- msg.incoming$payload$pop2
   checkEquals(names(pop1.vals), pop1)
   checkEquals(names(pop2.vals), pop2)

   checkEqualsNumeric(mean(as.numeric(pop1.vals)), 1.551, tol=1e-5)
      # utter mystery: why is pop1 a numeric vector, and pop2 a list?
   checkEquals(mean(unlist(pop2.vals, use.names=FALSE)), 0.8222222, tol=1e-5)

} # test_calculatePairedDistributionsOfPatientHistoryData
#----------------------------------------------------------------------------------------------------
