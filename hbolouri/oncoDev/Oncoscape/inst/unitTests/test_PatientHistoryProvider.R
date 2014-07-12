# test_PatientHistoryProvider.R
# this file tests only the factory method, "PatientHistoryProvider"
# for complete tests of the data-source-specific providers, see
#    test_CaisisPatientHistoryProvider.R
#    test_TCGA_PatientHistoryProvider.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   #test_constructor_caisis()
   #test_constructor_tcga()
   test_constructor_preparedTable()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_constructor_caisis <- function()
{
   print("--- test_constructor_caisis")
   path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
   cdp <- PatientHistoryProvider(path);
   checkTrue(is(cdp, "PatientHistoryProvider"))
   checkTrue(is(cdp, "LocalFileCaisisPatientHistoryProvider"))
   checkTrue(is.character(patientIDs(cdp)))
   checkTrue(is.character(patientEventNames(cdp)))
   
} # test_constructor_caisis
#----------------------------------------------------------------------------------------------------
test_constructor_tcga <- function()
{
   print("--- test_constructor_tcga")
   path <- "tcga://../explorations/tcga"
   cdp <- PatientHistoryProvider(path);
   checkTrue(is(cdp, "PatientHistoryProvider"))
   checkTrue(is(cdp, "LocalFileTCGAPatientHistoryProvider"))
   checkTrue(is.character(patientIDs(cdp)))
   checkTrue(is.character(patientEventNames(cdp)))
   
} # test_constructor_tcga
#----------------------------------------------------------------------------------------------------
test_constructor_preparedTable <- function()
{
     # data is found in file found in  Oncoscape/extdata/tcgaGBM/
   print("--- test_constructor_preparedTable")
         
   path <- "pkg://tcgaGBM/tbl.ptHistory.RData"
   php <- PatientHistoryProvider(path);
   tbl <- getTable(php)
   checkEquals(dim(tbl), c(583, 13))
   checkTrue(all(c("ID", "DOB", "ageAtDx") %in% colnames(tbl)))

} # test_constructor_preparedTable
#----------------------------------------------------------------------------------------------------
