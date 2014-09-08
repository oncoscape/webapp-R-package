#                   incoming message                     function to call                             return.cmd
#                   -------------------                  ----------------                             a-------------

addRMessageHandler("PLSR.ping",                         "PLSR.ping")
addRMessageHandler("getAgeAtDxAndSurvivalRanges",       "getAgeAtDxAndSurvivalRanges")
addRMessageHandler("calculatePLSR",   "calculatePLSR")

#----------------------------------------------------------------------------------------------------
PLSR.ping <- function(WS, msg)
{

  return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload="ping back!"))
  sendOutput(DATA=return.msg, WS=WS);

} # PLSR.ping
#----------------------------------------------------------------------------------------------------
# create convenient global variables for relevant data types specified in the current manifest
# print(ls(DATA.PROVIDERS))
# printf("exists ptHis? ", exists("tbl.ptHis"))
# stopifnot("patientHistoryTable" %in% ls(DATA.PROVIDERS))
# if(exists("tbl.patientHistory")){
#    printf("tbl.patientHistory (%d, %d) already loaded", nrow(tbl.patientHistory), ncol(tbl.patientHistory))
# }else{
#    patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
#    tbl.patientHistory <- getTable(patientHistoryProvider)
#    printf("tbl.patientHistory (%d, %d) freshly loaded", nrow(tbl.patientHistory), ncol(tbl.patientHistory))
#    }

