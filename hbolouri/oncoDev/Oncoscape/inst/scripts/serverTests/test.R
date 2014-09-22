#----------------------------------------------------------------------------------------------------
library(RUnit)
library(websockets)
library(RJSONIO)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
TEST.PORT = 7777L   # local build of tabsApp listens here
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_oncoscape_ping();
   test_request_mRNA_data()  # for entities and features (patients & genes) for which data exists
   test_request_mRNA_data_bogus_entities()
   test_request_mRNA_data_bogus_features()
   test_request_mRNA_data_largeSet()

   test_plsr_ping();
   test_plsr();
   test_plsr_withGeneSet();
   
   
} # runTests
#----------------------------------------------------------------------------------------------------
callbackFunction <- function(DATA, WS, ...)
{
    unparsed.msg <<- rawToChar(DATA)
    parsed.msg <- as.list(fromJSON(unparsed.msg))
    msg.incoming <<- parsed.msg

} # callbackFunction
#----------------------------------------------------------------------------------------------------
if(!exists("client")){
   client <- websocket("ws://localhost", port=TEST.PORT)
   }
setCallback("receive", callbackFunction, client);
#----------------------------------------------------------------------------------------------------
test_oncoscape_ping <- function()
{
   print("--- test_oncoscape_ping")
   cmd <- "oncoscape.ping"
   status <- "request"
   callback <- "handle.oncoscape.ping"
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload="")), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")
   checkEquals(head(msg.incoming$payload), "oncoscape ping back!")

} # test_oncoscape_ping
#----------------------------------------------------------------------------------------------------
test_request_mRNA_data <- function()
{
   print("--- test_request_mRNA_data")

    #  msg = {cmd:"get_mRNA_data",
    #          callback: "handle_angio_mRNA_data",
    #          status:"request",
    #          payload:{entities: entities, features: features}
    #          };

   cmd <- "get_mRNA_data"
   callback <- "handle.mRNA.results"
   status <- "request"
   payload <- list(entities=c("TCGA.06.0877", "TCGA.19.0964"),
                   features=c("TEK","JUN","SP1"))
       
   msg <- list(cmd=cmd, callback=callback, status=status, payload=payload)
   websocket_write(toJSON(msg), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")

   data <- fromJSON(msg.incoming$payload)
      # expact an unamed list of length 2, one for each entity, the moral
      # equivalent of a 2 x 4 array: 3 genes + 1 rowname (the entity name)
   checkEquals(length(data), 2)
   checkEquals(length(data[[1]]), 4)

   checkEquals(names(data[[1]]), c("TEK","JUN","SP1", "rowname"))
   checkEquals(names(data[[2]]), c("TEK","JUN","SP1", "rowname"))
   checkEquals(data[[1]]$rowname, "TCGA.06.0877")
   checkEquals(data[[2]]$rowname, "TCGA.19.0964")

   checkEqualsNumeric(data[[1]]$TEK, -0.37949)
   checkEqualsNumeric(data[[2]]$TEK, -1.0123)

} # test_request_mRNA_data
#----------------------------------------------------------------------------------------------------
test_request_mRNA_data_bogus_entities <- function()
{
   print("--- test_request_mRNA_entities")

    #  msg = {cmd:"get_mRNA_data",
    #          callback: "handle_angio_mRNA_data",
    #          status:"request",
    #          payload:{entities: entities, features: features}
    #          };

   cmd <- "get_mRNA_data"
   callback <- "handle.mRNA.results"
   status <- "request"
   payload <- list(entities=c("fee", "fi", "fo"),
                   features=c("TEK","JUN","SP1"))
       
   msg <- list(cmd=cmd, callback=callback, status=status, payload=payload)
   websocket_write(toJSON(msg), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status,  "failure")
   checkEquals(msg.incoming$payload, "empty table")

} # test_request_mRNA_data_bogus_entities
#----------------------------------------------------------------------------------------------------
test_request_mRNA_data_bogus_features <- function()
{
   print("--- test_request_mRNA_features_bogus_features")

    #  msg = {cmd:"get_mRNA_data",
    #          callback: "handle_angio_mRNA_data",
    #          status:"request",
    #          payload:{entities: entities, features: features}
    #          };

   cmd <- "get_mRNA_data"
   callback <- "handle.mRNA.results"
   status <- "request"

   entities=c("TCGA.06.0877", "TCGA.19.0964")
   payload <- list(entities=entities, features=c("bob","jim","joe"))
       
   msg <- list(cmd=cmd, callback=callback, status=status, payload=payload)
   websocket_write(toJSON(msg), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status,  "failure")
   checkEquals(msg.incoming$payload, "empty table")

} # test_request_mRNA_data_bogus_features
#----------------------------------------------------------------------------------------------------
test_request_mRNA_data_largeSet <- function()
{
   print("--- test_request_mRNA_data_largeSet")

    #  msg = {cmd:"get_mRNA_data",
    #          callback: "handle_angio_mRNA_data",
    #          status:"request",
    #          payload:{entities: entities, features: features}
    #          };

   cmd <- "get_mRNA_data"
   callback <- "handle.mRNA.results"
   status <- "request"
     # the tcga gbm "classifier patients" mrna data set, zscores
     # print(load("../../extdata/tcgaGBM/mrnaGBM-304patients-1375genes.RData"))  # tbl.mrna
     # all patient names from the above dataset
   
   patients <- c("TCGA.02.0001", "TCGA.02.0003", "TCGA.02.0006", "TCGA.02.0007", "TCGA.02.0009", 
                 "TCGA.02.0010", "TCGA.02.0011", "TCGA.02.0014", "TCGA.02.0021", "TCGA.02.0024", 
                 "TCGA.02.0027", "TCGA.02.0028", "TCGA.02.0033", "TCGA.02.0034", "TCGA.02.0037", 
                 "TCGA.02.0038", "TCGA.02.0043", "TCGA.02.0046", "TCGA.02.0047", "TCGA.02.0052", 
                 "TCGA.02.0054", "TCGA.02.0055", "TCGA.02.0057", "TCGA.02.0058", "TCGA.02.0060", 
                 "TCGA.02.0074", "TCGA.02.0107", "TCGA.02.0080", "TCGA.02.0075", "TCGA.02.0099", 
                 "TCGA.02.0085", "TCGA.02.0083", "TCGA.02.0102", "TCGA.02.0064", "TCGA.02.0116", 
                 "TCGA.02.0086", "TCGA.02.0115", "TCGA.02.0089", "TCGA.02.0114", "TCGA.02.0113", 
                 "TCGA.06.0129", "TCGA.06.0139", "TCGA.06.0145", "TCGA.06.0130", "TCGA.06.0140", 
                 "TCGA.06.0122", "TCGA.06.0133", "TCGA.06.0141", "TCGA.06.0124", "TCGA.06.0137", 
                 "TCGA.06.0142", "TCGA.06.0147", "TCGA.06.0125", "TCGA.06.0143", "TCGA.06.0148", 
                 "TCGA.06.0126", "TCGA.06.0169", "TCGA.06.0128", "TCGA.06.0176", "TCGA.06.0138", 
                 "TCGA.06.0156", "TCGA.06.0185", "TCGA.06.0208", "TCGA.06.0173", "TCGA.06.0187", 
                 "TCGA.06.0210", "TCGA.06.0240", "TCGA.06.0157", "TCGA.06.0174", "TCGA.06.0188", 
                 "TCGA.06.0211", "TCGA.06.0241", "TCGA.06.0158", "TCGA.06.0189", "TCGA.06.0132", 
                 "TCGA.06.0160", "TCGA.06.0190", "TCGA.06.0214", "TCGA.06.0171", "TCGA.06.0154", 
                 "TCGA.06.0166", "TCGA.06.0195", "TCGA.06.0219", "TCGA.06.0167", "TCGA.06.0178", 
                 "TCGA.06.0197", "TCGA.06.0221", "TCGA.06.0168", "TCGA.06.0184", "TCGA.06.0237", 
                 "TCGA.06.0201", "TCGA.06.0216", "TCGA.02.0422", "TCGA.06.0175", "TCGA.06.0397", 
                 "TCGA.06.0412", "TCGA.08.0510", "TCGA.08.0518", "TCGA.08.0522", "TCGA.08.0524", 
                 "TCGA.08.0525", "TCGA.02.0269", "TCGA.02.0337", "TCGA.02.0446", "TCGA.06.0177", 
                 "TCGA.06.0410", "TCGA.08.0514", "TCGA.02.0087", "TCGA.02.0271", "TCGA.02.0325", 
                 "TCGA.02.0338", "TCGA.02.0451", "TCGA.06.0179", "TCGA.08.0516", "TCGA.08.0529", 
                 "TCGA.02.0106", "TCGA.02.0281", "TCGA.02.0326", "TCGA.02.0339", "TCGA.02.0456", 
                 "TCGA.06.0182", "TCGA.06.0413", "TCGA.08.0517", "TCGA.08.0531", "TCGA.02.0111", 
                 "TCGA.02.0285", "TCGA.06.0146", "TCGA.06.0194", "TCGA.06.0414", "TCGA.02.0289", 
                 "TCGA.02.0330", "TCGA.02.0430", "TCGA.06.0149", "TCGA.06.0394", "TCGA.08.0509", 
                 "TCGA.08.0520", "TCGA.02.0290", "TCGA.02.0332", "TCGA.02.0432", "TCGA.06.0162", 
                 "TCGA.08.0521", "TCGA.02.0260", "TCGA.02.0317", "TCGA.02.0333", "TCGA.02.0439", 
                 "TCGA.06.0164", "TCGA.06.0402", "TCGA.08.0511", "TCGA.02.0266", "TCGA.02.0321", 
                 "TCGA.02.0440", "TCGA.06.0409", "TCGA.08.0512", "TCGA.02.0258", "TCGA.02.0004", 
                 "TCGA.02.0048", "TCGA.08.0245", "TCGA.08.0353", "TCGA.08.0380", "TCGA.02.0051", 
                 "TCGA.08.0246", "TCGA.08.0354", "TCGA.02.0015", "TCGA.02.0059", "TCGA.08.0344", 
                 "TCGA.08.0355", "TCGA.08.0385", "TCGA.02.0016", "TCGA.02.0068", "TCGA.08.0346", 
                 "TCGA.08.0356", "TCGA.08.0389", "TCGA.02.0023", "TCGA.02.0070", "TCGA.08.0347", 
                 "TCGA.08.0357", "TCGA.08.0390", "TCGA.02.0025", "TCGA.02.0104", "TCGA.08.0348", 
                 "TCGA.08.0359", "TCGA.08.0392", "TCGA.02.0026", "TCGA.08.0350", "TCGA.08.0360", 
                 "TCGA.02.0039", "TCGA.08.0244", "TCGA.08.0351", "TCGA.08.0375", "TCGA.02.0079", 
                 "TCGA.06.0648", "TCGA.12.0616", "TCGA.02.0084", "TCGA.08.0345", "TCGA.12.0618", 
                 "TCGA.06.0127", "TCGA.08.0349", "TCGA.12.0619", "TCGA.06.0152", "TCGA.08.0352", 
                 "TCGA.12.0620", "TCGA.06.0238", "TCGA.08.0358", "TCGA.06.0644", "TCGA.08.0373", 
                 "TCGA.06.0645", "TCGA.08.0386", "TCGA.06.0646", "TCGA.06.0192", "TCGA.06.0686", 
                 "TCGA.06.0744", "TCGA.12.0775", "TCGA.12.0688", "TCGA.06.0745", "TCGA.12.0776", 
                 "TCGA.06.0649", "TCGA.06.0747", "TCGA.12.0778", "TCGA.12.0692", "TCGA.06.0749", 
                 "TCGA.12.0780", "TCGA.12.0654", "TCGA.12.0703", "TCGA.06.0750", "TCGA.12.0656", 
                 "TCGA.12.0707", "TCGA.12.0657", "TCGA.15.0742", "TCGA.12.0772", "TCGA.06.0743", 
                 "TCGA.12.0773", "TCGA.14.0787", "TCGA.12.0821", "TCGA.16.0849", "TCGA.06.0878", 
                 "TCGA.14.0789", "TCGA.12.0822", "TCGA.16.0850", "TCGA.06.0879", "TCGA.14.0813", 
                 "TCGA.12.0826", "TCGA.16.0861", "TCGA.06.0881", "TCGA.14.0817", "TCGA.12.0827", 
                 "TCGA.14.0867", "TCGA.06.0882", "TCGA.12.0670", "TCGA.12.0828", "TCGA.14.0871", 
                 "TCGA.12.0829", "TCGA.06.0875", "TCGA.16.0846", "TCGA.06.0876", "TCGA.12.0820", 
                 "TCGA.16.0848", "TCGA.06.0877", "TCGA.06.0155", "TCGA.19.0964", "TCGA.16.1063", 
                 "TCGA.12.1092", "TCGA.19.1392", "TCGA.15.1447", "TCGA.14.0736", "TCGA.14.1034", 
                 "TCGA.06.1084", "TCGA.12.1093", "TCGA.14.1396", "TCGA.15.1449", "TCGA.14.0783", 
                 "TCGA.16.1045", "TCGA.06.1086", "TCGA.12.1094", "TCGA.14.1401", "TCGA.14.1451", 
                 "TCGA.14.0786", "TCGA.16.1047", "TCGA.06.1087", "TCGA.12.1095", "TCGA.14.1402", 
                 "TCGA.14.1452", "TCGA.16.1055", "TCGA.12.1088", "TCGA.12.1096", "TCGA.26.1438", 
                 "TCGA.14.1453", "TCGA.19.0960", "TCGA.16.1056", "TCGA.12.1089", "TCGA.12.1097", 
                 "TCGA.26.1440", "TCGA.19.0962", "TCGA.16.1060", "TCGA.12.1090", "TCGA.12.1098", 
                 "TCGA.26.1443", "TCGA.14.1459", "TCGA.19.0963", "TCGA.16.1062", "TCGA.12.1091", 
                 "TCGA.12.1099", "TCGA.15.1446", "TCGA.19.0955", "TCGA.14.1454")

     genes <- c("ABAT",        "ABCA1",       "ABCC9",       "ABCD2",       "ABCG2", 
                "ABI1",        "ABL1",        "ABL2",        "ACPP",        "ACSBG1", 
                "ACSL1",       "ACSL3",       "ACSL4",       "ACSL6",       "ACTN4", 
                "ACTR1A",      "ACVRL1",      "ACYP2",       "ADAM12",      "ADAM19", 
                "ADCY9",       "ADD3",        "AFAP1",       "AFF1",        "AFF3", 
                "AFF4",        "AGTPBP1",     "AGXT2L1",     "AHNAK2",      "AIM1", 
                "AKAP13",      "AKAP8L",      "AKAP9",       "AKR7A3",      "AKT1", 
                "AKT2",        "AKT3",        "ALCAM",       "ALDH2",       "ALDH3B1", 
                "ALK",         "ALOX5",       "AMOTL2",      "AMPD3",       "ANG", 
                "ANGPT1",      "ANGPT2",      "ANGPTL4",     "ANKRD11",     "ANKRD46", 
                "ANKS1B",      "ANXA1",       "ANXA2",       "ANXA3",       "ANXA4", 
                "ANXA5",       "ANXA7",       "AOF2",        "AP3D1",       "APBA3", 
                "APC",         "ARAF",        "ARHGAP26",    "ARHGAP29",    "ARHGEF12", 
                "ARHGEF18",    "ARHGEF9",     "ARID1A",      "ARNT",        "ARNTL", 
                "ARPC1A",      "ARPC1B",      "ARRB1",       "ARSJ",        "ASCL1", 
                "ASL",         "ASNS",        "ASPSCR1",     "ASXL1",       "ATAD5", 
                "ATF1",        "ATIC",        "ATM",         "ATP1A1",      "ATP1A3", 
                "ATP2B3",      "ATP5F1",      "ATP5L",       "ATPIF1",      "ATRNL1", 
                "ATRX",        "AXIN1",       "B3GALT1",     "BAI3",        "BAP1", 
                "BASP1",       "BAT2D1",      "BATF",        "BCAN",        "BCAS1", 
                "BCL10",       "BCL11A",      "BCL11B",      "BCL2",        "BCL2L1", 
                "BCL3",        "BCL6",        "BCL7A",       "BCL9",        "BCOR", 
                "BCR",         "BDKRB2",      "BEST1",       "BEX1",        "BICD2", 
                "BIRC3",       "BLM",         "BLVRB",       "BMI1",        "BMPR1A", 
                "BMS1",        "BNC2",        "BOP1",        "BPTF",        "BRAF", 
                "BRCA1",       "BRCA2",       "BRD3",        "BRD4",        "BRIP1", 
                "BRPF1",       "BTBD2",       "BTG1",        "BUB1B",       "C19ORF22", 
                "C19ORF28",    "C19ORF29",    "C19ORF6",     "C1ORF106",    "C1ORF38", 
                "C1ORF54",     "C1ORF61",     "C1QL1",       "C20ORF42",    "C2ORF44", 
                "C5AR1",       "C6ORF134",    "CA10",        "CA4",         "CACNA1D", 
                "CALM1",       "CALM2",       "CALR",        "CAMK2B",      "CAMK2G", 
                "CAMSAP1L1",   "CAMTA1",      "CANT1",       "CARS",        "CASC5", 
                "CASK",        "CASP1",       "CASP2",       "CASP4",       "CASP5", 
                "CASP8",       "CASQ1",       "CAST",        "CBFA2T3",     "CBFB", 
                "CBL",         "CBLB",        "CBLC",        "CBX1",        "CBX4", 
                "CC2D1A",      "CCDC109B",    "CCDC121",     "CCDC6",       "CCK", 
                "CCL2",        "CCNB1IP1",    "CCND1",       "CCND2",       "CCND3", 
                "CCNE1",       "CCR5",        "CD14",        "CD151",       "CD2AP", 
                "CD3EAP",      "CD4",         "CD44",        "CD74",        "CD79A", 
                "CD79B",       "CD97",        "CDC25A",      "CDC42",       "CDC42EP1", 
                "CDC7",        "CDC73",       "CDCP1",       "CDH1",        "CDH11", 
                "CDH2",        "CDH4",        "CDH6",        "CDK2",        "CDK4", 
                "CDK5R1",      "CDK6",        "CDKN1A",      "CDKN1B",      "CDKN2A", 
                "CDKN2B",      "CDKN2C",      "CDR1",        "CDV3",        "CDX2", 
                "CEBPA",       "CEBPB",       "CENTD1",      "CENTD3",      "CENTG1", 
                "CHCHD7",      "CHD4",        "CHD7",        "CHEK2",       "CHERP", 
                "CHI3L1",      "CHIC2",       "CHN1",        "CHST3",       "CIC", 
                "CIITA",       "CIZ1",        "CKAP4",       "CKB",         "CLASP2", 
                "CLCA4",       "CLCF1",       "CLEC2B",      "CLGN",        "CLIC1", 
                "CLIP2",       "CLP1",        "CLTC",        "CLTCL1",      "CNBP", 
                "CNN2",        "CNOT3",       "CNTN1",       "COL1A1",      "COL1A2", 
                "COL4A2",      "COL5A1",      "COL8A2",      "COPZ2",       "COX5B", 
                "COX6C",       "CPNE6",       "CRB1",        "CRBN",        "CREB1", 
                "CREB3L1",     "CREB3L2",     "CREB5",       "CREBBP",      "CRMP1", 
                "CRTC1",       "CRTC3",       "CRYL1",       "CRYM",        "CRYZL1", 
                "CSF3R",       "CSGLCA-T",    "CSNK1E",      "CSPG5",       "CSTA", 
                "CTNNB1",      "CTSA",        "CTSB",        "CTSC",        "CTSZ", 
                "CUL1",        "CUTC",        "CXXC4",       "CYBRD1",      "CYLD", 
                "DAB2",        "DAG1",        "DAXX",        "DBN1",        "DCBLD2", 
                "DCP1A",       "DCX",         "DDB2",        "DDIT3",       "DDX10", 
                "DDX42",       "DDX5",        "DDX6",        "DENND2A",     "DGKI", 
                "DHRS9",       "DIAPH1",      "DICER1",      "DLC1",        "DLL3", 
                "DMWD",        "DNAJC13",     "DNM2",        "DNM3",        "DNMT1", 
                "DNMT3A",      "DOCK5",       "DOCK6",       "DOK3",        "DOT1L", 
                "DPF1",        "DPP3",        "DPP6",        "DPYSL4",      "DRAM", 
                "DSC2",        "DSE",         "DUSP22",      "DUSP26",      "DYNC1I1", 
                "E2F1",        "E2F3",        "ECGF1",       "ECOP",        "EDG1", 
                "EDIL3",       "EED",         "EEF2",        "EFEMP2",      "EGFR", 
                "EHD2",        "EIF4A2",      "ELAVL1",      "ELAVL2",      "ELF4", 
                "ELK4",        "ELL",         "ELN",         "ELOVL2",      "EML4", 
                "EMP3",        "ENG",         "ENPP2",       "ENPP4",       "EP300", 
                "EP400",       "EPAS1",       "EPB41",       "EPB41L3",     "EPHB1", 
                "EPHB4",       "EPS15",       "ERBB2",       "ERBB3",       "ERC1", 
                "ERCC2",       "ERCC3",       "ERCC4",       "ERCC5",       "ERG", 
                "ETV1",        "ETV4",        "ETV5",        "ETV6",        "EVI1", 
                "EVI2A",       "EWSR1",       "EXT1",        "EXT2",        "EXTL3", 
                "EYA2",        "EZH1",        "EZH2",        "FAM110B",     "FAM125B", 
                "FAM38A",      "FAM46A",      "FAM46C",      "FAM49B",      "FAM77C", 
                "FANCA",       "FANCC",       "FANCE",       "FANCF",       "FANCG", 
                "FAS",         "FBXL11",      "FBXO11",      "FBXO17",      "FBXO21", 
                "FBXO3",       "FBXW7",       "FCGR2A",      "FCGR2B",      "FER", 
                "FER1L3",      "FES",         "FEV",         "FEZF2",       "FGF2", 
                "FGF9",        "FGFR1",       "FGFR1OP",     "FGFR2",       "FGFR3", 
                "FH",          "FHIT",        "FHL2",        "FHOD1",       "FHOD3", 
                "FIP1L1",      "FLG",         "FLI1",        "FLJ11286",    "FLJ20273", 
                "FLJ21963",    "FLJ22655",    "FLJ22662",    "FLNA",        "FLRT1", 
                "FLT3",        "FMNL1",       "FN1",         "FNBP1",       "FNDC3B", 
                "FOLR2",       "FOXL2",       "FOXO1",       "FOXO3",       "FOXO4", 
                "FPRL2",       "FRG1",        "FSTL3",       "FUBP1",       "FURIN", 
                "FUS",         "FUT9",        "FVT1",        "FXYD1",       "FXYD5", 
                "FXYD6",       "FZD1",        "FZD3",        "FZD7",        "FZR1", 
                "GAB1",        "GABARAPL2",   "GABRA3",      "GABRB2",      "GADD45G", 
                "GALNT4",      "GANAB",       "GAS1",        "GAS7",        "GATA1", 
                "GATA2",       "GATA3",       "GATAD2A",     "GCN1L1",      "GCNT1", 
                "GDF2",        "GJA1",        "GLG1",        "GLI1",        "GLI2", 
                "GLT25D1",     "GMPS",        "GNA11",       "GNA15",       "GNAI1", 
                "GNAS",        "GNG4",        "GNG7",        "GNL1",        "GNL2", 
                "GOLGA2",      "GOLGA3",      "GOLGA5",      "GPC3",        "GPHN", 
                "GPM6A",       "GPR161",      "GPR17",       "GPR172A",     "GPR22", 
                "GPR23",       "GPR56",       "GPRIN2",      "GRB2",        "GRIA2", 
                "GRID2",       "GRIK1",       "GRIK5",       "GRM1",        "GRM3", 
                "GRN",         "GSK3B",       "GSTA4",       "GSTK1",       "GSTT1", 
                "GTF2F1",      "GUK1",        "GUSB",        "GYS1",        "H3F3A", 
                "H3F3B",       "HCFC1",       "HDAC2",       "HELZ",        "HERPUD1", 
                "HEXA",        "HEXB",        "HEY1",        "HFE",         "HGF", 
                "HIF1A",       "HIF1AN",      "HIP1",        "HIST1H4I",    "HK3", 
                "HLF",         "HMG20B",      "HMGA1",       "HMGA2",       "HMGB3", 
                "HMOX1",       "HN1",         "HNF1A",       "HNRNPA2B1",   "HNRPA3", 
                "HNRPAB",      "HNRPH3",      "HNRPM",       "HNRPUL2",     "HOXA11", 
                "HOXA4",       "HOXA5",       "HOXA7",       "HOXA9",       "HOXC11", 
                "HOXC13",      "HOXD11",      "HOXD13",      "HOXD3",       "HPCA", 
                "HPCAL4",      "HPRT1",       "HRAS",        "HRASLS",      "HS3ST3B1", 
                "HSP90AA1",    "HSP90AB1",    "HSP90B1",     "HSPBP1",      "ICAM3", 
                "ICK",         "ID1",         "IDH1",        "IDH2",        "IFI30", 
                "IFNA2",       "IFNA6",       "IFNA8",       "IFNB1",       "IFNW1", 
                "IGF1R",       "IGFBP6",      "IKZF1",       "IL15RA",      "IL1R1", 
                "IL1RAPL1",    "IL2",         "IL21R",       "IL4R",        "IL6ST", 
                "IL7R",        "IL8",         "ILF3",        "ILK",         "IMPA1", 
                "IQGAP1",      "IRF3",        "IRF4",        "IRS1",        "IRS2", 
                "ITGA4",       "ITGA5",       "ITGA7",       "ITGAM",       "ITGB2", 
                "ITGB3",       "ITGB8",       "ITK",         "JAG1",        "JAK1", 
                "JAK2",        "JAK3",        "JARID1A",     "JMJD2B",      "JUN", 
                "JUND",        "KCNF1",       "KCNJ3",       "KCNJ5",       "KCNK1", 
                "KDR",         "KEAP1",       "KEL",         "KHSRP",       "KIAA0020", 
                "KIAA0152",    "KIAA0355",    "KIAA0892",    "KIAA1166",    "KIAA1598", 
                "KIF21B",      "KIF5B",       "KIRREL",      "KIT",         "KLF4", 
                "KLF6",        "KLHDC8A",     "KLHL25",      "KLHL4",       "KLK2", 
                "KLRC3",       "KLRC4",       "KLRK1",       "KPNB1",       "KRAS", 
                "KTN1",        "KYNU",        "LAIR1",       "LAMA5",       "LAMB1", 
                "LAMB2",       "LAMC1",       "LANCL2",      "LAPTM5",      "LARP1", 
                "LASP1",       "LCK",         "LCP1",        "LCP2",        "LDHA", 
                "LDLR",        "LEPREL2",     "LFNG",        "LGALS1",      "LGALS3", 
                "LHFP",        "LHFPL2",      "LIFR",        "LILRB2",      "LILRB3", 
                "LMAN1",       "LMNB2",       "LMO1",        "LMO2",        "LOC201229", 
                "LOC55565",    "LOC81691",    "LOX",         "LPA",         "LPHN3", 
                "LPP",         "LRFN3",       "LRP10",       "LRP2",        "LRP5", 
                "LRP6",        "LRRC16",      "LRRFIP1",     "LRRTM4",      "LTBP1", 
                "LTBP2",       "LY75",        "LY96",        "LYL1",        "LYPLA3", 
                "LYRM1",       "M6PRBP1",     "MAB21L1",     "MAF",         "MAFB", 
                "MAGEH1",      "MALT1",       "MAML1",       "MAN1A1",      "MAN2A1", 
                "MAN2B1",      "MAP2",        "MAP2K1",      "MAP2K2",      "MAP2K4", 
                "MAPK1",       "MAPK13",      "MAPK14",      "MAPK3",       "MAPK9", 
                "MAPT",        "MARCKS",      "MARCKSL1",    "MAST1",       "MAT2B", 
                "MATR3",       "MAX",         "MBP",         "MBTPS1",      "MC1R", 
                "MCC",         "MCM10",       "MDH1",        "MDM2",        "MDM4", 
                "MDS1",        "MED12",       "MEGF8",       "MEIS1",       "MEN1", 
                "MEOX2",       "MET",         "MFSD1",       "MGAM",        "MGAT1", 
                "MGC2752",     "MGC72080",    "MGMT",        "MGST2",       "MGST3", 
                "MIER2",       "MITF",        "MKL1",        "MLC1",        "MLF1", 
                "MLH1",        "MLL",         "MLLT1",       "MLLT10",      "MLLT11", 
                "MLLT3",       "MLLT4",       "MLXIP",       "MMD",         "MMP15", 
                "MMP16",       "MN1",         "MNX1",        "MORC2",       "MORF4L2", 
                "MPL",         "MPPED2",      "MRC2",        "MRPL49",      "MS4A4A", 
                "MSH2",        "MSH6",        "MSL2L1",      "MSN",         "MSR1", 
                "MSRB2",       "MTAP",        "MTCP1",       "MTSS1",       "MUC1", 
                "MUC16",       "MUTYH",       "MVP",         "MYB",         "MYBPC1", 
                "MYC",         "MYCL1",       "MYCN",        "MYD88",       "MYH11", 
                "MYH9",        "MYLIP",       "MYO10",       "MYO1E",       "MYO1F", 
                "MYO5C",       "MYO9B",       "MYST2",       "MYST3",       "MYST4", 
                "MYT1",        "NACA",        "NANOS1",      "NBN",         "NCALD", 
                "NCAM1",       "NCF2",        "NCF4",        "NCKIPSD",     "NCL", 
                "NCLN",        "NCOA1",       "NCOA2",       "NCOA4",       "NCOR2", 
                "NDP",         "NDRG1",       "NDRG2",       "NDUFS3",      "NES", 
                "NF1",         "NF2",         "NFATC3",      "NFE2L2",      "NFIB", 
                "NFKB1",       "NFKB2",       "NIPBL",       "NKX2-1",      "NKX2-2", 
                "NLGN3",       "NLRP2",       "NOD2",        "NOL4",        "NONO", 
                "NOS2A",       "NOTCH1",      "NOTCH2",      "NOTCH3",      "NPAS3", 
                "NPC2",        "NPEPL1",      "NPM1",        "NPPB",        "NPR1", 
                "NR0B1",       "NR1H2",       "NR1H3",       "NR2E1",       "NR2F6", 
                "NR4A3",       "NRAS",        "NRCAM",       "NRP1",        "NRXN1", 
                "NRXN2",       "NRXN3",       "NSD1",        "NSL1",        "NT5C2", 
                "NTRK1",       "NTRK3",       "NTSR2",       "NUMA1",       "NUP188", 
                "NUP214",      "NUP98",       "OBSCN",       "OLIG2",       "OMD", 
                "ORC4L",       "OSBPL3",      "P2RX7",       "P4HA2",       "P4HB", 
                "PABPC1",      "PAFAH1B2",    "PAFAH1B3",    "PAK3",        "PAK7", 
                "PALB2",       "PARP8",       "PATZ1",       "PAX3",        "PAX5", 
                "PAX7",        "PAX8",        "PBRM1",       "PBX1",        "PCDH11X", 
                "PCDH11Y",     "PCLO",        "PCM1",        "PCSK5",       "PCSK7", 
                "PDCD1LG2",    "PDE10A",      "PDE4DIP",     "PDE6D",       "PDGFA", 
                "PDGFB",       "PDGFRA",      "PDGFRB",      "PDPK1",       "PDPN", 
                "PDPR",        "PELI1",       "PEPD",        "PER1",        "PEX11B", 
                "PEX19",       "PFN2",        "PGBD5",       "PGCP",        "PHC2", 
                "PHF11",       "PHF16",       "PHF21A",      "PHLPP",       "PHOX2B", 
                "PICALM",      "PIGP",        "PIK3C2B",     "PIK3C2G",     "PIK3CA", 
                "PIK3CB",      "PIK3CD",      "PIK3CG",      "PIK3R1",      "PIK3R2", 
                "PIM1",        "PIPOX",       "PKM2",        "PLA2G5",      "PLAG1", 
                "PLAU",        "PLAUR",       "PLCB4",       "PLCG1",       "PLCL1", 
                "PLEKHA4",     "PLK3",        "PLOD3",       "PLS3",        "PLXNA1", 
                "PML",         "PMP22",       "PMS1",        "PMS2",        "PODXL2", 
                "POFUT1",      "POLD4",       "POLRMT",      "POMT2",       "POPDC3", 
                "POT1",        "POU2AF1",     "PPA1",        "PPARG",       "PPFIA2", 
                "PPM1D",       "PPM1E",       "PPM1G",       "PPP1R1A",     "PPP2R1A", 
                "PPP2R5A",     "PPYR1",       "PRCC",        "PRDM1",       "PRDM16", 
                "PRF1",        "PRKAR1A",     "PRKCA",       "PRKCB1",      "PRKCD", 
                "PRKCE",       "PRKCG",       "PRKCH",       "PRKCI",       "PRKCQ", 
                "PRKD2",       "PRKDC",       "PROCR",       "PRPF31",      "PRPSAP2", 
                "PRR4",        "PRRX1",       "PSCD1",       "PSCD4",       "PSCDBP", 
                "PSIP1",       "PTBP1",       "PTCH1",       "PTEN",        "PTGER4", 
                "PTK2",        "PTPN11",      "PTPN14",      "PTPN22",      "PTPN6", 
                "PTPRA",       "PTPRC",       "PTRF",        "PURG",        "PXN", 
                "PYGL",        "QTRT1",       "QTRTD1",      "RAB11FIP1",   "RAB27A", 
                "RAB32",       "RAB33A",      "RABEP1",      "RABGAP1L",    "RAC1", 
                "RAC2",        "RAD21",       "RAD51L1",     "RAD54L2",     "RAF1", 
                "RALGDS",      "RALGPS1",     "RALGPS2",     "RANBP17",     "RAP1GDS1", 
                "RAP2A",       "RARA",        "RASGRP1",     "RB1",         "RBBP6", 
                "RBCK1",       "RBKS",        "RBM10",       "RBM15",       "RBM15B", 
                "RBM42",       "RBMS1",       "RBPJ",        "RECQL4",      "REEP1", 
                "REL",         "RELA",        "RELB",        "REPS2",       "RET", 
                "RFX2",        "RFXANK",      "RGS12",       "RGS6",        "RHOG", 
                "RHOH",        "RIN1",        "RING1",       "RNASEN",      "RND1", 
                "RNF2",        "RNF43",       "ROGDI",       "ROS1",        "RP11-35N6.1", 
                "RPL10",       "RPL22",       "RPL5",        "RPN1",        "RPP14", 
                "RPS6KA4",     "RPS6KA5",     "RPS6KB1",     "RRAS",        "RREB1", 
                "RRP1B",       "RUFY3",       "RUNX1",       "RUNX1T1",     "RUNX2", 
                "RYR2",        "RYR3",        "S100A11",     "S100A13",     "S100A4", 
                "S100A9",      "SAFB",        "SAR1A",       "SARS2",       "SAT1", 
                "SATB1",       "SCAMP4",      "SCAPER",      "SCG3",        "SCHIP1", 
                "SCN3A",       "SCPEP1",      "SDC4",        "SDHB",        "SDHC", 
                "SDHD",        "SEC22B",      "SEC24D",      "SEC61A1",     "SEC61A2", 
                "SEC61G",      "SEMA6A",      "SEMA6D",      "SEPP1",       "SEPT11", 
                "SEPT6",       "SEPT9",       "SEPW1",       "SERPINA1",    "SERPINE1", 
                "SERPINH1",    "SERPINI1",    "SET",         "SETBP1",      "SETD2", 
                "SEZ6L",       "SF3B1",       "SFPQ",        "SFRS3",       "SFT2D2", 
                "SGK3",        "SH2B3",       "SH3GL1",      "SH3GL2",      "SH3GL3", 
                "SHC1",        "SHH",         "SHOX2",       "SIGLEC7",     "SIGLEC9", 
                "SIPA1L1",     "SIRT5",       "SLAMF8",      "SLC10A3",     "SLC11A1", 
                "SLC12A4",     "SLC16A3",     "SLC16A7",     "SLC1A1",      "SLC2A1", 
                "SLC2A10",     "SLC30A10",    "SLC31A2",     "SLC34A2",     "SLC4A4", 
                "SLC6A11",     "SLC6A9",      "SLCO1A2",     "SLCO5A1",     "SMAD4", 
                "SMARCA4",     "SMARCB1",     "SMARCE1",     "SMO",         "SNCG", 
                "SNTA1",       "SNTB2",       "SNX11",       "SNX26",       "SOCS1", 
                "SOCS2",       "SORCS3",      "SOX10",       "SOX11",       "SOX2", 
                "SOX4",        "SOX9",        "SP1",         "SP100",       "SPAST", 
                "SPINK5",      "SPPL2B",      "SPRY2",       "SPTA1",       "SPTBN2", 
                "SQRDL",       "SRC",         "SREBF2",      "SRF",         "SRGAP3", 
                "SRPX2",       "SRRM2",       "SS18",        "SS18L1",      "SSH3", 
                "SSRP1",       "SSX1",        "SSX2",        "ST14",        "STAB1", 
                "STAG2",       "STAT3",       "STAT5A",      "STAT5B",      "STAT6", 
                "STIL",        "STK10",       "STK11",       "STMN1",       "STMN4", 
                "STXBP2",      "SUZ12",       "SWAP70",      "SYK",         "SYNGR2", 
                "SYPL1",       "TAF15",       "TAF5",        "TAL1",        "TARS", 
                "TBL1XR1",     "TBX2",        "TCEA1",       "TCEAL1",      "TCEAL2", 
                "TCF12",       "TCF3",        "TCF7L2",      "TCHH",        "TCIRG1", 
                "TCL6",        "TEAD3",       "TEC",         "TEK",         "TERT", 
                "TES",         "TFE3",        "TFEB",        "TFG",         "TFPT", 
                "TFRC",        "TGFB2",       "TGFB3",       "TGFBI",       "TGFBR2", 
                "TGIF2",       "TGOLN2",      "THBD",        "THBS1",       "THOC2", 
                "THRAP3",      "THTPA",       "TIMP1",       "TLE2",        "TLR2", 
                "TLR4",        "TLX1",        "TMBIM1",      "TMCC1",       "TMED1", 
                "TMEFF1",      "TMEM118",     "TMEM144",     "TMEM147",     "TMEM161A", 
                "TMEM35",      "TMEM43",      "TMPRSS2",     "TMSL8",       "TNFAIP3", 
                "TNFAIP8",     "TNFRSF11A",   "TNFRSF14",    "TNFRSF17",    "TNFRSF1A", 
                "TNFRSF1B",    "TNFSF12",     "TNRC4",       "TOP1",        "TOP2B", 
                "TOPBP1",      "TOX3",        "TP53",        "TPM3",        "TPM4", 
                "TPR",         "TRA@",        "TRADD",       "TRAM2",       "TRIB2", 
                "TRIM22",      "TRIM24",      "TRIM27",      "TRIM33",      "TRIM38", 
                "TRIO",        "TRIP11",      "TRIP6",       "TRPM2",       "TRRAP", 
                "TSC1",        "TSC2",        "TSHR",        "TSNAX",       "TSPAN3", 
                "TSPAN9",      "TTC1",        "TTC28",       "TTC3",        "TTN", 
                "TTPA",        "TTYH1",       "TYK2",        "U2AF1",       "UAP1", 
                "UBN1",        "UBR5",        "UCP2",        "UGT8",        "UNC45A", 
                "UPF1",        "UROS",        "USH2A",       "USP33",       "USP6", 
                "VAMP5",       "VAV3",        "VAX2",        "VDR",         "VEZF1", 
                "VIP",         "VPS16",       "VSX1",        "WAS",         "WASF1", 
                "WDR68",       "WHSC1",       "WHSC1L1",     "WIF1",        "WIPF1", 
                "WIZ",         "WRN",         "WSCD1",       "WT1",         "WWOX", 
                "WWTR1",       "XPA",         "XPC",         "XPO1",        "XPO6", 
                "YAP1",        "YPEL1",       "YPEL5",       "YWHAE",       "ZBTB16", 
                "ZBTB43",      "ZDHHC18",     "ZEB1",        "ZEB2",        "ZFHX4", 
                "ZMYM2",       "ZNF134",      "ZNF146",      "ZNF184",      "ZNF20", 
                "ZNF211",      "ZNF217",      "ZNF227",      "ZNF228",      "ZNF235", 
                "ZNF248",      "ZNF264",      "ZNF286A",     "ZNF304",      "ZNF323", 
                "ZNF331",      "ZNF384",      "ZNF419",      "ZNF446",      "ZNF45", 
                "ZNF510",      "ZNF606",      "ZNF629",      "ZNF643",      "ZNF671", 
                "ZNF711",      "ZNF8",        "ZNF804A",     "ZRSR2",       "ZYX")
               
   patient.count <- 20
   gene.count <- 100
   payload <- list(entities=patients[1:patient.count], features=genes[1:gene.count])
       
   msg <- list(cmd=cmd, callback=callback, status=status, payload=payload)
   websocket_write(toJSON(msg), client)
   
   system("sleep 3")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")

   data <- fromJSON(msg.incoming$payload)
      # expact an unamed list of patient.count length long
      # with each row gene.count elementslong, with 1 rowname element
   checkEquals(length(data), patient.count)
   checkEquals(length(data[[1]]), gene.count + 1)

   checkEquals(names(data[[1]]), c(genes[1:gene.count], "rowname"))

   checkEquals(data[[1]]$rowname, patients[1])
   checkEquals(data[[2]]$rowname, patients[2])


} # test_request_mRNA_data_largeSet
#----------------------------------------------------------------------------------------------------
test_plsr_ping <- function()
{
   print("--- test_plsr_ping")
   cmd <- "PLSR.ping"
   status <- "request"
   callback <- "handle.plsr.ping"
   websocket_write(toJSON(list(cmd=cmd, callback=callback, status=status, payload="")), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "success")
   checkEquals(head(msg.incoming$payload), "ping back!")

} # test_plsr_ping
#----------------------------------------------------------------------------------------------------
test_plsr <- function()
{
   print("--- test_plsr")
   cmd <- "calculatePLSR"
   status <- "request"
   payload <- c(geneSet="tcga_GBM_centroid",
                ageAtDxThresholdLow=36, 
                ageAtDxThresholdHi=64,
                overallSurvivalThresholdLow=3.7,
                overallSurvivalThresholdHi=7.3)
       
   callback <- "handle.plsr.results"
   msg <- list(cmd=cmd, callback=callback, status=status, payload=toJSON(payload))
   websocket_write(toJSON(msg), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "fit")
   checkEquals(names(msg.incoming$payload), c("genes", "vectors", "absMaxValue"))
   checkTrue(nchar(msg.incoming$payload[["vectors"]]) > 300)  # 404 on (5 sep 2014)
   checkTrue(nchar(msg.incoming$payload[["genes"]]) > 10000)  # 83k on (5 sep 2014)
   checkTrue(nchar(msg.incoming$payload[["absMaxValue"]]) > 0.3)  # 0.31785 on (5 sep 2014)

} # test_plsr
#----------------------------------------------------------------------------------------------------
test_plsr_withGeneSet <- function()
{
   print("--- test_plsr_withGeneSet")
   cmd <- "calculatePLSR"
   status <- "request"
   payload <- c(geneSet="angiogenesis",
                ageAtDxThresholdLow=36, 
                ageAtDxThresholdHi=64,
                overallSurvivalThresholdLow=3.7,
                overallSurvivalThresholdHi=7.3)
       
   callback <- "handle.plsr.results"
   msg <- list(cmd=cmd, callback=callback, status=status, payload=toJSON(payload))
   websocket_write(toJSON(msg), client)
   
   system("sleep 1")
   service(client)
   checkEquals(names(msg.incoming), c("cmd", "callback", "status", "payload"))
   checkEquals(msg.incoming$cmd, callback)
   checkEquals(msg.incoming$status, "fit")
   checkEquals(names(msg.incoming$payload), c("genes", "vectors", "absMaxValue"))
   checkTrue(nchar(msg.incoming$payload[["vectors"]]) > 300)  # 404 on (5 sep 2014)
   checkTrue(nchar(msg.incoming$payload[["genes"]]) > 1000)  # 1196, 12 genes (7 sep 2014)
   checkTrue(nchar(msg.incoming$payload[["absMaxValue"]]) > 0.3)  # 0.31785 on (5 sep 2014)

} # test_plsr
#----------------------------------------------------------------------------------------------------
