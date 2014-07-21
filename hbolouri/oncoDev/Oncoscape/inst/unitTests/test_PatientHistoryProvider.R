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
   test_getEvents()
   
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
# condition requests on patientIDs and event names
test_getEvents <- function()
{
   printf("--- test_getEvents")
   sample.file.1 <- "demo/caisis.RData"

   path <- sprintf("caisisEvents://%s", sample.file.1)
   cdp <- PatientHistoryProvider(path);
   checkTrue(is(cdp, "PatientHistoryProvider"))
   checkTrue(is(cdp, "LocalFileCaisisEventsPatientHistoryProvider"))

   events <- getEvents(cdp)
   checkEquals(length(events), 73)

       #---------------------------------------------------------------------------------------
       # choose 3 patientIDs, do not filter on event names, make sure we get just those 3 back
       #---------------------------------------------------------------------------------------

   all.patientIDs <- unique(unlist(lapply(events, function(event) event$PatientID)))
   set.seed(31)
   poi <- sample(all.patientIDs, 3)

   events.2 <- getEvents(cdp, patient.ids=poi)
   patientIDs.returned <- sort(unique(unlist(lapply(events.2, function(event) event$PatientID))))
   checkEquals(length(patientIDs.returned), 3)
   checkTrue(all(patientIDs.returned %in% poi))

       #---------------------------------------------------------------
       # now filter on event names, but apply no filter to patient.ids
       #---------------------------------------------------------------
   
   all.event.type.names <- unique(unlist(lapply(events, function(event) event$Name)))
   checkTrue(length(all.event.type.names) >= 5)    # "Death" "Diagnosis" "Progression" "Chemo" "Radiation"  on (20 jul 2014)

   eoi <- sort(all.event.type.names[1:2])   # pick just the first two
   events.3 <- getEvents(cdp, event.names=eoi)
      # what did we get back?  should be 21 events of two types, with multiple (currently 10) patient.ids
   checkTrue(length(events.3) > 20)
   events.names.retrieved <- sort(unique(unlist(lapply(events.3, function(event) event$Name))))
   checkEquals(events.names.retrieved, eoi)

   patient.ids.retrieved <- unique(unlist(lapply(events.3, function(event) event$PatientID)))
   checkTrue(length(patient.ids.retrieved) > 5)   # lenient test, but guarantees we have multiple patientIDs

       #---------------------------------------------------------------------------------------
       # now filter on both patient.ids and event type names
       #---------------------------------------------------------------------------------------
   events.4 <- getEvents(cdp, patient.ids=poi, event.names=eoi)
   checkEquals(length(events.4), 6)
   events.names.retrieved <- sort(unique(unlist(lapply(events.4, function(event) event$Name))))
   checkEquals(events.names.retrieved, eoi)
   patientIDs.returned <- sort(unique(unlist(lapply(events.4, function(event) event$PatientID))))
   checkEquals(length(patientIDs.returned), 3)
   checkTrue(all(patientIDs.returned %in% poi))

} # test_getEvents
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
              
   
} # test_constructor_caisisEvents_large
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
         
   path <- "tbl://tcgaGBM/tbl.ptHistory.RData"
   php <- PatientHistoryProvider(path);
   tbl <- getTable(php)
   checkEquals(dim(tbl), c(583, 13))
   checkTrue(all(c("ID", "DOB", "ageAtDx") %in% colnames(tbl)))

} # test_constructor_preparedTable
#----------------------------------------------------------------------------------------------------
