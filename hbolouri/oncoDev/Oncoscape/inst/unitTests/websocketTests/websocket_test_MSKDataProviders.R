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

    test_get_MSK_GBM_CopyNumber_Data()
    test_get_MSK_GBM_CopyNumber_Data_bogus_inputs()

    test_get_MSK_GBM_mRNA_Data()    
    test_get_MSK_GBM_mRNA_Average()
    test_get_MSK_GBM_mRNA_Average_onSubsets()
    
    
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
test_get_MSK_GBM_CopyNumber_Data <- function()
{
   print("--- test__get_MSK_GBM_CopyNumber_Data")
   cmd <- "get_MSK_GBM_CopyNumber_Data"
   status <- "request"
   callback <- "handle_MSK_GBM_CopyNumber_Data"
   entities <-  c("1003.2.T.1", "1007.T.1")
   features <- c("CDKN2A", "EGFR")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 2)

   row1 <- mtx.as.list[[1]]
   row2 <- mtx.as.list[[2]]
   checkEquals(row1, list(CDKN2A=-1, EGFR=1, rowname="1003.2.T.1"))
   checkEquals(row2, list(CDKN2A=-1, EGFR=0, rowname="1007.T.1"))

} # test_get_MSK_GBM_CopyNumber_Data
#----------------------------------------------------------------------------------------------------
test_get_MSK_GBM_CopyNumber_Data_bogus_inputs <- function()
{
   print("--- test_get_MSK_GBM_CopyNumber_Data_bogus_inputs")
   cmd <- "get_MSK_GBM_CopyNumber_Data"
   status <- "request"
   callback <- "handle_MSK_GBM_CopyNumber_Data"

   entities <-  c("1003.2.T.1", "1007.T.1", "bogusPatient")
   features <- c("non-existent gene", "CDKN2A", "EGFR")

   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 2)

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 2)

   row1 <- mtx.as.list[[1]]
   row2 <- mtx.as.list[[2]]
   checkEquals(row1, list(CDKN2A=-1, EGFR=1, rowname="1003.2.T.1"))
   checkEquals(row2, list(CDKN2A=-1, EGFR=0, rowname="1007.T.1"))
   
      # now send only bogus entities

   entities <-  c("MSK.02.0003fubar", "MSK.02.0004fubar", "bogusPatient")
   features <- c("AKT1", "ATM", "non-existent-gene")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "failure")
   checkEquals(msg.incoming$payload, "empty table")


      # now send only bogus features

   entities <-  c("MSK.02.0003", "MSK.02.0004", "bogusPatient")
   features <- c("AKT1xx", "ATMxx", "non-existent-gene")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_CopyNumber_Data")
   checkEquals(msg.incoming$status, "failure")
   checkEquals(msg.incoming$payload, "empty table")

} # test_get_MSK_GBM_CopyNumber_Data
#----------------------------------------------------------------------------------------------------
test_get_MSK_GBM_mRNA_Data <- function()
{
   print("--- test_get_MSK_GBM_mRNA_Data")
   cmd <- "get_MSK_GBM_mRNA_Data"
   status <- "request"
   callback <- "handle_MSK_GBM_mRNA_Data"

     #               MDM4        REN
     # 1178.T.1 0.1083581 -0.2805017
     # 1182.T.1 0.1268618 -0.2463349

   entities <-  c("1178.T.1", "1182.T.1")
   features <- c("MDM4", "REN")
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_mRNA_Data")
   checkEquals(msg.incoming$status, "success")

   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 2)

   row1 <- mtx.as.list[[1]]
   row2 <- mtx.as.list[[2]]
   checkEquals(row1, list(MDM4=0.10836, REN=-0.2805,  rowname="1178.T.1"))
   checkEquals(row2, list(MDM4=0.12686,  REN=-0.24633, rowname="1182.T.1"))

} # test_get_MSK_GBM_mRNA_Data
#----------------------------------------------------------------------------------------------------
test_get_MSK_GBM_mRNA_Average <- function()
{
   print("--- test_get_MSK_GBM_mRNA_Average")

   cmd <- "get_MSK_GBM_mRNA_Average"
   status <- "request"
   callback <- "handle_MSK_GBM_mRNA_Average"

     #               MDM4        REN
     # 1178.T.1 0.1083581 -0.2805017
     # 1182.T.1 0.1268618 -0.2463349

   entities <-  c("1178.T.1", "1182.T.1")
   payload <- list(entities=entities, features="")

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "success")
   
   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 1)
   mtx.avg <- mtx.as.list[[1]]
   
   checkTrue(length(mtx.avg) > 100)   # 150 on (24 jun 2014)

     # last element in this named list should be "rowname" and its value should be "average"
   last.item <- length(mtx.avg)
   checkEquals(names(mtx.avg)[last.item], "rowname")
   checkEquals(mtx.avg[[last.item]], "average")

     # check the mean: a rather imprecise test, but one which establishes some sanity in
     # the data.  mean is, by inspection, 0.784
   
   mean <- mean(unlist(mtx.avg[-length(mtx.avg)], use.names=FALSE))
   checkTrue(mean > 0)
   checkTrue(mean < 1)

   checkEquals(head(sort(names(mtx.avg))), c("AKR1C3", "AKT3", "ANGPTL4", "AQP1", "ARC", "AVIL"))

} # test_get_MSK_GBM_mRNA_Average
#----------------------------------------------------------------------------------------------------
test_get_MSK_GBM_mRNA_Average_onSubsets <- function()
{
   print("--- test_get_MSK_GBM_mRNA_Average_onSubsets")

   cmd <- "get_MSK_GBM_mRNA_Average"
   status <- "request"
   callback <- "handle_MSK_GBM_mRNA_Average"

     #--- first, two genes and two tissues only
     #               MDM4        REN
     # 1178.T.1 0.1083581 -0.2805017
     # 1182.T.1 0.1268618 -0.2463349

   entities <-  c("1178.T.1", "1182.T.1")
   features <- c("MDM4", "REN")
   
   payload <- list(entities=entities, features=features)

   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "success")
   
   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 1)
   mtx.avg <- mtx.as.list[[1]]
   
     # last element in this named list should be "rowname" and its value should be "average"

   checkEquals(mtx.avg, list(MDM4=0.11761, REN=-0.26342, rowname="average"))

     #--- now, two genes and all tissues 
     #               MDM4        REN
   
   entities <-  ""
   features <- c("MDM4", "REN")
   
   payload <- list(entities=entities, features=features)
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "success")
   
   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 1)
   mtx.avg <- mtx.as.list[[1]]
   checkEquals(names(mtx.avg), c("MDM4", "REN", "rowname"))

      # the idiosyncratic way this matrix was calculated ensures that the mean of all values is very nearly zero
   checkEqualsNumeric(mtx.avg$MDM4, 0, tol=1e10)
   checkEqualsNumeric(mtx.avg$REN, 0, tol=1e10)

     #--- now, two tissues and all genes
     #               MDM4        REN
   
   entities <-  c("1178.T.1", "1182.T.1")
   features <- ""
   
   payload <- list(entities=entities, features=features)
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload=payload)), client)

   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, "handle_MSK_GBM_mRNA_Average")
   checkEquals(msg.incoming$status, "success")
   
   mtx.as.list <- fromJSON(msg.incoming$payload)
   checkEquals(length(mtx.as.list), 1)
   mtx.avg <- mtx.as.list[[1]]
   checkEquals(head(mtx.avg, n=3), list(B2M=5.2763, B4GALT1=1.1114, CLTC=0.15301))


} # test_get_MSK_GBM_mRNA_Average_onSubsets
#----------------------------------------------------------------------------------------------------
