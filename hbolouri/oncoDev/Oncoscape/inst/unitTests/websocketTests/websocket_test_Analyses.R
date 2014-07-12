library(RUnit)
library(websockets)
library(RJSONIO)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
# before loading and running this script:
#
#  start R in another shell
#    library(Oncoscape); startWebApp(file=NA, port=7781L, openBrowser=FALSE, manifest="../../scripts/clinicalDataTable3/manifest")
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
    test_calculate_mRNA_PCA_bigMatrix()
    test_calculate_mRNA_PCA_smallMatrix()
    
} # runTests
#----------------------------------------------------------------------------------------------------
test_ping <- function()
{
   print("--- test_ping")
   cmd <- "AnalysisBridge.ping"
   status <- "request"
   callback <- "handleAnalysisPing"
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload="")), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")
   checkEquals(head(msg.incoming$payload), "ping!")

} # test_ping
#----------------------------------------------------------------------------------------------------
test_calculate_mRNA_PCA_bigMatrix <- function()
{
   print("--- test_calculate_mRNA_PCA_bigMatrix")

   cmd <- "calculate_mRNA_PCA"
   status <- "request"
   callback <- "handle_mRNA_PCA"
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload="")), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")
   pca.result <- fromJSON(msg.incoming$payload)
   checkEquals(length(pca.result), 577)
   checkEquals(pca.result[[1]], list(PC1=-8.1579, PC2=2.8434, id="TCGA.02.0001"))

} # test_calculate_mRNA_PCA_bigMatrix
#----------------------------------------------------------------------------------------------------
test_calculate_mRNA_PCA_smallMatrix <- function()
{
   print("--- test_calculate_mRNA_PCA_smallMatrix")

   cmd <- "calculate_mRNA_PCA"
   status <- "request"
   callback <- "handle_mRNA_PCA"
   ids <- c("TCGA.02.0055", "TCGA.02.0290", "TCGA.06.0648", "TCGA.12.3653", "TCGA.16.1063",
           "TCGA.19.1385", "TCGA.19.5952", "TCGA.26.5134", "TCGA.28.5204", "TCGA.41.3915")

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=ids)), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")
   pca.result <- fromJSON(msg.incoming$payload)
   checkEquals(length(pca.result), length(ids))
   checkEquals(pca.result[[1]], list(PC1=-23.315, PC2=6.3794, id="TCGA.02.0055"))

} # test_calculate_mRNA_PCA_smallMatrix
#----------------------------------------------------------------------------------------------------
