#                   incoming message                   function to call                     return.cmd
#                   -------------------                ----------------                      -------------
addRMessageHandler("NanoStringExpresssionData.ping",   "nanoStringPing")                    # handleNanoStringping
addRMessageHandler("requestTissueNames",               "sendTissueNames")                   # handleTissueNames
addRMessageHandler("requestAverageExpression",         "sendAverageExpression")             # handleAverageExpression
addRMessageHandler("getNanoStringExpressionData",      "getNanoStringExpressionData")       # handleNanoStringExpressionData
addRMessageHandler("getGbmPathwaysCopyNumberData",     "getGbmPathwaysCopyNumberData")      # handleGbmPathwaysCopyNumberData
addRMessageHandler("getGbmPathwaysMutationData",       "getGbmPathwaysMutationData")        # handleGbmPathwaysMutationData
#----------------------------------------------------------------------------------------------------
nanoStringPing <- function(WS, msg)
{
    return.cmd <- "handleNanoStringPing"
    return.msg <- toJSON(list(cmd=return.cmd, status="success",
                              payload="ping!"))

    sendOutput(DATA=return.msg, WS=WS);

} # nanoStringPing
#----------------------------------------------------------------------------------------------------
sendTissueNames <- function(WS, msg)
{
    return.cmd <- "handleTissueNames"
    return.msg <- toJSON(list(cmd=return.cmd, status="success",
                              payload=tbl.idLookup$specimen))

    sendOutput(DATA=return.msg, WS=WS);

} # sendTissueNames
#----------------------------------------------------------------------------------------------------
sendAverageExpression <- function(WS, msg)
{
   tissueIDs <- msg$payload
   mtx.avg <- calculateAverageExpression(tissueIDs, mtx.nano)

   return.cmd <- "handleAverageExpression"
   
   if(!all(is.na(mtx.avg))) {
      payload <- matrixToJSON(mtx.avg)
      status <- "success"
      }
   else{
      payload <- NA
      status <- failure
      }

   return.msg <- toJSON(list(cmd=return.cmd, status=status, payload=payload))

   sendOutput(DATA=return.msg, WS=WS)

} # sendAverageExpression
#---------------------------------------------------------------------------------------------------
cleanupNanoStringMatrix <- function(tbl.nano, tbl.idLookup, sampleIDs=NA, geneList=NA)
{
   if(!all(is.na(sampleIDs)))
      sampleIDs.known <- intersect(sampleIDs, tbl.idLookup$specimen)
   else
      sampleIDs.known <- tbl.idLookup$specimen
   
   btcs.known <- tbl.idLookup[match(sampleIDs.known, tbl.idLookup$specimen),"btc"]
   expression.rows <- match(btcs.known, tbl.nano$BTC_ID)
   printf("found expression in tbl.nano for %d sampleIDs", length(expression.rows))
   tbl.expr <- tbl.nano[expression.rows,]
   tbl.expr$samples <- sampleIDs.known
   mtx <- as.matrix(tbl.expr[, 4:154])
   rownames(mtx) <- tbl.expr$samples

   bad.columns <- c("LOC390940","KIAA0746")

   for(bad.column in bad.columns){
      indx <- grep(bad.column, colnames(mtx))
      if(length(indx) > 0)
          mtx <- mtx[, -indx]
      } # for bad.column

   mtx [which(is.na(mtx))] <- 0.0

   empty.columns <- as.numeric(which(colSums(mtx) == 0))
   empty.rows <- as.numeric(which(rowSums(mtx) == 0))

   if(length(empty.columns) > 0)
       mtx <- mtx[, -empty.columns]
   if(length(empty.rows) > 0)
       mtx <- mtx[-empty.rows, ]

   if(!all(is.na(geneList))) { 
      columns.of.interest <- intersect(geneList, colnames(mtx))
      mtx <- mtx[, columns.of.interest]
      } # if geneList

   mtx

} # cleanupNanoStringMatrix
#----------------------------------------------------------------------------------------------------
calculateAverageExpression <- function (tissueIDs, mtx.nano, rowname="average")
{
   recognized.tissueIDs <- intersect(rownames(mtx.nano), tissueIDs)
   if(length(recognized.tissueIDs) == 0)
       return(NA)

   mtx.sub <- mtx.nano[recognized.tissueIDs,]
   result <- t(as.matrix(colSums(mtx.sub)/nrow(mtx.sub)))
   rownames(result) <- rowname
   result

} # calculateAverageExpression
#----------------------------------------------------------------------------------------------------
getNanoStringExpressionData <- function(WS, msg)
{
    nodeNames.from.network <- fromJSON(msg$payload)
    return.cmd <- "handleNanoStringExpressionData"
    payload <- ""
    status <- "failure"

    if(ncol(mtx.nano) > 0) {
        payload <- matrixToJSON(mtx.nano)
        status <- "success"
        }

    printf("NanoStringExpressionData::getNanoStringExpressionData returning 'handleNanoStringExpressionData'");
    return.msg <- toJSON(list(cmd=return.cmd, status=status, payload=payload))
    sendOutput(DATA=return.msg, WS=WS)

} # getAgeAtDxAndSurvivalRanges 
#---------------------------------------------------------------------------------------------------
getGbmPathwaysCopyNumberData <- function(WS, msg)
{
   nodeNames.from.network <- fromJSON(msg$payload)
   printf("getGbmPathwaysCopyNumberData: %s", paste(nodeNames.from.network, collapse=", "));

   dp <- DataProvider("MSK_GBM_copyNumber")

   tbl <- getData(dp)
   # print(tbl)
   genes.shared <- intersect(colnames(tbl), nodeNames.from.network)
   printf("genes.shared: %s", paste(genes.shared, collapse=","));
   tbl <- tbl[, genes.shared]
  
   return.cmd <- "handleGbmPathwaysCopyNumberData"
   payload <- ""
   status <- "failure"

    if(ncol(tbl) > 0) {
       payload <- matrixToJSON(tbl)
       status <- "success"
       }

   return.msg <- toJSON(list(cmd=return.cmd, status=status, payload=payload))
   #print(return.msg)
   
   sendOutput(DATA=return.msg, WS=WS)

} # getGbmPathwaysCopyNumberData
#---------------------------------------------------------------------------------------------------
getGbmPathwaysMutationData <- function(WS, msg)
{
   return.cmd <- "handleGbmPathwaysMutationData"
   return.payload <- ""
   return.status <- "failure"
   #browser()

   payload <- as.list(msg$payload)
   print(payload)

   if(!"mode" %in% names(payload)) {
       return.status <- "error"
       return.payload <- "no mode field in payload"
       return.msg <- toJSON(list(cmd=return.cmd, status=return.status, payload=return.payload))
       sendOutput(DATA=return.msg, WS=WS)
       return()
       } # error: payload has no mode field

   if(payload$mode == "ping"){
       return.status <- "ping returned"
       return.payload <- "nothing"
       return.msg <- toJSON(list(cmd=return.cmd, status=return.status, payload=return.payload))
       sendOutput(DATA=return.msg, WS=WS)
       return()
       } # ping

   if(payload$mode == "getEntitiesAndFeatures"){
      if(!exists("msk.gbm.dp"))
          msk.gbm.dp <<- DataProvider("MSK_GBM_mutation")
       tbl <- getData(msk.gbm.dp)
       entities <- rownames(tbl) # tissues
       features <- colnames(tbl) # genes
       return.status <- "success"
       return.payload <- list(entities=entities, features=features)
       return.msg <- toJSON(list(cmd=return.cmd, status=return.status, payload=return.payload))
       sendOutput(DATA=return.msg, WS=WS)
       return()
       } # 
       
       # optional extra payload fields: entities, features
   if(payload$mode == "getData"){   
      features <- c()
      entities <- c()
      if("features" %in% names(payload))
          features <- payload$features
      if("entities" %in% names(payload))
          entities <- payload$entities
      if(!exists("msk.gbm.dp"))
          msk.gbm.dp <<- DataProvider("MSK_GBM_mutation")


       tbl <- getData(msk.gbm.dp)
       printf("mutation tbl w/o filtering, rows: %d, columns: %d", nrow(tbl), ncol(tbl))

       if(length(features) > 0)
           tbl <- tbl[intersect(rownames(tbl), entities),]
       if(length(entities) > 0)
           tbl <- tbl[, intersect(colnames(tbl), features)]

       return.status <- "success"
       printf("mutation tbl rows: %d, columns: %d", nrow(tbl), ncol(tbl))
       return.payload <- matrixToJSON(tbl)
       return.msg <- toJSON(list(cmd=return.cmd, status=return.status, payload=return.payload))
       sendOutput(DATA=return.msg, WS=WS)
       return()
       } # 

} # getGbmPathwaysMutationData
#---------------------------------------------------------------------------------------------------
