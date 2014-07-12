# go.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
options(stringsAsFactors=FALSE)
source("../../patientHistoryTemplateDataFrame.R")
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_addOffsetToCalendarDate()

} # runTests
#--------------------------------------------------------------------------------
# > colnames(tbl)
#  [1] ID:   "TCGA-02-0001"
#  [2] DOB:
#  [3] ageAtDx:
#  [4] Diagnosis:
#  [5] ChemoStartDate:
#  [6] ChemoStopDate:
#  [7] ChemoAgent:
#  [8] RadiationStart:
#  [9] RadiationStop:
# [10] RaditionTarget:
# [11] FirstProgression:
# [12] Death:
# [13] survival:

# ---- tbl.pt
# bcr_patient_barcode                  "TCGA-02-0001"                        
# bcr_patient_uuid                     "30a1fe5e-5b12-472c-aa86-c2db8167ab23"
# form_completion_date                 "2008-12-16"                          
# history_lgg_dx_of_brain_tissue       "NO"                                  
# prospective_collection               "[Not Available]"                     
# retrospective_collection             "[Not Available]"                     
# gender                               "FEMALE"                              
# birth_days_to                        "-16179"                              
# race                                 "WHITE"                               
# ethnicity                            "NOT HISPANIC OR LATINO"              
# history_other_malignancy             "[Not Available]"                     
# history_neoadjuvant_treatment        "Yes"                                 
# initial_pathologic_dx_year           "2002"                                
# method_initial_path_dx               "Tumor resection"                     
# method_initial_path_dx_other         "[Not Applicable]"                    
# vital_status                         "Dead"                                
# last_contact_days_to                 "279"                                 
# death_days_to                        "358"                                 
# tumor_status                         "WITH TUMOR"                          
# karnofsky_score                      "80"                                  
# ecog_score                           "[Not Available]"                     
# performance_status_timing            "[Not Available]"                     
# radiation_treatment_adjuvant         "[Not Available]"                     
# pharmaceutical_tx_adjuvant           "[Not Available]"                     
# treatment_outcome_first_course       "[Not Available]"                     
# new_tumor_event_dx_indicator         "[Not Available]"                     
# age_at_initial_pathologic_diagnosis  "44"                                  
# anatomic_neoplasm_subdivision        "[Not Available]"                     
# days_to_initial_pathologic_diagnosis "0"                                   
# histological_type                    "Untreated primary (de novo) GBM"     
# icd_10                               "C71.9"                               
# icd_o_3_histology                    "9440/3"                              
# icd_o_3_site                         "C71.9"                               
# informed_consent_verified            "YES"                                 
# patient_id                           "0001"                                
# tissue_source_site                   "02"                                  
# tumor_tissue_site                    "Brain"
# 
# > noquote(colnames(tbl.rad))
#  [1] bcr_patient_barcode                
#  [2] bcr_radiation_barcode              
#  [3] bcr_radiation_uuid                 
#  [4] form_completion_date               
#  [5] radiation_therapy_type             
#  [6] radiation_therapy_site             
#  [7] radiation_total_dose               
#  [8] radiation_adjuvant_units           
#  [9] radiation_adjuvant_fractions_total 
# [10] radiation_therapy_started_days_to  
# [11] radiation_therapy_ongoing_indicator
# [12] radiation_therapy_ended_days_to    
# [13] treatment_best_response            
# [14] course_number                      
# [15] radiation_type_other               
# [16] therapy_regimen                    
# [17] therapy_regimen_other              
# 
# noquote(colnames(tbl.f1))
#  [1] bcr_patient_barcode               
#  [2] bcr_followup_barcode              
#  [3] bcr_followup_uuid                 
#  [4] form_completion_date              
#  [5] followup_reason                   
#  [6] followup_lost_to                  
#  [7] radiation_treatment_adjuvant      
#  [8] pharmaceutical_tx_adjuvant        
#  [9] treatment_outcome_first_course    
# [10] vital_status                      
# [11] last_contact_days_to              
# [12] death_days_to                     
# [13] tumor_status                      
# [14] new_tumor_event_dx_indicator      
# [15] treatment_outcome_at_tcga_followup
# [16] ecog_score                        
# [17] karnofsky_score                   
# [18] performance_status_timing         
# 
# noquote(colnames(tbl.f2))
# [1] bcr_patient_barcode                                 
# [2] bcr_followup_barcode                                
# [3] new_tumor_event_dx_days_to                          
# [4] new_tumor_event_radiation_tx                        
# [5] days_to_new_tumor_event_additional_surgery_procedure
# [6] new_neoplasm_event_type                             
# [7] new_tumor_event_additional_surgery_procedure        
# [8] new_tumor_event_pharmaceutical_tx                   
# >
# > noquote(colnames(tbl.drug))
#  [1] bcr_patient_barcode                
#  [2] bcr_drug_barcode                   
#  [3] bcr_drug_uuid                      
#  [4] form_completion_date               
#  [5] clinical_trial_indicator           
#  [6] pharmaceutical_therapy_drug_name   
#  [7] clinical_trial_drug_classification 
#  [8] pharmaceutical_therapy_type        
#  [9] pharmaceutical_tx_started_days_to  
# [10] pharmaceutical_tx_ongoing_indicator
# [11] pharmaceutical_tx_ended_days_to    
# [12] treatment_best_response            
# [13] pharma_adjuvant_cycles_count       
# [14] pharma_type_other                  
# [15] pharmaceutical_tx_dose_units       
# [16] pharmaceutical_tx_total_dose_units 
# [17] prescribed_dose                    
# [18] regimen_number                     
# [19] route_of_administration            
# [20] therapy_regimen                    
# [21] therapy_regimen_other              
# [22] total_dose                         

