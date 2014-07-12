library(RUnit)
library(websockets)
library(RJSONIO)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
# before loading and running this script:
#
#  start R in another shell
#    library(Oncoscape)
#    startWebApp(file=NA, port=7781L, openBrowser=FALSE)
#
# this provides the web sockets server called by the client created here
#----------------------------------------------------------------------------------------------------
callbackFunction <- function(DATA, WS, ...)
{
    unparsed.msg <<- rawToChar(DATA)
    #browser()
    parsed.msg <- as.list(fromJSON(unparsed.msg))
    #printf("rec'd msg: %s", parsed.msg$cmd)
    msg.incoming <<- parsed.msg
    #printf("in recieve callback, msg is:")
    #print(msg.incoming)
    #print("------------------ leaving receive callback")
    
    #return(msg)

} # callbackFunction
#----------------------------------------------------------------------------------------------------
if(!exists("client")){
   client <- websocket("ws://localhost", port=7781L)
   }
setCallback("receive", callbackFunction, client);
#----------------------------------------------------------------------------------------------------
runTests = function (levels)
{
    test_getTissueNames()
    test_ping()
    test_getAverageExpression()
    test_getGBMmutations()
    
} # runTests
#----------------------------------------------------------------------------------------------------
test_ping <- function()
{
   print("--- test_ping")
   cmd <- "NanoStringExpresssionData.ping"
   status <- "request"
   websocket_write(toJSON(list(cmd=cmd, status=status, payload="")), client)
   
   setCallback("receive", callbackFunction, client);
   system("sleep 1")
   service(client)
   #msg.parsed <- fromJSON(msg)
   checkEquals(names(msg.incoming), c("cmd", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handleNanoStringPing")
   checkEquals(msg.incoming$status, "success")
   checkEquals(head(msg.incoming$payload), "ping!")

} # test_ping
#----------------------------------------------------------------------------------------------------
test_getTissueNames <- function()
{
   print("--- test_getTissueNames")
   
   cmd <- "requestTissueNames"
   status <- "request"
   websocket_write(toJSON(list(cmd=cmd, status=status, payload="")), client)
   
   setCallback("receive", callbackFunction, client);
   system("sleep 1")
   service(client)
   #msg.parsed <- fromJSON(msg)
   checkEquals(names(msg.incoming), c("cmd", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handleTissueNames")
   checkEquals(msg.incoming$status, "success")
   checkEquals(head(msg.incoming$payload),
               c("0440.T.1", "0445.T.1", "0486.T.1", "0493.T.1", "0506.T.1", "0506.T.1"))

} # test_getTissueNames
#----------------------------------------------------------------------------------------------------
test_getAverageExpression <- function()
{
   print("--- test_getAverageExpression")
   
   cmd <- "requestAverageExpression"
   status <- "request"
   payload= c("0440.T.1", "0445.T.1")

   websocket_write(toJSON(list(cmd=cmd, status=status, payload=payload)), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "status", "payload"))
   #browser()
   checkEquals(msg.incoming$cmd, "handleAverageExpression")
   checkEquals(msg.incoming$status, "success")
   data <- fromJSON(msg.incoming$payload)[[1]]
   checkTrue(length(data) > 100)
   checkEquals(data[1:3], list(B2M=102670,
                               B4GALT1=1190.4,
                               CLTC=1857.4))


} # test_getAverageExpression
#----------------------------------------------------------------------------------------------------
test_getGBMmutations <- function()
{
   print("--- test_getGBMmutations")

   cmd <- "getGbmPathwaysMutationData"
   status <- "request"

       #-----------------------------------------------------
       #  simply ping the service, make sure it responds
       #-----------------------------------------------------

   payload <- list(mode="ping")
   msg.outgoing <- toJSON(list(cmd=cmd, status=status, payload=payload))
   websocket_write(msg.outgoing, client)
   
   system("sleep 1")
   service(client)
   system("sleep 1")
   checkEquals(names(msg.incoming), c("cmd", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handleGbmPathwaysMutationData")
   checkEquals(msg.incoming$status, "ping returned")

      #-------------------------------------------------------------------
      #  omit the required payload$mode argument, check for proper error
      #-------------------------------------------------------------------

   status <- "request"
   payload <- list(intentionalError.modeMissing="ping")
   msg.outgoing <- toJSON(list(cmd=cmd, status=status, payload=payload))
   websocket_write(msg.outgoing, client)

   system("sleep 1")
   service(client)
   system("sleep 1")

   checkEquals(names(msg.incoming), c("cmd", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handleGbmPathwaysMutationData")
   checkEquals(msg.incoming$status, "error")
   checkEquals(msg.incoming$payload, "no mode field in payload")

      #-------------------------------------------------------------------
      #  get list of tissues and genes.  following the
      #  DataProvider API, tissues are entities, genes (with mutations)
      #  are features
      #-------------------------------------------------------------------

   status <- "request"
   payload <- list(mode="getEntitiesAndFeatures")
   msg.outgoing <- toJSON(list(cmd=cmd, status=status, payload=payload))
   websocket_write(msg.outgoing, client)

   system("sleep 1")
   service(client)

   checkEquals(names(msg.incoming), c("cmd", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handleGbmPathwaysMutationData")
   checkEquals(msg.incoming$status, "success")
   checkEquals(names(msg.incoming$payload), c("entities", "features"))
   checkEquals(head(msg.incoming$payload$entities),
               c("1007.T.1", "1012.T.1", "103.1.T.1", "1039.T.1", "1050.T.1", "1056.T.1"))
   checkEquals(head(msg.incoming$payload$features), c("EGFR", "EPHA6", "ERBB2", "FGFR2", "FGFR3", "IDH1"))

      #-------------------------------------------------------------------
      #  get actual mutation data for a few tissues and a few genes.
      #-------------------------------------------------------------------

   status <- "request"
   payload <- list(mode="getData",
                   entities=c("1007.T.1", "103.1.T.1", "983.T.1", "889.T.1", "0618.T.1"),
                   features=c("EGFR", "IDH1"))
   msg.outgoing <- toJSON(list(cmd=cmd, status=status, payload=payload))
   websocket_write(msg.outgoing, client)

   system("sleep 1")
   service(client)
   #browser()
   
   checkEquals(names(msg.incoming), c("cmd", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handleGbmPathwaysMutationData")
   checkEquals(msg.incoming$status, "success")

   mutations <- fromJSON(msg.incoming$payload)
   checkEquals(length(mutations), 5)

      # the parsed-from-json data structure is a 4-element list, where
      # each element is a list data.frame values for 1 row, with one
      # extra twist:  the rowname of that row is an element of the list
      # thus
      #
      #                  EGFR  IDH1
      # 1007.T.1         <NA> R132H
      # 103.1.T.1       R222C  <NA>
      # 983.T.1   R222C R108K  <NA>
      # 889.T.1          <NA>  <NA>

   checkEquals(as.list(unlist(mutations[[1]])), list(IDH1="R132H", rowname="1007.T.1"))
   checkEquals(as.list(unlist(mutations[[2]])), list(EGFR="R222C", rowname="103.1.T.1"))
   checkEquals(as.list(unlist(mutations[[3]])), list(EGFR="R677H",  IDH1="R132H", rowname="0618.T.1"))
   checkEquals(as.list(unlist(mutations[[4]])), list(rowname="889.T.1"))
   checkEquals(as.list(unlist(mutations[[5]])), list(EGFR="R222C R108K", rowname="983.T.1"))

} # test_getGBMmutation
#----------------------------------------------------------------------------------------------------