#----------------------------------------------------------------------------------------------------
getAgeAtDxAndSurvivalRanges <- function(WS, msg)
{
    print("getAgeAtDxAndSurvivalRanges");
    if(!exists("tbl.patientHistory"))
       return.msg <- toJSON(list(cmd=msg$callback, callback="", status="error",
                                 payload="PLSR.R could not find tbl.patientHistory"))
    else{
      result <- list(ageAtDxLow=min(tbl.patientHistory$ageAtDx, na.rm=TRUE),
                     ageAtDxHigh=max(tbl.patientHistory$ageAtDx, na.rm=TRUE),
                     survivalLow=min(tbl.patientHistory$survival, na.rm=TRUE),
                     survivalHigh=max(tbl.patientHistory$survival, na.rm=TRUE))
      return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload=result))
      } # else: tbl.patientHistory exists

    sendOutput(DATA=return.msg, WS=WS)

} # getAgeAtDxAndSurvivalRanges 
#---------------------------------------------------------------------------------------------------
createClassificationMatrix <- function(tbl.ptHis,
                                       ageAtDx.lo=15,
                                       ageAtDx.hi=80,
                                       survival.lo=0.2,
                                       survival.hi=5
                                       )
{
    row.names <- tbl.ptHis$ID # eg, TCGA.02.001
    col.names <- c("ageAtDxLow", "ageAtDxHigh", "survivalLow", "survivalHigh")
    mtx.classify <- matrix(0, nrow(tbl.ptHis), ncol=4,dimnames=list(row.names, col.names))

    ageAtDxLowTissues <- subset(tbl.ptHis, ageAtDx <= ageAtDx.lo)$ID
    ageAtDxHighTissues <- subset(tbl.ptHis, ageAtDx >= ageAtDx.hi)$ID

    survivalLowTissues <- subset(tbl.ptHis, survival <= survival.lo)$ID
    survivalHighTissues <- subset(tbl.ptHis, survival >= survival.hi)$ID

    mtx.classify[ageAtDxLowTissues, "ageAtDxLow"] <- mtx.classify[ageAtDxLowTissues, "ageAtDxLow"] + 1;
    mtx.classify[ageAtDxHighTissues,  "ageAtDxHigh"] <- mtx.classify[ageAtDxHighTissues, "ageAtDxHigh"] + 1;
    
    mtx.classify[survivalLowTissues,   "survivalLow"]  <- mtx.classify[survivalLowTissues, "survivalLow"] + 1;
    mtx.classify[survivalHighTissues,  "survivalHigh"] <- mtx.classify[survivalHighTissues, "survivalHigh"] + 1;

    mtx.classify

}  # createClassificationMatrix
#----------------------------------------------------------------------------------------------------
# 'actual' rather than 'as quantiles' which is how we started (16 apr 2014)
calculatePLSR <- function(WS, msg)
{
    print("==== calculatePLSR")

    if(!exists("tbl.patientHistory")){
       patientHistoryProvider <- Oncoscape:::DATA.PROVIDERS$patientHistoryTable
       tbl.patientHistory <- getTable(patientHistoryProvider)
       }

    printf("tbl.patientHistory: %d x %d", nrow(tbl.patientHistory), ncol(tbl.patientHistory))

    if(!exists("tbl.mrna"))
       tbl.mrna <- getData(Oncoscape:::DATA.PROVIDERS[["mRNA"]])


    printf("tbl.mrna: %d x %d", nrow(tbl.mrna), ncol(tbl.mrna))

   #tbl.mrna <<- getData(Oncoscape:::DATA.PROVIDERS[["mRNA"]])
   #tbl.ptclass <<- getData(Oncoscape:::DATA.PROVIDERS[["patientClassification"]])
   #tbl.pt <<- getData(Oncoscape:::DATA.PROVIDERS[["patientHistoryTable"]])

   #patientHistoryProvider <- Oncoscape:::DATA.PROVIDERS$patientHistoryTable
   #tbl.ptHis <<- getTable(patientHistoryProvider)
   
   print("========= payload");
   print(msg$payload)
   payload <- fromJSON(msg$payload);

   geneSetName <- payload[["geneSet"]]
   printf("geneSetName: %s", geneSetName);
    
   ageAtDx.threshold.low <- payload[["ageAtDxThresholdLow"]]
   ageAtDx.threshold.high  <- payload[["ageAtDxThresholdHi"]]
   overallSurvival.threshold.low <- payload[["overallSurvivalThresholdLow"]]
   overallSurvival.threshold.high <- payload[["overallSurvivalThresholdHi"]]

   mtx.classify <- createClassificationMatrix(tbl.patientHistory,
                                              ageAtDx.threshold.low,
                                              ageAtDx.threshold.high,
                                              overallSurvival.threshold.low,
                                              overallSurvival.threshold.high)

   print(colSums(mtx.classify))
   mtx.mrna <- as.matrix(tbl.mrna)
   if(!geneSetName %in% names(genesets))
       keepers <- colnames(mtx.mrna)
   else
       keepers <- intersect(colnames(mtx.mrna), genesets[[geneSetName]])
    
   if(length(keepers) < 5){
      error.msg <- sprintf("PLSR geneSet error: only %d/%d %s genes are in mRNA dataset",
                           length(keepers), length(genesets[[geneSetName]]), geneSetName);
      return.msg <- toJSON(list(cmd=msg$callback, callback="",  status="error",
                            payload=error.msg))
      sendOutput(DATA=return.msg, WS=WS)
      return();
      } # keepers < 10
       
   mtx.mrna <- mtx.mrna[, keepers]

   mtx.classify <- mtx.classify[rownames(mtx.mrna),]
     #set.seed(17)
     # genes.indices <- sample(1:ncol(mtx.mrna), 100)
   #gene.indices <-  1:ncol(mtx.mrna)
   #printf("--- mtx.classify");
   #print(head(mtx.classify))
   #printf("--- mtx.mrna");
   #print(head(mtx.mrna))
    
   fit <- plsr(mtx.classify ~ mtx.mrna, ncomp=2, scale=TRUE,validation="none")

    # names(fit)
    #
    # coefficients    scores          loadings        loading.weights Yscores         Yloadings      
    # projection      Xmeans          Ymeans          fitted.values   residuals       Xvar           
    # Xtotvar         fit.time        ncomp           method          scale           call           
    # terms           model          

    # dim(mtx.mrna)             304 patients x 817 genes
    # dim(fit$coefficients)     817 4 2
    # dim(fit$scores)           304 2
    # dim(fit$loadings)         817 2
    # dim(fit$loading.weights)  817 2
    # dim(fit$Yscores)          304 2
    # dim(fit$Yloadings)          4 2
    # fit$Yloadings[,1]          ageAtDxLow  ageAtDxHigh  survivalLow survivalHigh 
    #                            0.017014155 -0.001067325 -0.008270052  0.003779102    x coordinate
    #              [,2]          0.021748847 -0.027534816 -0.010777649  0.002372023    y coordinate

    

   #print(fit)

   if(all(is.na(fit))){
       return.msg <- toJSON(list(cmd=msg$callback, status="error", callback="",
                                 payload="probable cause: patient classes not disjoint"))
       sendOutput(DATA=return.msg, WS=WS)
       return();
       } # is.na (result)

       # genes is an n x 2 matrix, rownames are gene symbols, columns are "Comp 1", "Comp 2"
       # load.vectors:  a 4 x 2 matrix, rownames are the low/hi ageAtDx, low/hi survival, colnames x & y

      # create the 4 x 2 vectors matrix.
    categories <- names(fit$Yloadings[,1]) # ageAtDxLow, ageAtDxHigh, survivalLow, survivalHigh
    load.vectors <- matrix(c(fit$Yloadings[,1], fit$Yloadings[,2]),
                           nrow=length(categories),
                           dimnames=list(categories, c("x", "y")))
    
    gene.loadings <- fit$loadings[,1:2]

       # these vectors are often stubby little things.
       # scale them up so that the largest extends beyond the most extreme gene location

       # we want the longest vector to project beyond the furthest point by
       # about a factor of 1.2
    
    scale <- 1.2 *  max(abs(gene.loadings))/max(abs(load.vectors))
    load.vectors <- load.vectors * scale

    maximum.value <- max(abs(c(as.numeric(gene.loadings), as.numeric(load.vectors))))

    payload <- list(genes=matrixToJSON(gene.loadings, category="gene"),
                    vectors=matrixToJSON(load.vectors, category="vector"),
                    absMaxValue=maximum.value)
    
    return.msg <- toJSON(list(cmd=msg$callback, callback="",  status="fit", payload=payload))
    sendOutput(DATA=return.msg, WS=WS)
    

} # calculatePLSR
#----------------------------------------------------------------------------------------------------
patientQuantileTimesPLSR <- function(ageAtDx.threshold.low,
                             ageAtDx.threshold.hi,
                             overallSurvival.threshold.low,
                             overallSurvival.threshold.hi,
                             tbl.clinical, tbl.idLookup)
{
      # TODO: validate the thresholds, clamp them to legit if necessary
    
      # find the tissues (specimen) ID for all patients with ageAtDx
      # above and below the <threshold> quartile

    mtx.data <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup)
    ageAtDiagnosis <- tbl.clinical$ageAtDx
    ageAtDiagnosis[ageAtDiagnosis < 0] <- NA

    if(interactive())
        print(fivenum(ageAtDiagnosis))

        # create 100 quantiles
    age.quantile <- quantile(ageAtDiagnosis, seq(0, 1, 0.01), na.rm=TRUE)
    min.age <- age.quantile[[ageAtDx.threshold.low + 1]]
    max.age <- age.quantile[[100 - ageAtDx.threshold.hi]]
    
    min.age.refs <- subset(tbl.clinical, ageAtDx <= min.age)$Ref
    stopifnot(all(tbl.clinical[match(min.age.refs, tbl.clinical$Ref), "ageAtDx"] <= min.age))
    min.age.tissues <- unique(tbl.idLookup[match(min.age.refs, tbl.idLookup$btc),]$specimen)
    min.age.tissues <- intersect(min.age.tissues, rownames(mtx.data))

    
    max.age.refs <- subset(tbl.clinical, ageAtDx >= max.age)$Ref
    stopifnot(all(tbl.clinical[match(max.age.refs, tbl.clinical$Ref), "ageAtDx"] >= max.age))
    max.age.tissues <- unique(tbl.idLookup[match(max.age.refs, tbl.idLookup$btc),]$specimen)
    max.age.tissues <- intersect(max.age.tissues, rownames(mtx.data))

      # find the tissues (specimen) ID for all patients with overallSurvival
      # above and below the <threshold> quartile

    overallSurvival <- tbl.clinical$overallSurvival
    overallSurvival[overallSurvival < 0] <- NA

    if(interactive())
        print(fivenum(overallSurvival))

    survival.quantile <- quantile(overallSurvival, seq(0, 1, 0.01), na.rm=TRUE)
    min.survival <- survival.quantile[[overallSurvival.threshold.low + 1]]
    max.survival <- survival.quantile[[100 - overallSurvival.threshold.hi]]

    if(interactive()){
       printf("min ageAtDx,  quantile and actual: %f, %f", min.age, ageAtDx.threshold.low)
       printf("max ageAtDx,  quantile and actual: %f, %f", max.age, ageAtDx.threshold.hi)
       printf("min survival, quantile and actual: %f, %f", min.survival, overallSurvival.threshold.low)
       printf("max survival, quantile and actual: %f, %f", max.survival, overallSurvival.threshold.hi)
       }
    
    min.survival.refs <- subset(tbl.clinical, overallSurvival <= min.survival)$Ref
    stopifnot(all(tbl.clinical[match(min.survival.refs, tbl.clinical$Ref), "overallSurvival"] <= min.survival))
    min.survival.tissues <- unique(tbl.idLookup[match(min.survival.refs, tbl.idLookup$btc),]$specimen)
    min.survival.tissues <- intersect(min.survival.tissues, rownames(mtx.data))

    max.survival.refs <- subset(tbl.clinical, overallSurvival >= max.survival)$Ref
    stopifnot(all(tbl.clinical[match(max.survival.refs, tbl.clinical$Ref), "overallSurvival"] >= max.survival))
    max.survival.tissues <- unique(tbl.idLookup[match(max.survival.refs, tbl.idLookup$btc),]$specimen)
    max.survival.tissues <- intersect(max.survival.tissues, rownames(mtx.data))

    min.survival.tissues <- setdiff(min.survival.tissues, c(min.age.tissues, max.age.tissues))
    max.survival.tissues <- setdiff(max.survival.tissues, c(min.age.tissues, max.age.tissues))

    #if(interactive()){
       printf("=====================================")
       printf("min.age.tissues: %d", length(min.age.tissues))
       printf("max.age.tissues: %d", length(max.age.tissues))
       printf("min.survival.tissues: %d", length(min.survival.tissues))
       printf("max.survival.tissues: %d", length(max.survival.tissues))
    #   } # if interactive

    ordered.tissues <- c(min.age.tissues, max.age.tissues, min.survival.tissues, max.survival.tissues)
    if(length(ordered.tissues) > length(unique(ordered.tissues))) {
        message(sprintf("error in patientQuantileTimesPLSR: tissues classes are not disjoint"))
        return(NA)
        }

    mtx.data <- mtx.data[ordered.tissues,]
    mtx.classify <- matrix(0, nrow(mtx.data), ncol=4,
                           dimnames=list(ordered.tissues,
                               c("Low Age at Dx", "High Age at Dx", "Low Survival", "High Survival")))

    mtx.classify[min.age.tissues,1] <- mtx.classify[min.age.tissues,1]  + 1
    mtx.classify[max.age.tissues,2] <- mtx.classify[max.age.tissues,2]  + 1
    mtx.classify[min.survival.tissues,3] <- mtx.classify[min.survival.tissues,3]  + 1
    mtx.classify[max.survival.tissues,4] <- mtx.classify[max.survival.tissues,4]  + 1
    
       # now elminate doubly classified samples:  we will figure them out later
    more.than.one.category <- as.integer(which(rowSums(mtx.classify) > 1))

    checkEquals(nrow(mtx.data), nrow(mtx.classify))
    checkEquals(rownames(mtx.data), rownames(mtx.classify))

    fit <- plsrAnalysis(mtx.data, mtx.classify)

    gene.coordinates <- fit$loadings[,1:2]
    checkEquals(dim(gene.coordinates), c(ncol(mtx.data), 2))   # comp1, comp2 values for each gene
                                                               # rownames are genes
    vectors <- fit$Yloadings[,1:2]    
    checkEquals(dim(vectors), c(4,2))              # comp1, comp2 values for endpoints of
                                                   # vectors of each classification category
    colnames(gene.coordinates) <- gsub(" ", "", colnames(gene.coordinates))
    colnames(vectors) <- gsub(" ", "", colnames(vectors))
    
    return(list(genes=gene.coordinates, vectors=vectors))

} # patientQuantileTimesPLSR
#----------------------------------------------------------------------------------------------------
patientActualTimesPLSR <- function(ageAtDx.threshold.low,
                                   ageAtDx.threshold.hi,
                                   overallSurvival.threshold.low,
                                   overallSurvival.threshold.hi,
                                   tbl.clinical, tbl.idLookup)
{
      # TODO: validate the thresholds, clamp them to legit if necessary
      # find the tissues (specimen) ID for all patients with ageAtDx
      # above and below the <threshold> quartile

    mtx.data <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup)
    ageAtDiagnosis <- tbl.clinical$ageAtDx
    ageAtDiagnosis[ageAtDiagnosis < 0] <- NA

    if(interactive())
        print(fivenum(ageAtDiagnosis))

        # create 100 quantiles
    #age.quantile <- quantile(ageAtDiagnosis, seq(0, 1, 0.01), na.rm=TRUE)
    #min.age <- age.quantile[[ageAtDx.threshold.low + 1]]
    #max.age <- age.quantile[[100 - ageAtDx.threshold.hi]]

    min.age <- ageAtDx.threshold.low
    max.age <- ageAtDx.threshold.hi
    
    min.age.refs <- subset(tbl.clinical, ageAtDx <= min.age)$Ref
    stopifnot(all(tbl.clinical[match(min.age.refs, tbl.clinical$Ref), "ageAtDx"] <= min.age))
    min.age.tissues <- unique(tbl.idLookup[match(min.age.refs, tbl.idLookup$btc),]$specimen)
    min.age.tissues <- intersect(min.age.tissues, rownames(mtx.data))

    
    max.age.refs <- subset(tbl.clinical, ageAtDx >= max.age)$Ref
    stopifnot(all(tbl.clinical[match(max.age.refs, tbl.clinical$Ref), "ageAtDx"] >= max.age))
    max.age.tissues <- unique(tbl.idLookup[match(max.age.refs, tbl.idLookup$btc),]$specimen)
    max.age.tissues <- intersect(max.age.tissues, rownames(mtx.data))

      # find the tissues (specimen) ID for all patients with overallSurvival
      # above and below the <threshold> quartile

    overallSurvival <- tbl.clinical$overallSurvival
    overallSurvival[overallSurvival < 0] <- NA

    if(interactive())
        print(fivenum(overallSurvival))

    #survival.quantile <- quantile(overallSurvival, seq(0, 1, 0.01), na.rm=TRUE)
    #min.survival <- survival.quantile[[overallSurvival.threshold.low + 1]]
    #max.survival <- survival.quantile[[100 - overallSurvival.threshold.hi]]

    min.survival <- overallSurvival.threshold.low
    max.survival <- overallSurvival.threshold.hi
    
    min.survival.refs <- subset(tbl.clinical, overallSurvival <= min.survival)$Ref
    stopifnot(all(tbl.clinical[match(min.survival.refs, tbl.clinical$Ref), "overallSurvival"] <= min.survival))
    min.survival.tissues <- unique(tbl.idLookup[match(min.survival.refs, tbl.idLookup$btc),]$specimen)
    min.survival.tissues <- intersect(min.survival.tissues, rownames(mtx.data))

    max.survival.refs <- subset(tbl.clinical, overallSurvival >= max.survival)$Ref
    stopifnot(all(tbl.clinical[match(max.survival.refs, tbl.clinical$Ref), "overallSurvival"] >= max.survival))
    max.survival.tissues <- unique(tbl.idLookup[match(max.survival.refs, tbl.idLookup$btc),]$specimen)
    max.survival.tissues <- intersect(max.survival.tissues, rownames(mtx.data))

    min.survival.tissues <- setdiff(min.survival.tissues, c(min.age.tissues, max.age.tissues))
    max.survival.tissues <- setdiff(max.survival.tissues, c(min.age.tissues, max.age.tissues))

    #if(interactive()){
       printf("=====================================")
       printf("min.age.tissues: %d", length(min.age.tissues))
       printf("max.age.tissues: %d", length(max.age.tissues))
       printf("min.survival.tissues: %d", length(min.survival.tissues))
       printf("max.survival.tissues: %d", length(max.survival.tissues))
    #   } # if interactive

    ordered.tissues <- c(min.age.tissues, max.age.tissues, min.survival.tissues, max.survival.tissues)
    if(length(ordered.tissues) > length(unique(ordered.tissues))) {
        message(sprintf("error in patientActualTimesPLSR: tissues classes are not disjoint"))
        return(NA)
        }

    mtx.data <- mtx.data[ordered.tissues,]
    mtx.classify <- matrix(0, nrow(mtx.data), ncol=4,
                           dimnames=list(ordered.tissues,
                               c("Low Age at Dx", "High Age at Dx", "Low Survival", "High Survival")))

    mtx.classify[min.age.tissues,1] <- mtx.classify[min.age.tissues,1]  + 1
    mtx.classify[max.age.tissues,2] <- mtx.classify[max.age.tissues,2]  + 1
    mtx.classify[min.survival.tissues,3] <- mtx.classify[min.survival.tissues,3]  + 1
    mtx.classify[max.survival.tissues,4] <- mtx.classify[max.survival.tissues,4]  + 1
    
       # now elminate doubly classified samples:  we will figure them out later
    more.than.one.category <- as.integer(which(rowSums(mtx.classify) > 1))

    checkEquals(nrow(mtx.data), nrow(mtx.classify))
    checkEquals(rownames(mtx.data), rownames(mtx.classify))

    fit <- plsrAnalysis(mtx.data, mtx.classify)

    gene.coordinates <- fit$loadings[,1:2]
    checkEquals(dim(gene.coordinates), c(ncol(mtx.data), 2))   # comp1, comp2 values for each gene
                                                               # rownames are genes
    vectors <- fit$Yloadings[,1:2]    
    checkEquals(dim(vectors), c(4,2))              # comp1, comp2 values for endpoints of
                                                   # vectors of each classification category
    colnames(gene.coordinates) <- gsub(" ", "", colnames(gene.coordinates))
    colnames(vectors) <- gsub(" ", "", colnames(vectors))
    
    printf("about to leave patientActualTimesPLSR")
    return(list(genes=gene.coordinates, vectors=vectors))

} # patientActualTimesPLSR
#----------------------------------------------------------------------------------------------------
plsrAnalysis <- function(mtx.expression, mtx.categories, numberOfComponents=2)
{
    if(nrow(mtx.expression) != nrow(mtx.categories)){
        message(sprintf("incongruent matrices for plsr, %d vs %d",
                        nrow(mtx.expression), nrow(mtx.categories)))
        return(NA)
        } # in incongruent matrices

    fit <- plsr(mtx.categories ~ mtx.expression, ncomp=numberOfComponents,
                validation="LOO")
    fit

} # plsrAnalysis
#----------------------------------------------------------------------------------------------------
# calculatePLSR <- function(WS, msg)
# {
#     printf("entering calculatePLSR")
#     
#     payload <- fromJSON(msg$payload)
# 
#     print(payload)
# 
#     samples <- payload$samples
#     if(samples == "ALL")
#         samples <- unique(tbl.idLookup$specimen)
# 
#     categories <- payload$categories
#     mtx <- Oncoscape:::cleanupNanoStringMatrix(samples, tbl.nano, tbl.idLookup)
#     mtx.classify <- matrix(0, nrow=length(samples), ncol=4, byrow=TRUE,
#                            dimnames=list(samples,
#                                c("Neural", "Proneural", "Classical", "Mesenchymal")))
#     # experiment with a small set
#     #samples <- samples[sample(1:length(samples), size=10)]
#     where <- match(samples, tbl.idLookup$specimen)
# 
#     classical.samples <- which(tbl.idLookup$dzSubType[where] == "Classical")
#     neural.samples <- which(tbl.idLookup$dzSubType[where] == "Neural")
#     proneural.samples <- which(tbl.idLookup$dzSubType[where] == "Proneural")
#     mesenchymal.samples <- which(tbl.idLookup$dzSubType[where] == "Mesenchymal")
#     mtx.classify[classical.samples, "Classical"] <- 1
#     mtx.classify[neural.samples, "Neural"] <- 1
#     mtx.classify[proneural.samples, "Proneural"] <- 1
#     mtx.classify[mesenchymal.samples, "Mesenchymal"] <- 1
#     
#     #print(names(msg))
#     #print(fromJSON(msg$cmd))
#     #print(fromJSON(msg$status))
#     #print(fromJSON(msg$payload))
#     #cat("sendTimeString")
#     #message("sendTimeString")
#     #return.msg <- toJSON(list(cmd="time", status="result", payload=result))
#     #sendOutput(DATA=return.msg, WS=WS)
#     #printf("after sendOutput of %s (class: %s)", result, class(result))
#    
# }
#----------------------------------------------------------------------------------------------------
