setClass("UserSelectPatientProvider",
         representation(sourceURI="character",
                        protocol="character",
                        path="character",
                        userList="list")
         )

#setGeneric("show",   signature="self", function (self, ...) standardGeneric ("show"))
setGeneric("userIDsWithSelection",   signature="self", function (self, ...) standardGeneric ("userIDsWithSelection"))
setGeneric("NumUsersWithSelection", signature="self", function (self) standardGeneric("NumUsersWithSelection"))
setGeneric("NumUserSelections", signature="self", function (self, userID=NA) standardGeneric("NumUserSelections"))
setGeneric("NumPatientsInSelection", signature="self", function (self, userID=NA, selectionname=NA) standardGeneric("NumPatientsInSelection"))
setGeneric("ValidSelectionname",    signature="self", function (self, userID=NA, selectionname=NA) standardGeneric ("ValidSelectionname"))
setGeneric("ValidUserID",    signature="self", function (self, userID=NA) standardGeneric ("ValidUserID"))
setGeneric("addUserIDforSelection",    signature="self", function (self, userID=NA) standardGeneric ("addUserIDforSelection"))
setGeneric("getSelectionnames",    signature="self", function (self, userID=NA) standardGeneric ("getSelectionnames"))
setGeneric("getSelection",    signature="self", function (self, userID=NA, selectionnames=NA) standardGeneric ("getSelection"))
setGeneric("addSelection",    signature="self", function (self, userID=NA,  selectionname=NA, patientIDs=NA, tab=NA, settings=NA) standardGeneric ("addSelection"))
#---------------------------------------------------------------------------------------------------
UserSelectPatientProvider = function(sourceURI)
{

   result <- NA
   
   if(sourceURI == ""){
       result <- NewUserSelectPatientProvider()
   } else {       #selection read from manifest file
   
       tokens <- strsplit(sourceURI, ":\\/\\/")[[1]]
       protocol <- tokens[1]
       path <- tokens[2]
   
       if(!protocol %in% c("pkg", "file")){
          warning(sprintf("UserSelectPatientProvider constructor, '%s protocol not yet supported", protocol));
          return(NA)
       }
       if(protocol %in% c("pkg", "file")){
          result <- LocalFileUserSelectPatientProvider(sourceURI)
       }
    }
   
   result

} # ctor: UserSelectPatientProvider
#---------------------------------------------------------------------------------------------------
NewUserSelectPatientProvider <- function()
{
      this <- new ("UserSelectPatientProvider", sourceURI="", protocol="new", path="", userList=list())
      this
}
#---------------------------------------------------------------------------------------------------
LocalFileUserSelectPatientProvider <- function(sourceURI)
{
   tokens <<- strsplit(sourceURI, "://")[[1]]

   if(!length(tokens) == 2){
       printf("Oncoscape LocalFileUserSelectPatientProvider  error.  Manifest line ill-formed: '%s'", path);
       stop()
       }

   protocol <- tokens[1]
   path <- tokens[2]

   if(protocol == "pkg")
      full.path <- system.file(package="Oncoscape", "extdata", path)

   if(protocol == "file")
      full.path <- path

   if(protocol %in% (c("pkg", "file"))){
       standard.name <- "userList"
       if(!file.exists(full.path)){
          printf("Oncoscape  LocalFileUserSelectPatientProvider  error.  Could not read SelectPatientHistory file: '%s'",
                 full.path);
          stop()
          }
       eval(parse(text=sprintf("%s <<- %s", standard.name, load(full.path))))
       printf("loaded %s from %s, length %d", standard.name, full.path,
              length(userList))
      } # either pkg or file protocol

   this <- new ("UserSelectPatientProvider", sourceURI=sourceURI, protocol=protocol, path=path,
                userList=userList)

   this

} # LocalFileData2DProvider
#----------------------------------------------------------------------------------------------------
setMethod("show", "UserSelectPatientProvider",

   function(object) {
       msg <- sprintf("UserSelectPatientProvider")
       cat(msg, "\n", sep="")
       msg <- sprintf("userList length: %d", length(object@userList))
       cat(msg, "\n", sep="")
       }) # show

#---------------------------------------------------------------------------------------------------
setMethod ("userIDsWithSelection", "UserSelectPatientProvider",   

   function(self) {
      result <- names(self@userList)
      result
      })
           
