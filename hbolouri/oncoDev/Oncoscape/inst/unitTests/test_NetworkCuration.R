# test_NetworkCuration.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
    if(!exists("refnet"))
       test_createRefNet()
    
    test_getRefNetProviders()
    #test_simplification()
    test_simplification_1psicquic_interaction_only()
    test_multipleGenes()
    test_parsePublicationIDs()
    
} # runTests
#----------------------------------------------------------------------------------------------------
test_createRefNet <- function()
{
    print("--- test_createRefNet")
    printf("RefNet creation time: %f", as.list(system.time((refnet <- RefNet())))$elapsed);
    refnet <<- refnet

} # test_createRefNet
#----------------------------------------------------------------------------------------------------
test_getRefNetProviders <- function()
{
   print("--- test_getRefNetProviders")
   providers <- Oncoscape:::getRefNetProviders()
   checkEquals(sort(tolower(names(providers))), c("native", "psicquic"))
   checkTrue(length(unlist(providers, use.names=FALSE)) > 20)
       
} # test_providers
#----------------------------------------------------------------------------------------------------
# MGMT is a human base excision repair gene
test_simplification <- function()
{
    print("--- test_simplification")
    if(!exists("refnet"))
       test_createRefNet()
    
    providers <- c("gerstein-2012", "BIND", "Reactome-FIs", "STRING")
    available.providers <- unlist(providers(refnet), use.names=FALSE)
    
    if(all(providers %in% available.providers)){
       tbl <- interactions(refnet, id="MGMT", provider=providers, species="9606")
       checkEquals(ncol(tbl), 28)
       checkTrue(nrow(tbl) > 280)
       tbl.2 <- Oncoscape:::simplifyRefNetTable(tbl)
       checkEquals(dim(tbl.2), c(285,8))
       checkEquals(colnames(tbl.2),
                c("A.name", "B.name", "type", "detectionMethod", "publicationID", "provider", "A.id", "B.id"))
       printf("--- TODO: gerstein A.sym not transfered to A.name");
       # checkTrue(! "-" %in% tbl.2$A.name)
       } # if gerstein-2012, BIND & Reactome-FIs are all available, which should be most of the time    
    else{
       printf("some providers not available: %s",
              paste(setdiff(providers, providers(refnet)), collapse=","))
       }


} # test_simplification
#----------------------------------------------------------------------------------------------------
test_simplification.intact <- function()
{
    print("--- test_simplification.intact")
    if(!exists("refnet"))
       test_createRefNet()
    
    providers <- "gerstein-2012"
    providers <- "IntAct"
    available.providers <- unlist(providers(refnet), use.names=FALSE)
    
    checkTrue(all(providers %in% available.providers))

    gene <- "HMGB1"
    tbl <- interactions(refnet, id=gene, provider=providers, species="9606")
    tbl.2 <- Oncoscape:::simplifyRefNetTable(tbl[1,])

    coi <-  c("A.name", "B.name")
    
    all.names <- unlist(c(tbl.2 [, coi]), use.names=FALSE)
    checkEquals(length(all.names), nrow(tbl.2) * 2)
    
    checkTrue(length(unique(all.names)) > 200)
       # valid gene symbols are usually 3-8 characters long
    average.length <- mean(unlist(lapply(unique(all.names), nchar)))
    checkTrue(average.length > 3)
    checkTrue(average.length < 8)

    mgmt.count <- length(grep("MGMT", all.names))
       # most (should be all) rows have MGMT as A.name or B.name                              
    checkTrue(mgmt.count > (0.9 * nrow(tbl.2)))
   
} # test_simplification.intact
#----------------------------------------------------------------------------------------------------
# this test exposed the case where [AB].[common|canonical] columns are not present
# which violated the original expectation of "simplifyRefNetTable"
test_simplification_1psicquic_interaction_only <- function()
{
    print("--- test_simplification_1psicquic_interaction_only")
    if(!exists("refnet"))
       test_createRefNet()
    
    providers <- c("Reactome-FIs")
    available.providers <- unlist(providers(refnet), use.names=FALSE)
    
    if(all(providers %in% available.providers)){
       tbl <- interactions(refnet, id="MGMT", provider=providers, species="9606")
       checkEquals(nrow(tbl), 1)
       tbl.2 <- Oncoscape:::simplifyRefNetTable(tbl)
       checkEquals(dim(tbl.2), c(1,8))
       checkEquals(colnames(tbl.2),
                c("A.name", "B.name", "type", "detectionMethod", "publicationID", "provider", "A.id", "B.id"))
       } # if gerstein-2012, BIND & Reactome-FIs are all available, which should be most of the time    
    else{
       printf("some providers not available: %s",
              paste(setdiff(providers, providers(refnet)), collapse=","))
       }

} # test_simplification_1psicquic_interaction_only
#----------------------------------------------------------------------------------------------------
test_multipleGenes <- function ()
{

      # vegfa has interactions with pgf and u2af1 in mentha, thus a good test
    genes <- c("VEGFA", "PGF", "U2AF1", "");
    empty <- which(lapply(genes, nchar) == 0)
    if (length(empty) > 0)
        genes <- genes[empty];
    
    genes <- c("VEGFA", "PGF", "U2AF1");
    tbl <- interactions(refnet, id=genes, provider="mentha", species="9606");
    tbl <- Oncoscape:::simplifyRefNetTable(tbl)
    checkTrue(ncol(tbl) >= 8)
    checkTrue(nrow(tbl) >= 4)

} # test_multipleGenes
#----------------------------------------------------------------------------------------------------
test_parsePublicationIDs <- function()
{

   id.0 <- "-"
   id.1 <- "22955619"
   id.2 <- "pubmed:08573590"
   id.3 <- "pubmed:00127891|pubmed:20477829"
   id.4 <- "pubmed:01300807|pubmed:01384961|pubmed:01394130"
   id.5 <- "omim:00137800"
   id.6 <- "omim:00137800|pubmed:01501894|pubmed:08615613"
   id.7 <- "omim:00137800|pubmed:17437278"
   id.8 <- "omim:00156569|omim:00300329|pubmed:09849428"

   parse <- Oncoscape:::parsePublicationIDs
   #parse <- parsePublicationIDs

   checkEquals(parse(id.0), "")
   checkEquals(parse(id.1), id.1)
   checkEquals(parse(id.2), "08573590")
   checkEquals(parse(id.3), "00127891,20477829")
   checkEquals(parse(id.4), "01300807,01384961,01394130")
   checkEquals(parse(id.5), "")
   checkEquals(parse(id.6), "01501894,08615613")
   checkEquals(parse(id.7), "17437278")


} # test_parsePublicationIDs
#----------------------------------------------------------------------------------------------------
exploreLongStartupAndExecutionTimes <- function() {
    op <- options(digits.secs = 6)
    print(Sys.time())
    psicquic <- PSICQUIC()
    print(Sys.time())
    print(system.time((ah <- AnnotationHub())))
    print(system.time((filters(ah) <- list(DataProvider = "RefNet"))))
    print(system.time((tbl.refnet <- metadata(ah))))
    pathnames <- sub("refnet/", "refnet.", tbl.refnet$RDataPath)
    pathnames <- sub("-", ".", pathnames)
    print(Sys.time())
    titles <- sub("interactions from ", "", tbl.refnet$Title)
    print(Sys.time())
    refnet.tables <- vector("list", length = length(pathnames))
    print(Sys.time())
    for (i in seq_len(length(pathnames))) {
        pathname <- pathnames[[i]]
        printf("pathname: %s", pathname)
        print(system.time(tbl <- ah[[pathname]]))
        refnet.tables[[i]] <- tbl
        }
    print(Sys.time())
    names(refnet.tables) <- titles
    print(Sys.time())
    object <- RefNet:::.RefNet()
    print(Sys.time())
    object@psicquic <- psicquic
    print(Sys.time())
    object@sources <- refnet.tables
    print(Sys.time())
    object@providers <- list(native = names(object@sources), PSICQUIC = providers(psicquic))
    print(Sys.time())
    object

} # exploreLongStartupAndExecutionTimes
#----------------------------------------------------------------------------------------------------

