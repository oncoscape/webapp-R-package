#                   incoming message                   function to call                      return.cmd
#                   -------------------                ----------------                      -------------
addRMessageHandler("DataProviderBridge.ping",         "DataProviderBridgePing")             # handleDataProviderPing
#addRMessageHandler("get_TCGA_GBM_CopyNumber_Data",    "get_TCGA_GBM_copyNumber_Data")
#addRMessageHandler("get_TCGA_GBM_mRNA_Data",          "get_TCGA_GBM_mRNA_Data")
#addRMessageHandler("get_TCGA_GBM_mRNA_Average",       "get_TCGA_GBM_mRNA_Average")
#addRMessageHandler("get_MSK_GBM_CopyNumber_Data",     "get_MSK_GBM_copyNumber_Data")
#addRMessageHandler("get_MSK_GBM_mRNA_Data",           "get_MSK_GBM_mRNA_Data")
#addRMessageHandler("get_MSK_GBM_mRNA_Average",        "get_MSK_GBM_mRNA_Average")
addRMessageHandler("getTabularPatientHistory",         "getTabularPatientHistory")
addRMessageHandler("getPatientHistoryDataVector",      "getPatientHistoryDataVector")
addRMessageHandler("createNewUserID",                  "createNewUserID")
addRMessageHandler("UserIDexists",                     "UserIDexists")
addRMessageHandler("addNewUserToList",                 "addNewUserToList")
addRMessageHandler("getUserSelectionnames",            "getUserSelectionnames")
addRMessageHandler("getUserSelection",                 "getUserSelectPatientHistory")
addRMessageHandler("addNewUserSelection",              "addUserSelectPatientHistory")
addRMessageHandler("filterPatientHistory",             "filterPatientHistory")
addRMessageHandler("getPatientClassification",         "getPatientClassification")
addRMessageHandler("getCaisisPatientHistory",          "getCaisisPatientHistory")          # uses eventList (multi-flat, list of lists)
addRMessageHandler("createRandomPatientPairedDistributionsForTesting", "createRandomPatientPairedDistributionsForTesting")
addRMessageHandler("calculatePairedDistributionsOfPatientHistoryData", "calculatePairedDistributionsOfPatientHistoryData")
addRMessageHandler("get_mRNA_data",                    "get_mRNA_data");
addRMessageHandler("get_cnv_data",                     "get_cnv_data");
addRMessageHandler("get_mutation_data",                "get_mutation_data");
addRMessageHandler("get_geneset_names",                "get_geneset_names");
addRMessageHandler("tTest",                            "tTest");
#----------------------------------------------------------------------------------------------------
genesets <- list(angiogenesis=c("ACVRL1","ANG","ANGPT1","ANGPT2","ANGPTL4","ATPIF1","CCL2","CTNNB1",
                                "EGLN1","EGLN3","EP300","ERAP1","FGF2","GDF2","HIF1AN","HMOX1",
                                "ID1","IL8","ITGA5","ITGB3","JUN","KDR","MAPK14","NPPB","NPR1",
                                "PTK2","SP1","SPINK5","SRF","TEK","TGFB2","TNFSF12","VEGFA","VHL"),
                 
                gbmPathways=c("ABCA1","AKT2","AKT3","ARAF","ARF","ATM","BCL2L1","BRAF","BRCA1","BRCA2",
                               "CBL","CCND1","CCND2","CCNE1","CDK2","CDK4","CDK6","CDKN1A","CDKN1B",
                              "CDKN2A","CDKN2A","CDKN2B","CDKN2C","CENTG1","CIC","CTNNB1","E2F1",
                              "EGFR","EP300","ERBB2","ERBB3","ERK1","ERK2","ERRFI1","ETV1","ETV4",
                              "ETV5","FGFR1","FGFR2","FOXO1","FOXO3","FOXO4","FUBP1","GAB1","GLUT1",
                              "GRB2","HRAS","IDH1","IDH2","IGF1R","IRS1","KRAS","LDHA","LDLR","MDM2",
                              "MDM4","MEK1","MEK2","MET","MSH6","MSK1","MSK2","MYC","MYLIP","NF1",
                              "NFKB1","NR1H1","NR1H2","NR1H3","NRAS","OLIG2","PDGFRA","PDGFRB","PDPK1",
                              "PI3P","PIK3C2A","PIK3C2B","PIK3C2G","PIK3CA","PIK3CB","PIK3CD","PIK3CG","PIK3R1",
                              "PIK3R2","PIP3","PKM2","PLCG","PRKCA","PRKCB1","PRKCD","PRKCE","PRKCG",
                              "PRKCH","PRKCI","PRKCQ","PRKCZ","PTEN","RAF1","RB1","RELA","SPRY2","SRC",
                              "SREBP1A","STAT3","STAT5","TET2","TP53","TSC1","TSC2"),
                 
                MUELLER_METHYLATED_IN_GLIOBLASTOMA=c("TKTL1","SERPINF1","KRT81","SERPINB5","RUNX3",
                   "CLDN4","S100A4","AREG","S100P","LAPTM5","TES","LSR","KRT19","LXN","IL24","KRT17","COX7A1","SSX3",
                   "HSD17B6","DAZL","MMP13","SSX1","CXCL2","SFN","TLR2","NPTX2","F11R","STAG3","CDA","FBXO2","IER3",
                    "GZMM","SPINT1","KRT4","MAST3","IFNA21","MAGEB2","SPANXC","LCN2","SERPIND1"),

                tcga_GBM_centroid=c("ABAT", "ABCD2", "ABL1", "ACPP", "ACSBG1",
                                    "ACSL1", "ACSL3", "ACSL4", "ACTN4", "ACTR1A",
                                    "ACYP2", "ADAM12", "ADAM19", "ADCY9", "ADD3",
                                    "AFAP1", "AFF4", "AGTPBP1", "AGXT2L1", "AIM1",
                                    "AKAP13", "AKAP8L", "AKR7A3", "AKT2", "ALCAM",
                                    "ALDH3B1", "ALOX5", "AMOTL2", "AMPD3", "ANKRD11",
                                    "ANKRD46", "ANKS1B", "ANXA1", "ANXA2", "ANXA3",
                                    "ANXA4", "ANXA5", "ANXA7", "AOF2", "AP3D1",
                                    "APBA3", "ARHGAP29", "ARHGEF18", "ARHGEF9", "ARNTL",
                                    "ARPC1B", "ARRB1", "ARSJ", "ASCL1", "ASL",
                                    "ATAD5", "ATP1A3", "ATP5F1", "ATP5L", "ATRNL1",
                                    "B3GALT1", "BAI3", "BASP1", "BAT2D1", "BATF",
                                    "BCAN", "BCAS1", "BCL7A", "BCOR", "BDKRB2",
                                    "BEST1", "BEX1", "BICD2", "BLM", "BLVRB",
                                    "BMS1", "BNC2", "BOP1", "BPTF", "BRD4",
                                    "BRPF1", "BTBD2", "C19orf22", "C19orf28", "C19orf29",
                                    "C19orf6", "C1QL1", "C1orf106", "C1orf38", "C1orf54",
                                    "C1orf61", "C20orf42", "C5AR1", "C6orf134", "CA10",
                                    "CA4", "CALM1", "CALM2", "CAMK2B", "CAMK2G",
                                    "CAMSAP1L1", "CASK", "CASP1", "CASP2", "CASP4",
                                    "CASP5", "CASP8", "CASQ1", "CAST", "CBX1",
                                    "CC2D1A", "CCDC109B", "CCDC121", "CCK", "CCR5",
                                    "CD14", "CD151", "CD2AP", "CD3EAP", "CD4",
                                    "CD97", "CDC25A", "CDC42", "CDC7", "CDCP1",
                                    "CDH2", "CDH4", "CDH6", "CDK5R1", "CDK6",
                                    "CDKN1B", "CDR1", "CDV3", "CEBPB", "CENTD1",
                                    "CENTD3", "CHD4", "CHD7", "CHERP", "CHI3L1",
                                    "CHN1", "CHST3", "CIZ1", "CKAP4", "CKB",
                                    "CLASP2", "CLCA4", "CLCF1", "CLEC2B", "CLGN",
                                    "CLIC1", "CLIP2", "CNN2", "CNTN1", "COL1A1",
                                    "COL1A2", "COL4A2", "COL5A1", "COL8A2", "COPZ2",
                                    "COX5B", "CPNE6", "CRB1", "CRBN", "CREB5",
                                    "CRMP1", "CRYL1", "CRYM", "CRYZL1", "CSGlcA-T",
                                    "CSNK1E", "CSPG5", "CSTA", "CTSA", "CTSB",
                                    "CTSC", "CTSZ", "CUTC", "CXXC4", "CYBRD1",
                                    "DAB2", "DAG1", "DBN1", "DCBLD2", "DCP1A",
                                    "DCX", "DDX42", "DENND2A", "DGKI", "DHRS9",
                                    "DIAPH1", "DLC1", "DLL3", "DMWD", "DNAJC13",
                                    "DNM3", "DNMT1", "DOCK6", "DOK3", "DOT1L",
                                    "DPF1", "DPP3", "DPP6", "DPYSL4", "DRAM",
                                    "DSC2", "DSE", "DUSP26", "DYNC1I1", "E2F3",
                                    "ECGF1", "EDG1", "EDIL3", "EEF2", "EFEMP2",
                                    "EGFR", "EHD2", "ELAVL1", "ELF4", "ELOVL2",
                                    "EMP3", "ENG", "ENPP2", "ENPP4", "EP400",
                                    "EPB41", "EPB41L3", "EPHB1", "EPHB4", "ERBB3",
                                    "ERCC2", "EVI2A", "EXT1", "EXTL3", "EYA2",
                                    "FAM110B", "FAM125B", "FAM38A", "FAM46A", "FAM49B",
                                    "FAM77C", "FBXL11", "FBXO17", "FBXO21", "FBXO3",
                                    "FCGR2A", "FCGR2B", "FER", "FER1L3", "FES",
                                    "FEZF2", "FGF9", "FGFR3", "FHIT", "FHL2",
                                    "FHOD1", "FHOD3", "FLJ11286", "FLJ20273", "FLJ21963",
                                    "FLJ22655", "FLJ22662", "FLNA", "FLRT1", "FMNL1",
                                    "FNDC3B", "FOLR2", "FPRL2", "FURIN", "FUT9",
                                    "FXYD1", "FXYD5", "FXYD6", "FZD3", "FZD7",
                                    "FZR1", "GABARAPL2", "GABRA3", "GABRB2", "GADD45G",
                                    "GALNT4", "GANAB", "GAS1", "GATAD2A", "GCN1L1",
                                    "GCNT1", "GJA1", "GLG1", "GLI2", "GLT25D1",
                                    "GNA11", "GNA15", "GNAI1", "GNAS", "GNG4",
                                    "GNG7", "GNL1", "GNL2", "GOLGA2", "GOLGA3",
                                    "GPM6A", "GPR161", "GPR17", "GPR172A", "GPR22",
                                    "GPR23", "GPR56", "GRIA2", "GRID2", "GRIK1",
                                    "GRIK5", "GRM1", "GRM3", "GRN", "GSK3B",
                                    "GSTA4", "GSTK1", "GTF2F1", "GUK1", "HCFC1",
                                    "HDAC2", "HELZ", "HEXA", "HEXB", "HFE",
                                    "HK3", "HMG20B", "HMGB3", "HN1", "HNRPA3",
                                    "HNRPAB", "HNRPH3", "HNRPM", "HNRPUL2", "HOXD3",
                                    "HPCA", "HPCAL4", "HPRT1", "HRASLS", "HS3ST3B1",
                                    "HSP90B1", "HSPBP1", "ICAM3", "ICK", "IFI30",
                                    "IGFBP6", "IL15RA", "IL1R1", "IL1RAPL1", "IL4R",
                                    "ILF3", "ILK", "IMPA1", "IQGAP1", "IRF3",
                                    "IRS2", "ITGA4", "ITGA5", "ITGA7", "ITGAM",
                                    "ITGB2", "ITGB8", "JAG1", "JARID1A", "JMJD2B",
                                    "JUND", "KCNF1", "KCNJ3", "KCNK1", "KEAP1",
                                    "KHSRP", "KIAA0020", "KIAA0152", "KIAA0355", "KIAA0892",
                                    "KIAA1166", "KIAA1598", "KIF21B", "KIRREL", "KLHDC8A",
                                    "KLHL25", "KLHL4", "KLRC3", "KLRC4", "KLRK1",
                                    "KPNB1", "KYNU", "LAIR1", "LAMA5", "LAMB1",
                                    "LAMB2", "LAMC1", "LAPTM5", "LARP1", "LCP1",
                                    "LCP2", "LEPREL2", "LFNG", "LGALS1", "LGALS3",
                                    "LHFP", "LHFPL2", "LILRB2", "LILRB3", "LMAN1",
                                    "LMNB2", "LMO2", "LOC201229", "LOC55565", "LOC81691",
                                    "LOX", "LPHN3", "LRFN3", "LRP10", "LRP5",
                                    "LRP6", "LRRC16", "LRRFIP1", "LRRTM4", "LTBP1",
                                    "LTBP2", "LY75", "LY96", "LYPLA3", "LYRM1",
                                    "M6PRBP1", "MAB21L1", "MAFB", "MAGEH1", "MAML1",
                                    "MAN1A1", "MAN2A1", "MAN2B1", "MAP2", "MAPK13",
                                    "MAPT", "MARCKS", "MARCKSL1", "MAST1", "MAT2B",
                                    "MATR3", "MBP", "MBTPS1", "MC1R", "MCC",
                                    "MCM10", "MDH1", "MED12", "MEGF8", "MEIS1",
                                    "MEOX2", "MFSD1", "MGAT1", "MGC2752", "MGC72080",
                                    "MGST2", "MGST3", "MIER2", "MLC1", "MLLT11",
                                    "MLXIP", "MMD", "MMP15", "MMP16", "MORC2",
                                    "MORF4L2", "MPPED2", "MRC2", "MRPL49", "MS4A4A",
                                    "MSL2L1", "MSR1", "MSRB2", "MTSS1", "MVP",
                                    "MYB", "MYBPC1", "MYH9", "MYO10", "MYO1E",
                                    "MYO1F", "MYO5C", "MYO9B", "MYST2", "MYST3",
                                    "MYT1", "NANOS1", "NCALD", "NCAM1", "NCF2",
                                    "NCF4", "NCL", "NCLN", "NCOR2", "NDP",
                                    "NDRG2", "NDUFS3", "NES", "NFATC3", "NIPBL",
                                    "NKX2-2", "NLGN3", "NOD2", "NOL4", "NOS2A",
                                    "NOTCH3", "NPAS3", "NPC2", "NPEPL1", "NR0B1",
                                    "NR2E1", "NR2F6", "NRP1", "NRXN1", "NRXN2",
                                    "NSL1", "NTSR2", "NUP188", "OLIG2", "ORC4L",
                                    "OSBPL3", "P2RX7", "P4HA2", "P4HB", "PABPC1",
                                    "PAFAH1B3", "PAK3", "PAK7", "PARP8", "PCDH11X",
                                    "PCDH11Y", "PCSK5", "PCSK7", "PDE10A", "PDE6D",
                                    "PDGFA", "PDPN", "PELI1", "PEPD", "PEX11B",
                                    "PEX19", "PFN2", "PGBD5", "PGCP", "PHC2",
                                    "PHF11", "PHF16", "PHLPP", "PIGP", "PIPOX",
                                    "PLA2G5", "PLAU", "PLAUR", "PLCB4", "PLCG1",
                                    "PLCL1", "PLEKHA4", "PLK3", "PLOD3", "PLS3",
                                    "PLXNA1", "PMP22", "PODXL2", "POFUT1", "POLD4",
                                    "POLRMT", "POMT2", "POPDC3", "PPA1", "PPFIA2",
                                    "PPM1D", "PPM1E", "PPM1G", "PPP1R1A", "PPP2R5A",
                                    "PRKD2", "PRKDC", "PROCR", "PRPF31", "PRPSAP2",
                                    "PSCD1", "PSCD4", "PSCDBP", "PTBP1", "PTGER4",
                                    "PTPN14", "PTPN22", "PTPN6", "PTPRA", "PTPRC",
                                    "PTRF", "PURG", "PXN", "PYGL", "QTRT1",
                                    "QTRTD1", "RAB11FIP1", "RAB27A", "RAB32", "RAB33A",
                                    "RABGAP1L", "RAC2", "RAD21", "RAD54L2", "RALGPS1",
                                    "RALGPS2", "RAP2A", "RASGRP1", "RBBP6", "RBCK1",
                                    "RBKS", "RBM10", "RBM15B", "RBM42", "RBMS1",
                                    "RBPJ", "REEP1", "RELB", "REPS2", "RFX2",
                                    "RFXANK", "RGS12", "RGS6", "RHOG", "RIN1",
                                    "RNASEN", "RND1", "ROGDI", "RP11-35N6.1", "RRAS",
                                    "RREB1", "RRP1B", "RUFY3", "RUNX2", "S100A11",
                                    "S100A13", "S100A4", "SAFB", "SAR1A", "SARS2",
                                    "SAT1", "SATB1", "SCAMP4", "SCG3", "SCHIP1",
                                    "SCN3A", "SCPEP1", "SEC24D", "SEC61A1", "SEC61A2",
                                    "SEMA6A", "SEMA6D", "SEPP1", "SEPT11", "SEPW1",
                                    "SERPINA1", "SERPINE1", "SERPINH1", "SERPINI1", "SEZ6L",
                                    "SFT2D2", "SGK3", "SH2B3", "SH3GL2", "SH3GL3",
                                    "SHC1", "SHOX2", "SIGLEC7", "SIGLEC9", "SIPA1L1",
                                    "SIRT5", "SLAMF8", "SLC10A3", "SLC11A1", "SLC12A4",
                                    "SLC16A3", "SLC16A7", "SLC1A1", "SLC2A10", "SLC30A10",
                                    "SLC31A2", "SLC4A4", "SLC6A11", "SLC6A9", "SLCO1A2",
                                    "SLCO5A1", "SMARCA4", "SMO", "SNCG", "SNTA1",
                                    "SNTB2", "SNX11", "SNX26", "SOCS2", "SORCS3",
                                    "SOX10", "SOX11", "SOX2", "SOX4", "SOX9",
                                    "SP1", "SP100", "SPAST", "SPPL2B", "SPRY2",
                                    "SPTBN2", "SQRDL", "SRF", "SRGAP3", "SRPX2",
                                    "SRRM2", "SSH3", "SSRP1", "ST14", "STAB1",
                                    "STAT6", "STK10", "STK11", "STMN1", "STMN4",
                                    "STXBP2", "SWAP70", "SYNGR2", "SYPL1", "TAF5",
                                    "TARS", "TBX2", "TCEAL1", "TCEAL2", "TCF3",
                                    "TCIRG1", "TEAD3", "TEC", "TES", "TGFB3",
                                    "TGFBI", "TGFBR2", "TGIF2", "TGOLN2", "THBD",
                                    "THBS1", "THOC2", "THTPA", "TIMP1", "TLE2",
                                    "TLR2", "TLR4", "TMBIM1", "TMCC1", "TMED1",
                                    "TMEFF1", "TMEM118", "TMEM144", "TMEM147", "TMEM161A",
                                    "TMEM35", "TMEM43", "TMSL8", "TNFAIP3", "TNFAIP8",
                                    "TNFRSF11A", "TNFRSF1A", "TNFRSF1B", "TNRC4", "TOP1",
                                    "TOP2B", "TOPBP1", "TOX3", "TPM3", "TPM4",
                                    "TPR", "TRADD", "TRAM2", "TRIB2", "TRIM22",
                                    "TRIM38", "TRIO", "TRIP6", "TRPM2", "TRRAP",
                                    "TSNAX", "TSPAN3", "TSPAN9", "TTC1", "TTC28",
                                    "TTC3", "TTPA", "TTYH1", "TYK2", "UAP1",
                                    "UBN1", "UCP2", "UGT8", "UNC45A", "UPF1",
                                    "UROS", "USP33", "VAMP5", "VAV3", "VAX2",
                                    "VDR", "VEZF1", "VIP", "VPS16", "VSX1",
                                    "WASF1", "WDR68", "WIPF1", "WIZ", "WSCD1",
                                    "WWTR1", "XPO6", "YAP1", "YPEL1", "YPEL5",
                                    "ZBTB43", "ZDHHC18", "ZEB2", "ZFHX4", "ZNF134",
                                    "ZNF146", "ZNF184", "ZNF20", "ZNF211", "ZNF217",
                                    "ZNF227", "ZNF228", "ZNF235", "ZNF248", "ZNF264",
                                    "ZNF286A", "ZNF304", "ZNF323", "ZNF419", "ZNF446",
                                    "ZNF45", "ZNF510", "ZNF606", "ZNF629", "ZNF643",
                                    "ZNF671", "ZNF711", "ZNF8", "ZNF804A", "ZYX"))


