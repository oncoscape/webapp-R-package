#                   incoming message                   function to call 
#                   -------------------                ---------------- 
addRMessageHandler("AnalysisBridge.ping",              "AnalysisBridge.ping")
addRMessageHandler("calculate_mRNA_PCA",               "calculate_mRNA_PCA")
#----------------------------------------------------------------------------------------------------
AnalysisBridge.ping <- function(WS, msg)
{
    return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload="ping!"))
    sendOutput(DATA=return.msg, WS=WS);

} # AnalysisBridge.ping
#----------------------------------------------------------------------------------------------------
calculate_mRNA_PCA <- function(WS, msg)
{
   entities <- msg$payload
   
   if(!"mRNA" %in% ls(DATA.PROVIDERS)){
       return.msg <- list(cmd=msg$callback, callback="", status="error",
                          payload="no mRNA data provider defined");
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   dp <- DATA.PROVIDERS$mRNA
 
   if((length(entities) == 0) | (length(entities) == 1 && nchar(entities) == 0))
       entities <- NA
   else
      entities <- intersect(entities, entities(dp))

   mtx <- as.matrix(getData(dp, entities=entities))
   printf("rows in max about to be fed to PCA: %d", nrow(mtx))

   pca <- new.pcaAnalysis(mtx)
   tbl.pca <- pca$scores[,c("PC1", "PC2", "PC3", "PC4", "PC5", "id")]
       printf("pca score columns: %s", colnames(tbl.pca))


   if(all(is.na(tbl.pca))){
       printf("Oncoscape::calculatePCA encountered pcaAnalysis error")
       return.msg <- toJSON(list(cmd=msg$callback, callback="", status="error",
                                 payload="error calculating PCA"));
       sendOutput(DATA=return.msg, WS=WS)
       return()
       }
  
  
       
   printf("pca on %d samples returned nrows %d", length(entities), nrow(tbl.pca))
   json.string <- new.pcaResultsToJSONstring(tbl.pca)

   return.msg <- toJSON(list(cmd=msg$callback, callback="",  status="success", payload=json.string))
   sendOutput(DATA=return.msg, WS=WS)


} # calculate.mRNA.PCA
#----------------------------------------------------------------------------------------------------
