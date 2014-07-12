# test_Analyses.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
if (!exists("tbl.nano"))
    Oncoscape:::.loadData()
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test.cleanupClinicalTable()
   test.survivalBoxPlot()
   test.pcaAnalysis()
   test.plsrAnalysis.dzSubType()
   test.plsrAnalysis.patientQuantileTimes()
   test.plsrAnalysis.patientActualTimes()
   test.matrixToJSON()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test.cleanupClinicalTable <- function()
{
    print("--- test.cleanupClinicalTable")
    tbl.clinical <<- Oncoscape:::cleanupClinicalTable(tbl.clinical, tbl.idLookup)
    checkEquals(nrow(tbl.clinical), 226)

} # test.cleanupClinicalTable
#----------------------------------------------------------------------------------------------------
test.survivalBoxPlot <- function()
{
    checkTrue(exists("tbl.clinical2"))
    checkTrue("monthsTo1stProgression" %in% colnames(tbl.clinical2))

       # try first with specified samples
    set.seed(31)
    samples <- sample(tbl.clinical2$tissueID, 30)
    deleters <- grep("NULL", samples)
    if(length(deleters) > 0)
        samples <- samples[-deleters]
    filename <- tempfile(fileext=".png");
    Oncoscape:::survivalBoxPlot(samples, filename)
    checkTrue(file.exists(filename))
    if(interactive())
        system(sprintf("open %s", filename))

       # now try wihout explicit samples.  this leads to a division of the samples
       # at the mean of all monthsTo1stProgression
    
    filename <- tempfile(fileext=".png");
    Oncoscape:::survivalBoxPlot(samples=NA, filename)
    checkTrue(file.exists(filename))

        # visual inspection should show no overlap between two boxes
    if(interactive())
        system(sprintf("open %s", filename))


} # test.survivalBoxPlot
#----------------------------------------------------------------------------------------------------
test.pcaAnalysis <- function()
{
   print("--- test.pcaAnalysis")

   samples.12 <- c("0493.T.1",       "0513.T.1",       "0525.T.2",
                  "0531.T.1",        "0547.C.1",       "0547.T.1",
                  "0576.C.1",        "0576.T.1",       "0585.T.1",
                  "0598.T.1",        "0600.C.1",       "0600.T.1")

   mtx.8 <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup, samples.12, geneList=NA)
       # run with just the rows in mtx, 8/12 sample names are found in tbl.idLookup
   tbl.pca <- Oncoscape:::pcaAnalysis(mtx.8)
   checkTrue(is(tbl.pca, "data.frame"))
   checkEquals(dim(tbl.pca), c(8,4))
   checkEquals(colnames(tbl.pca), c("PC1", "PC2", "sample", "dzSubType"))
   checkTrue(min(as.numeric(as.matrix(tbl.pca[, c(1:2)]))) < -5.0)
   checkTrue(max(as.numeric(as.matrix(tbl.pca[, c(1:2)]))) > 5.0)
   
       # cleanup tbl.nano again, getting all known samples
   samples <- tbl.idLookup$specimen
   mtx.all <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup, samples, geneList=NA)

   tbl.pca <- Oncoscape:::pcaAnalysis(mtx.all)
   checkEquals(ncol(tbl.pca), 4)
   checkTrue(nrow(tbl.pca) > 40)
   checkEquals(colnames(tbl.pca), c("PC1", "PC2", "sample", "dzSubType"))
 
       # now exercise the second (optional) argument, sampleIDs
   mtx.all <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup, samples, geneList=NA)

   samples.subset <- samples[1:100]
   tbl.pca <- Oncoscape:::pcaAnalysis(mtx.all, samples.subset)
   checkEquals(ncol(tbl.pca), 4)
   checkTrue(nrow(tbl.pca) > 40)
   checkEquals(colnames(tbl.pca), c("PC1", "PC2", "sample", "dzSubType"))


      # reproduce a small analysis which fails (12 apr 2014) when called from javascript
   tbl.pca <- Oncoscape:::pcaAnalysis(mtx.all, samples.12)
   checkEquals(ncol(tbl.pca), 4)
   checkTrue(nrow(tbl.pca) > 5)
   checkEquals(colnames(tbl.pca), c("PC1", "PC2", "sample", "dzSubType"))

      # "[250.T.1\",\"349.T.1\",\"480.T.1\"]"
   sample.ids <- c("250.T.1","349.T.1","480.T.1")

   
 } # test.pcaAnalysis
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
test.matrixToJSON <- function()
{
    print("--- test.matrixToJSON")
    values <- c(11, 12, 13, 21, 22, 23)
    m <- matrix(values, nrow=2, byrow=TRUE)
    colnames(m) <- c("col1", "col2", "col3")
    rownames(m) <- c("row1", "row2")
    json <- matrixToJSON(m)    
    x <- fromJSON(json)

    checkTrue(is(x, "list"))
    checkEquals(length(x), nrow(m))
    checkEquals(class(x[[1]][[1]]), class(m[1,1]))

    checkEquals(x[[1]], list(col1=11, col2=12, col3=13, rowname="row1"))
    checkEquals(x[[2]], list(col1=21, col2=22, col3=23, rowname="row2"))

       # now add a category, which should appear as a new 'column' in the returned list

    json <- matrixToJSON(m, "gene")
    x <- fromJSON(json)
    checkEquals(x[[1]], list(col1=11, col2=12, col3=13, rowname="row1", category="gene"))
    checkEquals(x[[2]], list(col1=21, col2=22, col3=23, rowname="row2", category="gene"))
    
    json <- matrixToJSON(m, c("gene", "vector"))
    x <- fromJSON(json)
    checkEquals(x[[1]], list(col1=11, col2=12, col3=13, rowname="row1", category="gene"))
    checkEquals(x[[2]], list(col1=21, col2=22, col3=23, rowname="row2", category="vector"))
    

} # test.matrixToJSON
#----------------------------------------------------------------------------------------------------
