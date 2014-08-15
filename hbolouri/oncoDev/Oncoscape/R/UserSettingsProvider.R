setClass("UserSettingsProvider",
         representation(sourceURI="character",
                        protocol="character",
                        path="character",
                        userIDmap="list")
         )

#setGeneric("show",   signature="self", function (self, ...) standardGeneric ("show"))
setGeneric("userIDs",   signature="self", function (self, ...) standardGeneric ("userIDs"))
setGeneric("NumUsers", signature="self", function (self) standardGeneric("NumUsers"))
setGeneric("getUserID",    signature="self", function (self, userID=NA) standardGeneric ("getUserID"))
setGeneric("addUserID",    signature="self", function (self, userID=NA, username=NA) standardGeneric ("addUserID"))
#---------------------------------------------------------------------------------------------------
UserSettingsProvider = function(sourceURI)
{

   result <- NA
   
   if(sourceURI == ""){
       result <- NewUserSettingsProvider()
   } else {       #selection read from manifest file
   
       tokens <- strsplit(sourceURI, ":\\/\\/")[[1]]
       protocol <- tokens[1]
       path <- tokens[2]
   
       if(!protocol %in% c("pkg", "file")){
          warning(sprintf("UserSettingsProvider constructor, '%s protocol not yet supported", protocol));
          return(NA)
       }
       if(protocol %in% c("pkg", "file")){
          result <- LocalFileUserSettingsProvider(sourceURI)
       }
    }
   
   result

} # ctor: UserSettingsProvider
#---------------------------------------------------------------------------------------------------
NewUserSettingsProvider <- function()
{
      this <- new ("UserSettingsProvider", sourceURI="", protocol="new", path="", userIDmap=list())
      this
}
#---------------------------------------------------------------------------------------------------
LocalFileUserSettingsProvider <- function(sourceURI)
{
   tokens <<- strsplit(sourceURI, "://")[[1]]

   if(!length(tokens) == 2){
       printf("Oncoscape LocalFileUserSettingsProvider  error.  Manifest line ill-formed: '%s'", path);
       stop()
       }

   protocol <- tokens[1]
   path <- tokens[2]

   if(protocol == "pkg")
      full.path <- system.file(package="Oncoscape", "extdata", path)

   if(protocol == "file")
      full.path <- path

   if(protocol %in% (c("pkg", "file"))){
       standard.name <- "userIDmap"
       if(!file.exists(full.path)){
          printf("Oncoscape  LocalFileUserSettingsProvider  error.  Could not read UserIDmap file: '%s'",
                 full.path);
          stop()
          }
       eval(parse(text=sprintf("%s <<- %s", standard.name, load(full.path))))
       printf("loaded %s from %s, length %d", standard.name, full.path,
              length(userIDmap))
      } # either pkg or file protocol

   this <- new ("UserSettingsProvider", sourceURI=sourceURI, protocol=protocol, path=path,
                userIDmap=userIDmap)

   this

} # LocalFileData2DProvider
#----------------------------------------------------------------------------------------------------
setMethod("show", "UserSettingsProvider",

   function(object) {
       msg <- sprintf("UserSettingsProvider")
       cat(msg, "\n", sep="")
       msg <- sprintf("userIDmap length: %d", length(object@userIDmap))
       cat(msg, "\n", sep="")
       }) # show

#---------------------------------------------------------------------------------------------------
setMethod ("userIDs", "UserSettingsProvider",   

   function(self) {
      result <- names(self@userIDmap)
      result
      })
           
#---------------------------------------------------------------------------------------------------
setMethod ("getUserID", "UserSettingsProvider",

   function(self, userID=NA) {

      #browser()
      if(is.na(userID))
         return(NA)
      else
         user <- match(userID, names(self@userIDmap))

      if(length(user) != 1)
          return(NA)
            
      self@userIDmap[[user]]
      })

#---------------------------------------------------------------------------------------------------
setMethod ("addUserID", "UserSettingsProvider",
   function(self, userID=NA, username=NA) {

      if(!is.na(userID) & !(userID %in%  names(self@userIDmap)))
           self@userIDmap[[userID]] <- username
       
#      return(userID)
      self
      })

#---------------------------------------------------------------------------------------------------
setMethod ("NumUsers", "UserSettingsProvider",

    function(self) {
        return(length(self@userIDmap))
    })
#---------------------------------------------------------------------------------------------------
