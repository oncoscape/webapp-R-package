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
addRMessageHandler("getPatientHistoryDataVector",      "getPatientHistoryDataVector")
addRMessageHandler("createNewUserID",                  "createNewUserID")
addRMessageHandler("UserIDexists",                     "UserIDexists")
addRMessageHandler("addNewUserToList",                 "addNewUserToList")
addRMessageHandler("getUserSelectionnames",            "getUserSelectionnames")
addRMessageHandler("getUserSelection",                 "getUserSelectPatientHistory")
addRMessageHandler("addNewUserSelection",              "addUserSelectPatientHistory")
addRMessageHandler("filterPatientHistory",             "filterPatientHistory")
addRMessageHandler("getPatientClassification",         "getPatientClassification")
addRMessageHandler("getCaisisPatientHistory",          "getCaisisPatientHistory")          # uses eventList (multi-flat, list of lists)
addRMessageHandler("createRandomPatientPairedDistributionsForTesting", "createRandomPatientPairedDistributionsForTesting")
addRMessageHandler("calculatePairedDistributionsOfPatientHistoryData", "calculatePairedDistributionsOfPatientHistoryData")
addRMessageHandler("get_mRNA_data",                    "get_mRNA_data");
addRMessageHandler("get_cnv_data",                     "get_cnv_data");
addRMessageHandler("get_mutation_data",                "get_mutation_data");
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
getPatientHistoryDataVector <- function(WS, msg)
{
   signature <- "patientHistoryTable";
   
   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
   tbl <- getTable(patientHistoryProvider)

   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

      # payload must be a list
   payload <- msg$payload;
   printf("--- payload");
   print(payload)
   if(!is.list(payload)) {
       status <- "failure"
       error.message <- "need two fields in payload: 'colname' and 'patients'"
       return.msg <- list(cmd=msg$callback, callback="", status="error", payload=error.message)
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

   printf("checked for two fields");
      # list must have two fields
   constraint.fields <- sort(names(payload))
   legal.constraint.fields <- constraint.fields == c("colname", "patients")
   if (any(!legal.constraint.fields)){
      status <- "failure"
      error.message <- sprintf("payload fields not precisely 'colname', 'patients': %s",
                               paste(constraint.fields, collapse=", "))
      return.msg <- list(cmd=msg$callback, callback="", status="error", payload=error.message)
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      }
   
   printf("extracting payload field values");
   patients <- payload$patients
   print(patients)
   if(all(nchar(patients) == 0))
      patients <- NA
       
   columnOfInterest <- payload$colname
   printf("getting colname: %s", columnOfInterest)
   if(!columnOfInterest %in% colnames(tbl)){
      error.message <- sprintf("Oncoscape DataProviderBridge patientHistoryDataVector error:  '%s' is not a column title", columnOfInterest);
      return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      } # 
       
   return.cmd = msg$callback
   result <- as.numeric(tbl[, columnOfInterest])
   names(result) <- tbl$ID
   if(!all(is.na(patients)))
      result <- result[patients];
       
   printf("returning %d values from column %s", length(result), columnOfInterest)
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=toJSON(result));

   printf("DataProviderBridge.R, getPatientHistoryDataVector responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getTabularPatientHistory
#----------------------------------------------------------------------------------------------------
get_mRNA_data <- function(WS, msg)
{
   signature <- "mRNA";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   printf("--- get_mRNA_data, msg fields: %s", paste(names(msg), collapse=","))
   printf("    payload fields: %s", names(msg$payload))
   
   dataProvider <- DATA.PROVIDERS[[signature]];
   payload <- msg$payload
   
     # entities and features fields can be empty, but must be present
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
         printf("entities: %s", paste(entities, collapse=","))
         printf("features: %s", paste(features, collapse=","))
         tbl <- getData(dataProvider, entities=entities, features=features)
         matrix <- as.matrix(tbl)
         printf("matrix dim: %d, %d", nrow(matrix), ncol(matrix))
         return.cmd <- msg$callback
         #return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(mtx=matrixToJSON(matrix)))
         payload <- list(mtx=matrixToJSON(matrix))
         status <- "success"
         }
       } # is.list(payload)


   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }

   status <- "success"

   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   printf("DataProviderBridge.R, get_mRNA_data responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # get_mRNA_data
#----------------------------------------------------------------------------------------------------
get_cnv_data <- function(WS, msg)
{
   signature <- "cnv";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   printf("--- get_cnv_data, msg fields: %s", paste(names(msg), collapse=","))
   printf("    payload fields: %s", names(msg$payload))
   
   dataProvider <- DATA.PROVIDERS[[signature]];
   payload <- msg$payload
   
     # entities and features fields can be empty, but must be present
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
         printf("entities: %s", paste(entities, collapse=","))
         printf("features: %s", paste(features, collapse=","))
         tbl <- getData(dataProvider, entities=entities, features=features)
         matrix <- as.matrix(tbl)
         printf("matrix dim: %d, %d", nrow(matrix), ncol(matrix))
         return.cmd <- msg$callback
         #return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(mtx=matrixToJSON(matrix)))
         payload <- list(mtx=matrixToJSON(matrix))
         status <- "success"
         }
       } # is.list(payload)


   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }

   status <- "success"

   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   printf("DataProviderBridge.R, get_cnv_data responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # get_cnv_data
#----------------------------------------------------------------------------------------------------
get_mutation_data <- function(WS, msg)
{
   signature <- "mut";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       printf("DataProviderBridge error: %s", error.message)
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   printf("--- get_mut_data, msg fields: %s", paste(names(msg), collapse=","))
   printf("    payload fields: %s", names(msg$payload))
   
   dataProvider <- DATA.PROVIDERS[[signature]];
   payload <- msg$payload
   status <- "failure"
   print("--- payload");
   print(payload)
   print(class(payload))
     # entities and features fields can be empty, but must be present
   if(!is.list(payload)) {
       payload <- "no constraint fields in payload"
       printf("DataProviderBridge error: %s", payload)
       }

   if(is.list(payload)){
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
           printf("DataProviderBridge error: %s", payload)
          }
      else {
         entities <- payload$entities
         features <- payload$features
         printf("entities: %s (%d)", paste(entities, collapse=","), length(entities))
         printf("features: %s (%d)", paste(features, collapse=","), length(features))
         tbl <- getData(dataProvider, entities=entities, features=features)
         if(nrow(tbl) == 0) {
            payload <- "empty table"
            printf("DataProviderBridge error: %s", payload)
           }
         else{
            status <- "success"
            matrix <- as.matrix(tbl)
            matrix[matrix=="NaN"] <- NA
            printf("matrix dim: %d, %d", nrow(matrix), ncol(matrix))
            return.cmd <- msg$callback
            #return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(mtx=matrixToJSON(matrix)))
            payload <- list(mtx=matrixToJSON(matrix))
            } # some rows in tbl
         } # legal constraint fields found
       } # is.list(payload)


   if(nrow(tbl) == 0) {
      }

   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   printf("DataProviderBridge.R, get_cnv_data responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # get_mutation_data
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
   if(all(is.na(patientIDs)))
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
createNewUserID <- function(WS, msg)
{
   printf("===== generate new User ID")
             
   category.name <- "UserIDmap"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }

     userID <- msg$payload

     if(nchar(userID)==0 | is.na(userID)){
  	   NewID <- sample(c(1,2), 36, replace=T)
	   NewID[which(NewID==1)] <- sample(LETTERS, length(which(NewID==1)), replace=T)
	   NewID[which(NewID==2)] <- sample(0:9, length(which(NewID==2)), replace=T)
	 
       userID <- paste(NewID, collapse="")
     }

   AccountSettingsProvider <- USER.SETTINGS$UserIDmap
   while(userID %in% userIDs(AccountSettingsProvider)){
       	 NewID <- sample(c(1,2), 36, replace=T)
	     NewID[which(NewID==1)] <- sample(LETTERS, length(which(NewID==1)), replace=T)
	     NewID[which(NewID==2)] <- sample(0:9, length(which(NewID==2)), replace=T)
	 
         userID <- paste(NewID, collapse="")
    }

    payload <- list(userID = userID)

    return.msg <- list(cmd=msg$callback, payload=payload, status="success")
    
    sendOutput(DATA=toJSON(return.msg), WS=WS)
}
#----------------------------------------------------------------------------------------------------
UserIDexists <- function(WS, msg)
{
   printf("===== checking User ID")
             
   category.name <- "UserIDmap"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }

     userID <- msg$payload
     UserStatus <- FALSE;

   AccountSettingsProvider <- USER.SETTINGS$UserIDmap
   if(userID %in% userIDs(AccountSettingsProvider)){
       	  UserStatus = TRUE
    }

    return.msg <- list(cmd=msg$callback, payload=UserStatus, status="success")
    
    sendOutput(DATA=toJSON(return.msg), WS=WS)
}

