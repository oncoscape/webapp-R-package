# test_TCGA_DataProviders
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_mrna_constructor()
   test_mrna_entitiesAndFeatures ()
   test_mrna_getData()
   
   test_copyNumber_constructor()
   test_copyNumber_entitiesAndFeatures()
   test_copyNumber_getData()
   
   test_mutation_constructor()
   test_mutation_entitiesAndFeatures()
   test_mutation_getData()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_mrna_constructor <- function()
{
    print("--- test_TCGA_mrna_constructor")

    dp <- DataProvider("TCGA_GBM_mRNA")
    checkTrue(is(dp, "DataProvider"))
    checkTrue(is(dp, "TCGA_GBM_mRNA_DataProvider"))

} # test_constructor
#----------------------------------------------------------------------------------------------------
test_mrna_entitiesAndFeatures <- function()
{
    print("--- test_mrna_entitiesAndFeatures")
    dp <- DataProvider("TCGA_GBM_mRNA")
    rownames <- entities(dp)
    checkEquals(length(rownames), 577)
    checkEquals(head(rownames),
       c("TCGA.02.0001","TCGA.02.0002","TCGA.02.0003","TCGA.02.0004","TCGA.02.0006","TCGA.02.0007"))
    colnames <- features(dp)
    checkEquals(head(colnames), c("ABL1", "AKT1", "AKT2", "AKT3", "ANAPC1", "ANAPC10"))
    
} # test_mrna_entitiesAndFeatures
#----------------------------------------------------------------------------------------------------
test_mrna_getData <- function()
{
    print("--- test_mrna_getData")
    dp <- DataProvider("TCGA_GBM_mRNA")

    entities <- c("TCGA.02.0001","TCGA.02.0002","TCGA.02.0003")
    features <- c("ABL1", "AKT1", "AKT2")

    mtx.0 <- getData(dp, entities, features)
    checkEquals(dim(mtx.0), c(3,3))
    checkEqualsNumeric(sum(mtx.0), 3.94, tol=0.02)    
    checkEquals(rownames(mtx.0), entities)
    checkEquals(colnames(mtx.0), features)

    all.features <- features(dp)
    mtx.1 <- getData(dp, entities=entities)
    checkEquals(dim(mtx.1), c(3, length(all.features)))

    all.entities <- entities(dp)
    mtx.2 <- getData(dp, features=features)
    checkEquals(dim(mtx.2), c(length(all.entities), 3))

} # test_mrna_getData
#----------------------------------------------------------------------------------------------------
test_copyNumber_constructor <- function()
{
    print("--- test_TCGA_copyNumber_constructor")

    dp <- DataProvider("TCGA_GBM_copyNumber")
    checkTrue(is(dp, "DataProvider"))
    checkTrue(is(dp, "TCGA_GBM_copyNumber_DataProvider"))

} # test_copyNumber_constructor
#----------------------------------------------------------------------------------------------------
test_copyNumber_entitiesAndFeatures <- function()
{
    print("--- test_copyNumber_entitiesAndFeatures")
    dp <- DataProvider("TCGA_GBM_copyNumber")
    rownames <- entities(dp)
    checkEquals(length(rownames), 577)
    checkEquals(head(rownames),
       c("TCGA.02.0001","TCGA.02.0002","TCGA.02.0003","TCGA.02.0004","TCGA.02.0006","TCGA.02.0007"))
    colnames <- features(dp)
    checkEquals(head(colnames), c("ABL1", "AKT1", "AKT2", "AKT3", "ANAPC1", "ANAPC10"))


    
    
} # test_copyNumber_entitiesAndFeatures
#----------------------------------------------------------------------------------------------------
test_copyNumber_getData <- function()
{
    print("--- test_copyNumber_getData")
    dp <- DataProvider("TCGA_GBM_copyNumber")

    mtx <- getData(dp)
    checkEquals(dim(mtx), c(577, 413))
    checkEquals(sum(mtx$PDGFRA, na.rm=TRUE), 52)
    
    mtx <- getData(dp, features="PDGFRA")
    checkEquals(sum(mtx, na.rm=TRUE), 52)

    entities <- c("TCGA.02.0001","TCGA.02.0002","TCGA.02.0003")
    features <- c("ABL1", "AKT1", "AKT2", "PDGFRA", "TP53")
    mtx <- getData(dp, entities, features)

    checkEquals(dim(mtx), c(3,5))
    checkEquals(sum(mtx, na.rm=TRUE), 0)
    checkEquals(rownames(mtx), entities)
    checkEquals(colnames(mtx), features)

    all.features <- features(dp)
    mtx.1 <- getData(dp, entities=entities)
    checkEquals(dim(mtx.1), c(3, length(all.features)))

    all.entities <- entities(dp)
    mtx.2 <- getData(dp, features=features)
    checkEquals(dim(mtx.2), c(length(all.entities), 5))

       # add some bogus entries, make sure they do not appear in the result
    entities <-  c("TCGA.02.0003","TCGA.02.0004","bogus patient");
    features <-  c("AKT1", "bogus gene", "AKT3")
    
    mtx.3 <- getData(dp, entities=entities, features=features)
    checkEquals(dim(mtx.3), c(2,2))
    checkEquals(rownames(mtx.3), c("TCGA.02.0003","TCGA.02.0004"))
    checkEquals(colnames(mtx.3), c("AKT1", "AKT3"))

} # test_copyNumber_getData
#----------------------------------------------------------------------------------------------------
test_mutation_constructor <- function()
{
    print("--- test_TCGA_mutation_constructor")

    dp <- DataProvider("TCGA_GBM_mutation")
    checkTrue(is(dp, "DataProvider"))
    checkTrue(is(dp, "TCGA_GBM_mutation_DataProvider"))

} # test_mutation_constructor
#----------------------------------------------------------------------------------------------------
test_mutation_entitiesAndFeatures <- function()
{
    print("--- test_mutation_entitiesAndFeatures")
    dp <- DataProvider("TCGA_GBM_mutation")
    rownames <- entities(dp)
    checkEquals(length(rownames), 577)
    checkEquals(head(rownames),
       c("TCGA.02.0001","TCGA.02.0002","TCGA.02.0003","TCGA.02.0004","TCGA.02.0006","TCGA.02.0007"))
    colnames <- features(dp)
    checkEquals(head(colnames), c("ABL1", "AKT1", "AKT2", "AKT3", "ANAPC1", "ANAPC10"))
    
} # test_mutation_entitiesAndFeatures
#----------------------------------------------------------------------------------------------------
test_mutation_getData <- function()
{
    print("--- test_mutation_getData")
    dp <- DataProvider("TCGA_GBM_mutation")

    mtx <- getData(dp)
    checkEquals(dim(mtx), c(577, 413))
    pdgfra.muts <- mtx$PDGFRA
    wildtype <- which(is.na(pdgfra.muts))
    mutations <- pdgfra.muts[-wildtype]
    checkEquals(mutations, c("W349C", "C235Y", "V536E,V536E,V536E"))
    
    entities <- c("TCGA.02.0001","TCGA.02.0002","TCGA.02.0003")
    features <- c("ABL1", "AKT1", "AKT2", "PDGFRA", "TP53")
    mtx <- getData(dp, entities, features)

    checkEquals(dim(mtx), c(3,5))
    checkEquals(rownames(mtx), entities)
    checkEquals(colnames(mtx), features)

    all.features <- features(dp)
    mtx.1 <- getData(dp, entities=entities)
    checkEquals(dim(mtx.1), c(3, length(all.features)))

    all.entities <- entities(dp)
    mtx.2 <- getData(dp, features=features)
    checkEquals(dim(mtx.2), c(length(all.entities), 5))

} # test_mutation_getData
#----------------------------------------------------------------------------------------------------
