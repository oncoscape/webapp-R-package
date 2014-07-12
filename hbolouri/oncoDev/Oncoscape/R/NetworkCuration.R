addRMessageHandler("fetchInteractions", "fetchInteractions");
addRMessageHandler("fetchRefNetProviders", "fetchRefNetProviders");
addRMessageHandler("initializeNetworkCurationServices", "initializeNetworkCurationServices");
addRMessageHandler("fetchPubmedAbstract", "fetchPubmedAbstract");
addRMessageHandler("prepNewCyjsInteractions", "prepNewCyjsInteractions");
#---------------------------------------------------------------------------------------------------
initializeNetworkCurationServices <- function(WS, msg)
{
   printf("===== entering initializeNetworkCurationServices")
   
   if(!exists("refnet")){
      printf("=== creating RefNet()");
      refnet <<- RefNet()
      }

} # initializeNetworkCurationServices
#---------------------------------------------------------------------------------------------------
fetchInteractions <- function(WS, msg)
{
    printf("------ entering fetchInteractions");
    print(msg)
    genes <- msg$payload$genes
    providers <- msg$payload$providers
    tbl <- getInteractions(genes, providers)
    result <- sprintf("%d interactions for %s", nrow(tbl), paste(genes, collapse=","))
    # return.msg <- toJSON(list(cmd="displayInteractions", status="result", payload=result))

    tbl.result <- as.matrix(tbl)
    colnames(tbl.result) <- NULL

    return.cmd <- "displayInteractions";
    status = "success"
    if(nrow(tbl.result) == 0){
        return.msg <- list(cmd=return.cmd, status="failure", payload="no interactions found")
        }
    else{
       return.msg <- list(cmd=return.cmd, status="success", payload=tbl.result)
       return.msg <- gsub("\n", "", toJSON(return.msg))
       }

    printf("sending refnet result to js: %d rows", nrow(tbl.result))
   
    websocket_write(DATA=return.msg, WS=WS)
   
} # fetchInteractions
#---------------------------------------------------------------------------------------------------
getInteractions <- function(geneNames, requested.providers)
{
   #providers <- unlist(providers(refnet), use.names=FALSE);
   #providers <- c("APID", "BioGrid", "Reactome-FIs", "gerstein-2012",
   #               "hypoxiaSignaling-2006", "stamlabTFs-2012", "recon202")

      # nice simple test set
   #sample.providers <- c("gerstein-2012", "BIND", "Reactome-FIs")
   available.providers <- unlist(providers(refnet), use.names=FALSE)
   providers <- intersect(requested.providers, available.providers)

   empty <- which(lapply(geneNames, nchar) == 0)
   if (length(empty) > 0)
       geneNames <- geneNames[-empty];

   printf("about to call RefNet::interactions, gene count: %d", length(geneNames));
   printf("geneNames: %s", paste(geneNames, collapse=","))
   
   tbl <- interactions(refnet, id=geneNames, provider=providers, species="9606", quiet=FALSE)

   tbl.simple <- simplifyRefNetTable(tbl)

   printf("--- leaving getInteractions")
   
   invisible(tbl.simple)

} # getInteractions
#---------------------------------------------------------------------------------------------------
fetchRefNetProviders <- function(WS, msg)
{
    printf("------ entering fetchRefNetProviders");
    providers <- getRefNetProviders()

    return.cmd <- "displayRefNetProviders";
    return.msg <- toJSON(list(cmd=return.cmd, status="success", payload=providers))
   
    websocket_write(DATA=return.msg, WS=WS)

} # fetchRefNetProviders
#---------------------------------------------------------------------------------------------------
getRefNetProviders <- function()
{
   if(!exists("refnet")){
      printf("=== createing RefNet()");
      refnet <<- RefNet()
      }

   providers(refnet)

} # getRefNetProviders
#---------------------------------------------------------------------------------------------------
# refnet tables may have up to ~30 columns.  interactions from PSICQUIC usually (maybe always)
# lack straightforward gene symbols.  The PSICQUIC IDMapper helps with that.  use that here, toss
# out most columns, keeping interaction type, pmid, detectionMethod, provider)
simplifyRefNetTable <- function(tbl)
{
   coi <- c("A", "B", "A.common", "B.common",
            "A.canonical", "B.canonical",
            "publicationID", "detectionMethod",
            "provider", "type")

   coi <- intersect(colnames(tbl), coi)
   
   tbl.1 <- tbl[, coi]
   if(!exists("geneNameMapper"))
       geneNameMapper <<- IDMapper("9606")
   tbl.2 <- addGeneInfo(geneNameMapper, tbl.1)

   unmapped.A.common <- which(tbl.2$A.common == "-")
   unmapped.B.common <- which(tbl.2$B.common == "-")
   unmapped.A.canonical <- which(tbl.2$A.canonical == "-")
   unmapped.B.canonical <- which(tbl.2$B.canonical == "-")

   if(length(unmapped.A.common) > 0)
       tbl.2$A.common[unmapped.A.common] <- tbl.2$A[unmapped.A.common]

   if(length(unmapped.B.common) > 0)
       tbl.2$B.common[unmapped.B.common] <- tbl.2$B[unmapped.B.common]
   
   if(length(unmapped.A.canonical) > 0)
       tbl.2$A.canonical[unmapped.A.canonical] <- tbl.2$A[unmapped.A.canonical]

   if(length(unmapped.B.canonical) > 0)
       tbl.2$B.canonical[unmapped.B.canonical] <- tbl.2$B[unmapped.B.canonical]
   
   final.coi <-  c("A.name", "B.name",
                   "type", "detectionMethod",
                   "publicationID", "provider",
                   "A.id", "B.id")
   tbl.2 <- tbl.2[, final.coi]
   #colnames(tbl.2) <- c("A.name", "B.name",
   #                     "type", "detectionMethod",
   #                     "publicationID", "provider",
   #                     "A.id", "B.id")
   
   tbl.2$A.name <- sub("refseq:", "", tbl.2$A.name)
   tbl.2$B.name <- sub("refseq:", "", tbl.2$B.name)
   tbl.2$A.id <- sub("refseq:", "", tbl.2$A.id)
   tbl.2$B.id <- sub("refseq:", "", tbl.2$B.id)

   tbl.2$type <- sub("\\).*", "", sub(".*\\(", "", tbl.2$type))
   tbl.2$detectionMethod <- sub("\\).*", "", sub(".*\\(", "", tbl.2$detectionMethod))
       #tbl.2$publicationID <- sub("pubmed:", "", tbl.2$publicationID)
   tbl.2$publicationID <- parsePublicationIDs(tbl.2$publicationID)

   rownames(tbl.2)  <- NULL
   invisible(tbl.2)

} # simplifyRefnetTable
#---------------------------------------------------------------------------------------------------
fetchPubmedAbstract <- function(WS, msg)
{
   pmid <- msg$payload
   text <- pubmedAbstract(pmid)
   result <- paste(text, collapse="<br>")
   return.cmd <- "displayPubmedAbstractText";
   return.msg <- toJSON(list(cmd=return.cmd, status="success", payload=result))
   
   websocket_write(DATA=return.msg, WS=WS)

} # fetchPubmedAbstract
#---------------------------------------------------------------------------------------------------
prepNewCyjsInteractions <- function(WS, msg)
{
   interaction.list <- msg$payload
   printf("interaction count: %d", length(interaction.list))
   unique.interactions <- unique(interaction.list)
   printf("unique interactions: %d", length(unique.interactions))
   
   return.cmd <- "addInteractionsToNetworkCuratorCyjs";
   return.msg <- toJSON(list(cmd=return.cmd, status="success", payload=unique.interactions))

   websocket_write(DATA=return.msg, WS=WS)

} # prepNewCyjsInteractions
#----------------------------------------------------------------------------------------------------
parsePublicationIDs <- function(ids)
{
    x <- gsub("-", "", ids)
    x <- gsub("omim:[0-9]+\\|*", "", x)     # no omim ids for now
    x <- gsub("pubmed:", "", x)
    x <- gsub("\\|", ",", x)

    x

} # parsePublicationIDs
#----------------------------------------------------------------------------------------------------

