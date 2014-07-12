# test_Data2DProvider.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_constructor()
   test_features()
   test_entities()
   test_getData()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_constructor <- function()
{
    print("--- test_constructor")

    suppressWarnings(dp.bogus <- Data2DProvider("bogus"))
    checkTrue(is.na(dp.bogus))
    
    dp <- Data2DProvider("pkg://tcgaGBM/mrnaGBM.RData")
    checkTrue(is(dp, "Data2DProvider"))
    checkTrue(is(dp, "LocalFileData2DProvider"))


    dp <- Data2DProvider("file://../extdata/tcgaGBM/mrnaGBM.RData")
    checkTrue(is(dp, "Data2DProvider"))
    checkTrue(is(dp, "LocalFileData2DProvider"))


} # test_constructor
#----------------------------------------------------------------------------------------------------
test_features <- function()
{
    print("--- test_features")
    dp <- Data2DProvider("pkg://tcgaGBM/mrnaGBM.RData")
    features <- features(dp)
    checkEquals(head(sort(features)), c("ABL1", "AKT1", "AKT2", "AKT3", "ANAPC1", "ANAPC10"))
    
} # test_features
#----------------------------------------------------------------------------------------------------
test_entities <- function()
{
    print("--- test_entities")
    dp <- Data2DProvider("pkg://tcgaGBM/mrnaGBM.RData")
    entities <- entities(dp)
    checkEquals(head(sort(entities)),
                c("TCGA.02.0001", "TCGA.02.0002", "TCGA.02.0003", "TCGA.02.0004", "TCGA.02.0006", "TCGA.02.0007"))

} # test_entities
#----------------------------------------------------------------------------------------------------
test_getData <- function()
{
    print("--- test_getData")
    dp <- Data2DProvider("pkg://tcgaGBM/mrnaGBM.RData")
    dims <- dimensions(dp)
    checkEquals(dims, c(577, 413))

       # the null test: no specimen or features requested
    tbl.full <- getData(dp)
    checkEquals(dim(tbl.full), c(577, 413))
    
      # small subset
    features <- c("ANAPC1", "ANAPC10")
    entities <- c("TCGA.02.0003", "TCGA.02.0004")

    tbl.2 <- getData(dp, entities, features)

    checkEquals(dim(tbl.2), c(2, 2))
    checkEquals(rownames(tbl.2), entities)
    checkEquals(colnames(tbl.2), features)
    checkEqualsNumeric(sum(as.matrix(tbl.2)), 2.2951, tol=0.0001)
    

} # test_getData
#----------------------------------------------------------------------------------------------------
