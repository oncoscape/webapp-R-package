# go.R
#------------------------------------------------------------------------------------------------------------------------
options(stringsAsFactors=FALSE)
library (RUnit)
#------------------------------------------------------------------------------------------------------------------------
run = function (levels)
{
  if (0 %in% levels) {
    load("tbl.clinical2.RData", envir=.GlobalEnv)
    } # 0


  if (1 %in% levels) {
    } # 1

  if (2 %in% levels) {
    fn <- "../../extdata/allGBM_timedCDEs.txt"
    tbl.tc <<- read.table(fn, sep="\t", header=TRUE, as.is=TRUE)
    } # 2 

  if (3 %in% levels) {
    spec2 <<- tbl.clinical2$tissueID
    btc2  <<- tbl.clinical2$Ref
    specL <<- tbl.tc$SpecimenId
    btcL <<-  tbl.tc$Ref
    printf("spec2: %d   specL: %d  shared: %d", length(spec2), length(specL), length(intersect(spec2, specL)))
    printf("btc2: %d   btcL: %d  shared: %d", length(btc2), length(btcL), length(intersect(btc2, btcL)))
    } # 3

  if (4 %in% levels) {
    tbl.x <<- merge(tbl.clinical2, tbl.tc[, c("Ref", "monthsTo1stProgression")], by="Ref")
    print(head(tbl.x[, c("tissueID", "Ref",  "RTx_StartDt",  "FirstProgression", "monthsTo1stProgression")], n=10))
    } # 4

  if (5 %in% levels) {
    new.colnames <- c("Ref",                   "Grade",                 "tissueID",              "RTx_StartDt",          
                      "monthsTo1stProgression",
                      "Type",                  "ChemoStartDate",        "ChemoAgent",            "FirstProgression",     
                      "Vital",                 "overallSurvival",       "ageAtDx",               "KPS",                  
                      "Surgeon",               "Procedure",             "Histology",             "HistologicCategory",   
                      "SpecimenId",            "RTx_StopDt",            "Target",                "TotalDose",            
                      "ChemoEndDate",          "ChemoStartDate2",       "ChemoEndDate2",         "ChemoAgent2",          
                      "ChemoStartDate3",       "ChemoEndDate3",         "ChemoAgent3",           "ChemoStartDate4",      
                      "ChemoEndDate4",         "ChemoAgent4",           "ChemoStartDate5",       "ChemoEndDate5",        
                      "ChemoAgent5",           "ChemoStartDate6",       "ChemoStopDate6",        "ChemoAgent6",          
                      "PostOpMRIDate",         "PostOpMRIResult",       "SecondProgression",     "ThirdProgression",     
                      "StatusDate")
    tbl.clinical2 <- tbl.x[, new.colnames]
    save(tbl.clinical2, file="tbl.clinical2a.RData")
    } # 5

  if (6 %in% levels) {
    } # 6 

  if (7 %in% levels) {
    } # 7

  if (8 %in% levels) {
    } # 8

  if (9 %in% levels) {
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
#------------------------------------------------------------------------------------------------------------------------
