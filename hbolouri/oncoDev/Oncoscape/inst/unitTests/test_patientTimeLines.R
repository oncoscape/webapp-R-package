# test_Analyses.R
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
# hidden in the package, but useful to have available here for tests and exploration
if(!exists("tbl.pt")){
    filename <- system.file(package="Oncoscape", "extdata", "tbl.pt.RData")
    stopifnot(file.exists(filename))
    load(filename)
    }

if(!exists("tbl.idLookup")){
    printf("calling .loadData");
    Oncoscape:::.loadData();
    }


#----------------------------------------------------------------------------------------------------
runTests <- function()
{
   test_colorMap()
   test_filterPatientTimeLineTable()
   test_createTimeMatrix()
   test_alignMatrix()
   test_timelineMatrixExtractLines()
   test_timelineMatrixAsEvents()
   test_tissueID.mapping()
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_colorMap <- function()
{
   printf("--- test_colorMap");
   cmap <- Oncoscape:::getColorMap()
   mapped.events <- ls(cmap)
   tbl.pt <- Oncoscape:::filterPatientTimeLineTable()
   checkEquals(length(intersect(mapped.events, colnames(tbl.pt))), length(mapped.events))
   checkEquals(cmap[["OR_Date"]], "cornflowerblue")

} # test_colorMap
#----------------------------------------------------------------------------------------------------
test_filterPatientTimeLineTable <- function()
{
    printf("--- test_filterPatientTimeLineTable")
    #port.number <- 7589L
    #onco <- Oncoscape(htmlFile=NA, mode="websockets", port=port.number)
    tbl.pt <- Oncoscape:::filterPatientTimeLineTable()
    checkEquals(dim(tbl.pt), c(282,  52))

    color.map <- Oncoscape:::getColorMap()
    events.of.interest <- c("DOB", "MSKEncounterDate", "DiagnosisDate", 
                            "OR_Date", "RTx_StartDt",
                            "ChemoStartDate", "ChemoEndDate",
                            "FirstProgression", "RTx_StopDt")

    checkTrue(all(events.of.interest  %in% ls(color.map)))
    
    tbl.eoi <- Oncoscape:::filterPatientTimeLineTable(colnames = events.of.interest)
    checkEquals(colnames(tbl.eoi), events.of.interest)
    checkEquals(dim(tbl.eoi), c(282,9))

} # test_filterPatientTimeLineTable
#----------------------------------------------------------------------------------------------------
test_createTimeMatrix <- function()
{
    printf("--- test_createTimeMatrix")
    events.of.interest <- c("DOB", "MSKEncounterDate", "DiagnosisDate", 
                            "OR_Date", "RTx_StartDt",
                            "ChemoStartDate", "ChemoEndDate",
                            "FirstProgression", "StatusDate")
    patients.of.interest <- c ("P10", "P11", "P12")
    mtx <- Oncoscape:::createTimeMatrix(patients.of.interest, events.of.interest)
    checkTrue(is(mtx, "matrix"))
    checkTrue(is(mtx[1,1], "numeric"))
    checkEquals(rownames(mtx), c("P10", "P11", "P12"))
    checkEquals(colnames(mtx), events.of.interest)
    checkEqualsNumeric(mean(mtx), 12756, tol=1.0)

        # now transform to log2
    mtx <- Oncoscape:::createTimeMatrix(patients.of.interest, events.of.interest, log2Transform=TRUE)
    checkEqualsNumeric(mean(mtx), 8, tol=1.0)
    checkEquals(rownames(mtx), c("P10", "P11", "P12"))

       # get the full matrix
    mtx <- Oncoscape:::createTimeMatrix()
    checkEquals(dim(mtx), c (282, 24))

} # test_createTimeMatrix
#----------------------------------------------------------------------------------------------------
test_alignMatrix <- function()
{
    printf("--- test_shiftMatrix")
    events.of.interest <- c("DOB", "MSKEncounterDate", "DiagnosisDate", 
                            "OR_Date", "RTx_StartDt",
                            "ChemoStartDate", "ChemoEndDate",
                            "FirstProgression", "StatusDate")
    patients.of.interest <- c ("P10", "P11", "P12")
    mtx <- Oncoscape:::createTimeMatrix(patients.of.interest, events.of.interest)

    alignmentColumn <-  "DiagnosisDate"
    mtx.0 <- Oncoscape:::alignTimeMatrix(mtx, alignmentColumn)
    checkTrue(all(mtx.0[, alignmentColumn] == 0))

       # the DiagnosisDates are subtracted from each column of every row
       # so the rowSums should be equals if that (i.e., 9 columms * offsets)
       # is subtracted

    offsets <- as.numeric(mtx[, alignmentColumn])
    rSums.mtx  <- as.numeric(rowSums(mtx))
    rSums.mtx0 <- as.numeric(rowSums(mtx.0))
    checkEquals(rSums.mtx0, rSums.mtx - (ncol(mtx) * offsets))
    
    alignmentColumn <- "FirstProgression"
    mtx.1 <- Oncoscape:::alignTimeMatrix(mtx, alignmentColumn)
    checkTrue(all(mtx.1[, alignmentColumn] == 0))

       # the DiagnosisDates are subtracted from each column of every row
       # so the rowSums should be equals if that (i.e., 9 columms * offsets)
       # is subtracted

    offsets <- as.numeric(mtx[, alignmentColumn])
    rSums.mtx  <- as.numeric(rowSums(mtx))
    rSums.mtx1 <- as.numeric(rowSums(mtx.1))
    checkEquals(rSums.mtx1, rSums.mtx - (ncol(mtx) * offsets))
    
} # test_alignMatrix
#----------------------------------------------------------------------------------------------------
createTestMatrix <- function(patients.of.interest=NA, align=FALSE)
{
   events.of.interest <- c("DOB", "MSKEncounterDate", "DiagnosisDate", 
                            "OR_Date", "RTx_StartDt",
                           "ChemoStartDate", "ChemoEndDate",
                           "FirstProgression", "StatusDate")
   if(all(is.na(patients.of.interest)))
       patients.of.interest <- c ("P10", "P11", "P12")

   mtx <- Oncoscape:::createTimeMatrix(patients.of.interest, events.of.interest)
   if(align){
      alignmentColumn <-  "DiagnosisDate"
      mtx <- Oncoscape:::alignTimeMatrix(mtx, alignmentColumn)
      }

   mtx
   
} # createTestMatrix
#----------------------------------------------------------------------------------------------------
test_timelineMatrixExtractLines <- function()
{
   print("--- test_timelineMatrixExtractLines")

   mtx <- createTestMatrix(align=TRUE)
   df <- Oncoscape:::timelineMatrixExtractLines(mtx)

   checkEquals(dim(df), c(3,3))
   checkEquals(colnames(df), c("min", "max", "lineNumber"))
   checkEquals(rownames(df), c("P10", "P11", "P12"))
   checkEqualsNumeric(mean(as.numeric(c(df$min, df$max))), -7441.833, tol=1.0)

   json <- Oncoscape:::timelineMatrixExtractLines(mtx, returnJSON=TRUE)
     
   checkEquals(substring(json,1,1), "[")

   checkEquals(substring(json,nchar(json), nchar(json)), "]")
   checkEquals(substr(json, 1, 77),
      "[ {\n \"min\": \"-24138\",\n\"max\": \"497\",\n\"lineNumber\": \"1\",\n\"patiendID\": \"P10\" \n},")

      # P2 has some missing values, which will confuse min & max if they are
      # not told na.rm=TRUE.   make sure that's the case
   
   mtx.2 <- createTestMatrix(patients.of.interest=c("P1", "P2"), align=FALSE)
   df <- Oncoscape:::timelineMatrixExtractLines(mtx.2)
   checkTrue(all(!is.na(as.numeric(as.matrix(df)))))

} # test_timelineMatrixExtractLines
#----------------------------------------------------------------------------------------------------
test_timelineMatrixAsEvents  <- function()
{
   print("--- timelineMatrixAsEvents")

   mtx <- createTestMatrix(patients.of.interest=c("P1","P2"), align=TRUE)

   df <- Oncoscape:::timelineMatrixAsEvents(mtx)
   checkTrue(all(!is.na(df$value)))
   checkEquals(dim(df), c(14, 4))
   checkEquals(colnames(df), c("event", "value", "patientNumber", "patientID"))
   tbl.DOB <- subset(df, event=="DOB")
   checkEquals(dim(tbl.DOB), c(2,4))
   checkEquals(tbl.DOB$value, c(-18184, -23009))

   json <- Oncoscape:::timelineMatrixAsEvents(mtx, returnJSON=TRUE)

      # some apparently erratic behavior with toJSON.
      #  called on (df) it returns the proper
      # '[{event: "DOB",value: "-24138, patientNumber: "1",patientID: "P10" },
      #   {event: "MSKEncounterDate", value: -4, patientNumber: "1",patientID: "P10"}, ... ]
      # but when called on (df[1:2,]), a hash of hashes a returned, not the desired array of hashes
   checkEquals(substr(json, 1, 1), "[")

} # test_timelineMatrixAsEvents 
#----------------------------------------------------------------------------------------------------
test_toJSON.timelineMatrixAsEvents <- function()
{
   print("--- test_toJSON.timelineMatrixAsEvents")
   mtx <- createTestMatrix(align=TRUE)
   df <- Oncoscape:::timelineMatrixAsEvents(mtx)
   json <- Oncoscape:::toJSON.timelineMatrixAsEvents(df)
      # some apparently erratic behavior with toJSON.
      #  called on (df) it returns the proper
      # '[{event: "DOB",value: "-24138, patientNumber: "1",patientID: "P10" },
      #   {event: "MSKEncounterDate", value: -4, patientNumber: "1",patientID: "P10"}, ... ]
      # but when called on (df[1:2,]), a hash of hashes a returned, not the desired array of hashes
   checkEquals(substr(json, 1, 1), "[")
    
} # test_toJSON.timelineMatrixAsEvents 
#----------------------------------------------------------------------------------------------------
test_tissueID.mapping <- function()
{
   print("--- test_tissueID.mapping")
   tissueIDs <- c("1233.T.1", "201X.T.1", "396.1.T.1", "0645.T.1", "803.T.1")
   x <- Oncoscape:::timelineMapTissueIDs(tissueIDs);
   checkEquals(x, c("P75", "P107", "P197"))

   checkEquals(Oncoscape:::timelineMapTissueIDs(""), c())
   checkEquals(Oncoscape:::timelineMapTissueIDs("bogus"), c())

   events.of.interest <- c("DOB", "MSKEncounterDate", "DiagnosisDate", 
                           "OR_Date", "RTx_StartDt",
                           "ChemoStartDate", "ChemoEndDate",
                           "FirstProgression", "StatusDate")

   mtx <- Oncoscape:::createTimeMatrix(tissueIDs, events.of.interest)
   checkEquals(dim(mtx), c(3, 9))
   checkEquals(rownames(mtx), c("P75", "P107", "P197"))

   tissueIDs <- c("1183.T.1", "1184.T.1" , "0641.T.1", "806.T.1");
   mtx <- Oncoscape:::createTimeMatrix(tissueIDs, events.of.interest)

} # test_tissueID.mapping
#----------------------------------------------------------------------------------------------------
