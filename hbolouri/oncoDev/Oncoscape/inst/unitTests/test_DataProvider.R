# test_DataProvider.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_constructor()
   test_entities()
   test_features()
   test_getData()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_constructor <- function()
{
    print("--- test_constructor")

    dp.bogus <- DataProvider("bogus")
    checkTrue(is.na(dp.bogus))
    
    dp <- DataProvider("MSK.old")
    checkTrue(is(dp, "DataProvider"))
    checkTrue(is(dp, "MSKoldClinicalDataProvider"))


} # test_constructor
#----------------------------------------------------------------------------------------------------
test_features <- function()
{
    print("--- test_features")
    dp <- DataProvider("MSK.old")
    features <- features(dp)
    checkEquals(sort(features),
                c("ChemoAgent",             "ChemoAgent2",            "ChemoAgent3",
                  "ChemoAgent4",            "ChemoAgent5",            "ChemoAgent6",
                  "ChemoEndDate",           "ChemoEndDate2",          "ChemoEndDate3",
                  "ChemoEndDate4",          "ChemoEndDate5",          "ChemoStartDate",
                  "ChemoStartDate2",        "ChemoStartDate3",        "ChemoStartDate4",
                  "ChemoStartDate5",        "ChemoStartDate6",        "ChemoStopDate6",
                  "FirstProgression",       "Grade",                  "HistologicCategory",
                  "Histology",              "KPS",                    "PostOpMRIDate",
                  "PostOpMRIResult",        "Procedure",              "RTx_StartDt",
                  "RTx_StopDt",             "Ref",                    "SecondProgression",
                  "SpecimenId",             "StatusDate",             "Surgeon",
                  "Target",                 "ThirdProgression",       "TotalDose",
                  "Type",                   "Vital",                  "ageAtDx",
                  "monthsTo1stProgression", "overallSurvival",        "tissueID"))

} # test_features
#----------------------------------------------------------------------------------------------------
test_entities <- function()
{
    print("--- test_entities")
    dp <- DataProvider("MSK.old")
    entities <- entities(dp)
    checkEquals(head(sort(entities)), c("1003-1", "1015-1", "1019-1", "1028-1", "103", "1036-1"))

} # test_specimen
#----------------------------------------------------------------------------------------------------
test_getData <- function()
{
    print("--- test_getData")
    dp <- DataProvider("MSK.old")

       # the null test: no specimen or features requested
    tbl.sub <- getData(dp, c(), c())
    checkEquals(dim(tbl.sub), c(0, 0))
    
      # small subset
    features <- c("ageAtDx", "StatusDate", "Surgeon")
    specimen <- c("1003-1", "1015-1", "1019-1", "1028-1", "103", "1036-1")
    tbl.2 <- getData(dp, specimen, features)
                          
    checkEquals(dim(tbl.2), c(6,4))
    checkEquals(colnames(tbl.2), c("Ref", features))

} # test_getData
#----------------------------------------------------------------------------------------------------
