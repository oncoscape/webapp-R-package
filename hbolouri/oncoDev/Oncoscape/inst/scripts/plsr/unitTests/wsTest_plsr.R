#----------------------------------------------------------------------------------------------------
# to run this script
#
#  sh-server>  a shell for building and installing Oncoscape, to make revisions to PLSR.R avialable
#  rsh-server> startWebApp (headless Oncoscape) here
#    library(Oncoscape); startWebApp(file=NA, port=7781L, openBrowser=FALSE, manifest="~/s/data/hamid/repo/hbolouri/oncoDev/Oncoscape/inst/scripts/plsr/manifest.txt");
#  tsh-plsr> source and run this file
#            source("wsTest_plsr.R"); runTests()
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(websockets)
library(RJSONIO)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_ping();
   test_plsr();
   
} # runTests
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
test_ping <- function()
{
   print("--- test_ping")
   cmd <- "PLSR.ping"
   status <- "request"
   callback <- "handle.plsr.ping"
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload="")), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")
   checkEquals(head(msg.incoming$payload), "ping back!")

} # test_ping
#----------------------------------------------------------------------------------------------------
test_plsr <- function()
{
   print("--- test_plsr")
   cmd <- "calculatePLSR"
   status <- "request"
   payload <- c(geneSet="default",
                ageAtDxThresholdLow=36, 
                ageAtDxThresholdHi=64,
                overallSurvivalThresholdLow=3.7,
                overallSurvivalThresholdHi=7.3)
       
   callback <- "handle.plsr.results"
   msg <- list(cmd=cmd, callback=callback, status=status, payload=toJSON(payload))
   websocket_write(toJSON(msg), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "fit")
   checkEquals(names(msg.incoming$payload), c("genes", "vectors"))
   checkTrue(nchar(msg.incoming$payload[["vectors"]]) > 300)  # 404 on (5 sep 2014)
   checkTrue(nchar(msg.incoming$payload[["genes"]]) > 10000)  # 83k on (5 sep 2014)

} # test_plsr
#----------------------------------------------------------------------------------------------------