#---------------------------------------------------------------------------------------------------
setMethod ("NumPatientsInSelection", "UserSelectPatientProvider",

   function(self, userID=NA, selectionname=NA) {

      #browser()
      if(is.na(userID))
         return(NA)
      else
         user <- match(userID, names(self@userList))

      if(length(user) != 1)
          return(NA)
      
      if(all(is.na(selectionname)))
          return(NA)

         matches <- match(selectionname, names(self@userList[[user]]))
         nas <- which(is.na(matches))
         if(length(nas) > 0)
            matches <- matches[-nas]
         recognized.columns  <- names(self@userList[[user]])[matches]
      
      if(length(recognized.selections) == 0)
          return(NA)
      
      length(self@userList[[user]][recognized.columns])
      })
#---------------------------------------------------------------------------------------------------
setMethod ("NumUserSelections", "UserSelectPatientProvider",

   function(self, userID=NA) {

      #browser()
      if(is.na(userID))
         return(NA)
      else
         user <- match(userID, names(self@userList))

      if(length(user) != 1)
          return(NA)
            
      length(self@userList[[user]])
      })

#---------------------------------------------------------------------------------------------------
setMethod ("getSelection", "UserSelectPatientProvider",

   function(self, userID=NA, selectionnames=NA) {

      #browser()
      if(is.na(userID))
         return(list())
      else
         user <- match(userID, names(self@userList))

      if(length(user) != 1)
          return(list())
      
      if(all(is.na(selectionnames)))
          return(list())
#         recognized.selections <- names(self@userList[[user]])
      else{
         matches <- match(selectionnames, names(self@userList[[user]]))
         nas <- which(is.na(matches))
         if(length(nas) > 0)
            matches <- matches[-nas]
         recognized.selections  <- names(self@userList[[user]])[matches]
         }
      
      if(length(recognized.selections) == 0)
          return(list())
      
      self@userList[[user]][recognized.selections]
      })
#---------------------------------------------------------------------------------------------------
setMethod ("ValidUserID", "UserSelectPatientProvider",
   function(self, userID=NA) {

      if(is.na(userID))
         return(FALSE)
      
     user <- match(userID, names(self@userList))

     if(is.na(user)){
      	return(FALSE)
     }
      
     if(length(user) != 1)
        return(FALSE)
      
     return(TRUE)
      })

#---------------------------------------------------------------------------------------------------
setMethod ("addUserIDforSelection", "UserSelectPatientProvider",
   function(self, userID=NA) {

      if(is.na(userID))
         return(self)
      
     user <- match(userID, names(self@userList))

     if(is.na(user)){
      	self@userList[[userID]] <- list()
     }
     return(self);
})

#---------------------------------------------------------------------------------------------------
setMethod ("ValidSelectionname", "UserSelectPatientProvider",
   function(self, userID=NA, selectionname=NA) {

      if(is.na(selectionname))
          return(FALSE)
      
      user <- match(userID, names(self@userList))
      !(selectionname  %in% names(self@userList[[user]]))
      })

#---------------------------------------------------------------------------------------------------
setMethod ("addSelection", "UserSelectPatientProvider",
   function(self, userID=NA, selectionname=NA, patientIDs=NA, tab=NA, settings=NA) {

       if(is.na(userID))
         return(self)
      
      user <- match(userID, names(self@userList))

      if(is.na(user)){
      	self@userList[[userID]] <- list()
        user <- match(userID, names(self@userList))
      }
      
      if(length(user) != 1)
          return(self)
      
      if(is.na(selectionname))
          return(self)
            
   		i=0; 
      while(selectionname %in% names(self@userList[[user]])){
		    i=i+1;
		    selectionname = paste(selectionname,i, sep="_")
		}

      selectionVals <- list(selectionname=selectionname, patientIDs=patientIDs, tab=tab, settings=settings)
      selection<-list(selectionVals); names(selection)<-selectionname
       
      self@userList[[user]] <- c(self@userList[[user]], selection)
       cat("Attempting to add -", selectionname, "- to list: ", names(self@userList[[user]]),"\n", sep="")
  
      self
      })

#---------------------------------------------------------------------------------------------------
setMethod ("NumUsersWithSelection", "UserSelectPatientProvider",

    function(self) {
        return(length(self@userList))
    })
#---------------------------------------------------------------------------------------------------
setMethod ("getSelectionnames", "UserSelectPatientProvider",
    function(self, userID=NA) {
    
        return(names(self@userList[[userID]]))
    })
#---------------------------------------------------------------------------------------------------