#----------------------------------------------------------------------------------------------------
addNewUserToList <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
   printf("===== Add User ID to List")
             
   callback <- msg$callback
   payload <- msg$payload
   
   userID <- payload[["userID"]]
   username <- payload[["username"]]
   
   printf("Adding ID %s and name %s to list", userID, username)
   
   if(nchar(userID)==0)
       userID = NA
 
    if(is.na(userID)){
       error.message <- "Oncoscape DataProviderBridge error:  no userID defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }

   category.name <- "UserIDmap"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- username: %s", username);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }
       
   previousUsers <- NumUsers(USER.SETTINGS$UserIDmap)

   USER.SETTINGS$UserIDmap <- addUserID(USER.SETTINGS$UserIDmap, userID=userID, username=username)
   updatedUsers <- NumUsers(USER.SETTINGS$UserIDmap)

   addedUsers <- updatedUsers - previousUsers
   
   printf("added %d (== %d) users with username: %s", length(userID), addedUsers, username)
   
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(userID=userID, username= username))

   printf("DataProviderBridge.R, addNewUserToList responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getCaisisPatientHistory
#----------------------------------------------------------------------------------------------------
getUserSelectionnames <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
  
   callback <- msg$callback
   userID <- msg$payload$userID
   if(nchar(userID)==0)
       userID = NA

  if(is.na(userID)){
       error.message <- "Oncoscape DataProviderBridge error:  no userID defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   category.name <- "PatientSelectionHistory"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- userID: %s", userID);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientSelectionHistoryProvider <- USER.SETTINGS$PatientSelectionHistory
   selectionnames <- getSelectionnames(patientSelectionHistoryProvider, userID=userID)

    selection.count <- length(selectionnames)
   
   printf("found %d (== %d) saved selections for user: %s", length(selectionnames), selection.count, userID)
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=selectionnames)

   printf("DataProviderBridge.R, getUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getUserSelectPatientHistory
#----------------------------------------------------------------------------------------------------
getUserSelectPatientHistory <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
  
#   printf("--- DataProviderBridge looking for payload %s",  msg$payload)
   payload <- msg$payload
   userID <- payload["userID"]
   if(nchar(userID)==0)
       userID = NA
   selectionnames <- payload["selectionname"]
   if(all(nchar(selectionnames))==0)
       selectionnames = NA

   category.name <- "PatientSelectionHistory"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- userID: %s", userID);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientSelectionHistoryProvider <- USER.SETTINGS$PatientSelectionHistory
   selections <- getSelection(patientSelectionHistoryProvider, userID=userID, selectionnames=selectionnames)

   if(all(is.na(selectionnames)))
       selection.count <- "all"
   else
       selection.count <- length(selectionnames)
   
   printf("found %d (== %d) saved selections for user: %s", length(selections), selection.count, userID)
   
   return.msg <- list(cmd=msg$callback, status="success", payload=selections)

   printf("DataProviderBridge.R, getUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getUserSelectPatientHistory
#----------------------------------------------------------------------------------------------------
addUserSelectPatientHistory <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
   printf("===== Add User Selection to Patient History")
   printf("for userID %s", msg$payload$userID)
                
   callback <- msg$callback
   userID <- msg$payload$userID
   if(nchar(userID)==0)
       userID = NA
   selectionname <- msg$payload$selectionname
   if(nchar(selectionname)==0)
       selectionname = NA
   patientIDs <- msg$payload$PatientIDs
   if(all(nchar(patientIDs)==0))
       patientIDs = NA


  if(is.na(userID)){
       error.message <- "Oncoscape DataProviderBridge error:  no userID defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
  }  
  if(all(is.na(patientIDs))){
       error.message <- "Oncoscape DataProviderBridge error:  no patient IDs defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
  }  
  
  selection <- list(selectionname = selectionname, 
                    patientIDs = patientIDs, 
                    tab = msg$payload$Tab, 
                    settings = msg$payload$Settings)

   category.name <- "PatientSelectionHistory"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- userID: %s", userID);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }
       
   if(!(userID %in% userIDsWithSelection(USER.SETTINGS$PatientSelectionHistory))){
       USER.SETTINGS$PatientSelectionHistory<- addUserIDforSelection(USER.SETTINGS$PatientSelectionHistory, userID)
   }

  printf("Current User length: %d", NumUsersWithSelection(USER.SETTINGS$PatientSelectionHistory))
  printf("Current User Selection length: %d", NumUserSelections(USER.SETTINGS$PatientSelectionHistory, userID))
  previousSelection <-  NumUserSelections(USER.SETTINGS$PatientSelectionHistory, userID)
  
   		i=0; ValidSelectionName = selectionname
        while(!ValidSelectionname(USER.SETTINGS$PatientSelectionHistory, userID=userID, selectionname=ValidSelectionName)){
		    i=i+1;
		    ValidSelectionName = paste(selectionname,i, sep="_")
		}
  
  USER.SETTINGS$PatientSelectionHistory <- addSelection(USER.SETTINGS$PatientSelectionHistory, userID=userID, selectionname=ValidSelectionName,
                                  patientIDs = patientIDs, tab = msg$payload$Tab, settings = msg$payload$Settings)

   if(previousSelection >= NumUserSelections(USER.SETTINGS$PatientSelectionHistory, userID)){
       error.message <- "Oncoscape DataProviderBridge error:  could not add saved selection"
       print(error.message)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       printf("DataProviderBridge.R, addUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
       sendOutput(DATA=toJSON(return.msg), WS=WS)
   } else {
    
       printf("added %s saved selection for user: %s", ValidSelectionName, userID)
   
        SavedSelectionRow <- list(selectionname = ValidSelectionName,
                          tab = msg$payload$Tab, 
                          settings = msg$payload$Settings, 
                          patientIDs = patientIDs);

        return.cmd = msg$callback
        return.msg <- list(cmd=msg$callback, callback="", status="success", payload=SavedSelectionRow)

        printf("DataProviderBridge.R, addUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback); 
        sendOutput(DATA=toJSON(return.msg), WS=WS)
   }
} # addUserSelectPatientHistory
#----------------------------------------------------------------------------------------------------
# this message handler requires that a "patientHistoryTable" is in DATA.PROVIDERS
# no support here yet for a "patientHistoryEvents" data source
calculatePairedDistributionsOfPatientHistoryData <- function(WS, msg)
{
   #browser()
   
   callback <- msg$callback
   attribute.of.interest <- msg$payload[["attribute"]]
   numberOfPopulations <- msg$payload[["popCount"]]
   
   
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
   
	dataset<-list()
   
	if(testing){  # generate random populations
		full.count <- length(all.ids) #ID list length
		population.sizes <- as.integer(full.count/10) #determine pop size
		count <- 1;
		for(i in 1:numberOfPopulations){
			population.IDs<- all.ids[sample(1:full.count, population.sizes)] #grab some IDs
			population.name <- sprintf("pop%d", i)  # name pop
			for(j in 1:population.sizes){
      			random.value <- sample(1:100, 1) # grab random number
      			dataset[[count]] <- list(name=population.name, ID=population.IDs[j], value=random.value)
      			count <- 1 + count
      		}
      	}
    }

   #if(testing){  # generate two random populations
    #  full.count <- length(all.ids)
    #  population.sizes <- as.integer(full.count/10)
    #  population.1 <- all.ids[sample(1:full.count, population.sizes)]
    #  population.2 <- all.ids[sample(1:full.count, population.sizes)]
    #    # eliminate overlap
    #  population.2 <- setdiff(population.2, population.1)
    #  }
   #else {
    #  population.1 <- msg$payload$pop1
    #  population.2 <- msg$payload$pop2
    #  population.1 <- intersect(population.1, all.ids)
    #  population.2 <- intersect(population.2, all.ids)
    #  }

	#for(i in 1:max){
	#	population.name <- sprintf("pop%d", i)  # dumb name, but maybe adequate
	#	random.values <- sample(1:100, 10)                     # grab 10 numbers 1:100 at random
	#	payload[[i]] <- list(name=population.name, values=random.values)
    #}

      
   populations.error <- FALSE
   #if(length(population.1) < 1){
   #   error.msg <- sprintf("%s. population.1 has no members", error.msg)
   #   populations.error <- TRUE
   #   }

   #if(length(population.2) < 1){
   #   error.msg <- sprintf("%s. population.2 has no members", error.msg)
   #   populations.error <- TRUE
   #   }
      
   if(populations.error){    
      return.msg <- list(cmd=msg$callback, payload=error.msg, status="error")
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      }
                              
   #pop.indices.1 <- match(population.1, all.ids)
   #pop.indices.2 <- match(population.2, all.ids)
      
   #printf("pop.indices.1: %d", length(pop.indices.1))
   #printf("pop.indices.2: %d", length(pop.indices.2))
   
   #vals.1 <- as.numeric(tbl[pop.indices.1, attribute.of.interest])
   #vals.2 <- as.numeric(tbl[pop.indices.2, attribute.of.interest])

   #names(vals.1) <- tbl$ID[pop.indices.1]
   #names(vals.2) <- tbl$ID[pop.indices.2]
   
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload = dataset)
   sendOutput(DATA=toJSON(return.msg), WS=WS)   

} # calculatePairedDistributionsOfPatientHistoryData
#----------------------------------------------------------------------------------------------------
