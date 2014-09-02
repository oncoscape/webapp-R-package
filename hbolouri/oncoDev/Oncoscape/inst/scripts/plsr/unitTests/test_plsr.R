library(Oncoscape)
library(RUnit)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
    startOncoscape()
    test_oliveOilExampleFromManPage()
    test_createClassificationMatrix()
    demo.with.tcga.gbm.data()
    
} # runTests
#----------------------------------------------------------------------------------------------------
# create an oncoscape instance, providing access to manifest-specified data, but do not start
# the websockets server
startOncoscape <- function()
{
   print("--- startOncoscape")
   
   manifest.file <- "manifest.txt"
   onco <- Oncoscape(htmlFile=NA, port=7654L, mode="websockets", openBrowser=FALSE, manifest.file)
   checkEquals(sort(ls(Oncoscape:::DATA.PROVIDERS)), c("cnv", "mRNA", "mut", "patientClassification",
                                                       "patientHistoryTable"))
   tbl.mrna <<- getData(Oncoscape:::DATA.PROVIDERS[["mRNA"]])
   tbl.ptclass <<- getData(Oncoscape:::DATA.PROVIDERS[["patientClassification"]])
   #tbl.pt <<- getData(Oncoscape:::DATA.PROVIDERS[["patientHistoryTable"]])

   patientHistoryProvider <- Oncoscape:::DATA.PROVIDERS$patientHistoryTable
   tbl.ptHis <<- getTable(patientHistoryProvider)

} # startOncoscape
#----------------------------------------------------------------------------------------------------
test_oliveOilExampleFromManPage <- function()
{
    print("--- test_oliveOilExampleFromManPage")
    # oliveoil:      A data set with scores on 6 attributes from a sensory panel and
    #  measurements of 5 physico-chemical quality parameters on 16 olive
    # oil samples.  The first five oils are Greek, the next five are
    # Italian and the last six are Spanish.
    # very odd data structure here.  dataframe with dim 16 x 2, but each column is apparently itself a
    # data.frame or matrix,  hidden within an AsIs type:
    # colnames(oliveoil)
    # [1] "chemical" "sensory" 
    # oliveoil$chemical
    #   Acidity Peroxide  K232   K270     DK
    #G1    0.73    12.70 1.900 0.1390  0.003
    #G2    0.19    12.30 1.678 0.1160 -0.004
    #G3    0.26    10.30 1.629 0.1160 -0.005

    data(oliveoil)   # 16 x 2 matrix
    x <- plsr(sensory ~ chemical, ncomp = 4, scale = TRUE, data = oliveoil)
      # first two components make for good xy plot, and probably (how to check?) explain most
      # of the variance
    loadings12 <- x$loadings[, 1:2]
    yLoadings12 <- x$Yloadings[, 1:2]
    checkEquals(dim(loadings12), c(5,2))
    checkEquals(dim(yLoadings12), c(6,2))

    checkEquals(rownames(x$Yloadings[, 1:2]), c("yellow", "green", "brown","glossy", "transp", "syrup"))
    checkEquals(rownames(x$loadings[, 1:2]), c("Acidity",  "Peroxide", "K232", "K270", "DK"))

} # test_oliveOilExampleFromManPage
#----------------------------------------------------------------------------------------------------
demo.with.tcga.gbm.data <- function()
{
   print("--- demo.with.tcga.gbm.data")
    
   stopifnot(exists("tbl.mrna"))
   stopifnot(exists("tbl.ptHis"))
   checkEquals(fivenum(tbl.ptHis$ageAtDx), c(10, 50, 59, 68, 89))
   checkEquals(fivenum(tbl.ptHis$survival), c(0.010, 0.415, 0.980, 1.595, 10.630))

   ageAtDx.lo <- 40
   ageAtDx.hi <- 60
   survival.lo <- 2.0
   survival.hi <- 3

   mtx.classify <- createClassificationMatrix(tbl.ptHis, ageAtDx.lo, ageAtDx.hi, survival.lo, survival.hi)
   print(colSums(mtx.classify))
   mtx.mrna <- as.matrix(tbl.mrna)
   mtx.classify <- mtx.classify[rownames(mtx.mrna),]
   set.seed(17)
   random.samples <- sample(1:ncol(mtx.mrna), 1000)
   fit <- plsr(mtx.classify ~ mtx.mrna[,random.samples], ncomp=4, scale=TRUE,validation="LOO")
   browser()
   x <- 99
    #fit <- plsr(mtx.categories ~ mtx.mrna, ncomp=numberOfComponents,  validation="LOO")
    #fit

} # demo.with.tcga.gbm.data
#----------------------------------------------------------------------------------------------------
test_createClassificationMatrix <- function()
{
   print("--- test_createClassificationMatrix")
   ageAtDx.lo <- 30
   ageAtDx.hi <- 80
   survival.lo <- 0.2
   survival.hi <- 5

   mtx.classify <- createClassificationMatrix(tbl.ptHis, ageAtDx.lo, ageAtDx.hi, survival.lo, survival.hi)
   checkEquals(dim(mtx.classify), c(583, 4))

      # with the thresholds specified above, only 96 tissues are included
   checkEquals(length(which(rowSums(mtx.classify) > 0)), 96)
   checkEquals(as.list(colSums(mtx.classify)),
               list(ageAtDxLow=27, ageAtDxHigh=24, survivalLow=41, survivalHigh=13))
   
   #browser();
   #x <- 99

} # test_createClassificationMatrix
#----------------------------------------------------------------------------------------------------
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
test.plsrAnalysis.dzSubType <- function()
{
    print("--- test.plsrAnalysis.dzSubType")
    neural.specimens      <- unique(subset(tbl.idLookup, dzSubType=="Neural")$specimen)[1:4]
    proneural.specimens   <- unique(subset(tbl.idLookup, dzSubType=="Proneural")$specimen)[1:4]
    classical.specimens   <- unique(subset(tbl.idLookup, dzSubType=="Classical")$specimen)[1:4]
    mesenchymal.specimens <- unique(subset(tbl.idLookup, dzSubType=="Mesenchymal")$specimen[1:4])

    specimens.all <- c(neural.specimens, proneural.specimens,
                       classical.specimens, mesenchymal.specimens)

    mtx.classify <- matrix(0, nrow=16, ncol=4, byrow=TRUE,
                           dimnames=list(specimens.all,
                               c("Neural", "Proneural", "Classical", "Mesenchymal")))
    mtx.classify [1:4,   1] <- 1
    mtx.classify [5:8,   2] <- 1
    mtx.classify [9:12,  3] <- 1
    mtx.classify [13:16, 4] <- 1
    
    mtx <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup, specimens.all)
    checkEquals(dim(mtx), c(16, 144))

    fit <- Oncoscape:::plsrAnalysis(mtx, mtx.classify)
    checkEquals(names(fit),
            c("coefficients", "scores",      "loadings", "loading.weights", "Yscores",
              "Yloadings",    "projection",  "Xmeans",   "Ymeans",          "fitted.values",
              "residuals",    "Xvar",        "Xtotvar",  "fit.time",        "ncomp",
              "method",       "validation",  "call",     "terms",           "model"))
 
    gene.coordinates <- fit$loadings[,1:2]
    checkEquals(dim(gene.coordinates), c(144,2))   # comp1, comp2 values for each gene
                                                   # rownames are genes
    vectors <- fit$Yloadings[,1:2]    
    checkEquals(dim(vectors), c(4,2))              # comp1, comp2 values for endpoints of
                                                   # vectors of each classification category
                                                   # rownames are category names
    #checkEquals(dim(gene.coordinates), c(,))
    if(interactive())
         biplot(gene.coordinates, vectors, col=c("black","red"),cex=c(0.5,1))
         #biplot(fit$loadings[,1:2], fit$Yloadings[,1:2], col=c("gray","red"),cex=c(0.5,1))

} # test.plsrAnalysis.dzSubType
#----------------------------------------------------------------------------------------------------
test.plsrAnalysis.patientQuantileTimes <- function()
{
    print("--- test.plsrAnalysis.patientQuantileTimes")

      # variables, column names in tbl.clinical
      #   ageAtDx:         -11.28219  51.05205  60.36301  67.73699  89.88493
      #   overallSurvival:  -1.314168   9.297741  15.293634  24.476386 133.683778

    ageAtDx.threshold.low <- 3         
    ageAtDx.threshold.hi <- 2          
    overallSurvival.threshold.low <- 2
    overallSurvival.threshold.hi <- 3
                                
    result.1 <- Oncoscape:::patientQuantileTimesPLSR(ageAtDx.threshold.low,
                                             ageAtDx.threshold.hi,
                                             overallSurvival.threshold.low,
                                             overallSurvival.threshold.hi,
                                             tbl.clinical, tbl.idLookup)
    checkEquals(names(result.1), c("genes", "vectors"))
    checkEquals(length(result.1$genes), nrow(tbl.nano))

        # CHI3L1 is the most variable gene in the nanostring set.  check its pls coordinates
    checkEquals(as.numeric(result.1$genes["CHI3L1",]), c(-0.9660069, 0.004154921))
    
    if(interactive())
         biplot(result.1$genes, result.1$vectors, col=c("black","red"),cex=c(0.5,1),
                main="1) test.plsrAnalysis.patientQuantileTimes")

    ageAtDx.threshold.low <- 30
    ageAtDx.threshold.hi <- 20        
    overallSurvival.threshold.low <- 15
    overallSurvival.threshold.hi <- 20
                                
    result.2 <- Oncoscape:::patientQuantileTimesPLSR(ageAtDx.threshold.low,
                                             ageAtDx.threshold.hi,
                                             overallSurvival.threshold.low,
                                             overallSurvival.threshold.hi,
                                             tbl.clinical, tbl.idLookup)
    checkEquals(names(result.2), c("genes", "vectors"))
    checkEquals(length(result.2$genes), nrow(tbl.nano))
    checkEqualsNumeric(result.2$genes["CHI3L1", "Comp1"], -0.4955452, tol=10e-5)
    checkEqualsNumeric(result.2$genes["CHI3L1", "Comp2"], -0.5791781, tol=10e-5)

    if(interactive())
         biplot(result.2$genes, result.2$vectors, col=c("black","red"),cex=c(0.5,1),
                main="2) test.plsrAnalysis.patientQuantileTimes")



} # test.plsrAnalysis.patientQuantileTimes
#----------------------------------------------------------------------------------------------------
test.plsrAnalysis.patientActualTimes <- function()
{
    print("--- test.plsrAnalysis.patientActualTimes")

      # 4 small sets, with quantile boundares of 3 and 2, actual ages you can see
      # min ageAtDx,  quantile and actual: 29.898849, 3.000000
      # max ageAtDx,  quantile and actual: 80.782466, 2.000000
      # min survival, quantile and actual: 1.609856, 2.000000
      #max survival, quantile and actual: 58.119097, 3.000000



      # variables, column names in tbl.clinical
      #   ageAtDx:         -11.28219  51.05205  60.36301  67.73699  89.88493
      #   overallSurvival:  -1.314168   9.297741  15.293634  24.476386 133.683778

    ageAtDx.threshold.low <- 29.898849
    ageAtDx.threshold.hi <- 80.782466
    overallSurvival.threshold.low <- 1.609856
    overallSurvival.threshold.hi <- 58.119097
                                
    result.1 <- Oncoscape:::patientActualTimesPLSR(ageAtDx.threshold.low,
                                             ageAtDx.threshold.hi,
                                             overallSurvival.threshold.low,
                                             overallSurvival.threshold.hi,
                                             tbl.clinical, tbl.idLookup)
    checkEquals(names(result.1), c("genes", "vectors"))
    checkEquals(length(result.1$genes), nrow(tbl.nano))

        # CHI3L1 is the most variable gene in the nanostring set.  check its pls coordinates
    checkEquals(as.numeric(result.1$genes["CHI3L1","Comp1"]), -0.95,  tolerance=0.1)
    #checkEquals(as.numeric(result.1$genes["CHI3L1","Comp2"]), -0.06,  tolerance=0.01)
    
    if(interactive())
         biplot(result.1$genes, result.1$vectors, col=c("black","red"),cex=c(0.5,1),
                main="1) test.plsrAnalysis.patientActualTimes")

      # 4 larger sets, with quantile boundares of 3 and 2, actual ages you can see
      # min ageAtDx,  quantile and actual: 53.098630, 30.000000
      # max ageAtDx,  quantile and actual: 68.019288, 20.000000
      # min survival, quantile and actual: 6.472279, 15.000000
      # max survival, quantile and actual: 26.442382, 20.000000


    ageAtDx.threshold.low <- 53
    ageAtDx.threshold.hi <- 68       
    overallSurvival.threshold.low <- 6
    overallSurvival.threshold.hi <- 26
                                
    result.2 <- Oncoscape:::patientActualTimesPLSR(ageAtDx.threshold.low,
                                             ageAtDx.threshold.hi,
                                             overallSurvival.threshold.low,
                                             overallSurvival.threshold.hi,
                                             tbl.clinical, tbl.idLookup)
    checkEquals(names(result.2), c("genes", "vectors"))
    checkEquals(length(result.2$genes), nrow(tbl.nano))
    #checkEqualsNumeric(result.2$genes["CHI3L1", "Comp1"], -0.4955452, tol=10e-5)
    #checkEqualsNumeric(result.2$genes["CHI3L1", "Comp2"], -0.5791781, tol=10e-5)

    if(interactive())
         biplot(result.2$genes, result.2$vectors, col=c("black","red"),cex=c(0.5,1),
                main="2) test.plsrAnalysis.patientActualTimes")

} # test.plsrAnalysis.patientActualTimes
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
