setClass("PatientHistoryProvider",
         representation(sourceURI="character",
                        protocol="character",
                        path="character",
                        patientIDs="character",
                        eventNames="character",
                        table="data.frame",
                        events="list")
        
         )

#setGeneric("patientIDs", signature="self", function (self, ...) standardGeneric ("patientIDs"))
#setGeneric("patientEventNames",   signature="self", function (self, ...) standardGeneric ("patientEventNames"))
#setGeneric("getPatientData", signature="self", function(self, patients=NA, events=NA) standardGeneric("getPatientData"))
#setGeneric("getClinicalTable", signature="self", function(self, patients=NA, events=NA) standardGeneric("getClinicalTable"))
setGeneric("getTable", signature="self", function(self, patient.ids=NA, event.names=NA) standardGeneric("getTable"))
setGeneric("getEvents", signature="self", function(self, patient.ids=NA, event.names=NA) standardGeneric("getEvents"))
setGeneric("legalEventNames", signature="self", function(self) standardGeneric("legalEventNames"))
setGeneric("requiredEventNames", signature="self", function(self) standardGeneric("requiredEventNames"))


# constructor
#---------------------------------------------------------------------------------------------------
PatientHistoryProvider = function(sourceURI)
{
   tokens <- strsplit(sourceURI, ":\\/\\/")[[1]]
   protocol <- tokens[1]
   path <- tokens[2]
   
   if(!protocol %in% c("caisisEvents", "tbl")){
       warning(sprintf("'%s% protocol not yet supported", protocol));
       return(NA)
       }

   result <- NA
   
   if(protocol == "caisisEvents")
     result <- LocalFileCaisisEventsPatientHistoryProvider(sourceURI)
   else if(protocol == "tbl")
     result <- LocalFilePreparedTablePatientHistoryProvider(sourceURI)

   result

} # ctor
#---------------------------------------------------------------------------------------------------
# setMethod ("patientIDs", "PatientHistoryProvider",
# 
#    function(self) {
#       return(self@patientIDs)
#       });
# 
# #---------------------------------------------------------------------------------------------------
# setMethod ("patientEventNames", "PatientHistoryProvider",
# 
#    function(self) {
#        return(self@eventNames)
# 
#    });
# #---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
# setMethod ("getClinicalTable", "PatientHistoryProvider",
# 
#    function(self, patients=NA, events=NA) {
#       x <- getPatientData(self, patients, events)
#       toTable(x)
#       }); # getClinicalTable
# 
# #---------------------------------------------------------------------------------------------------
# toTable <- function(patientEvents)
# {
#    patientIds <- sort(unique(unlist(lapply(patientEvents, function(element) element$PatientId))))
#    groups <- lapply(patientIds, function(id) grep(id, patientEvents))
#    names(groups) <- patientIds
#    
#    count <- length(patientIds)
#    result <- data.frame(list(ID = vector("character", count),
#                              DOB = vector("character", count),
#                              Diagnosis  = vector("character", count),
#                              ChemoStartDate = vector("character", count),
#                              ChemoStopDate = vector("character", count),
#                              ChemoAgent = vector("character", count),
#                              RadiationStart = vector("character", count),
#                              RadiationStop = vector("character", count),
#                              RaditionTarget = vector("character", count),
#                              FirstProgression = vector("character", count),
#                              Death = vector("character", count)),
#                              stringsAsFactors=FALSE)
#    
#    i <- 0
# 
#    new.row.template <- as.list(rep(NA_character_, ncol(result)))
#    names(new.row.template) <- colnames(result)
# 
#    for(patientId in patientIds){
#       events <- patientEvents[groups[[patientId]]]
#       new.row <- new.row.template
#       new.row$ID <- patientId
#       for(x in events){
#          if(x$TableName == "MedicalTherapy"){
#          startDate <- x$MedTxDateText
#          stopDate <- x$MedTxStopDateText
#          if(is.na(stopDate))
#             stopDate <- startDate
#          new.row$ChemoStartDate <- startDate
#          new.row$ChemoStopDate <- stopDate
#          new.row$ChemoAgent <- x$MedTxAgent
#          } # MedicalTherapy
#       else if(x$TableName == "RadiationTherapy"){
#          startDate <- x$RadTxDateText
#          stopDate <- x$RadTxStopDateText
#          if(is.na(stopDate))
#              stopDate <- startDate
#          new.row$RadiationStart <- Oncoscape:::reformatDate(startDate)
#          new.row$RadiationStop <- Oncoscape:::reformatDate(stopDate)
#          new.row$RaditionTarget <- x$RadTxTarget
#          } # RadiationTherapy
#      else if(x$TableName == "Status"){
#         date <- x$StatusDateText
#         if(is.na(date)){
#            printf("--- no date for Status/%s, arbitrary assignment made", x$PatientId)
#            date <- "2009-08-11"
#            }
#         date <- Oncoscape:::reformatDate(date)
#         if(x$Status == "Diagnosis Date")
#            new.row$Diagnosis <- date
#         if(x$Status == "1st Progression")
#            new.row$FirstProgression <- date
#         if(x$Status == "Alive")
#            new.row$Death <- date
#         } # Status
#      else if(x$TableName == "Patients"){
#         date <- x$PtBirthDateText;
#         if(is.na(date))
#            date <- ""
#         else
#            date <- Oncoscape:::reformatDate(date)
#         new.row$DOB <- date
#         date <- x$PtDeathDateText
#         if(is.na(date))
#            date <- ""
#         else
#            date <- Oncoscape:::reformatDate(date)
#         new.row$Death <- date
#         #browser()
#         #zzzzz <- 99
#         } # Patients
#      } # for x in events
#      i <- i + 1
#      #printf("i: %d, patientId: %s", i, patientId)
#      #browser()
#      result[i,]  <- new.row[colnames(result)]
#      }# for patientId
# 
#   result
#       
# } # toTable
#---------------------------------------------------------------------------------------------------
setMethod ("legalEventNames", "PatientHistoryProvider",

   function(self){
     c("DOB", "Status",  "Diagnosis", "MRI", "Chemo", "Radiation", "OR", "Pathology", "Encounter", "Progression", "Death")
     })

#---------------------------------------------------------------------------------------------------
setMethod ("requiredEventNames", "PatientHistoryProvider",

   function(self){
     legalEventNames(self)
     })

#---------------------------------------------------------------------------------------------------
setMethod("getEvents", "PatientHistoryProvider",

   function(self, patient.ids=NA, event.names=NA) {

      hits <- 1:length(self@events)  # so we can return all events for all patients

      if(!all(is.na(patient.ids))){
         hits <- which(unlist(lapply(self@events, function(event) event$PatientID %in% patient.ids)))
         }

      events <- self@events[hits]   # apply any filtering which
      
      if(!all(is.na(event.names))){
         hits <- which(unlist(lapply(events, function(event) event$Name %in% event.names)))
         }

      events[hits]
      })

#---------------------------------------------------------------------------------------------------
