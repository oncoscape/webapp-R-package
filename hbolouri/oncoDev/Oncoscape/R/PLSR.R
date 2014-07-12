#                   incoming message                     function to call                             return.cmd
#                   -------------------                  ----------------                             a-------------
addRMessageHandler("getAgeAtDxAndSurvivalRanges",       "getAgeAtDxAndSurvivalRanges")
addRMessageHandler("calculatePLSRActualPatientTimes",   "calculatePLSRActualPatientTimes.stage")
#addRMessageHandler("calculatePLSR",                     "calculatePLSR")

#----------------------------------------------------------------------------------------------------
getAgeAtDxAndSurvivalRanges <- function(WS, msg)
{
    result <- list(ageAtDxLow=18.03,
                   ageAtDxHigh=89.88,
                   survivalLow=0.23,
                   survivalHigh=82.96)
    
    return.msg <- toJSON(list(cmd="ageAtDxAndSurvivalRanges", status="result", payload=result))

    sendOutput(DATA=return.msg, WS=WS)

} # getAgeAtDxAndSurvivalRanges 
#---------------------------------------------------------------------------------------------------
# 'actual' rather than 'as quantiles' which is how we started (16 apr 2014)
calculatePLSRActualPatientTimes.stage <- function(WS, msg)
{
    payload <- fromJSON(msg$payload)

    ageAtDx.threshold.low <- payload$ageAtDxThresholdLow
    ageAtDx.threshold.hi  <- payload$ageAtDxThresholdHi
    overallSurvival.threshold.low <- payload$overallSurvivalThresholdLow
    overallSurvival.threshold.hi <- payload$overallSurvivalThresholdHi

    result <- patientActualTimesPLSR(ageAtDx.threshold.low,
                                     ageAtDx.threshold.hi,
                                     overallSurvival.threshold.low,
                                     overallSurvival.threshold.hi,
                                     tbl.clinical, tbl.idLookup)
    if(is.na(result)){
        return.msg <- toJSON(list(cmd="plotPLSRPatientTimesResult", status="error",
                                  payload="tissue classes not disjoint"))
        sendOutput(DATA=return.msg, WS=WS)
        return();
        } # is.na (result)

       # genes is an n x 2 matrix, rownames are gene symbols, columns are "Comp 1", "Comp 2"
       # vectors is a 4 x 2 matrix, rownames are the low/hi ageAtDx, low/hi survival

    vectors <- result$vectors
    scale <- 0.8 / max(abs(result$vectors))
    vectors <- vectors * scale
    response.payload <- list(genes=matrixToJSON(result$genes, "gene"),
                             vectors=matrixToJSON(vectors, "vector"))
    
    return.msg <- toJSON(list(cmd="plotPLSRPatientTimesResult", status="result", payload=response.payload))
    sendOutput(DATA=return.msg, WS=WS)
    

} # calculatePLSRPatientTimes.stage
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
plsrAnalysis <- function(mtx.expression, mtx.categories, numberOfComponents=4)
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
