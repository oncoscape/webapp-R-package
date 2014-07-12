setClass ("LocalFileData2DProvider",
          contains="Data2DProvider"
          )

#----------------------------------------------------------------------------------------------------
LocalFileData2DProvider <- function(sourceURI)
{
   tokens <<- strsplit(sourceURI, "://")[[1]]

   if(!length(tokens) == 2){
       printf("Oncoscape LocalFileData2DProvider  error.  Manifest line ill-formed: '%s'", path);
       stop()
       }

   protocol <- tokens[1]
   path <- tokens[2]

   if(protocol == "pkg")
      full.path <- system.file(package="Oncoscape", "extdata", path)

   if(protocol == "file")
      full.path <- path

   if(protocol %in% (c("pkg", "file"))){
       standard.name <- "tbl"
       if(!file.exists(full.path)){
          printf("Oncoscape  LocalFileData2DProvider  error.  Could not read patientHistory file: '%s'",
                 full.path);
          stop()
          }
       eval(parse(text=sprintf("%s <<- %s", standard.name, load(full.path))))
       printf("loaded %s from %s, %d x %d", standard.name, full.path,
              nrow(tbl), ncol(tbl))
      } # either pkg or file protocol

   this <- new ("LocalFileData2DProvider", sourceURI=sourceURI, protocol=protocol, path=path,
                tbl=tbl)

   this

} # LocalFileData2DProvider
#----------------------------------------------------------------------------------------------------
setMethod("show", "LocalFileData2DProvider",

   function(object) {
       msg <- sprintf("LocalFileData2DProvider")
       cat(msg, "\n", sep="")
       msg <- sprintf("tbl dimensions: %d x %d", nrow(object@tbl), ncol(object@tbl))
       cat(msg, "\n", sep="")
       }) # show

#---------------------------------------------------------------------------------------------------
setMethod ("features", "LocalFileData2DProvider",   

   function(self) {
      result <- colnames(self@tbl)
      result
      })

#---------------------------------------------------------------------------------------------------
setMethod ("entities", "LocalFileData2DProvider",  

   function(self) {
      unique(rownames(self@tbl))
      })
           
#---------------------------------------------------------------------------------------------------
setMethod ("getData", "LocalFileData2DProvider",

   function(self, entities=NA, features=NA) {

      #browser()
      if(all(is.na(entities)))
         rows <- row.names(self@tbl)
      else
         rows <- match(entities, row.names(self@tbl))

      deleters <- which(is.na(rows))
      if(length(deleters) > 0)
          rows <- rows [-deleters]

      if(length(rows) == 0)
          return(data.frame())
      
      if(all(is.na(features)))
         recognized.columns <- colnames(self@tbl)
      else{
         matches <- match(features, colnames(self@tbl))
         nas <- which(is.na(matches))
         if(length(nas) > 0)
            matches <- matches[-nas]
         recognized.columns  <- colnames(self@tbl)[matches]
         }
      
      if(length(recognized.columns) == 0)
          return(data.frame())
      
      self@tbl[rows, recognized.columns]
      })

#---------------------------------------------------------------------------------------------------
setMethod ("dimensions", "LocalFileData2DProvider",

    function(self) {
        return(dim(self@tbl))
    })
#---------------------------------------------------------------------------------------------------
