patientHistoryTemplateDataFrame <- function(count) {
   data.frame(list(ID = vector("character", count),
                   ageAtDx = vector("numeric", count),
                   FirstProgression = vector("character", count),
                   survival = vector("numeric", count),
                   ChemoAgent = vector("character", count),
                   DOB = vector("character", count),
                   Diagnosis  = vector("character", count),
                   RadiationStart = vector("character", count),
                   RadiationStop = vector("character", count),
                   RadiationTarget = vector("character", count),
                   ChemoStartDate = vector("character", count),
                   ChemoStopDate = vector("character", count),
                   Death = vector("character", count)
                   ),
               stringsAsFactors=FALSE)
}
