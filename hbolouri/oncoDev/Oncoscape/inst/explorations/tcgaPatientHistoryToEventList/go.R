# go.R
# desired fields: Chemo    DOB   Death   Diagnosis   Encounter   MRI   OR Progression   Radiation 
#------------------------------------------------------------------------------------------------------------------------
options(stringsAsFactors=FALSE)
library (RUnit)
library(plyr)
#------------------------------------------------------------------------------------------------------------------------
if(!exists("elold")){
   print(load("~/s/data/hamid/repo/hbolouri/oncoDev/Oncoscape/inst/extdata/mskGBM/BTC_clinicaldata_6-18-14.RData"))
   elold <- PatientData_json
   }

if(!exists("tbl.pt")){
   tbl.pt <- read.table("clinical_patient_gbm.txt", quote="", sep="\t", header=TRUE, as.is=TRUE)
   tbl.pt <- tbl.pt[3:nrow(tbl.pt),]
   tbl.drug <- read.table("clinical_drug_gbm.txt", quote="", sep="\t", header=TRUE, as.is=TRUE)
   tbl.drug <- tbl.drug[3:nrow(tbl.pt),]
   tbl.rad <- read.table("clinical_radiation_gbm.txt", quote="", sep="\t", header=TRUE, as.is=TRUE)
   }

 # all of the btc data, as multi-flat and converted to data.frame
if(!exists("tbl.btcEvents")) {
   load("~/s/data/hamid/repo/hbolouri/oncoDev/Oncoscape/inst/extdata/mskGBM/BTC_clinicaldata_6-18-14.RData")
   btc.events <- PatientData_json[1:100]
   tbl.btcEvents <- rbind.fill(lapply(btc.events, function(y){as.data.frame(t(y),stringsAsFactors=FALSE)}))
   }

if(!exists("tcga.ids")){
   tcga.ids <- unique(tbl.pt$bcr_patient_barcode)
   id.map <- 1:length(tcga.ids)
   fixed.ids <- gsub("-", ".", tcga.ids, fixed=TRUE)
   names(id.map) <- fixed.ids
   }
