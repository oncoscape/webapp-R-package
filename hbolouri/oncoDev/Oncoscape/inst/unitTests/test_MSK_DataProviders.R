# test_MSK_DataProviders
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_copyNumber_constructor()
   test_copyNumber_entitiesAndFeatures()
   test_copyNumber_getData()

   test_mutation_constructor()
   test_mutation_entitiesAndFeatures()
   test_mutation_getData()
   
   test_mRNA_constructor()
   #test_mRNA_entitiesAndFeatures()
   test_mRNA_getData()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_copyNumber_constructor <- function()
{
    print("--- test_MSK_copyNumber_constructor")

    dp <- DataProvider("MSK_GBM_copyNumber")
    checkTrue(is(dp, "DataProvider"))
    checkTrue(is(dp, "MSK_copyNumber_DataProvider"))

} # test_copyNumber_constructor
#----------------------------------------------------------------------------------------------------
test_copyNumber_entitiesAndFeatures <- function()
{
    print("--- test_copyNumber_entitiesAndFeatures")
    dp <- DataProvider("MSK_GBM_copyNumber")
    rownames <- entities(dp)
    checkEquals(length(rownames), 208)
    checkEquals(head(rownames),
       c("1003.2.T.1", "1007.T.1", "1012.T.1", "1019.1.T.1", "1020.T.1", "1028.T.1"))
    colnames <- features(dp)
    checkEquals(head(colnames), c("CDK4", "CDKN2A", "EGFR", "MDM2", "MET", "NF1"))
    
} # test_copyNumber_entitiesAndFeatures
#----------------------------------------------------------------------------------------------------
test_copyNumber_getData <- function()
{
    print("--- test_copyNumber_getData")
    dp <- DataProvider("MSK_GBM_copyNumber")

    tbl <- getData(dp)
    checkEquals(dim(tbl), c(208, 9))
    checkEquals(sum(tbl$EGFR, na.rm=TRUE), 227)
    
    tbl <- getData(dp, features="EGFR")
    checkEquals(sum(tbl, na.rm=TRUE), 227)

    entities <- c("1003.2.T.1", "1007.T.1", "1012.T.1", "1019.1.T.1", "1020.T.1", "1028.T.1")
    features <- c("CDK4", "CDKN2A", "EGFR", "MDM2", "MET")
    tbl <- getData(dp, entities, features)

    checkEquals(dim(tbl), c(6,5))
    checkEquals(sum(abs(tbl)), 14)
    checkEquals(rownames(tbl), entities)
    checkEquals(colnames(tbl), features)

    all.features <- features(dp)
    tbl.1 <- getData(dp, entities=entities)
    checkEquals(dim(tbl.1), c(6, length(all.features)))

    all.entities <- entities(dp)
    tbl.2 <- getData(dp, features=features)
    checkEquals(dim(tbl.2), c(length(all.entities), 5))

} # test_copyNumber_getData
#----------------------------------------------------------------------------------------------------
test_mutation_constructor <- function()
{
    print("--- test_MSK_mutation_constructor")

    dp <- DataProvider("MSK_GBM_mutation")
    checkTrue(is(dp, "DataProvider"))
    checkTrue(is(dp, "MSK_mutation_DataProvider"))

} # test_mutation_constructor
#----------------------------------------------------------------------------------------------------
test_mutation_entitiesAndFeatures <- function()
{
    print("--- test_mutation_entitiesAndFeatures")
    dp <- DataProvider("MSK_GBM_mutation")
    tissues <- entities(dp)
    checkEquals(length(tissues), 92)
    genes <- features(dp)
    checkEquals(length(genes), 15)
    checkEquals(head(sort(tissues)),
       c("0493.T.1", "0511.T.1", "0518.T.1", "0538.T.1", "0556.T.1", "0561.T.1"))
    checkEquals(head(sort(genes)), c("EGFR", "EPHA6", "ERBB2", "FGFR2", "FGFR3", "IDH1"))
    
} # test_mutation_entitiesAndFeatures
#----------------------------------------------------------------------------------------------------
test_mutation_getData <- function()
{
    print("--- test_mutation_getData")
    dp <- DataProvider("MSK_GBM_mutation")

    tbl <- getData(dp)
    checkEquals(dim(tbl), c(92, 15))
    checkEquals(features(dp),
                c("EGFR","EPHA6","ERBB2","FGFR2","FGFR3","IDH1","IDH2","KIT",
                  "KRAS","NTRK1","PGFRA","PIK3","PIK3CA","PIK3R1","ROR2"))

    checkEquals(head(sort(entities(dp))),
                c("0493.T.1", "0511.T.1", "0518.T.1", "0538.T.1", "0556.T.1", "0561.T.1"))
    
       # look at all the reported mutations for EGFR
    egfr.xtab <- as.list(sort(table(tbl$EGFR), decreasing=TRUE))
    checkEquals(egfr.xtab$L62R, 5)
    checkEquals(egfr.xtab[["S703F R677H R222C"]], 2)


       # get counts for each mutation
    counts <- head(as.list(sort(sapply(colnames(tbl),
                                       function(column)
                                          length(which(!is.na(tbl[,column])))), decreasing=TRUE)))

    checkEquals(counts$EGFR, 37)
    checkEquals(counts$IDH1, 37)
    checkEquals(counts$PIK3CA, 17)

       # get a few values with specificity
    checkTrue(is.na(getData(dp, entities="1007.T.1", features="NTRK1")))
    checkEquals(getData(dp, entities="1159.T.1", features="NTRK1"), "V420M")

      # get all mutations for 1039.T.1
    tissue <- "1039.T.1"
    muts <- as.list(getData(dp, entities=tissue))
    realmuts <- as.list(muts[-(which(is.na(muts)))])
    checkEquals(realmuts, list(IDH1="R132G",
                               PIK3CA="H1047R"))
    
} # test_mutation_getData
#----------------------------------------------------------------------------------------------------
test_mRNA_constructor <- function()
{
    print("--- test_MSK_mRNA_constructor")

    dp <- DataProvider("MSK_GBM_mRNA")
    checkTrue(is(dp, "DataProvider"))
    checkTrue(is(dp, "MSK_GBM_mRNA_DataProvider"))
   
} # test_mutation_constructor
#----------------------------------------------------------------------------------------------------
test_mRNA_getData <- function()
{
    print("--- test_MSK_mRNA_getData")

    dp <- DataProvider("MSK_GBM_mRNA")

    mtx <- getData(dp)
    checkEquals(dim(mtx), c (275, 149))

    first.tissues <- c("0440.T.1","0445.T.1", "0486.T.1", "0493.T.1", "0506.T.1", "0509.T.1")
    checkEquals(head(rownames(mtx)), first.tissues)

    first.genes <-  c("B2M", "B4GALT1", "CLTC", "E2F4", "GAPDH", "POLR2A")
    checkEquals(head(colnames(mtx)), first.genes)
    
    checkEqualsNumeric(min(mtx), -1.820105, tol=1e-5)
    checkEqualsNumeric(max(mtx), 16.39079,  tol=1e-5)

    checkEquals(dim(getData(dp, entities=first.tissues, features=first.genes)),
                c(6,6))
   
} # test_mutation_constructor
#----------------------------------------------------------------------------------------------------
