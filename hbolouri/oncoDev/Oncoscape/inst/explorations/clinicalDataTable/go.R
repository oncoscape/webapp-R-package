# go.R
#------------------------------------------------------------------------------------------------------------------------
options(stringsAsFactors=FALSE)
library (RUnit)
#------------------------------------------------------------------------------------------------------------------------
run = function (levels)
{
  if (0 %in% levels) {
    load("tbl.clinical.RData", envir=.GlobalEnv)
    } # 0

  if (1 %in% levels) {
    old.colnames <<- c("KPS", "Surgeon", "Procedure", "Histology", "HistologicCategory", "Grade",
                       "SpecimenId", "Ref", "RTx_StartDt", "RTx_StopDt", "Type", "Target",
                       "TotalDose", "ChemoStartDate", "ChemoEndDate", "ChemoAgent", "ChemoStartDate2",
                       "ChemoEndDate2", "ChemoAgent2", "ChemoStartDate3", "ChemoEndDate3",
                       "ChemoAgent3", "ChemoStartDate4", "ChemoEndDate4", "ChemoAgent4",
                       "ChemoStartDate5", "ChemoEndDate5", "ChemoAgent5", "ChemoStartDate6",
                       "ChemoStopDate6", "ChemoAgent6", "PostOpMRIDate", "PostOpMRIResult",
                       "X1stProgression", "X2ndProgression", "X3rdProgression", "StatusDate",
                       "Vital", "overallSurvival", "ageAtDx")

    checkTrue(all(colnames(tbl.clinical) == old.colnames))
    } # 1

  if (2 %in% levels) {
     print(match("Grade", old.colnames))
     print(match("Ref", old.colnames))
     print(match("RTx_StartDt", old.colnames))
     print(match("Type", old.colnames))
     print(match("ChemoStartDate", old.colnames))
     print(match("ChemoAgent", old.colnames))
     print(match("X1stProgression", old.colnames))
     print(match("Vital", old.colnames))
     print(match("overallSurvival", old.colnames))
     print(match("ageAtDx", old.colnames))
    } # 2

  if (3 %in% levels) {
     indices <<- c(match("Grade", old.colnames),
                   match("Ref", old.colnames),
                   match("RTx_StartDt", old.colnames),
                   match("Type", old.colnames),
                   match("ChemoStartDate", old.colnames),
                   match("ChemoAgent", old.colnames),
                   match("X1stProgression", old.colnames),
                   match("Vital", old.colnames),
                   match("overallSurvival", old.colnames),
                   match("ageAtDx", old.colnames))

     new.indices <<- c(indices, setdiff(1:length(old.colnames), indices))
    } # 3

  if (4 %in% levels) {
    tbl <<- tbl.clinical[, new.indices]
    } # 4

  if (5 %in% levels) {
    printf("loading %s", load("../../extdata/tbl.idLookupWithDzSubType.RData", envir=.GlobalEnv))
    } # 5

  if (6 %in% levels) {
    x <- match(tbl$Ref, tbl.idLookup$btc)
    tissueID <<- tbl.idLookup$specimen[x]
    tissueID[is.na(tissueID)] <<- "NULL"
    } # 6

  if (7 %in% levels) {
    tbl <<- cbind(tbl[, 1:2], tissueID, tbl[, 3:40])
    } # 7

  if (8 %in% levels) {
       # "X1stProgression" "X2ndProgression" "X3rdProgression"
     progression.indices <<- grep("Progression", colnames(tbl), ignore.case=TRUE)
     col <- grep("X1stProgression", colnames(tbl))
     colnames(tbl)[col] <<- "FirstProgression"
     col <- grep("X2ndProgression", colnames(tbl))
     colnames(tbl)[col] <<- "SecondProgression"
     col <- grep("X3rdProgression", colnames(tbl))
     colnames(tbl)[col] <<- "ThirdProgression"
     print(colnames(tbl)[progression.indices])   # did it take?
     } # 8

  if (9 %in% levels) {
    tbl.clinical2 <- unique(tbl)
    save(tbl.clinical2, file="tbl.clinical2.RData")
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
