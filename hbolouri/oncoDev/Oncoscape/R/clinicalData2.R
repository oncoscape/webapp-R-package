#                   incoming message          function to call            return.cmd
#                   -------------------       ----------------           -------------
addRMessageHandler("fetchClinicalData2",      "sendClinicalData2")       # clinicalData2
addRMessageHandler("fetchAllTissueIDs",       "sendAllTissueIDs")        # allTissueIDs
addRMessageHandler("filterClinicalData",      "filterClinicalData")      # selectClinicalDataRows
addRMessageHandler("sendTissueIDsToModule",   "sendTissueIDsToModule")   # tissueIDsFor%s (destination module)



#addRMessageHandler("selectClinicalDataRows", "filterClinicalDataTable2");
#addRMessageHandler("tissueIDsForClinicalDataTable2", handleIncomingTissueIDs);

#----------------------------------------------------------------------------------------------------
sendClinicalData2 <- function(WS, msg)
{
   rows <- msg$payload
   if(rows == -1)
      rows <- nrow(tbl.clinical2)

   tbl.result <- as.matrix(tbl.clinical2[1:rows,])
   colnames(tbl.result) <- NULL

   return.cmd = "clinicalData2"
   return.msg <- list(cmd=return.cmd, payload=tbl.result)
   return.msg <- gsub("\n", "", toJSON(return.msg))
   printf("sending 'clinicalData2' to js: %d rows", nrow(tbl.result))
   
   sendOutput(DATA=return.msg, WS=WS)

} # sendClinicalData2
#----------------------------------------------------------------------------------------------------
sendTissueIDsToModule <- function(WS, msg)
{
   destination <- msg$payload$module
   tissueIDs <- msg$payload$tissueIDs

   recognized.tissueIDs <- sort(intersect(tissueIDs, rownames(mtx.nano)))
   printf("%d/%d tissueIDs found in mtx.nano", length(recognized.tissueIDs), length(tissueIDs))

   return.cmd <- sprintf("tissueIDsFor%s", destination)
   tissueID.count <- length(recognized.tissueIDs)

   return.msg <- toJSON(list(cmd=return.cmd, status="request",
                              payload=list(count=tissueID.count,
                                           tissueIDs=recognized.tissueIDs)))
   
   printf("Oncoscape::sendTissueIDsToModule msg.cmd: %s", return.cmd)
   
   sendOutput(DATA=return.msg, WS=WS)

} # sendTissueIDsToModule
#----------------------------------------------------------------------------------------------------
sendClinicalData2 <- function(WS, msg)
{
   rows <- msg$payload
   if(rows == -1)
      rows <- nrow(tbl.clinical2)

   tbl.result <- as.matrix(tbl.clinical2[1:rows,])
   colnames(tbl.result) <- NULL

   cmd = "clinicalData2"
   return.msg <- list(cmd=cmd, payload=tbl.result)
   return.msg <- gsub("\n", "", toJSON(return.msg))
   printf("sending 'clinicalData2' to js: %d rows", nrow(tbl.result))
   
   sendOutput(DATA=return.msg, WS=WS)

} # sendClinicalData2
#----------------------------------------------------------------------------------------------------
sendAllTissueIDs = function(WS, msg)
{
   return.cmd <- "allTissueIDs"
   return.msg = toJSON(list(cmd = return.cmd,
                             status = "reply",
                             payload = tbl.clinical2$tissueID));
   printf("Oncoscape::sendAllTissueIDs");
   
   sendOutput(DATA=return.msg, WS=WS)

} # sendAllTissueIDs
#----------------------------------------------------------------------------------------------------
filterClinicalData <- function(WS, msg)
{
   filters <- msg$payload
   printf("number of filters: %d", length(filters));
   validArgs <- all(sort(names(filters)) == c("ageAtDxMax", "ageAtDxMin", "overallSurvivalMax", "overallSurvivalMin"))

   return.cmd <- "selectClinicalDataRows"

   if(!validArgs){
       printf(" invalid args in request to filter clinical data");
       return.msg <- list(cmd=return.cmd, status="error", payload="invalidArgs")
       tissueID.count <- 0
       }
   else{
      ageMin <- as.numeric(filters[["ageAtDxMin"]])
      ageMax <- as.numeric(filters[["ageAtDxMax"]])
      survivalMin <- as.numeric(filters[["overallSurvivalMin"]])
      survivalMax <- as.numeric(filters[["overallSurvivalMax"]])
      printf("filtering tbl.clinical2 on 4 values");
      printf("        ageMin: %d", ageMin)
      printf("        ageMax: %d", ageMax)
      printf("   survivalMin: %d", survivalMin)
      printf("   survivalMax: %d", survivalMax)
      
      tbl.sub <- subset(tbl.clinical2, ageAtDx >= ageMin & ageAtDx <= ageMax &
                        overallSurvival >= survivalMin  & overallSurvival <= survivalMax)
      printf("  rows before: %d   rows after: %d", nrow(tbl.clinical2), nrow(tbl.sub))
      tissueIDs <- tbl.sub$tissueID
      deleters.string <- grep ("NULL", tissueIDs)
      printf("  nulls found in tissueIDs: %d/%d", length(deleters.string), length(tissueIDs))
      if(length(deleters.string) > 0)
          tissueIDs <- tissueIDs[-deleters.string]
      tissueID.count <- length(tissueIDs)
      return.msg <- list(cmd=return.cmd, status="success",
                         payload=list(count=tissueID.count, tissueIDs=tissueIDs))
      } # else
      
   printf("returning 'selectClinicalData' with status %s, tissueID count: %d",
          return.msg$status, tissueID.count)
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # filterClinicalData
#----------------------------------------------------------------------------------------------------
