#                   incoming message                   function to call                      return.cmd
#                   -------------------                ----------------                      -------------
addRMessageHandler("DataProviderBridge.ping",         "DataProviderBridgePing")             # handleDataProviderPing
#addRMessageHandler("get_TCGA_GBM_CopyNumber_Data",    "get_TCGA_GBM_copyNumber_Data")
#addRMessageHandler("get_TCGA_GBM_mRNA_Data",          "get_TCGA_GBM_mRNA_Data")
#addRMessageHandler("get_TCGA_GBM_mRNA_Average",       "get_TCGA_GBM_mRNA_Average")
#addRMessageHandler("get_MSK_GBM_CopyNumber_Data",     "get_MSK_GBM_copyNumber_Data")
#addRMessageHandler("get_MSK_GBM_mRNA_Data",           "get_MSK_GBM_mRNA_Data")
#addRMessageHandler("get_MSK_GBM_mRNA_Average",        "get_MSK_GBM_mRNA_Average")
addRMessageHandler("getTabularPatientHistory",         "getTabularPatientHistory")
addRMessageHandler("filterPatientHistory",             "filterPatientHistory")
addRMessageHandler("getPatientClassification",         "getPatientClassification")
addRMessageHandler("getCaisisPatientHistory",          "getCaisisPatientHistory")          # uses eventList (multi-flat, list of lists)
addRMessageHandler("createRandomPatientPairedDistributionsForTesting", "createRandomPatientPairedDistributionsForTesting")
addRMessageHandler("calculatePairedDistributionsOfPatientHistoryData", "calculatePairedDistributionsOfPatientHistoryData")
#----------------------------------------------------------------------------------------------------
DataProviderBridgePing <- function(WS, msg)
{
    return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload="ping!"))
    sendOutput(DATA=return.msg, WS=WS);

} # DataProviderBridgePing
#----------------------------------------------------------------------------------------------------
get_TCGA_GBM_copyNumber_Data <- function(WS, msg)
{
   dp <- DataProvider("TCGA_GBM_copyNumber")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         }
      } # is.list(payload)

   status <- "success"

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_TCGA_GBM_copyNumber_Data
#---------------------------------------------------------------------------------------------------
get_TCGA_GBM_mRNA_Data <- function(WS, msg)
{
   dp <- DataProvider("TCGA_GBM_mRNA")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         status <- "success"
         }
      } # is.list(payload)

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_TCGA_GBM_mRNA_Data
#---------------------------------------------------------------------------------------------------
get_TCGA_GBM_mRNA_Average <- function(WS, msg)
{
   dp <- DataProvider("TCGA_GBM_mRNA")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         if(all(nchar(entities) == 0)) entities <- NA
         if(all(nchar(features) == 0)) features <- NA
         mtx <- as.matrix(getData(dp, entities=entities, features=features))
         mtx[which(is.na(mtx))] <- 0.0
         result <- t(as.matrix(colSums(mtx)/nrow(mtx)))
         rownames(result) <- "average"
         payload <- matrixToJSON(result)
         status <- "success"
         }
      } # is.list(payload)

   if(nrow(mtx) == 0) {
      status <- "failure"
      payload <- "no rows matching supplied entities and features"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_TCGA_GBM_mRNA_Average
#---------------------------------------------------------------------------------------------------
get_MSK_GBM_copyNumber_Data <- function(WS, msg)
{
   dp <- DataProvider("MSK_GBM_copyNumber")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         }
      } # is.list(payload)

   status <- "success"

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_MSK_GBM_copyNumber_Data
#---------------------------------------------------------------------------------------------------
get_MSK_GBM_mRNA_Data <- function(WS, msg)
{
   dp <- DataProvider("MSK_GBM_mRNA")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         }
      } # is.list(payload)

   status <- "success"

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_MSK_GBM_mRNA_Data
#----------------------------------------------------------------------------------------------------
get_MSK_GBM_mRNA_Average <- function(WS, msg)
{
   dp <- DataProvider("MSK_GBM_mRNA")
   
   payload <- msg$payload
   
   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         if(all(nchar(entities) == 0)) entities <- NA
         if(all(nchar(features) == 0)) features <- NA
         mtx <- getData(dp, entities=entities, features=features)
         if(nrow(mtx) == 0) {
            status = "failure"
            payload = "no entities (tissueIDs) recognized"
            }
         else{
            result <- t(as.matrix(colSums(mtx)/nrow(mtx)))
            rownames(result) <- "average"
            payload <- matrixToJSON(result)
            status <- "success"
            } # else: some rows in mtx
        } # else: payload constrains
      } # payload is a list, as needed
   
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   sendOutput(DATA=return.msg, WS=WS)

} # get_MSK_GBM_mRNA_Average
#----------------------------------------------------------------------------------------------------
getTabularPatientHistory <- function(WS, msg)
{
   signature <- "patientHistoryTable";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   print("---- current provider keys:")
   print(ls(DATA.PROVIDERS))
   
   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
   tbl <- getTable(patientHistoryProvider)
   colnames <- colnames(tbl)
   matrix <- as.matrix(tbl)
   colnames(matrix) <- NULL
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(colnames=colnames, mtx=matrix))

   printf("DataProviderBridge.R, getTabularPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getTabularPatientHistory
#----------------------------------------------------------------------------------------------------
# msg$payload has 4 fields:
#   ageAtDxMin, ageAtDxMax, overallSurvivalMin, overallSurvivalMax
#   return the IDs for all rows that meet these constraints
filterPatientHistory <- function(WS, msg)
{
   signature <- "patientHistoryTable";

   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
   tbl <- getTable(patientHistoryProvider)

   filters <- msg$payload
   validArgs <- all(sort(names(filters)) == c("ageAtDxMax", "ageAtDxMin", "overallSurvivalMax", "overallSurvivalMin"))

   if(!validArgs){
       return.msg <- list(cmd=msg$callback, callback="", status="error", payload="invalidArgs")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   ageMin <- as.numeric(filters[["ageAtDxMin"]])
   ageMax <- as.numeric(filters[["ageAtDxMax"]])
   survivalMin <- as.numeric(filters[["overallSurvivalMin"]])
   survivalMax <- as.numeric(filters[["overallSurvivalMax"]])

   tbl.sub <- subset(tbl, ageAtDx >= ageMin & ageAtDx <= ageMax &
                     survival >= survivalMin  & survival <= survivalMax)
   printf("  rows before: %d   rows after: %d", nrow(tbl), nrow(tbl.sub))
   ids <- tbl.sub$ID
   deleters.string <- grep ("NULL", ids)
   if(length(deleters.string) > 0)
       ids <- ids[-deleters.string]
   id.count <- length(ids)
   return.msg <- list(cmd=msg$callback, callback="", status="success",
                      payload=list(count=id.count, ids=ids))
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # filterPatientHistory
#----------------------------------------------------------------------------------------------------
getPatientClassification <- function(WS, msg)
{
   if(!"patientClassification" %in% ls(DATA.PROVIDERS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patient classification provider defined"
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       printf("found no patient classifcation, return this msg:")
       print(return.msg)
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return();
       }

   provider <- DATA.PROVIDERS$patientClassification
   tbl <- getData(provider)

   payload <- matrixToJSON(tbl)
   status <- "success"
   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getPatientClassification
#----------------------------------------------------------------------------------------------------
getCaisisPatientHistory <- function(WS, msg)
{
   callback <- msg$callback
   patientIDs <- msg$payload
   if(all(nchar(patientIDs)==0))
       patientIDs = NA

   category.name <- "patientHistoryEvents"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(DATA.PROVIDERS))
   printf("--- payload: %s", paste(patientIDs, collapse=","));
    
   if(!category.name %in% ls(DATA.PROVIDERS)){
       error.message <- "Oncoscape DataProviderBridge error:  no caisisPatientHistoryProvider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryEvents
   events <- getEvents(patientHistoryProvider, patient.ids=patientIDs)
   if(is.na(patientIDs))
       patient.count <- "all"
   else
       patient.count <- length(patientIDs)
   
   printf("found %d caisis-style events for %s patients", length(events), patient.count)
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=events)

   printf("DataProviderBridge.R, getCaisisPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getCaisisPatientHistory
#----------------------------------------------------------------------------------------------------
# this message handler requires that a "patientHistoryTable" is in DATA.PROVIDERS
# no support here yet for a "patientHistoryEvents" data source
calculatePairedDistributionsOfPatientHistoryData <- function(WS, msg)
{
   #browser()
   
   callback <- msg$callback
   attribute.of.interest <- msg$payload[["attribute"]]

      # define the basic error message, to which details can be added
   error.msg <- "Error.  DataProviderBridge::calculatePairedDistributionsOfPatientHistoryData"

   testing <- FALSE
   
   if("mode" %in% names(msg$payload)){
      testing <- length(grep("test",  msg$payload[["mode"]], ignore.case=TRUE)) > 0
      } # no "mode" in payload
       
      # make sure we have the data
   data.category.name <- "patientHistoryTable"
   printf("--- DataProviderBridge looking for '%s': %s",  data.category.name, data.category.name %in% ls(DATA.PROVIDERS))
   
   if(!data.category.name %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s defined", data.category.name)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

   provider <- DATA.PROVIDERS[[data.category.name]]
   tbl <- getTable(provider)
   if(!attribute.of.interest %in% colnames(tbl)){
       error.msg <- sprintf("%s: attribute.of.interest not in colnames(tbl): '%s'",
                            error.msg, attribute.of.interest)
       return.msg <- list(cmd=msg$callback, payload=error.msg, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

   all.ids <- tbl$ID

   if(testing){  # generate two random populations
      full.count <- length(all.ids)
      population.sizes <- as.integer(full.count/10)
      population.1 <- all.ids[sample(1:full.count, population.sizes)]
      population.2 <- all.ids[sample(1:full.count, population.sizes)]
        # eliminate overlap
      population.2 <- setdiff(population.2, population.1)
      }
   else {
      population.1 <- msg$payload$pop1
      population.2 <- msg$payload$pop2
      population.1 <- intersect(population.1, all.ids)
      population.2 <- intersect(population.2, all.ids)
      }
      
   populations.error <- FALSE
   if(length(population.1) < 1){
      error.msg <- sprintf("%s. population.1 has no members", error.msg)
      populations.error <- TRUE
      }

   if(length(population.2) < 1){
      error.msg <- sprintf("%s. population.2 has no members", error.msg)
      populations.error <- TRUE
      }
      
   if(populations.error){    
      return.msg <- list(cmd=msg$callback, payload=error.msg, status="error")
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      }
                              
   pop.indices.1 <- match(population.1, all.ids)
   pop.indices.2 <- match(population.2, all.ids)
      
   printf("pop.indices.1: %d", length(pop.indices.1))
   printf("pop.indices.2: %d", length(pop.indices.2))
   
   vals.1 <- as.numeric(tbl[pop.indices.1, attribute.of.interest])
   vals.2 <- as.numeric(tbl[pop.indices.2, attribute.of.interest])

   names(vals.1) <- tbl$ID[pop.indices.1]
   names(vals.2) <- tbl$ID[pop.indices.2]
   
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(pop1=vals.1,
                                                                                    pop2=vals.2))
   sendOutput(DATA=toJSON(return.msg), WS=WS)   

} # calculatePairedDistributionsOfPatientHistoryData
#----------------------------------------------------------------------------------------------------
