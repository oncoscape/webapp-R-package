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
   #test_constructor_tcga()
   test_constructor_preparedTable()
   test_constructor_caisisEvents_small()   # an RData file, a list of lists
   test_constructor_caisisEvents_large()   # an RData file, a list of lists
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_constructor_caisisEvents_small <- function()
{
   print("--- test_constructor_caisisEvents_small")

      # both of these files are named relative to Oncoscape/inst/extdata
   sample.file.1 <- "demo/caisis.RData"

   path <- sprintf("caisisEvents://%s", sample.file.1)
   cdp <- PatientHistoryProvider(path);
   checkTrue(is(cdp, "PatientHistoryProvider"))
   checkTrue(is(cdp, "LocalFileCaisisEventsPatientHistoryProvider"))

   events <- getEvents(cdp)
   checkEquals(length(events), 73)

   all.events <- sort(unique(unlist(lapply(events, function(event) event$Name))))

     # whittle these down to zero
   missing.events <- setdiff(requiredEventNames(cdp), all.events)
   checkEquals(missing.events, c("DOB", "Status", "MRI", "OR", "Pathology", "Encounter"))

   e <- events[[1]]

   checkEquals(e, list(PatientID="FC5PKZ244GQOB098PB2IH2C7X33XO1OT765X",
                       PtNum=1,
                       Name="Death",
                       date="06/05/2000",
                       StatusQuality="STD"))

   checkEquals(sort(legalEventNames(cdp)),
               sort(c("DOB", "Status",  "Diagnosis", "MRI", "Chemo", "Radiation", "OR", "Pathology", "Encounter", "Progression", "Death")))
   


   checkEquals(sort(requiredEventNames(cdp)), 
                c("Chemo", "DOB", "Death", "Diagnosis", "Encounter", "MRI", "OR", "Pathology",
                  "Progression", "Radiation", "Status"))
              
   
} # test_constructor_caisisEvents_small
#----------------------------------------------------------------------------------------------------
test_constructor_caisisEvents_large <- function()
{
   print("--- test_constructor_caisisEvents_large")

      # file named relative to Oncoscape/inst/extdata

   sample.file.2 <- "BTC_clinicaldata_6-18-14.RData" # no subdirectory

   path <- sprintf("caisisEvents://%s", sample.file.2)
   cdp <- PatientHistoryProvider(path);
   checkTrue(is(cdp, "PatientHistoryProvider"))
   checkTrue(is(cdp, "LocalFileCaisisEventsPatientHistoryProvider"))

   events <- getEvents(cdp)
   checkEquals(length(events), 2851)
   all.events <- sort(unique(unlist(lapply(events, function(event) event$Name))))

   e <- events[[1]]

   checkEquals(e, list(PatientID="P1",
                       PtNum=1,
                       Name="Chemo",
                       date=c("7/12/2006", "8/22/2006"),
                       Type="Temozolomide"))

   checkEquals(sort(legalEventNames(cdp)),
                c("Chemo", "DOB", "Death", "Diagnosis", "Encounter", "MRI", "OR", "Pathology",
                  "Progression", "Radiation", "Status"))

   checkEquals(sort(requiredEventNames(cdp)), 
                c("Chemo", "DOB", "Death", "Diagnosis", "Encounter", "MRI", "OR", "Pathology",
                  "Progression", "Radiation", "Status"))
              
   
} # test_constructor_caisisEvents_small
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
