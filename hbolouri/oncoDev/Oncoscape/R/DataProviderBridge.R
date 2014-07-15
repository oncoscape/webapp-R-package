#                   incoming message                   function to call                      return.cmd
#                   -------------------                ----------------                      -------------
addRMessageHandler("DataProviderBridge.ping",         "DataProviderBridgePing")             # handleDataProviderPing
#addRMessageHandler("get_TCGA_GBM_CopyNumber_Data",    "get_TCGA_GBM_copyNumber_Data")
#addRMessageHandler("get_TCGA_GBM_mRNA_Data",          "get_TCGA_GBM_mRNA_Data")
#addRMessageHandler("get_TCGA_GBM_mRNA_Average",       "get_TCGA_GBM_mRNA_Average")
#addRMessageHandler("get_MSK_GBM_CopyNumber_Data",     "get_MSK_GBM_copyNumber_Data")
#addRMessageHandler("get_MSK_GBM_mRNA_Data",           "get_MSK_GBM_mRNA_Data")
#addRMessageHandler("get_MSK_GBM_mRNA_Average",        "get_MSK_GBM_mRNA_Average")
addRMessageHandler("getPatientHistory",                "getPatientHistory")
addRMessageHandler("filterPatientHistory",             "filterPatientHistory")
addRMessageHandler("getPatientClassification",         "getPatientClassification")
addRMessageHandler("getCaisisPatientHistory",          "getCaisisPatientHistory")
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
getPatientHistory <- function(WS, msg)
{
   if(!"patientHistory" %in% ls(DATA.PROVIDERS)){
       error.message <- "Oncoscape DataBridge error:  no patientHistoryProvider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientHistoryProvider <- DATA.PROVIDERS$patientHistory
   tbl <- getTable(patientHistoryProvider)
   colnames <- colnames(tbl)
   matrix <- as.matrix(tbl)
   colnames(matrix) <- NULL
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(colnames=colnames, mtx=matrix))

   printf("DataBridge.R responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getPatientHistory
#----------------------------------------------------------------------------------------------------
# msg$payload has 4 fields:
#   ageAtDxMin, ageAtDxMax, overallSurvivalMin, overallSurvivalMax
#   return the IDs for all rows that meet these constraints
filterPatientHistory <- function(WS, msg)
{
   if(!"patientHistory" %in% ls(DATA.PROVIDERS)){
       error.message <- "Oncoscape DataBridge error:  no patientHistoryProvider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientHistoryProvider <- DATA.PROVIDERS$patientHistory
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
       error.message <- "Oncoscape DataBridge error:  no patient classification provider defined"
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
    filename <- msg$payload
    full.path <-  system.file(package="Oncoscape", "extdata", filename)

   category.name <- "patientHistory"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(DATA.PROVIDERS))
    
   if(!category.name %in% ls(DATA.PROVIDERS)){
       error.message <- "Oncoscape DataBridge error:  no caisisPatientHistoryProvider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientHistoryProvider <- DATA.PROVIDERS$patientHistory
   events <- getEvents(patientHistoryProvider)
   #colnames <- colnames(tbl)
   #matrix <- as.matrix(tbl)
   #colnames(matrix) <- NULL
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=events)

   printf("DataBridge.R responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)



#    if(file.exists(full.path)){
#       var.name <- load(full.path)
#       stopifnot(var.name == "PatientData_json")
#       payload <- toJSON(PatientData_json)
#       status <- "success"
#       return.msg <- list(cmd=msg$callback, callback="", status="success", payload=payload)
#       }
#    else{
#       return.msg <- list(cmd=msg$callback, callback="", status="failure", payload=sprintf("could not read '%s'", filename))
#       }

#   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getCaisisPatientHistory
#----------------------------------------------------------------------------------------------------
                                    
