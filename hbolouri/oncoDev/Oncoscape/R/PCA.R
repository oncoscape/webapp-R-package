#                   incoming message          function to call            return.cmd
#                   -------------------       ----------------           -------------
addRMessageHandler("calculatePCA",            "calculatePCA")            # pcaPlot
#----------------------------------------------------------------------------------------------------
calculatePCA <- function(WS, msg)
{
   printf("entering calculatePCA");
   printf("msg$cmd: %s", msg$cmd)
   printf("========== payload")
   print(msg$payload)

   return.cmd <- "pcaPlot"

   sampleNames <- fromJSON(msg$payload)
   printf("calculatePCA has %d sampleNames", length(sampleNames))

   mtx <- cleanupNanoStringMatrix(tbl.nano, tbl.idLookup, sampleNames, geneList=NA)

   tbl.pca <- new.pcaAnalysis(mtx, sampleNames)
   if(all(is.na(tbl.pca))){
       printf("Oncoscape::calculatePCA encountered pcaAnalysis error")
       return.msg <- toJSON(list(cmd=return.cmd, status="error", payload="error calculating PCA"));
       sendOutput(DATA=return.msg, WS=WS)
       return()
       }
       
   printf("pca on %d samples returned nrows %d", length(sampleNames), nrow(tbl.pca))
   json.string <- pcaResultsToJSONstring(tbl.pca)


   return.msg <- toJSON(list(cmd=return.cmd, status="success", payload=json.string))
   sendOutput(DATA=return.msg, WS=WS)

} # calculatePCA
#----------------------------------------------------------------------------------------------------
new.pcaAnalysis <- function(mtx)
{
   printf("=== entering Analyses::pcaAnalysis");
   printf("dim(mtx): %d x %d", nrow(mtx), ncol(mtx))
   
   printf("looking at column.sums");

   mtx[is.na(mtx)] <- 0.0
   
   column.sums <- colSums(mtx)
   removers <- as.integer(which(column.sums == 0))
   if(length(removers) > 0) {
       printf("removing %d columns", length(removers))
       mtx <- mtx[, -removers]
       } # if removers

   printf("before prcomp, %d, %d", nrow(mtx), ncol(mtx))
   
   PCs <- tryCatch(
      prcomp(mtx,center=T,scale=T),
      error=function(error.message){
         print(error.message)
         return(NA)
         })
   
   if(all(is.na(PCs)))
       return(NA)
    
   result <- list()
     result$scores <- as.data.frame(PCs$x)
     result$scores$id <- rownames(result$scores)
     rownames(result$scores) <- NULL
   
     result$loadings <- as.data.frame(PCs$rotation)
     result$loadings$id <- rownames(result$loadings)
     rownames(result$loadings) <- NULL
   
     result$importance <- summary(PCs)$importance
     
     result$method <- list(method = "prcomp", center="True", scale="True")
   
   invisible (result)

} # new.pcaAnalysis
#----------------------------------------------------------------------------------------------------
pcaAnalysis <- function(mtx, sampleIDs=NA)
{
   printf("=== entering Analyses::pcaAnalysis");
   printf("dim(mtx): %d x %d, sample count: %d", nrow(mtx), ncol(mtx), length(sampleIDs))
   
   printf("is.na(sampleIDs)? ", all(is.na(sampleIDs)))

   if(!all(is.na(sampleIDs))) {
       recognized.rownames <- intersect(rownames(mtx), sampleIDs)
       if(length(recognized.rownames) == 0)
           return(NA)
        mtx <- mtx[recognized.rownames,]
        } # sampleIDs provided
       
   column.sums <- colSums(mtx)
   removers <- which(column.sums == 0)
   if(length(removers) > 0) {
       printf("removing %d columns", length(removers))
       mtx <- mtx[, -removers]
       } # if removers

   PCs <- tryCatch(
      prcomp(mtx,center=T,scale=T),
      error=function(error.message){
         print(error.message)
         return(NA)
         })
   
   if(all(is.na(PCs)))
       return(NA)
      
   result <- as.data.frame(PCs$x[, 1:2])
   result$sample <- rownames(result)
   rownames(result) <- NULL
   result <- merge(result, tbl.idLookup[, c("specimen", "dzSubType")],
                   by.x="sample", by.y="specimen")
   result <- result[, c("PC1", "PC2", "sample", "dzSubType")]
   invisible (result)

} # pcaAnalysis
#----------------------------------------------------------------------------------------------------
new.pcaResultsToJSONstring <- function(tbl)
{
    stopifnot(colnames(tbl) == c("PC1", "PC2","PC3", "PC4", "PC5", "id"))
    s <- "["
    max <- nrow(tbl)
    for(r in 1:max){
       new.row <- toJSON(tbl[r,])
       separator <- ","
       if(r == 1)
           separator <- ""
       s <- paste(s, new.row, sep=separator)
       } # for r
       
    s <- paste(s, "]", sep="")
    gsub("\n", "", s)
    s

} # new.pcaResultsToJSONstring
#-------------------------------------------------------------------------------
pcaResultsToJSONstring <- function(tbl)
{
    stopifnot(colnames(tbl) == c("PC1", "PC2", "sample", "dzSubType"))
    s <- "["
    max <- nrow(tbl)
    for(r in 1:max){
       new.row <- toJSON(tbl[r,])
       separator <- ","
       if(r == 1)
           separator <- ""
       s <- paste(s, new.row, sep=separator)
       } # for r
       
    s <- paste(s, "]", sep="")
    gsub("\n", "", s)
    s

} # pcaResultsToJSONstring
#-------------------------------------------------------------------------------

