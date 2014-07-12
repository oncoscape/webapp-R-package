# test_CaisisPatientHistoryProvider.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
library(data.table)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
    test_constructor()
    test_getPatientsAndEventIDs()
    test_getPatientData_onePatient_oneEvent()
    test_getPatientData_patientInfo()
    
    test_getPatientData_twoPatients_oneEvent()
    test_getPatientData_twoPatients_twoEvents()

    test_getPatientData_allPatients()
    test_getPatientData_all()

    test_getClinicalTable_allEvents()
    test_getClinicalTable_DOB_Death()
    
} # runTests
#----------------------------------------------------------------------------------------------------
test_constructor <- function()
{
    print("--- test__constructor")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    checkTrue(is(cdp, "PatientHistoryProvider"))
    checkTrue(is(cdp, "LocalFileCaisisPatientHistoryProvider"))
    checkTrue(is.character(patientIDs(cdp)))
    checkTrue(is.character(patientEventNames(cdp)))

} # test_constructor
#----------------------------------------------------------------------------------------------------
test_getPatientsAndEventIDs <- function()
{
    print("--- test_getPatientsAndEventIDs")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    checkEquals(sort(patientEventNames(cdp)), c("AbsentEvents",   "Diagnostics",   "Encounters",
                                                "MedicalTherapy", "Medications",   "OperatingRoomDetails",
                                                "PathStageGrade", "PathTest",      "Pathology",
                                                "Patients",       "Procedures",    "RadiationTherapy",
                                                "Status"))
    checkEquals(head(sort(patientIDs(cdp)), n=3),
                c("0067F2WO048DC2A872UJ87355L237DPVK283", "008609569XO6AL8KISITTPNS7Q8L58P0VEL1",
                  "00K83D4LK879EURT6LTWIN24U8M3PNGZS3U5"))


} # test_getPatientsAndEventIDs
#----------------------------------------------------------------------------------------------------
test_getPatientData_onePatient_oneEvent <- function()
{
    print("--- test_getPatientData_onePatient_oneEvent")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    patient <- "1A14UWY76UUD29815FZHJ9O9I8WOWUR592YS"
    eventName <- "MedicalTherapy"

    x <- getPatientData(cdp, patients=patient, events=eventName)
    checkEquals(length(x), 5) 

       # check just the first one
    event <- x [[1]]
    checkEquals(event$PatientId, patient)
    checkEquals(event$TableName,  eventName)
    checkEquals(event$MedTxType,  "CHEMO")
    checkEquals(event$MedTxAgent, "Temozolomide")
    checkEquals(event$MedTxDateText, "2009-03-13")
    checkEquals(event$MedTxStopDateText, "2009-04-24")

} # test_getPatientData_onePatient_oneEvent
#----------------------------------------------------------------------------------------------------
test_getPatientData_patientInfo <- function()
{
    print("--- test_getPatientData_patientInfo")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);
    

    patient <- "1A14UWY76UUD29815FZHJ9O9I8WOWUR592YS"
    eventName <- "Patients"

    x <- getPatientData(cdp, patients=patient, events=eventName)
    checkEquals(length(x), 1) 

       # check just the first one
    event <- x [[1]]
    checkEquals(event$PatientId, patient)
    checkEquals(event$TableName,  eventName)
    checkEquals(event$PtGender, "Male")
    checkEquals(event$PtBirthDateText, "1947-04-01")
    checkEquals(event$PtDeathDateText, "2010-04-30")
    checkEquals(event$PtDeathType, "Death from Unknown Causes")

} # test_getPatientData_patientInfo
#----------------------------------------------------------------------------------------------------
test_getPatientData_twoPatients_oneEvent <- function()
{
    print("--- test_getPatientData_twoPatients_oneEvent")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);


    patients <- c("1A14UWY76UUD29815FZHJ9O9I8WOWUR592YS",
                  "66J9FXV1DSCZ3NYPNJ67606YICACTG950ZKR")

    eventName <- "MedicalTherapy"

    x <- getPatientData(cdp, patients=patients, events=eventName)
    checkEquals(length(x), 6)

} # test_getPatientData_twoPatients_oneEvent
#----------------------------------------------------------------------------------------------------
test_getPatientData_twoPatients_twoEvents <- function()
{
    print("--- test_getPatientData_twoPatients_twoEvents")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    patients <- c("1A14UWY76UUD29815FZHJ9O9I8WOWUR592YS",
                  "66J9FXV1DSCZ3NYPNJ67606YICACTG950ZKR")

    eventName <- c("MedicalTherapy", "RadiationTherapy")

    x <- getPatientData(cdp, patients=patients, events=eventName)
    checkEquals(length(x), 9)

       # find the elements by type, then use easy data.frame accessors
       # to spot check contents

    med.rows <- grep("MedTxAgent", x)
    rad.rows <- grep("RadTxType", x)

    tbl.med <- rbindlist(x[med.rows])
    tbl.rad <- rbindlist(x[rad.rows])

    checkEquals(unique(tbl.med$MedTxType), "CHEMO")
    checkEquals(unique(tbl.med$TableName), "MedicalTherapy")

    checkEquals(unique(tbl.rad$TableName), "RadiationTherapy")
    checkEquals(as.integer(tbl.rad$RadTxTotalDose), c(6000, 18, 6000))    

} # test_getPatientData_twoPatients_twoEvents
#----------------------------------------------------------------------------------------------------
test_getPatientData_allPatients <- function()
{
    print("--- test_getPatientData_allPatients")
    
    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);
    eventName <- c("MedicalTherapy", "RadiationTherapy")

    x <- getPatientData(cdp, patients=NA, events=eventName)
    checkEquals(length(x), 3454)
    med.rows <- grep("MedTxAgent", x)
    rad.rows <- grep("RadTxType", x)

    tbl.med <- rbindlist(x[med.rows])
    tbl.rad <- rbindlist(x[rad.rows])

    checkEquals(dim(tbl.med), c(1068, 18))
    checkEquals(dim(tbl.rad), c(644, 16))

    checkEquals(sort(unique(tbl.med$MedTxType)), 
            c("BIO_TX", "CHEMO", "CLIN_TRIAL", "Chemo", "OTHER", "PRTCL"))
    checkEquals(head(sort(unique(tbl.rad$RadTxTarget)), n=3),
                c("2 superolateral lesions", "Bifrontal", "Bifrontal brain"))

} # test_getPatientData_allPatients
#----------------------------------------------------------------------------------------------------
# keep in mind that these events are returned in an unnamed list, each element of which
# is a named list corresponding to one event for one patient.
# these lists can be easily converted to JSON with the structure unchanged, but need
# further processing to represent as a data.frame.
test_getPatientData_twoPatients_allEvents <- function()
{
    print("--- test_getPatientData_twoPatients_allEvents")
    
    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    patients <- c("1A14UWY76UUD29815FZHJ9O9I8WOWUR592YS",
                  "66J9FXV1DSCZ3NYPNJ67606YICACTG950ZKR")

    x <- getPatientData(cdp, patients=patients, events=NA)
    checkEquals(length(x), 36)

    counts <- as.list(table(unlist(lapply(x, function(element) element$TableName))))    
    checkEquals(length(counts), 11)

    checkEquals(sort(names(counts)), 
        c("Diagnostics", "Encounters", "MedicalTherapy", "OperatingRoomDetails",
        "PathStageGrade", "PathTest", "Pathology", "Patients", 
        "Procedures", "RadiationTherapy", "Status"))

        # check just one field of the most common event
    
    mostCommonEvent <- names(counts)[which(counts == max(as.integer(counts)))]
    checkEquals(mostCommonEvent, "Encounters")
    tbl.encounters <- rbindlist(x[grep("Encounters", x)])
    checkEquals(tbl.encounters$EncType, c("NV","NV","NV","FR","NV","NV","NV"))

} # test_getPatientData_allPatients
#----------------------------------------------------------------------------------------------------
test_getPatientData_all <- function()
{
    print("--- test_getPatientData_all")
    
    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    x <- getPatientData(cdp, patients=NA, events=NA)
    checkEquals(length(x), 22451)
    counts <- as.list(table(unlist(lapply(x, function(element) element$TableName))))    
    checkEquals(length(counts), length(patientEventNames(cdp)))

    patientIDs <- lapply(x, function(element) element$PatientId)
    checkEquals(length(patientIDs), 22451)
    # todo: this next test fails, off by 1, a NULL patientID being present
    # checkEquals(length(unique(patientIDs)), length(patientIDs(cdp)))

    
} # test_getPatientData_all
#----------------------------------------------------------------------------------------------------
# lisa mcferrin's timelines module needs a patientnumber "ptNum" assigned to each
# patientID.   in addition, it requires certain very specific names for events:
#     Radiation, not RadiationTherapy
#     Chemo, not MedicalTherapy
#     Diagnosis, Progression, Death rather than Diagnosis Date, 1st Progression, Alive
test_toPatientTimelinesEventStatus <- function()
{
    print("--- test_toPatientTimelinesEventStatus")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    eventName <- c("Status", "MedicalTherapy", "RadiationTherapy")

    poi <- head(identifyRichCandidates(cdp), n=10)
    x <- getPatientData(cdp, patients=poi, events=eventName)

    x2 <- lapply(x, toPatientTimelinesEventFormat)
    x2 <- x2[which(!is.na(x2))]
    x3 <- assignPatientNumbersToTimelinesEvent(x2)

    checkTrue(is(x, "list"))
    checkTrue(is(x3, "list"))
    checkTrue(length(x3) <= length(x))
    checkEquals(x[[1]]$PatientID, x[[3]]$PatientID)
    checkEquals(x3[[1]]$PtNum, 1)
    
} # test_toPatientTimelinesEventStatus
#----------------------------------------------------------------------------------------------------
# test the mild transformation of the unamed list of lists,  needed for the d3 timelines component,
# on data from the Patients table
test_toPatientTimelinesEventStatus_patientInfo <- function()
{
    print("--- test_toPatientTimelinesEventStatus_patientInfo")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    eventName <- c("Patients")

    poi <- head(identifyRichCandidates(cdp), n=10)
    x <- getPatientData(cdp, patients=poi, events=eventName)

    x2 <- lapply(x, toPatientTimelinesEventFormat)
    x2 <- x2[which(!is.na(x2))]
    x3 <- assignPatientNumbersToTimelinesEvent(x2)

    checkEquals(length(x), 10)
    checkEquals(length(x3), 10)

    checkEquals(x[[1]]$PatientId, "FC5PKZ244GQOB098PB2IH2C7X33XO1OT765X")
    checkEquals(x[[1]]$PtGender, "f")
    checkEquals(x[[1]]$PtBirthDateText, "1959-05-12")
    checkTrue(is.na(x[[1]]$PtDeathDateText))
    checkTrue(is.na(x[[1]]$PtDeathType))
    checkEquals(x[[1]]$TableName, "Patients")

    checkEquals(x3[[1]],
                list(PatientID="FC5PKZ244GQOB098PB2IH2C7X33XO1OT765X", PtNum=1,
                     Name="DOB", date="05/12/1959",Gender="Female"))
    
} # test_toPatientTimelinesEventStatus_patientInfo
#----------------------------------------------------------------------------------------------------
identifyRichCandidates <- function(cdp)
{
    eventName <- c("Status", "MedicalTherapy", "RadiationTherapy")
    patients <- NA
    x <- getPatientData(cdp, patients=patients, events=eventName)

    status.indices <- grep("Status", x)
    patients.with.status <- unique(unlist(lapply(status.indices, function(i) x[[i]]$PatientId)))
    
    medical.indices <- grep("Medical", x)
    patients.with.medical <- unique(unlist(lapply(medical.indices, function(i) x[[i]]$PatientId)))
    
    radiation.indices <- grep("Radiation", x)
    patients.with.radiation <- unique(unlist(lapply(radiation.indices, function(i) x[[i]]$PatientId)))
    
    poi <- intersect(patients.with.status, intersect(patients.with.medical, patients.with.radiation))

    deleters <- match(c("5YOQ1OX81949BUVP56CD1QR8Q4E8K0XU175V"), poi)
    if(length(deleters) > 0)
        poi <- poi[-deleters]

    poi

} # identifyRichCandidates
#----------------------------------------------------------------------------------------------------
test_getClinicalTable_DOB_Death <- function()
{
    print("--- test_getClinicalTable_DOB_Death")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    patients <- identifyRichCandidates(cdp)
    events <- "Patients"
    
    tbl <- getClinicalTable(cdp, patients[1:5], events)
    checkEquals(dim(tbl), c(5,11))
    all.twentieth.century <- length(grep("/19", tbl$DOB, fixed=TRUE)) == 5
    checkTrue(all.twentieth.century)
       # only two death dates
    in.twentyFirst.century <- length(grep("/20", tbl$Death, fixed=TRUE))
    checkEquals(in.twentyFirst.century, 2)
    missing.death.dates <- length(which(nchar(tbl$Death) == 0))
    checkEquals(missing.death.dates, 3)

    tbl <- getClinicalTable(cdp, patients, events)
    checkEquals(dim(tbl), c(320,11))

    which.twentieth.century <- grep("/19", tbl$DOB, fixed=TRUE)
    checkEquals(length(which.twentieth.century), 319)
    missing <- which(tbl$DOB == "")
    checkEquals(missing, 112)

    missing.death.dates <- length(which(nchar(tbl$Death) == 0))
    checkEquals(missing.death.dates, 228)
    
} # test_getClinicalTable_DOB_Death
#----------------------------------------------------------------------------------------------------
test_getClinicalTable_allEvents <- function()
{
    print("--- test_getClinicalTable_allEvents")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    patients <- identifyRichCandidates(cdp)
    events <- c("Patients", "Status", "MedicalTherapy", "RadiationTherapy")
    tbl <- getClinicalTable(cdp, patients[1:5], events)
    checkEquals(dim(tbl), c(5, 11))

    tbl <- getClinicalTable(cdp, patients, events)
    checkEquals(dim(tbl), c(320, 11))
    
} # test_getClinicalTable_allEvents
#----------------------------------------------------------------------------------------------------
run_getClinicalTable <- function()
{
    print("--- run_getClinicalTable")

    path <- "caisis://../explorations/caisis/Caisis_BrainTables_5-28-14";
    cdp <- PatientHistoryProvider(path);

    patients <- identifyRichCandidates(cdp)
    printf("rich candidate count: %d",  length(patients))
    events <- c("Status", "MedicalTherapy", "RadiationTherapy", "Patients")

    tbl <- getClinicalTable(cdp, patients, events)
    #events.list  <- getPatientData(cdp, patients, events)
    #tbl <- toTable(events.list)
    checkEquals(dim(tbl), c(320, 11))
    save(tbl, file="../extdata/demo/clinicalTable320.Rdata")

} # run_getClinicalTable
#----------------------------------------------------------------------------------------------------
