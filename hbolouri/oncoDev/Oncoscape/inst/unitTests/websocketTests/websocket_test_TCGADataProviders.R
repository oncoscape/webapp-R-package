library(RUnit)
library(websockets)
library(RJSONIO)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
# before loading and running this script:
#
#  start R in another shell
#    library(Oncoscape); startWebApp(file=NA, port=7781L, openBrowser=FALSE)
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
    test_get_TCGA_GBM_CopyNumber_Data()
    test_get_TCGA_GBM_CopyNumber_Data_bogus_inputs()

    test_get_TCGA_GBM_mRNA_Data()
    test_get_TCGA_GBM_mRNA_Average()

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
test_get_TCGA_GBM_CopyNumber_Data <- function()
{
   print("--- test__get_TCGA_GBM_CopyNumber_Data")
   cmd <- "get_TCGA_GBM_CopyNumber_Data"
   status <- "request"
   callback <- "handle_TCGA_GBM_CopyNumber_Data"
   entities <-  c("TCGA.02.0003","TCGA.02.0004")
   features <- c("AKT1", "ATM")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 2)

   row1 <- mtx.as.list[[1]]
   row2 <- mtx.as.list[[2]]
   checkEquals(row1, list(AKT1=0, ATM=0, rowname="TCGA.02.0003"))
   checkEquals(row2, list(AKT1=1, ATM=0, rowname="TCGA.02.0004"))

} # test_get_TCGA_GBM_CopyNumber_Data
#----------------------------------------------------------------------------------------------------
test_get_TCGA_GBM_CopyNumber_Data_bogus_inputs <- function()
{
   print("--- test__get_TCGA_GBM_CopyNumber_Data_bogus_inputs")
   cmd <- "get_TCGA_GBM_CopyNumber_Data"
   status <- "request"
   callback <- "handle_TCGA_GBM_CopyNumber_Data"
   entities <-  c("TCGA.02.0003","TCGA.02.0004", "bogusPatient")
   features <- c("AKT1", "ATM", "non-existent-gene")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 2)

   row1 <- mtx.as.list[[1]]
   row2 <- mtx.as.list[[2]]
   checkEquals(row1, list(AKT1=0, ATM=0, rowname="TCGA.02.0003"))
   checkEquals(row2, list(AKT1=1, ATM=0, rowname="TCGA.02.0004"))

      # now send only bogus entities

   entities <-  c("TCGA.02.0003fubar", "TCGA.02.0004fubar", "bogusPatient")
   features <- c("AKT1", "ATM", "non-existent-gene")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "failure")
   checkEquals(msg.incoming$payload, "empty table")


      # now send only bogus features

   entities <-  c("TCGA.02.0003", "TCGA.02.0004", "bogusPatient")
   features <- c("AKT1xx", "ATMxx", "non-existent-gene")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "failure")
   checkEquals(msg.incoming$payload, "empty table")

} # test_get_TCGA_GBM_CopyNumber_Data
#----------------------------------------------------------------------------------------------------
test_get_TCGA_GBM_mRNA_Data <- function()
{
   print("--- test_get_TCGA_GBM_mRNA_Data")
   cmd <- "get_TCGA_GBM_mRNA_Data"
   status <- "request"
   callback <- "handle_TCGA_GBM_mRNA_Data"
   entities <-  c("TCGA.02.0003","TCGA.02.0004")
   features <- c("AKT1", "ATM")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_mRNA_Data")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 2)

   row1 <- mtx.as.list[[1]]
   row2 <- mtx.as.list[[2]]
   checkEquals(row1, list(AKT1=-0.1337, ATM=0.3206, rowname="TCGA.02.0003"))
   checkEquals(row2, list(AKT1=0.0865, ATM=-0.5156, rowname="TCGA.02.0004"))

} # test_get_TCGA_GBM_mRNA_Data
#----------------------------------------------------------------------------------------------------
test_get_TCGA_GBM_mRNA_Average <- function()
{
   print("--- test_get_TCGA_GBM_mRNA_Average")

   cmd <- "get_TCGA_GBM_mRNA_Average"
   status <- "request"
   callback <- "handle_TCGA_GBM_mRNA_Average"

     # dp <- DataProvider("TCGA_GBM_mRNA")
     # x <- getData(dp)
     # x [86:87, 86:87]
     #               CDKN2B  CDKN2C
     # TCGA.02.0440 -0.6117  0.5126
     # TCGA.02.0446 -1.4286 -3.1140

   entities <-  c("TCGA.02.0440", "TCGA.02.0446")
   features <- c("CDKN2B", "CDKN2C")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "success")
   
   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 1)
   mtx.avg <- mtx.as.list[[1]]
   
   checkEquals(mtx.avg, list(CDKN2B=-1.0202, CDKN2C=-1.3007, rowname="average"))

     # now get these two genes across all conditions
   entities <- ""
   features <- c("CDKN2B", "CDKN2C")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 1)
   mtx.avg <- mtx.as.list[[1]]
   
   checkEquals(mtx.avg, list(CDKN2B=-0.56238, CDKN2C=-0.058223, rowname="average"))

      # now add a bogus gene (feature) name, make sure we get the same results

   features <- c("CDKN2B", "CDKN2C", "bogusGeneSymbol")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 1)
   mtx.avg <- mtx.as.list[[1]]
   
   checkEquals(mtx.avg, list(CDKN2B=-0.56238, CDKN2C=-0.058223, rowname="average"))

      # query for only bogus gene (feature) names, make sure we get status = "error"

   
   features <- c("foobar", "midrash88", "bogusGeneSymbol")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_TCGA_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "failure")
   checkEquals(msg.incoming$payload, "no rows matching supplied entities and features")

} # test_get_TCGA_GBM_mRNA_Average
#----------------------------------------------------------------------------------------------------