#------------------------------------------------------------------------------------------------------------------------
run = function(patient.ids=NA, file="testTCGApatientHistory.RData")
{
    if(all(is.na(patient.ids)))
        patient.ids <- tcga.ids
    
    dob.events <- lapply(patient.ids, function(id) create.DOB.record(id))
    chemo.events <- create.all.Chemo.records(patient.ids)

    diagnosis.events <- lapply(patient.ids, create.Diagnosis.record)

    events <- append(dob.events, chemo.events)
    events <- append(events, diagnosis.events)

    printf("saving %d events for %d patients to file %s", length(events), length(patient.ids),  file)
    save(events, file=file)
    #checkEquals(length(dob.events), 583)
    #checkEquals(length(chemo.events), 347)
    #checkEquals(length(diagnosis.events), 583)
    #checkEquals(length(events), 1513)

} # run
#------------------------------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_create.DOB.record()
   test_create.Chemo.record()
   test_create.Diagnosis.record()
   
} # runTests
#------------------------------------------------------------------------------------------------------------------------
# emulate this:      $PatientID [1] "P1"  $PtNum [1] 1 $Name [1] "DOB"  $date [1] "5/14/1940"
#
# from this:     head(tbl.pt[-(1:2), c(1, 8, 27, 13)])
#        bcr_patient_barcode birth_days_to age_at_initial_pathologic_diagnosis days_to_initial_pathologic_diagnosis initial_pathologic_dx_year
#      3        TCGA-02-0001        -16179                                  44                                    0                       2002
create.DOB.record <- function(patient.id)
{
   tbl.pt.row <- subset(tbl.pt, bcr_patient_barcode==patient.id)
   patient.id <- gsub("-", ".", patient.id, fixed=TRUE)
   patient.number <- as.integer(id.map[patient.id])
   diagnosis.year <- tbl.pt.row$initial_pathologic_dx_year
   diagnosis.date <- as.Date(sprintf("%s-%s-%s", diagnosis.year, "01", "01"))
   birth.offset <-   as.integer(tbl.pt.row$birth_days_to)
   dob <- reformatDate(format(diagnosis.date + birth.offset))
   return(list(PatientID=patient.id, PtNum=patient.number, Name="DOB", date=dob))
   
} # create.DOB.record
#------------------------------------------------------------------------------------------------------------------------
test_create.DOB.record <- function()
{
    print("--- test_create.DOB.record")
    x <- create.DOB.record(tcga.ids[1])
    checkTrue(is.list(x))
    checkEquals(names(x), c("PatientID", "PtNum", "Name", "date"))
    checkEquals(x, list(PatientID="TCGA.02.0001", PtNum=1, Name="DOB", date="09/15/1957"))

} # test_create.DOB.record
#------------------------------------------------------------------------------------------------------------------------
# emulate this:  elold[[ head(which(unlist(lapply(elold, function(element) element$Name=="Chemo"))), n=1) ]]
#
# $PatientID [1] "P1"
# $PtNum [1] 1
# $Name [1] "Chemo"
# $date [1] "7/12/2006" "8/22/2006"
# $Type [1] "Temozolomide"
#
# use these fields in the drug table, possibly finding many rows per patient
#   pharmaceutical_therapy_drug_name    "Celebrex"
#   pharmaceutical_tx_started_days_to    92
#   pharmaceutical_tx_ended_days_to     278
create.Chemo.record <- function(patient.id)
{

   tbl.drugSub <- subset(tbl.drug, bcr_patient_barcode==patient.id & pharmaceutical_therapy_type =="Chemotherapy")
   if(nrow(tbl.drugSub) == 0)
       return(list())
   
   diagnosis.year <- subset(tbl.pt, bcr_patient_barcode==patient.id)$initial_pathologic_dx_year[1]
   diagnosis.date <- as.Date(sprintf("%s-%s-%s", diagnosis.year, "01", "01"))

   patient.id <- gsub("-", ".", patient.id, fixed=TRUE)
   patient.number <- as.integer(id.map[patient.id])

   name <- "Chemo"

   result <- vector("list", nrow(tbl.drugSub))
   good.records.found <- 0
   
     # to look at the subset:
     # tbl.drugSub[, c("pharmaceutical_therapy_drug_name", "pharmaceutical_tx_started_days_toleng", "pharmaceutical_tx_ended_days_to")]

   for(chemoEvent in 1:nrow(tbl.drugSub)){
      start.chemoDate <- tbl.drugSub$pharmaceutical_tx_started_days_to[chemoEvent]
      if(length(grep("no", start.chemoDate, ignore.case=TRUE)) > 0)
          next;
      #printf("start chemoDate: %s", start.chemoDate)
      end.chemoDate <- tbl.drugSub$pharmaceutical_tx_ended_days_to[chemoEvent]
      if(length(grep("no", end.chemoDate, ignore.case=TRUE)) > 0)
          next;
      #printf("  end chemoDate: %s", end.chemoDate)
      #start.date.unformatted <- diagnosis.date + as.integer(tbl.drugSub$pharmaceutical_tx_started_days_to[chemoEvent])
      #end.date.unformatted <- diagnosis.date + as.integer(tbl.drugSub$pharmaceutical_tx_ended_days_to[chemoEvent])
      start.date.unformatted <- diagnosis.date + as.integer(start.chemoDate)
      end.date.unformatted <- diagnosis.date + as.integer(end.chemoDate)
      if(is.na(start.date.unformatted) | is.na(end.date.unformatted))
          next;
      #printf("chemo from   %s   to  %s", start.date.unformatted, end.date.unformatted)
      start.date <- reformatDate(start.date.unformatted)
      end.date <- reformatDate(end.date.unformatted)
      drug <- tbl.drugSub$pharmaceutical_therapy_drug_name[chemoEvent]
      new.event <- list(PatientID=patient.id,
                        PtNum=patient.number,
                        Name=name,
                        date=c(start.date, end.date),
                        Type=drug)
      good.records.found <- good.records.found + 1
      result[[good.records.found]] <- new.event
      } # for chemoEvent

   result[1:good.records.found]
   
} # create.Chemo.record
#------------------------------------------------------------------------------------------------------------------------
test_create.Chemo.record <- function()
{
    print("--- test_create.Chemo.record")
    id <- "TCGA-02-0001"
    x <- create.Chemo.record(id)
    id <- gsub("-", ".", id, fixed=TRUE)
    checkTrue(is.list(x))
    checkEquals(length(x), 2)
    checkEquals(names(x[[1]]), c("PatientID", "PtNum", "Name", "date", "Type"))
    checkEquals(names(x[[2]]), c("PatientID", "PtNum", "Name", "date", "Type"))
    checkEquals(x[[1]], list(PatientID=id, PtNum=1, Name="Chemo", date=c("04/03/2002", "10/06/2002"), Type="Celebrex"))
    checkEquals(x[[2]], list(PatientID=id, PtNum=1, Name="Chemo", date=c("04/03/2002", "10/06/2002"), Type="CRA"))

      # try 1 id, two events, but only one start date, no end dates
   x <- create.Chemo.record("TCGA-02-0014")
   checkEquals(length(x), 1)
   checkTrue(is.null(unlist(x)))

} # test_create.Chemo.record
#------------------------------------------------------------------------------------------------------------------------
create.all.Chemo.records <- function(patient.ids)
{
      # 388 good rows
  tbl.good <- subset(tbl.drug, bcr_patient_barcode %in% patient.ids & pharmaceutical_therapy_type =="Chemotherapy" &
                     pharmaceutical_tx_started_days_to != "[Not Available]")
  ids <- unique(tbl.good$bcr_patient_barcode)   # 167

  count <- 1
  result <- vector("list", nrow(tbl.good))
  for(id in ids){
     #printf("id: %s", id)
     new.list <- create.Chemo.record(id)
     range <- count:(count+length(new.list)-1)
     result[range] <- new.list
     count <- count + length(new.list)
     } # for id

     # some number of the expected events will fail, often (always?) because
     # one or both dates is "[Not Available]".  count tells us how many good 
     # we found
    deleters <- which(unlist(lapply(result, is.null)))
    if(length(deleters) > 0)
        result <- result[-deleters]

    result

} # create.all.Chemo.records
#------------------------------------------------------------------------------------------------------------------------
# emulate this:  elold[[ head(which(unlist(lapply(elold, function(element) element$Name=="Diagnosis"))), n=1) ]]
#   $PatientID [1] "P1"
#   $PtNum   [1] 1
#   $Name   [1] "Diagnosis"
#   $date   [1] "6/15/2006"
#   $Type   [1] "G4"
#
# very simple-minded solution here:
#   date is supplied as tbl.pt$initial_pathologic_dx_year
#   1989 1990 1991 1992 1993 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 
#      3    3    2    5    5    9   15   10   14   20   12   17   20   29   28   30   57   40   41   66   78   58   17    3    1 
# hamid says that all tcga samples are implicitly G4
create.Diagnosis.record <- function(patient.id)
{
   diagnosis.year <- subset(tbl.pt, bcr_patient_barcode==patient.id)$initial_pathologic_dx_year[1]
   diagnosis.date <- reformatDate(sprintf("%s-%s-%s", diagnosis.year, "01", "01"))
   patient.id <- gsub("-", ".", patient.id, fixed=TRUE)
   patient.number <- as.integer(id.map[patient.id])

   name <- "Diagnosis"
   type <- "G4"
   new.event <- list(PatientID=patient.id,
                     PtNum=patient.number,
                     Name=name,
                     date=diagnosis.date,
                     Type=type)
   new.event
   
} # create.Diagnosis.record
#------------------------------------------------------------------------------------------------------------------------
test_create.Diagnosis.record <- function()
{
   print("--- test_create.Diagnosis.record")
   x <- create.Diagnosis.record(tcga.ids[1])
   checkEquals(x, list(PatientID="TCGA.02.0001", PtNum=1, Name="Diagnosis", date="01/01/2002", Type="G4"))

} # test_create.Diagnosis.record
#------------------------------------------------------------------------------------------------------------------------
toPatientTimelinesEventFormat <- function(patientEvent)
{
   x <- patientEvent
   newX <- NA
   
   if(x$TableName == "MedicalTherapy"){
      startDate <- x$MedTxDateText
      stopDate <- x$MedTxStopDateText
      if(is.na(stopDate))
          stopDate <- startDate
      newX <- list(PatientID=x$PatientId,
                   PtNum=-1,
                   #Name=x$TableName,
                   Name="Chemo",
                   date=c(reformatDate(startDate), reformatDate(stopDate)),
                   MedTxType=x$MedTxType,
                   Type=x$MedTxAgent)
      } # MedicalTherapy

   else if(x$TableName == "RadiationTherapy"){
      startDate <- x$RadTxDateText
      stopDate <- x$RadTxStopDateText
      if(is.na(stopDate))
          stopDate <- startDate
      newX <- list(PatientID=x$PatientId,
                   PtNum=-1,
                   #Name=x$TableName,
                   Name="Radiation",
                   date=c(reformatDate(startDate), reformatDate(stopDate)),
                   Type=x$RadTxType,
                   RadTxTarget=x$RadTxTarget)
      } # RadiationTherapy

   else if(x$TableName == "Patients"){
      dob <- x$PtBirthDateText;
      if(is.na(dob))
          dob <- ""
      else
          dob <- reformatDate(dob)
      gender <- x$PtGender
      if(gender == "f")
          gender <- "Female"
      newX <- list(PatientID=x$PatientId,
                   PtNum=-1,
                   Name="DOB",
                   date=dob,
                   Gender=gender)
      } # Patients

   else if(x$TableName == "Status" & x$Status %in% c("Diagnosis Date", "1st Progression", "Alive")){
      date <- x$StatusDateText
      if(is.na(date)){
          printf("--- no date for Status/%s, arbitrary assignment made", x$PatientId)
          date <- "2009-08-11"
          }
      #printf("new status record: %s", x$Status)
      accepted.name <- switch(x$Status,
                              "Diagnosis Date" = "Diagnosis",
                              "1st Progression" = "Progression",
                              "Alive" = "Death");
      newX <- list(PatientID=x$PatientId,
                   PtNum=-1,
                   Name=accepted.name,
                   date=reformatDate(date),
                   StatusQuality=x$StatusQuality)
      } # Status

   newX

} # toPatientTimelinesEventFormat
#---------------------------------------------------------------------------------------------------
# format(strptime("2009-08-11", "%Y-%m-%d"), "%m/%d/%Y") # ->  "08/11/2009"
reformatDate <- function(dateString)
{
   format(strptime(dateString, "%Y-%m-%d"), "%m/%d/%Y")

} # reformatDate
#---------------------------------------------------------------------------------------------------
# no longer used.  see id.map instead.
assignPatientNumbersToTimelinesEvent <- function(x)
{
   patientIDs <- unique(unlist(lapply(x, function(element) element$PatientID)))
   patientID.assignments <-
        lapply(x, function(element) element$PtNum <- match(element$PatientID, patientIDs))

   for(i in 1:length(patientID.assignments))
      x[[i]]$PtNum <- patientID.assignments[[i]]

   x

} # assignPatientNumbersToTimelinesEvent
#---------------------------------------------------------------------------------------------------
