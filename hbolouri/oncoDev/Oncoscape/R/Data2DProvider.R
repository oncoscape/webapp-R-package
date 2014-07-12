setClass("Data2DProvider",
         representation(sourceURI="character",
                        protocol="character",
                        path="character",
                        tbl="data.frame")
         )

setGeneric("entities",   signature="self", function (self, ...) standardGeneric ("entities"))
setGeneric("features",   signature="self", function (self, ...) standardGeneric ("features"))
setGeneric("getData",    signature="self", function (self, entities=NA, features=NA) standardGeneric ("getData"))
setGeneric("getAverage", signature="self", function (self, rowsOrColumns, entities=NA, features=NA) standardGeneric("getAverage"))
setGeneric("dimensions", signature="self", function (self) standardGeneric("dimensions"))
#---------------------------------------------------------------------------------------------------
Data2DProvider = function(sourceURI)
{
   tokens <- strsplit(sourceURI, ":\\/\\/")[[1]]
   protocol <- tokens[1]
   path <- tokens[2]
   
   if(!protocol %in% c("pkg", "file")){
       warning(sprintf("Data2dProvider constructor, '%s protocol not yet supported", protocol));
       return(NA)
       }

   result <- NA
   
   if(protocol %in% c("pkg", "file")){
     result <- LocalFileData2DProvider(sourceURI)
     }

   result

} # ctor: Data2DProvider
#---------------------------------------------------------------------------------------------------