#Rprof("test.prof", memory.profiling=FALSE, interval=0.001)
#o <- hack()
#Rprof(NULL)
#summaryRprof("test.prof")

# "local"                                   1.240     58.96     0.000     0.00
# "load"                                    1.239     58.92     1.239    58.92
# "gc"                                      0.287     13.65     0.287    13.65
# the bottlenecks:
# system.time((filters(ah) <- list(DataProvider = "RefNet")))
#    user  system elapsed 
#   0.038   0.001   3.920 

# [1] pathname: refnet.stamlabTFs.2012.tsv_0.0.1.RData
#    user  system elapsed 
#   3.104   0.032   3.499 
# [1] pathname: refnet.gerstein.2012.tsv_0.0.1.RData
#   user  system elapsed 
#  0.075   0.001   0.455 
#[1] pathname: refnet.hypoxiaSignaling.2006.tsv_0.0.1.RData
#   user  system elapsed 
#  0.028   0.000   0.395 
#[1] pathname: refnet.stamlabTFs.2012.tsv_0.0.1.RData
#   user  system elapsed 
#  3.104   0.032   3.499 
#[1] pathname: refnet.recon202.tsv_0.0.1.RData
#   user  system elapsed 
#  0.412   0.004   0.774 
#   user  system elapsed 
#  6.893   0.147  14.793 

# summarized? filters: 4 seconds
#             total for files: 7 seconds
#                stamlab: 3.5 seconds
#                other files: 1.5 seconds
#            PSICQUIC: 0.5
#            unaccounted for: 2 seconds 