#----------------------------------------------------------------------------------------------------
DataProviderBridgePing <- function(WS, msg)
{
    return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload="ping!"))
    sendOutput(DATA=return.msg, WS=WS);

} # DataProviderBridgePing
#----------------------------------------------------------------------------------------------------
get_geneset_names <- function(WS, msg)
{
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=names(genesets))

   sendOutput(DATA=toJSON(return.msg), WS=WS)
                       
} # get_geneset_names
#----------------------------------------------------------------------------------------------------
get_TCGA_GBM_copyNumber_Data <- function(WS, msg)
{
   dp <- DataProvider("TCGA_GBM_copyNumber")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         }
      } # is.list(payload)

   status <- "success"

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_TCGA_GBM_copyNumber_Data
#---------------------------------------------------------------------------------------------------
get_TCGA_GBM_mRNA_Data <- function(WS, msg)
{
   dp <- DataProvider("TCGA_GBM_mRNA")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         status <- "success"
         }
      } # is.list(payload)

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_TCGA_GBM_mRNA_Data
#---------------------------------------------------------------------------------------------------
get_TCGA_GBM_mRNA_Average <- function(WS, msg)
{
   dp <- DataProvider("TCGA_GBM_mRNA")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         if(all(nchar(entities) == 0)) entities <- NA
         if(all(nchar(features) == 0)) features <- NA
         mtx <- as.matrix(getData(dp, entities=entities, features=features))
         mtx[which(is.na(mtx))] <- 0.0
         result <- t(as.matrix(colSums(mtx)/nrow(mtx)))
         rownames(result) <- "average"
         payload <- matrixToJSON(result)
         status <- "success"
         }
      } # is.list(payload)

   if(nrow(mtx) == 0) {
      status <- "failure"
      payload <- "no rows matching supplied entities and features"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_TCGA_GBM_mRNA_Average
#---------------------------------------------------------------------------------------------------
get_MSK_GBM_copyNumber_Data <- function(WS, msg)
{
   dp <- DataProvider("MSK_GBM_copyNumber")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         }
      } # is.list(payload)

   status <- "success"

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_MSK_GBM_copyNumber_Data
#---------------------------------------------------------------------------------------------------
get_MSK_GBM_mRNA_Data <- function(WS, msg)
{
   dp <- DataProvider("MSK_GBM_mRNA")
   tbl <- data.frame()
   
   payload <- msg$payload

   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         tbl <- getData(dp, entities=entities, features=features)
         payload <- matrixToJSON(tbl)
         }
      } # is.list(payload)

   status <- "success"

   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }
      
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   
   sendOutput(DATA=return.msg, WS=WS)

} # get_MSK_GBM_mRNA_Data
#----------------------------------------------------------------------------------------------------
get_MSK_GBM_mRNA_Average <- function(WS, msg)
{
   dp <- DataProvider("MSK_GBM_mRNA")
   
   payload <- msg$payload
   
   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){ 
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
         }
      else {
         entities <- payload$entities
         features <- payload$features
         if(all(nchar(entities) == 0)) entities <- NA
         if(all(nchar(features) == 0)) features <- NA
         mtx <- getData(dp, entities=entities, features=features)
         if(nrow(mtx) == 0) {
            status = "failure"
            payload = "no entities (tissueIDs) recognized"
            }
         else{
            result <- t(as.matrix(colSums(mtx)/nrow(mtx)))
            rownames(result) <- "average"
            payload <- matrixToJSON(result)
            status <- "success"
            } # else: some rows in mtx
        } # else: payload constrains
      } # payload is a list, as needed
   
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status=status, payload=payload))
   sendOutput(DATA=return.msg, WS=WS)

} # get_MSK_GBM_mRNA_Average
#----------------------------------------------------------------------------------------------------
getTabularPatientHistory <- function(WS, msg)
{
   signature <- "patientHistoryTable";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   print("---- current provider keys:")
   print(ls(DATA.PROVIDERS))
   
   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
   tbl <- getTable(patientHistoryProvider)
   colnames <- colnames(tbl)
   matrix <- as.matrix(tbl)
   colnames(matrix) <- NULL
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(colnames=colnames, mtx=matrix))

   printf("DataProviderBridge.R, getTabularPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getTabularPatientHistory
#----------------------------------------------------------------------------------------------------
getPatientHistoryDataVector <- function(WS, msg)
{
   signature <- "patientHistoryTable";
   
   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
   tbl <- getTable(patientHistoryProvider)

   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

      # payload must be a list
   payload <- msg$payload;
   #printf("--- payload");
   #print(payload)
   if(!is.list(payload)) {
       status <- "failure"
       error.message <- "need two fields in payload: 'colname' and 'patients'"
       return.msg <- list(cmd=msg$callback, callback="", status="error", payload=error.message)
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

   printf("checked for two fields");
      # list must have two fields
   constraint.fields <- sort(names(payload))
   legal.constraint.fields <- constraint.fields == c("colname", "patients")
   if (any(!legal.constraint.fields)){
      status <- "failure"
      error.message <- sprintf("payload fields not precisely 'colname', 'patients': %s",
                               paste(constraint.fields, collapse=", "))
      return.msg <- list(cmd=msg$callback, callback="", status="error", payload=error.message)
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      }
   
   printf("extracting payload field values");
   patients <- payload$patients
   print(patients)
   if(all(nchar(patients) == 0))
      patients <- NA
       
   columnOfInterest <- payload$colname
   printf("getting colname: %s", columnOfInterest)
   printf("All column names %s", colnames(tbl))
   if(!columnOfInterest %in% colnames(tbl)){
      error.message <- sprintf("Oncoscape DataProviderBridge patientHistoryDataVector error:  '%s' is not a column title", columnOfInterest);
      return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      } # 
       
   return.cmd = msg$callback
   result <- as.numeric(tbl[, columnOfInterest])
   names(result) <- tbl$ID
   if(!all(is.na(patients)))
      result <- result[patients];
       
   printf("returning %d values from column %s", length(result), columnOfInterest)
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=toJSON(result));

   printf("DataProviderBridge.R, getPatientHistoryDataVector responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getTabularPatientHistory
#----------------------------------------------------------------------------------------------------
get_mRNA_data <- function(WS, msg)
{
   signature <- "mRNA";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   printf("--- get_mRNA_data, msg fields: %s", paste(names(msg), collapse=","))
   printf("    payload fields: %s", names(msg$payload))
   
   dataProvider <- DATA.PROVIDERS[[signature]];
   payload <- msg$payload
   
     # entities and features fields can be empty, but must be present
   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
          }
      else {
         entities <- payload$entities
         features <- payload$features
         printf("entities: %s", paste(entities, collapse=","))
         printf("features: %s", paste(features, collapse=","))
         tbl <- getData(dataProvider, entities=entities, features=features)
         if(nrow(tbl) == 0){
            status <- "failure"
            payload <- sprintf("get_mRNA_data, no matching rows");
            }
         else{            
            matrix <- as.matrix(tbl)
            printf("matrix dim: %d, %d", nrow(matrix), ncol(matrix))
            return.cmd <- msg$callback
            #return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(mtx=matrixToJSON(matrix)))
            payload <- list(mtx=matrixToJSON(matrix))
            status <- "success"
            } # else: some good rows
         } # else: legal constraint fields
       } # is.list(payload)


   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }

   status <- "success"

   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   printf("DataProviderBridge.R, get_mRNA_data responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # get_mRNA_data
#----------------------------------------------------------------------------------------------------
get_cnv_data <- function(WS, msg)
{
   signature <- "cnv";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   printf("--- get_cnv_data, msg fields: %s", paste(names(msg), collapse=","))
   printf("    payload fields: %s", names(msg$payload))
   
   dataProvider <- DATA.PROVIDERS[[signature]];
   payload <- msg$payload
   
     # entities and features fields can be empty, but must be present
   if(!is.list(payload)) {
       status <- "failure"
       payload <- "no constraint fields in payload"
       }

   if(is.list(payload)){
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          status <- "failure"
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
          }
      else {
         entities <- payload$entities
         features <- payload$features
         printf("entities: %s", paste(entities, collapse=","))
         printf("features: %s", paste(features, collapse=","))
         tbl <- getData(dataProvider, entities=entities, features=features)
         if(nrow(tbl) == 0){
            status <- "failure"
            payload <- sprintf("get_mRNA_data, no matching rows");
            }
         else{            
            matrix <- as.matrix(tbl)
            printf("matrix dim: %d, %d", nrow(matrix), ncol(matrix))
            return.cmd <- msg$callback
            #return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(mtx=matrixToJSON(matrix)))
            payload <- list(mtx=matrixToJSON(matrix))
            status <- "success"
            } # else: some good rows
         } # else: legal.constraints
       } # is.list(payload)


   if(nrow(tbl) == 0) {
      status <- "failure"
      payload <- "empty table"
      }

   status <- "success"

   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   printf("DataProviderBridge.R, get_cnv_data responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # get_cnv_data
#----------------------------------------------------------------------------------------------------
get_mutation_data <- function(WS, msg)
{
   signature <- "mut";
   
   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       printf("DataProviderBridge error: %s", error.message)
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   printf("--- get_mut_data, msg fields: %s", paste(names(msg), collapse=","))
   printf("    payload fields: %s", names(msg$payload))
   
   dataProvider <- DATA.PROVIDERS[[signature]];
   payload <- msg$payload
   status <- "failure"
   #print("--- payload");
   #print(payload)
   #print(class(payload))
     # entities and features fields can be empty, but must be present
   if(!is.list(payload)) {
       payload <- "no constraint fields in payload"
       printf("DataProviderBridge error: %s", payload)
       }

   if(is.list(payload)){
      constraint.fields <- sort(names(payload))
      legal.constraint.fields <- constraint.fields == c("entities", "features")
      if (any(!legal.constraint.fields)){
          payload <- sprintf("payload fields not precisely 'entities', 'features': %s",
                             paste(constraint.fields, collapse=", "))
           printf("DataProviderBridge error: %s", payload)
          }
      else {
         entities <- payload$entities
         features <- payload$features
         printf("entities: %s (%d)", paste(entities, collapse=","), length(entities))
         printf("features: %s (%d)", paste(features, collapse=","), length(features))
         tbl <- getData(dataProvider, entities=entities, features=features)
         if(nrow(tbl) == 0) {
            payload <- "empty table"
            printf("DataProviderBridge error: %s", payload)
           }
         else{
            status <- "success"
            matrix <- as.matrix(tbl)
            matrix[matrix=="NaN"] <- NA
            printf("matrix dim: %d, %d", nrow(matrix), ncol(matrix))
            return.cmd <- msg$callback
            #return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(mtx=matrixToJSON(matrix)))
            payload <- list(mtx=matrixToJSON(matrix))
            } # some rows in tbl
         } # legal constraint fields found
       } # is.list(payload)


   if(nrow(tbl) == 0) {
      }

   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   printf("DataProviderBridge.R, get_cnv_data responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # get_mutation_data
#----------------------------------------------------------------------------------------------------
# msg$payload has 4 fields:
#   ageAtDxMin, ageAtDxMax, overallSurvivalMin, overallSurvivalMax
#   return the IDs for all rows that meet these constraints
filterPatientHistory <- function(WS, msg)
{
   signature <- "patientHistoryTable";

   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s defined", signature)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
   tbl <- getTable(patientHistoryProvider)

   filters <- msg$payload
   validArgs <- all(sort(names(filters)) == c("ageAtDxMax", "ageAtDxMin", "overallSurvivalMax", "overallSurvivalMin"))

   if(!validArgs){
       return.msg <- list(cmd=msg$callback, callback="", status="error", payload="invalidArgs")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   ageMin <- as.numeric(filters[["ageAtDxMin"]])
   ageMax <- as.numeric(filters[["ageAtDxMax"]])
   survivalMin <- as.numeric(filters[["overallSurvivalMin"]])
   survivalMax <- as.numeric(filters[["overallSurvivalMax"]])

   tbl.sub <- subset(tbl, ageAtDx >= ageMin & ageAtDx <= ageMax &
                     survival >= survivalMin  & survival <= survivalMax)
   printf("  rows before: %d   rows after: %d", nrow(tbl), nrow(tbl.sub))
   ids <- tbl.sub$ID
   deleters.string <- grep ("NULL", ids)
   if(length(deleters.string) > 0)
       ids <- ids[-deleters.string]
   id.count <- length(ids)
   return.msg <- list(cmd=msg$callback, callback="", status="success",
                      payload=list(count=id.count, ids=ids))
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # filterPatientHistory
#----------------------------------------------------------------------------------------------------
getPatientClassification <- function(WS, msg)
{
   if(!"patientClassification" %in% ls(DATA.PROVIDERS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patient classification provider defined"
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       printf("found no patient classifcation, return this msg:")
       print(return.msg)
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return();
       }

   provider <- DATA.PROVIDERS$patientClassification
   tbl <- getData(provider)

   payload <- matrixToJSON(tbl)
   status <- "success"
   return.msg <- list(cmd=msg$callback, callback="", status=status, payload=payload)

   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getPatientClassification
#----------------------------------------------------------------------------------------------------
getCaisisPatientHistory <- function(WS, msg)
{
   callback <- msg$callback
   patientIDs <- msg$payload
   if(all(nchar(patientIDs)==0))
       patientIDs = NA

   category.name <- "patientHistoryEvents"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(DATA.PROVIDERS))
   #printf("--- payload: %s", paste(patientIDs, collapse=","));
    
   if(!category.name %in% ls(DATA.PROVIDERS)){
       error.message <- "Oncoscape DataProviderBridge error:  no caisisPatientHistoryProvider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryEvents
   events <- getEvents(patientHistoryProvider, patient.ids=patientIDs)
   if(all(is.na(patientIDs)))
       patient.count <- "all"
   else
       patient.count <- length(patientIDs)
   
   printf("found %d caisis-style events for %s patients", length(events), patient.count)
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=events)

   printf("DataProviderBridge.R, getCaisisPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getCaisisPatientHistory
#----------------------------------------------------------------------------------------------------
createNewUserID <- function(WS, msg)
{
   printf("===== generate new User ID")
             
   category.name <- "UserIDmap"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }

     userID <- msg$payload

     if(nchar(userID)==0 | is.na(userID)){
  	   NewID <- sample(c(1,2), 36, replace=T)
	   NewID[which(NewID==1)] <- sample(LETTERS, length(which(NewID==1)), replace=T)
	   NewID[which(NewID==2)] <- sample(0:9, length(which(NewID==2)), replace=T)
	 
       userID <- paste(NewID, collapse="")
     }

   AccountSettingsProvider <- USER.SETTINGS$UserIDmap
   while(userID %in% userIDs(AccountSettingsProvider)){
       	 NewID <- sample(c(1,2), 36, replace=T)
	     NewID[which(NewID==1)] <- sample(LETTERS, length(which(NewID==1)), replace=T)
	     NewID[which(NewID==2)] <- sample(0:9, length(which(NewID==2)), replace=T)
	 
         userID <- paste(NewID, collapse="")
    }

    payload <- list(userID = userID)

    return.msg <- list(cmd=msg$callback, payload=payload, status="success")
    
    sendOutput(DATA=toJSON(return.msg), WS=WS)
}
#----------------------------------------------------------------------------------------------------
UserIDexists <- function(WS, msg)
{
   printf("===== checking User ID")
             
   category.name <- "UserIDmap"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }

     userID <- msg$payload
     UserStatus <- FALSE;

   AccountSettingsProvider <- USER.SETTINGS$UserIDmap
   if(userID %in% userIDs(AccountSettingsProvider)){
       	  UserStatus = TRUE
    }

    return.msg <- list(cmd=msg$callback, payload=UserStatus, status="success")
    
    sendOutput(DATA=toJSON(return.msg), WS=WS)
}

#----------------------------------------------------------------------------------------------------
addNewUserToList <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
   printf("===== Add User ID to List")
             
   callback <- msg$callback
   payload <- msg$payload
   
   userID <- payload[["userID"]]
   username <- payload[["username"]]
   
   printf("Adding ID %s and name %s to list", userID, username)
   
   if(nchar(userID)==0)
       userID = NA
 
    if(is.na(userID)){
       error.message <- "Oncoscape DataProviderBridge error:  no userID defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }

   category.name <- "UserIDmap"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- username: %s", username);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }
       
   previousUsers <- NumUsers(USER.SETTINGS$UserIDmap)

   USER.SETTINGS$UserIDmap <- addUserID(USER.SETTINGS$UserIDmap, userID=userID, username=username)
   updatedUsers <- NumUsers(USER.SETTINGS$UserIDmap)

   addedUsers <- updatedUsers - previousUsers
   
   printf("added %d (== %d) users with username: %s", length(userID), addedUsers, username)
   
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=list(userID=userID, username= username))

   printf("DataProviderBridge.R, addNewUserToList responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getCaisisPatientHistory
#----------------------------------------------------------------------------------------------------
getUserSelectionnames <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
  
   callback <- msg$callback
   userID <- msg$payload$userID
   if(nchar(userID)==0)
       userID = NA

  if(is.na(userID)){
       error.message <- "Oncoscape DataProviderBridge error:  no userID defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   category.name <- "PatientSelectionHistory"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- userID: %s", userID);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientSelectionHistoryProvider <- USER.SETTINGS$PatientSelectionHistory
   selectionnames <- getSelectionnames(patientSelectionHistoryProvider, userID=userID)

    selection.count <- length(selectionnames)
   
   printf("found %d (== %d) saved selections for user: %s", length(selectionnames), selection.count, userID)
   
   return.cmd = msg$callback
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload=selectionnames)

   printf("DataProviderBridge.R, getUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getUserSelectPatientHistory
#----------------------------------------------------------------------------------------------------
getUserSelectPatientHistory <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
  
#   printf("--- DataProviderBridge looking for payload %s",  msg$payload)
   payload <- msg$payload
   userID <- payload["userID"]
   if(nchar(userID)==0)
       userID = NA
   selectionnames <- payload["selectionname"]
   if(all(nchar(selectionnames))==0)
       selectionnames = NA

   category.name <- "PatientSelectionHistory"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- userID: %s", userID);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       }

   patientSelectionHistoryProvider <- USER.SETTINGS$PatientSelectionHistory
   selections <- getSelection(patientSelectionHistoryProvider, userID=userID, selectionnames=selectionnames)

   if(all(is.na(selectionnames)))
       selection.count <- "all"
   else
       selection.count <- length(selectionnames)
   
   printf("found %d (== %d) saved selections for user: %s", length(selections), selection.count, userID)
   
   return.msg <- list(cmd=msg$callback, status="success", payload=selections)

   printf("DataProviderBridge.R, getUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
   
   sendOutput(DATA=toJSON(return.msg), WS=WS)

} # getUserSelectPatientHistory
#----------------------------------------------------------------------------------------------------
addUserSelectPatientHistory <- function(WS, msg)
{
  # only allows for 1 username at a time
  # 
   printf("===== Add User Selection to Patient History")
   printf("for userID %s", msg$payload$userID)
                
   callback <- msg$callback
   userID <- msg$payload$userID
   if(nchar(userID)==0)
       userID = NA
   selectionname <- msg$payload$selectionname
   if(nchar(selectionname)==0)
       selectionname = NA
   patientIDs <- msg$payload$PatientIDs
   if(all(nchar(patientIDs)==0))
       patientIDs = NA


  if(is.na(userID)){
       error.message <- "Oncoscape DataProviderBridge error:  no userID defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
  }  
  if(all(is.na(patientIDs))){
       error.message <- "Oncoscape DataProviderBridge error:  no patient IDs defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
  }  
  
  selection <- list(selectionname = selectionname, 
                    patientIDs = patientIDs, 
                    tab = msg$payload$Tab, 
                    settings = msg$payload$Settings)

   category.name <- "PatientSelectionHistory"

   printf("--- DataProviderBridge looking for '%s': %s",  category.name, category.name %in% ls(USER.SETTINGS))
   printf("--- userID: %s", userID);
    
   if(!category.name %in% ls(USER.SETTINGS)){
       error.message <- "Oncoscape DataProviderBridge error:  no patientSelectionHistory Provider defined"
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
    }
       
   if(!(userID %in% userIDsWithSelection(USER.SETTINGS$PatientSelectionHistory))){
       USER.SETTINGS$PatientSelectionHistory<- addUserIDforSelection(USER.SETTINGS$PatientSelectionHistory, userID)
   }

  printf("Current User length: %d", NumUsersWithSelection(USER.SETTINGS$PatientSelectionHistory))
  printf("Current User Selection length: %d", NumUserSelections(USER.SETTINGS$PatientSelectionHistory, userID))
  previousSelection <-  NumUserSelections(USER.SETTINGS$PatientSelectionHistory, userID)
  
   		i=0; ValidSelectionName = selectionname
        while(!ValidSelectionname(USER.SETTINGS$PatientSelectionHistory, userID=userID, selectionname=ValidSelectionName)){
		    i=i+1;
		    ValidSelectionName = paste(selectionname,i, sep="_")
		}
  
  USER.SETTINGS$PatientSelectionHistory <- addSelection(USER.SETTINGS$PatientSelectionHistory, userID=userID, selectionname=ValidSelectionName,
                                  patientIDs = patientIDs, tab = msg$payload$Tab, settings = msg$payload$Settings)

   if(previousSelection >= NumUserSelections(USER.SETTINGS$PatientSelectionHistory, userID)){
       error.message <- "Oncoscape DataProviderBridge error:  could not add saved selection"
       print(error.message)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       printf("DataProviderBridge.R, addUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback);
       sendOutput(DATA=toJSON(return.msg), WS=WS)
   } else {
    
       printf("added %s saved selection for user: %s", ValidSelectionName, userID)
   
        SavedSelectionRow <- list(selectionname = ValidSelectionName,
                          tab = msg$payload$Tab, 
                          settings = msg$payload$Settings, 
                          patientIDs = patientIDs);

        return.cmd = msg$callback
        return.msg <- list(cmd=msg$callback, callback="", status="success", payload=SavedSelectionRow)

        printf("DataProviderBridge.R, addUserSelectPatientHistory responding to '%s' with '%s'", msg$cmd, msg$callback); 
        sendOutput(DATA=toJSON(return.msg), WS=WS)
   }
} # addUserSelectPatientHistory
#----------------------------------------------------------------------------------------------------
# this message handler requires that a "patientHistoryTable" is in DATA.PROVIDERS
# no support here yet for a "patientHistoryEvents" data source
calculatePairedDistributionsOfPatientHistoryData <- function(WS, msg)
{
   #browser()
   
   callback <- msg$callback
   attribute.of.interest <- msg$payload[["attribute"]]
   numberOfPopulations <- msg$payload[["popCount"]]
   
   
      # define the basic error message, to which details can be added
   error.msg <- "Error.  DataProviderBridge::calculatePairedDistributionsOfPatientHistoryData"

   testing <- FALSE
   
   if("mode" %in% names(msg$payload)){
      testing <- length(grep("test",  msg$payload[["mode"]], ignore.case=TRUE)) > 0
      } # no "mode" in payload
       
      # make sure we have the data
   data.category.name <- "patientHistoryTable"
   printf("--- DataProviderBridge looking for '%s': %s",  data.category.name, data.category.name %in% ls(DATA.PROVIDERS))
   
   if(!data.category.name %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s defined", data.category.name)
       return.msg <- list(cmd=msg$callback, payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

   provider <- DATA.PROVIDERS[[data.category.name]]
   tbl <- getTable(provider)
   if(!attribute.of.interest %in% colnames(tbl)){
       error.msg <- sprintf("%s: attribute.of.interest not in colnames(tbl): '%s'",
                            error.msg, attribute.of.interest)
       return.msg <- list(cmd=msg$callback, payload=error.msg, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

	all.ids <- tbl$ID
   
	dataset<-list()
   
	if(testing){  # generate random populations
		full.count <- length(all.ids) #ID list length
		population.sizes <- as.integer(full.count/10) #determine pop size
		count <- 1;
		for(i in 1:numberOfPopulations){
			population.IDs<- all.ids[sample(1:full.count, population.sizes)] #grab some IDs
			population.name <- sprintf("pop%d", i)  # name pop
			for(j in 1:population.sizes){
      			random.value <- sample(1:100, 1) # grab random number
      			dataset[[count]] <- list(name=population.name, ID=population.IDs[j], value=random.value)
      			count <- 1 + count
      		}
      	}
    }

   #if(testing){  # generate two random populations
    #  full.count <- length(all.ids)
    #  population.sizes <- as.integer(full.count/10)
    #  population.1 <- all.ids[sample(1:full.count, population.sizes)]
    #  population.2 <- all.ids[sample(1:full.count, population.sizes)]
    #    # eliminate overlap
    #  population.2 <- setdiff(population.2, population.1)
    #  }
   #else {
    #  population.1 <- msg$payload$pop1
    #  population.2 <- msg$payload$pop2
    #  population.1 <- intersect(population.1, all.ids)
    #  population.2 <- intersect(population.2, all.ids)
    #  }

	#for(i in 1:max){
	#	population.name <- sprintf("pop%d", i)  # dumb name, but maybe adequate
	#	random.values <- sample(1:100, 10)                     # grab 10 numbers 1:100 at random
	#	payload[[i]] <- list(name=population.name, values=random.values)
    #}

      
   populations.error <- FALSE
   #if(length(population.1) < 1){
   #   error.msg <- sprintf("%s. population.1 has no members", error.msg)
   #   populations.error <- TRUE
   #   }

   #if(length(population.2) < 1){
   #   error.msg <- sprintf("%s. population.2 has no members", error.msg)
   #   populations.error <- TRUE
   #   }
      
   if(populations.error){    
      return.msg <- list(cmd=msg$callback, payload=error.msg, status="error")
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      }
                              
   #pop.indices.1 <- match(population.1, all.ids)
   #pop.indices.2 <- match(population.2, all.ids)
      
   #printf("pop.indices.1: %d", length(pop.indices.1))
   #printf("pop.indices.2: %d", length(pop.indices.2))
   
   #vals.1 <- as.numeric(tbl[pop.indices.1, attribute.of.interest])
   #vals.2 <- as.numeric(tbl[pop.indices.2, attribute.of.interest])

   #names(vals.1) <- tbl$ID[pop.indices.1]
   #names(vals.2) <- tbl$ID[pop.indices.2]
   
   return.msg <- list(cmd=msg$callback, callback="", status="success", payload = dataset)
   sendOutput(DATA=toJSON(return.msg), WS=WS)   

} # calculatePairedDistributionsOfPatientHistoryData
#----------------------------------------------------------------------------------------------------
tTest <- function(WS, msg)
{
 pop1 <- msg$payload[["pop1"]]
 pop2 <- msg$payload[["pop2"]]
 pValue <- t.test(pop1, pop2)$p.value
 return.msg <- list(cmd="tTest", callback="", status="success", payload = toString(pValue))
 sendOutput(DATA=toJSON(return.msg), WS=WS)
}
#----------------------------------------------------------------------------------------------------
