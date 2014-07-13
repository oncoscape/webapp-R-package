setClass ("LocalFilePreparedTablePatientHistoryProvider",
          contains="PatientHistoryProvider"
          )

#----------------------------------------------------------------------------------------------------
LocalFilePreparedTablePatientHistoryProvider <- function(path)
{
   tokens <<- strsplit(path, "://")[[1]]

   if(!length(tokens) == 2){
       printf("Oncoscape LocalFilePreparedTablePatientHistoryProvider  error.  Manifest line ill-formed: '%s'", path);
       stop()
       }

   protocol <- tokens[1]
   path <- tokens[2]

   if(protocol == "pkg")
      full.path <- system.file(package="Oncoscape", "extdata", path)

   if(protocol == "file")
      full.path <- path

   if(protocol %in% (c("pkg", "file"))){
       standard.name <- "tbl.patientHistory"
       if(!file.exists(full.path)){
          printf("Oncoscape  LocalFilePreparedTablePatientHistoryProvider  error.  Could not read patientHistory file: '%s'", full.path);
          stop()
          }
       eval(parse(text=sprintf("%s <<- %s", standard.name, load(full.path))))
       printf("loaded %s from %s, %d x %d", standard.name, full.path,
              nrow(tbl.patientHistory), ncol(tbl.patientHistory))
      } # either pkg or file protocol

   this <- new ("LocalFilePreparedTablePatientHistoryProvider", table=tbl.patientHistory, events=list())

   this

} # LocalFilePreparedTablePatientHistoryProvider
#----------------------------------------------------------------------------------------------------
setMethod("show", "LocalFilePreparedTablePatientHistoryProvider",

   function(object) {
       msg <- sprintf("LocalFilePreparedTablePatientHistoryProvider")
       cat(msg, "\n", sep="")
       msg <- sprintf("tbl dimensions: %d x %d", nrow(object@table), ncol(object@table))
       cat(msg, "\n", sep="")
       msg <- sprintf("events list length: %d", length(object@events))
       cat(msg, "\n", sep="")
       }) # show

#---------------------------------------------------------------------------------------------------
# setMethod ("getPatientData", "LocalFilePreparedTableDataProvider",
# 
#    function(self, patients=NA, events=NA) {
# 
#        if(all(is.na(patients)))
#            patients <- patientIDs(self)
# 
#        if(all(is.na(events)))
#           events <- patientEventNames(self)
#           
#        unrecognized.events <- setdiff(events, patientEventNames(self))
#        if(length(unrecognized.events) > 0){
#            warning(sprintf("unrecognized events skipped: %s",
#                            paste(unrecognized.events, collapse=", ")));
#            }
# 
#        recognized.events <- intersect(events, patientEventNames(self));
#        recognized.patients <- intersect(patients, patientIDs(self))
#        result <- vector("list", length(recognized.events) *  length(recognized.patients))
#        i = 0;
#        for(event in recognized.events){
#            for(patient in recognized.patients){
#               tbl.tmp <- subset(self@data[[event]], PatientId==patient)
#               #printf("events for pt %s and event %s: %d", patient, event, nrow(tbl.tmp))
#               rows <- split(tbl.tmp, rownames(tbl.tmp))
#               rows <- lapply(rows, as.list)
#               for(row in rows){
#                  row[["TableName"]] <- event
#                   i = i + 1
#                  result[[i]] <- row
#                  } # for row
#               }# for patient
#           } # for event
#        invisible(result)
#    });  # getPatientData
# 
#---------------------------------------------------------------------------------------------------
setMethod("getTable", "LocalFilePreparedTablePatientHistoryProvider",

   function(self) {
      self@table
  })
#---------------------------------------------------------------------------------------------------
setMethod("getEvents", "LocalFilePreparedTablePatientHistoryProvider",

   function(self) {
      self@events
  })
#---------------------------------------------------------------------------------------------------


