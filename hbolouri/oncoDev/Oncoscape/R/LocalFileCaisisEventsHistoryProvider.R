setClass ("LocalFileCaisisEventsPatientHistoryProvider",
          contains="PatientHistoryProvider"
          )

#----------------------------------------------------------------------------------------------------
LocalFileCaisisEventsPatientHistoryProvider <- function(path)
{
   tokens <<- strsplit(path, "://")[[1]]

   if(!length(tokens) == 2){
       printf("Oncoscape LocalFileCaisisEventsPatientHistoryProvider  error.  Manifest line ill-formed: '%s'", path);
       stop()
       }

   protocol <- tokens[1]
   path <- tokens[2]

      # try first in the package.  if that fails, try the path directly
   if(!file.exists("path"))
       path <- system.file(package="Oncoscape", "extdata", path)

   if(!file.exists(path)){
       printf("Oncoscape LocalFileCaisisEventsPatientHistoryProvider error, file not found: %s", path)
       return(NA)
       }

   standard.name <- "events"
   printf("LocalFileCaisisEventsHistoryProvider about to load '%s'", path)
   given.var.name <- load(path)

      # give the just-read variable our standard name
   eval(parse(text=sprintf("%s <- %s", standard.name, given.var.name)))

   this <- new ("LocalFileCaisisEventsPatientHistoryProvider", table=data.frame(), events=events)

   this

} # LocalFileCaisisEventsPatientHistoryProvider
#----------------------------------------------------------------------------------------------------
setMethod("show", "LocalFileCaisisEventsPatientHistoryProvider",

   function(object) {
       msg <- sprintf("LocalFileCaisisEventsPatientHistoryProvider")
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
setMethod("getTable", "LocalFileCaisisEventsPatientHistoryProvider",

   function(self) {
      self@table
  })
#---------------------------------------------------------------------------------------------------
setMethod("getEvents", "LocalFileCaisisEventsPatientHistoryProvider",

   function(self) {
      self@events
  })
#---------------------------------------------------------------------------------------------------