#----------------------------------------------------------------------------------------------------
run = function (levels)
{
  if("redo" %in% levels){
     run(0:9)
     }
  
  if (0 %in% levels) {
     # first two rows do not contain patient data
    tbl.pt <<- read.table("patient_gbm.txt", sep="\t", header=TRUE, as.is=TRUE)[-(1:2),]
    tbl.rad <<- read.table("radiation_gbm.txt", sep="\t", quote="", header=TRUE, as.is=TRUE)[-(1:2),]
    tbl.f1 <<- read.table("follow_up_v1.0_gbm.txt", sep="\t", header=TRUE, as.is=TRUE)[-(1:2),]
    tbl.f2 <<- read.table("follow_up_v1.0_nte_gbm.txt", sep="\t", header=TRUE, as.is=TRUE)[-(1:2),]
    tbl.drug <<- read.table("drug_gbm.txt", sep="\t", header=TRUE, as.is=TRUE)[-(1:2),]
    } # 0

  if (1 %in% levels) {
    tbl <<- patientHistoryTemplateDataFrame(nrow(tbl.pt))
    } # 1

  if (2 %in% levels) {
    tcga.ids <- tbl.pt$bcr_patient_barcode
    checkEquals(length(tcga.ids), length(unique(tcga.ids)))
    checkEquals(length(tcga.ids), nrow(tbl))
    tbl$ID <<- tcga.ids
    } # 2

    # derive DOB (10/10/49),
    # ageAtDx (49.81918)
    # Diagnosis
    # use mm/dd/yyyy   format(1,1,year, "%m/%d/%Y") # ->  "01/01/1948"
  if (3 %in% levels) {
    age.at.dx <<- as.numeric(tbl.pt$age_at_initial_pathologic_diagnosis)
    dx.year <<- as.integer(tbl.pt$initial_pathologic_dx_year)
    dob.year <<- dx.year - age.at.dx
    dob <- paste("01/01/", dob.year, sep="")
    tbl$ageAtDx <<- age.at.dx
    tbl$DOB <<- dob
    dx.date <- paste("01/01/", dx.year, sep="")
    tbl$Diagnosis <<- dx.date
    } # 3

    # derive ChemoStartDate, ChemoEndDate
  if (4 %in% levels) {
      # get just the first "chemo1" record for each patient
    dups <- duplicated(tbl.drug$bcr_patient_barcode)
    tbl.drug1 <- tbl.drug[!dups,]
    start.day.offset <- as.numeric(tbl.drug1$pharmaceutical_tx_started_days_to)
    end.day.offset <- as.numeric(tbl.drug1$pharmaceutical_tx_ended_days_to)
    ids <- tbl.drug1$bcr_patient_barcode
    indices <- match(ids, tbl$ID)
    base.dates <- tbl$Diagnosis[indices]
    chemoStartDate <- addOffsetToCalendarDate(base.dates, start.day.offset)
    tbl$ChemoStartDate[indices] <<- chemoStartDate

    chemoEndDate <- addOffsetToCalendarDate(base.dates, end.day.offset)
    tbl$ChemoStopDate[indices] <<- chemoEndDate

    drug <- tbl.drug1$pharmaceutical_therapy_drug_name
    tbl$ChemoAgent[indices] <<- drug
    } # 4

  if (5 %in% levels) {
    dups <- duplicated(tbl.rad$bcr_patient_barcode)
    tbl.rad1 <- tbl.rad[!dups,]
    start.day.offset <- as.numeric(tbl.rad1$radiation_therapy_started_days_to)
    end.day.offset <- as.numeric(tbl.rad1$radiation_therapy_ended_days_to)
    ids <- tbl.rad1$bcr_patient_barcode
    indices <- match(ids, tbl$ID)
    base.dates <- tbl$Diagnosis[indices]
    radiationStartDate <- addOffsetToCalendarDate(base.dates, start.day.offset)
    tbl$RadiationStart[indices] <<- radiationStartDate

    radiationEndDate <- addOffsetToCalendarDate(base.dates, end.day.offset)
    tbl$RadiationStop[indices] <<- radiationEndDate

    target <- tbl.rad1$radiation_therapy_site
    tbl$RadiationTarget[indices] <<- target

    } # 5

    # survival in years
  if (6 %in% levels) {
    survival.years <- as.numeric(tbl.pt$death_days_to)/365
    survival.years <- round(survival.years, digits=2)
    tbl$survival <<- survival.years
    } # 6

    # death date
  if (7 %in% levels) {
    diagnosis.date <- tbl$Diagnosis
    survival.days <- as.numeric(tbl.pt$death_days_to)
    death.date <- addOffsetToCalendarDate(diagnosis.date, survival.days)
    tbl$Death <<- death.date
    } # 7

    # recurrence, aka new tumor aka first progression
    # tbl.f2$new_tumor_event_dx_days_to
  if (8 %in% levels) {
    dups <- duplicated(tbl.f2$bcr_patient_barcode)
    tbl.f2a <- tbl.f2[!dups,]
    ids <- tbl.f2a$bcr_patient_barcode
    indices <- match(ids, tbl$ID)
    new.tumor.day.offset <- as.numeric(tbl.f2a$new_tumor_event_dx_days_to)
    new.tumor.years <- round(new.tumor.day.offset/365, digits=2)
    tbl$FirstProgression[indices] <<- new.tumor.years
    } # 8

  if (9 %in% levels) {
    tbl.ptHistory <- tbl
    filename <- "tbl.ptHistory.RData"
    printf("saving TCGA GBM patient history table, tbl.ptHistory, as %s", filename)
    save(tbl.ptHistory, file=filename)
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
#----------------------------------------------------------------------------------------------------
addOffsetToCalendarDate <- function(baseCalendarDate, offset.in.days)
{
    offsets <- offset.in.days * 60 * 60 * 24
    format(strptime(baseCalendarDate, "%d/%m/%Y") + offsets, "%d/%m/%Y")

} # addOffsetToCalendarDate
#----------------------------------------------------------------------------------------------------
test_addOffsetToCalendarDate <- function()
{
   print("--- test_addOffsetToCalendarDate")

   checkEquals(addOffsetToCalendarDate("01/01/2002", 92), "03/04/2002")

   pair <- addOffsetToCalendarDate(rep("01/01/2002", 2), c(1, -1))
   checkEquals(pair, c("02/01/2002", "31/12/2001"))

} # test_addOffsetToCalendarDate
#----------------------------------------------------------------------------------------------------
