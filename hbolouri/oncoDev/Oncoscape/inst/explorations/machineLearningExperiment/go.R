# go.R
#------------------------------------------------------------------------------------------------------------------------
options(stringsAsFactors=FALSE)
library(Oncoscape)
library(cgdsr)
#------------------------------------------------------------------------------------------------------------------------
run = function (levels)
{
  if (0 %in% levels) {
     #tbl.mRNA <<- getData(DataProvider("TCGA_GBM_mRNA"))   # old selection of gene symbols, needs to be redeon
     getDataFresh(0:1)
     } # 0

  if (1 %in% levels) {
     filename <- system.file(package="Oncoscape", "extdata", "tbl.idLookupWithDzSubType.RData")
     printf("loading '%s'", load(filename, envir=.GlobalEnv))
     filename <- system.file(package="Oncoscape", "extdata", "298SamplesNanoStringExp.RData")
     printf("loading '%s' as 'tbl.nano'", load(filename))
     tbl.nano <<- nano
     mtx.nano <<-  Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup)
    } # 1

  if (2 %in% levels) {
    shared.genes <<- intersect(colnames(tbl.mRNA), colnames(mtx.nano))   # 136 genes
    } # 2

  if (3 %in% levels) {
    nano <<- as.matrix(mtx.nano[, shared.genes])
    tcga <<- as.matrix(tbl.mRNA[, shared.genes])
    } # 3

  if (4 %in% levels) {
    means <<- apply(nano, 2, mean)
    sds   <<- apply(nano, 2, sd)
    nanoZ <<- t(apply(nano, 1, function(row) (row-means)/sds))
    } # 4

  if (5 %in% levels) {
    max <- nrow(nanoZ)
    #max <- 3
    cors <<- matrix(nrow=max, ncol=nrow(tcga), dimnames=list(rownames(nanoZ)[1:max], rownames(tcga)))
    for(r in 1:max){
       correlations <- apply(tcga, 1, function(row) cor(nanoZ[r,], row, use="pairwise.complete"))
       #browser()
       cors[r,] <<- correlations
       } # for r
    cors[is.na(cors)] <<- 0
    cors <<- unique(cors)
    } # 5

  if (6 %in% levels) {
    tissues <- rownames(cors)
    highest.cor <- vector("numeric", length(tissues))
    tcga.patient <- vector("character", length(tissues))
    i = 0
    for(tissue in tissues){
       i = i + 1
       highest.correlation <- max(cors[tissue,])
       #browser()
       tcga.pt <- names(which(cors[tissue,] == highest.correlation))
       highest.cor[i] <- highest.correlation
       tcga.patient[i] <- tcga.pt
       } # for tissue
    tbl.map <<- data.frame(tcga=tcga.patient, correlation=highest.cor)
    rownames(tbl.map) <<- tissues
    } # 6

  if (7 %in% levels) {
    tbl.map <- tbl.map[order(tbl.map$tcga, tbl.map$correlation, decreasing=TRUE),]
    duplicates <- which(duplicated(tbl.map$tcga))
    if(length(duplicates) > 0)
       tbl.map <<- tbl.map[-duplicates,]
    tbl.map <<- tbl.map[order(tbl.map$correlation, decreasing=TRUE),]
    } # 7

  if (8 %in% levels) {
    save(tbl.map, file="~/Desktop/stage/nano-to-tcga.RData")
    } # 8

  if (9 %in% levels) {
    } # 9

  if (10 %in% levels) {
    } # 10

  if (11 %in% levels) {
    } # 11

  if (12 %in% levels) {
    } # 12

  if (13 %in% levels) {
    } # 13

  if (14 %in% levels) {
    } # 14

  if (15 %in% levels) {
    } # 15

  if (16 %in% levels) {
    } # 16

  if (17 %in% levels) {
    } # 17

  if (18 %in% levels) {
    } # 18

  if (19 %in% levels) {
    } # 19

  if (20 %in% levels) {
    } # 20

} # run
#------------------------------------------------------------------------------------------------------------------------
getDataFresh <- function(levels)
{
  if (0 %in% levels) {
     url.new <- 'http://www.cbioportal.org/public-portal/';   # trailing slash needed!
     ds <<- CGDS(url.new)
     tbl.studies <<- getCancerStudies(ds)
     t(tbl.studies[grep("gbm", tbl.studies$description, ignore.case=TRUE),])
     study <- "gbm_tcga_pub"   # 2008
     study <- "gbm_tcga"       # 2008
     tbl.cases <<- getCaseLists(ds, study)
     case <- "gbm_tcga_3way_complete"
     case <- "gbm_tcga_rna_seq_v2_mrna"
     data.set <- "gbm_tcga_pub2013"
     data.set <- "gbm_tcga_rna_seq_v2_mrna"
     tbl.geneticProfile <- getGeneticProfiles(ds, study)
       #  [1] "gbm_tcga_gistic"                        
       #  [2] "gbm_tcga_mrna_U133"                     
       #  [3] "gbm_tcga_mrna_U133_Zscores"             
       #  [4] "gbm_tcga_mrna_median_Zscores"           
       #  [5] "gbm_tcga_rna_seq_v2_mrna"               
       #  [6] "gbm_tcga_rna_seq_v2_mrna_median_Zscores"
       #  [7] "gbm_tcga_log2CNA"                       
       #  [8] "gbm_tcga_methylation_hm27"              
       #  [9] "gbm_tcga_methylation_hm450"             
       # [10] "gbm_tcga_mutations"                     
       # [11] "gbm_tcga_RPPA_protein_level"            
       # [12] "gbm_tcga_mirna"                         
       # [13] "gbm_tcga_mirna_median_Zscores"          
       # [14] "gbm_tcga_mrna_merged_median_Zscores"    
       # [15] "gbm_tcga_mrna"                          

     if(!exists("mtx.nano")) run (1)
     nano.syms <<- colnames(mtx.nano)
     data.type <- "gbm_tcga_pub2013_rna_seq_v2_mrna"
     #data.type <- "gbm_tcga_pub2013_rna_seq_v2_mrna_median_Zscores"
     tbl.mRNA <<- getProfileData(ds, nano.syms, data.type, "gbm_tcga_all")  # 596 x 140
     } # 0

  if(1 %in% levels){  # eliminate the rows with all NAs
     deleters <- as.integer(which(apply(tbl.mRNA, 1, function(row) all(is.nan(row)))))
     if(length(deleters) > 0)
         tbl.mRNA <<- tbl.mRNA[-deleters,]
     } #1

# syms <- c("ERBB2","KRAS","ARHGEF6","AKT3","AKT1","AKT2")
# tbl.mrna <- getProfileData(ds, syms, "paad_tcga_rna_seq_v2_mrna", "paad_tcga_all")
# tbl.cnv  <- getProfileData(ds, syms, "paad_tcga_gistic", "paad_tcga_all")


} # getDataFresh
#------------------------------------------------------------------------------------------------------------------------
#   library(cgdsr)   # 1.1.30
#   url.new <- 'http://www.cbioportal.org/public-portal/';   # trailing slash needed!
#   ds <- CGDS(url.new)
#   tbl.studies <- getCancerStudies(ds)
# 
#   t(tbl.studies[grep("gbm", tbl.studies$description, ignore.case=TRUE),])
#     cancer_study_id "gbm_tcga"                                                                                                                                                                                               
#     name            "Glioblastoma Multiforme (TCGA, Provisional)"                                                                                                                                                            
#     description     "TCGA Glioblastoma Multiforme, containing 548 samples; raw data at the <A HREF=\"https://tcga-data.nci.nih.gov/tcga/tcgaCancerDetails.jsp?diseaseType=gbm&diseaseName=Glioblastoma Multiforme\">NCI</A>."
# 
#   tbl.cases <- getCaseLists(ds, "gbm_tcga")
# 
# tbl.cases[, 1:4]   # column 5 has the case_ids
#                  case_list_id                       case_list_name                                  case_list_description cancer_study_id
# 1               paad_tcga_all                           All Tumors                         All tumor samples (66 samples)              34
# 2              paad_tcga_acgh                          Tumors aCGH                 All tumors with aCGH data (50 samples)              34
# 3           paad_tcga_log2CNA              Tumors log2 copy-number     All tumors with log2 copy-number data (50 samples)              34
# 4 paad_tcga_methylation_hm450 Tumors with methylation data (HM450) All samples with methylation (HM450) data (65 samples)              34
# 5   paad_tcga_rna_seq_v2_mrna   Tumors with mRNA data (RNA Seq V2)     All samples with mRNA expression data (40 samples)              34
# 
# tbl.geneticProfile <- getGeneticProfiles(ds, "paad_tcga")  # dim 5 6
# tbl.geneticProfile[,c(1:2)]
#                            genetic_profile_id                         genetic_profile_name
#    1                         paad_tcga_gistic Putative copy-number alterations from GISTIC
#    2                        paad_tcga_log2CNA                      Log2 copy-number values
#    3              paad_tcga_methylation_hm450                          Methylation (HM450)
#    4                paad_tcga_rna_seq_v2_mrna            mRNA expression (RNA Seq V2 RSEM)
#    5 paad_tcga_rna_seq_v2_mrna_median_Zscores   mRNA Expression z-Scores (RNA Seq V2 RSEM)
# 
# tbl.geneticProfile[,1]
# [1] "paad_tcga_gistic"                        
# [2] "paad_tcga_log2CNA"                       
# [3] "paad_tcga_methylation_hm450"             
# [4] "paad_tcga_rna_seq_v2_mrna"               
# [5] "paad_tcga_rna_seq_v2_mrna_median_Zscores"
# 
# syms <- c("ERBB2","KRAS","ARHGEF6","AKT3","AKT1","AKT2")
# tbl.mrna <- getProfileData(ds, syms, "paad_tcga_rna_seq_v2_mrna", "paad_tcga_all")
# tbl.cnv  <- getProfileData(ds, syms, "paad_tcga_gistic", "paad_tcga_all")
