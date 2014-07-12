# test_ClinicalDataProvider.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_constructor()
   test_dataTypes()
   test_specimen()
   test_getData()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_constructor <- function()
{
    print("--- test_constructor")

    cdp.bogus <- ClinicalDataProvider("bogus")
    checkTrue(is.na(cdp.bogus))
    
    cdp <- ClinicalDataProvider("MSK.old")
    checkTrue(is(cdp, "DataProvider"))
    checkTrue(is(cdp, "MSKoldClinicalDataProvider"))


} # test_constructor
#----------------------------------------------------------------------------------------------------
test_dataTypes <- function()
{
    print("--- test_dataTypes")
    cdp <- ClinicalDataProvider("MSK.old")
#    dataTypes <- dataTypes(cdp)
#    checkEquals(sort(dataTypes),
#                c("ChemoAgent",             "ChemoAgent2",            "ChemoAgent3",
#                  "ChemoAgent4",            "ChemoAgent5",            "ChemoAgent6",
#                  "ChemoEndDate",           "ChemoEndDate2",          "ChemoEndDate3",
#                  "ChemoEndDate4",          "ChemoEndDate5",          "ChemoStartDate",
#                  "ChemoStartDate2",        "ChemoStartDate3",        "ChemoStartDate4",
#                  "ChemoStartDate5",        "ChemoStartDate6",        "ChemoStopDate6",
#                  "FirstProgression",       "Grade",                  "HistologicCategory",
#                  "Histology",              "KPS",                    "PostOpMRIDate",
#                  "PostOpMRIResult",        "Procedure",              "RTx_StartDt",
#                  "RTx_StopDt",             "Ref",                    "SecondProgression",
#                  "SpecimenId",             "StatusDate",             "Surgeon",
#                  "Target",                 "ThirdProgression",       "TotalDose",
#                  "Type",                   "Vital",                  "ageAtDx",
#                  "monthsTo1stProgression", "overallSurvival",        "tissueID"))

} # test_dataTypes
#----------------------------------------------------------------------------------------------------
test_specimen <- function()
{
    print("--- test_speciment")
    cdp <- ClinicalDataProvider("MSK.old")
    specimen <- specimen(cdp)
    checkEquals(head(sort(specimen)), c("1003-1", "1015-1", "1019-1", "1028-1", "103", "1036-1"))

} # test_specimen
#----------------------------------------------------------------------------------------------------
test_getData <- function()
{
    print("--- test_getData")
    cdp <- ClinicalDataProvider("MSK.old")

       # the null test: no specimen or dataTypes requested
    tbl.sub <- getData(cdp, c(), c())
    checkEquals(dim(tbl.sub), c(0, 0))
    
      # small subset
    dataTypes <- c("ageAtDx", "StatusDate", "Surgeon")
    specimen <- c("1003-1", "1015-1", "1019-1", "1028-1", "103", "1036-1")
    tbl.2 <- getData(cdp, specimen, dataTypes)
                          
    checkEquals(dim(tbl.2), c(6,4))
    checkEquals(colnames(tbl.2), c("Ref", dataTypes))

} # test_getData
#----------------------------------------------------------------------------------------------------
