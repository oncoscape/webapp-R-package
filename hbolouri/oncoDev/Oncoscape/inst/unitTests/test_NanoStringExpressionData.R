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
   test.cleanupNanoStringMatrix()
   test.calculateAverageExpression()

} # runTests
#----------------------------------------------------------------------------------------------------
test.cleanupNanoStringMatrix <- function()
{
    print("--- test.cleanupNanoStringMatrix")
    checkEquals(dim(tbl.nano), c (298, 154))
       # check the expression table structure: first few colnames and BTC numbers
    checkEquals(colnames(tbl.nano)[1:5], c("Index", "BTC_ID", "Samples.ID", "B2M", "B4GALT1"))
    checkEquals(as.character(tbl.nano$BTC_ID[1:5]), c("1003-2","1005-1","1007-1","1009-1","1011-1"))

       # check the id mapping table
    checkEquals(dim(tbl.idLookup), c(285, 4))
    checkEquals(colnames(tbl.idLookup), c("specimen", "btc", "expr.id", "dzSubType"))

    checkEquals(as.list(tbl.idLookup[1,]), 
                list(specimen="0440.T.1",
                     btc="440",
                     expr.id="S06.942_workingFolder20110407_HuseNano5",
                     dzSubType="Neural"))

    samples.12 <- c("0493.T.1",       "0513.T.1",       "0525.T.2",
                    "0531.T.1",        "0547.C.1",       "0547.T.1",
                    "0576.C.1",        "0576.T.1",       "0585.T.1",
                    "0598.T.1",        "0600.C.1",       "0600.T.1")

   mtx0 <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup,
                                               sampleIDs=samples.12, geneList=NA)
   checkEquals(dim(mtx0), c(8, 144))

       # can we filter on genes?
   geneList <- c("AQP1", "CDK4", "LTF", "RTN1", "MYCN", "bogusGeneNameToBeIgnored")
   mtx1 <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup,
                                               sampleIDs=samples.12, geneList=geneList)
   checkEquals(dim(mtx1), c(8,5))    
      # spot check one row
    checkEquals(as.numeric(mtx1["0493.T.1",]),
                           c(573.3340, 416.7156, 2893.60715, 1109.4138, 135.38248))

      # get the largest possible matrix
   samples.all <- tbl.idLookup$specimen
   checkEquals(length(samples.all), 285)
   mtx1 <- Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup, sampleIDs=samples.all)
      # with many samples, fewer columns are completely empty, than in mtx0
   checkEquals(dim(mtx1), c(275, 149))

} # test.cleanupNanoStringMatrix
#----------------------------------------------------------------------------------------------------
test.calculateAverageExpression <- function()
{
    print("--- test.calculateAverageExpression")
    tissueIDs <- c("1159.T.1", "1160.T.1", "1184.T.1")
    checkTrue(exists("mtx.nano"))
    mtx.avg <- Oncoscape:::calculateAverageExpression(tissueIDs, mtx.nano)
    checkEquals(dim(mtx.avg), c(1, ncol(mtx.nano)))
        # a simple test on the math
    checkEqualsNumeric(mean(mtx.nano[tissueIDs,]), mean(mtx.avg))
    checkEquals(rownames(mtx.avg), "average")   # the default

        # supply a rowname
    supplied.rowname <- "mean (of 3)"
    mtx.avg <- Oncoscape:::calculateAverageExpression(tissueIDs, mtx.nano, rowname=supplied.rowname)
    checkEquals(dim(mtx.avg), c(1, ncol(mtx.nano)))
    checkEqualsNumeric(mean(mtx.nano[tissueIDs,]), mean(mtx.avg))
    checkEquals(rownames(mtx.avg), supplied.rowname)

        # include an unknown tissueID among some good ones
    tissueIDs <- c("1159.T.1", "1160.T.1", "bogus")
    mtx.avg <- Oncoscape:::calculateAverageExpression(tissueIDs, mtx.nano)
    checkEquals(dim(mtx.avg), c(1, ncol(mtx.nano)))
    checkEqualsNumeric(mean(mtx.nano[tissueIDs[-3],]), mean(mtx.avg))
    
       # only an unknown tissueID
    tissueIDs <- "bogus"
    mtx.avg <- Oncoscape:::calculateAverageExpression(tissueIDs, mtx.nano)
    checkTrue(is.na(mtx.avg))

       # an empty list of tissueIDs
    tissueIDs <- character(0)
    mtx.avg <- Oncoscape:::calculateAverageExpression(tissueIDs, mtx.nano)
    checkTrue(is.na(mtx.avg))

        # not a test, but a demo and reminder:  how this will be used with javascript
        # where there are no matrices
    tissueIDs <- c("1159.T.1", "1160.T.1", "1184.T.1")
        # just 5 genes, so we can look at things
    mtx.avgSmall <- Oncoscape:::calculateAverageExpression(tissueIDs, mtx.nano[, 1:5])
    mj <- matrixToJSON(mtx.avgSmall)
    mj <- gsub("\n", "", mj)
    mj <- gsub("\n", "", mj)
      # "[{ \"B2M\": 1.1474e+05,\"B4GALT1\": 2314.1,\"CLTC\": 4912.8,\"E2F4\": 848.92,\"GAPDH\": 1.016e+05,\"rowname\": \"average\" }]"
    mf <- fromJSON(mj)
      # [[1]]
      # [[1]]$B2M
      # [1] 114740
      # 
      # [[1]]$B4GALT1
      # [1] 2314.1
      # 
      # [[1]]$CLTC
      # [1] 4912.8
      # 
      # [[1]]$E2F4
      # [1] 848.92
      # 
      # [[1]]$GAPDH
      # [1] 101600
      # 
      # [[1]]$rowname
      # [1] "average"

    
} # test.calculateAverageExpression
#----------------------------------------------------------------------------------------------------
