# go.R
#------------------------------------------------------------------------------------------------------------------------
options(stringsAsFactors=FALSE)
library (RUnit)
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_identifyAllGenes();
   test_toGistic()
   
} # runTests
#------------------------------------------------------------------------------------------------------------------------
run = function (levels)
{
  if("redo" %in% levels){
     run(0:8)
     } # redo

  if("redo.mutations" %in% levels){
     run(0)
     run(9)
     # run(11) # writes out mutations to tsv file, for hand edition
     run(12)   # reads that modified file back in
     run(13)   # adds the column to the original tbl, (jenny's table)
     run(c(14, 15))
     run(16)
     run(18)   # write it out to inst/extdata/mskGBM
     } # redo.mutations
  
  if (0 %in% levels) {
    filename <- system.file(package="Oncoscape", "extdata", "tbl.idLookupWithDzSubType.RData")
    printf("loading '%s'", load(filename, envir=.GlobalEnv))
    tbl <<- read.table("../../extdata/JennysSummaryTable_HBversion.txt", sep="\t", header=TRUE)
    printf("jenny/HB table: %d, %d", nrow(tbl), ncol(tbl))
    } # 0

  if (1 %in% levels) {
    acgh <<- tbl$ACGH
    names(acgh) <<- tbl$BTC_ID
    } # 1

  if (2 %in% levels) {
    btc.shared <<- intersect(tbl$BTC_ID, tbl.idLookup$btc)
    printf("jenny btc's found in tbl.idLookup: %d/%d", length(btc.shared), length(tbl$BTC_ID))
    } # 2

  if (3 %in% levels) {
    acgh <<- acgh[btc.shared]    
    na.elements <- which(is.na(acgh))
    if(length(na.elements) > 0)
        acgh <<- acgh[-na.elements]
    } # 3

  if (4 %in% levels) {
    all.genes <<- identifyAllGenes(acgh)
    } # 4

  if (5 %in% levels) {
    genes <- all.genes
    tissueCount <- length(acgh)
    tbl.gistic <<- as.data.frame(sapply(all.genes,
                                       function(gene) vector("numeric", tissueCount)), stringsAsFactors=FALSE)
    rownames(tbl.gistic) <<- names(acgh)
    } # 5

  if (6 %in% levels) {
     for(tissue in names(acgh)){
        list <- toGistic(acgh[tissue])
        tbl.gistic[tissue, names(list)] <<- as.numeric(list)
        }
    } # 6

  if (7 %in% levels) {  # replace btc ids with tissue ids used in oncoscape
    indices <- match(rownames(tbl.gistic), tbl.idLookup$btc)
    rownames(tbl.gistic) <<- tbl.idLookup$specimen[indices]
    } # 7

  if (8 %in% levels) {
    printf("saving %dx%d tbl.gistic as tbl.gistic.RData", nrow(tbl.gistic), ncol(tbl.gistic))
    save(tbl.gistic, file="tbl.gistic.RData")
    printf("system('cp tbl.gistic.RData  ../../extdata/mskGBM/')")
    } # 8

  if (9 %in% levels) {
    muts <- tbl$Sequenom
    muts[muts=="NoMutation"] <- NA
    names(muts) <- tbl$BTC_ID
    indices <- match(names(muts), tbl.idLookup$btc)
    tissue.names <- tbl.idLookup$specimen[indices]
    names(muts) <- tissue.names
    deleters.by.name <- which(is.na(names(muts)))
    if (length(deleters.by.name) > 0)
        muts <- muts[-deleters.by.name]
    deleters.by.content <- which(is.na(muts))
    if (length(deleters.by.content) > 0)
        muts <- muts[-deleters.by.content]
    muts <<- muts
    } # 9

  if (10 %in% levels) {
     mx <- as.character(head(muts))
     mx0 <- gsub("_", " ", mx) 
     mx1 <- gsub("\\[.*?\\]", "", mx0)
     mx2 <- strsplit(mx1, ";")
    } # 10

  if (11 %in% levels) {
    tbl.muts <- as.data.frame(tbl[, "Sequenom"])
    write.table(tbl.muts, file="muts.tsv", row.names=FALSE, col.names=FALSE, quote=FALSE, sep="\t")
    } # 11

  if (12 %in% levels) {
    muts.fixed <- scan("muts.tsv", sep="\n", what=character(0));
    tbl <<- cbind(tbl, data.frame(mutation=muts.fixed, stringsAsFactors=FALSE))
    } # 12

  if (13 %in% levels) {
    muts.raw <- tbl$mutation
    muts.raw[muts.raw=="NoMutation"] <- NA
    names(muts.raw) <- tbl$BTC_ID
    dups <- which(duplicated(names(muts.raw)))
    if(length(dups) > 0)
        muts.raw <- muts.raw[-dups]
    indices <- match(names(muts.raw), tbl.idLookup$btc)
    tissue.names <- tbl.idLookup$specimen[indices]
    names(muts.raw) <- tissue.names
    deleters.by.name <- which(is.na(names(muts.raw)))
    if (length(deleters.by.name) > 0)
        muts.raw <- muts.raw[-deleters.by.name]
    deleters.by.content <- which(is.na(muts.raw))
    if (length(deleters.by.content) > 0)
        muts.raw <- muts.raw[-deleters.by.content]    # now 92, with unique names
    muts.raw <<- muts.raw
    } # 13

  if (14 %in% levels) {
    muts <- strsplit(as.character(muts.raw), ";")
    muts <<- lapply(muts, unique)
    mut.genes <- sort(unique(unlist(lapply(strsplit(unique(unlist(muts)),"_"), "[", 1))))   # 15
    names(muts) <<- names(muts.raw)
    } # 14

  if (15 %in% levels) {
    empty <- rep("", length(muts))
    tbl.muts <<- data.frame(row.names=names(muts.raw),
                           EGFR=empty,
                           EPHA6=empty,
                           ERBB2=empty,
                           FGFR2=empty,
                           FGFR3=empty,
                           IDH1=empty,
                           IDH2=empty,
                           KIT=empty,
                           KRAS=empty,
                           NTRK1=empty,
                           PGFRA=empty,
                           PIK3=empty,
                           PIK3CA=empty,
                           PIK3R1=empty,
                           ROR2=empty,
                           stringsAsFactors=FALSE);
    } # 15

  if (16 %in% levels) {
    for(tissue in names(muts)){
       token.sets <- strsplit(muts[[tissue]], "_")
       #if(tissue == "1007.T.1") browser()
       #if(tissue == "1184.T.1") browser()
       #x <- 99
       for(tokens in token.sets){
          gene <- tokens[1]
          modification <- tokens[2]
          tbl.muts[tissue, gene] <<- strstrip(paste(modification, tbl.muts[tissue, gene], sep=" "))
          #if(tissue == "1184.T.1") browser()
          } # for tokens
       } # for tissue
    } # 16

  if (17 %in% levels) { # check some of these final results (in tbl.muts) against the originals (in tbl)
     t <- "1007.T.1"; gene <- "IDH1";
     subset(tbl, BTC_ID==tbl.idLookup$btc[match(t, tbl.idLookup$specimen)])$Sequenom  # "IDH1_R132H[AG];IDH1R132H[AG]" "IDH1_R132H[AG];IDH1R132H[AG]"
     tbl.muts[t,] #  [1] "R132H"

     t <- "1184.T.1"; gene <- c("EGFR", "EPHA6", "ERBB2", "NTRK1", "PGFRA")
     subset(tbl, BTC_ID==tbl.idLookup$btc[match(t, tbl.idLookup$specimen)])$Sequenom
     tbl.muts[t,]

     t <- "273X.T.1"
     subset(tbl, BTC_ID==tbl.idLookup$btc[match(t, tbl.idLookup$specimen)])$Sequenom
     tbl.muts[t,]
     } # 17

  if (18 %in% levels) {
    tbl.muts[tbl.muts==""] <- NA
    save(tbl.muts, file="../../extdata/mskGBM/tbl.mutation.RData")
    } # 18

  if (19 %in% levels) {
    } # 19

  if (20 %in% levels) {
    } # 20


} # run
#------------------------------------------------------------------------------------------------------------------------
identifyAllGenes <- function(acgh)
{
   x <- strsplit(acgh, ";")
   genes.raw <- unlist(x, use.names=FALSE);
   genes <- unique(unlist(lapply(strsplit(genes.raw, ":"), "[", 1)))
   lower.case.removers <- grep("[a-z]", genes)
   if(length(lower.case.removers) > 0)
       genes <- genes[-lower.case.removers]

   sort(genes)

} # identifyAllGenes
#------------------------------------------------------------------------------------------------------------------------
test_identifyAllGenes <- function()
{
   print("--- test_identifyAllGenes")
   
   checkEquals(identifyAllGenes(acgh[1:3]), c("CDKN2A", "EGFR", "MET", "NF1", "PTEN", "PTPRD"))

} # test_identifyAllGenes
#------------------------------------------------------------------------------------------------------------------------
toGistic <- function(x)
{
   tokens <- strsplit(x, ";")[[1]]
   genes <- unlist(lapply(strsplit(tokens, ":"), "[", 1))
   deleters <- grep("[a-z]", genes)
   if(length(deleters) > 0){
       genes <- genes[-deleters]
       tokens <- tokens[-deleters]
       }
   
   mods.raw <-  unlist(lapply(strsplit(tokens, ":"), "[", 2))
   mods <- gsub("\\^", "", mods.raw)
   mods <- gsub("\\*", "", mods)

   codes <- list("--"=-2, "-"=-1, "+"=1, "++"=2)
   result <- codes[mods]
   names(result) <- genes

   result
   
} # toGistic
#------------------------------------------------------------------------------------------------------------------------
test_toGistic <- function()
{
   print("--- test_toGistic")
   
   checkEquals(toGistic(acgh[4]), list(EGFR=2, MET=1, CDKN2A=-2, PTEN=-1, PTPRD=-1))
   checkEquals(toGistic(acgh[2]), list(CDKN2A=-1, PTPRD=-1))

} # test_identifyAllGenes
#------------------------------------------------------------------------------------------------------------------------
