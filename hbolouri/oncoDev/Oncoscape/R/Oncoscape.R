setClass("Oncoscape",
         representation(server="environment",
                        htmlFile="character",
                        mode="character",
                        port="integer",
                        openBrowser="logical"),
         prototype(htmlFile="oncoscape.html")
         )

setGeneric ("getMode", signature="self", function (self) standardGeneric ("getMode"))
setGeneric ("getServer", signature="self", function (self) standardGeneric ("getServer"))
setGeneric ("isWebSockets", signature="self", function (self) standardGeneric ("isWebSockets"))
setGeneric ("setup", signature="self", function (self) standardGeneric ("setup"))
setGeneric ("setupWebServer", signature="self", function (self) standardGeneric ("setupWebServer"))
setGeneric ("run", signature="self", function (self) standardGeneric ("run"))
setGeneric ("runWebServer", signature="self", function (self) standardGeneric ("runWebServer"))
setGeneric ("close", signature="self", function (self) standardGeneric ("close"))
#---------------------------------------------------------------------------------------------------
printf <- function(...) print(noquote(sprintf(...)))
dispatchMap <- new.env(parent=emptyenv())
DATA.PROVIDERS <- new.env(parent=emptyenv())
USER.SETTINGS <-  new.env(parent=emptyenv())
#---------------------------------------------------------------------------------------------------
addRMessageHandler <- function(key, function.name)
{
    # printf("adding handler for %s: %s", key, function.name)
    dispatchMap[[key]] <- function.name
    
} # addRMessageHandler
#---------------------------------------------------------------------------------------------------
.oldLoadData <- function()
{
   filename <- system.file(package="Oncoscape", "extdata", "tbl.clinical.RData")
   printf("loading '%s'", load(filename, envir=.GlobalEnv))

   filename <- system.file(package="Oncoscape", "extdata", "tbl.clinical2a.RData")
   printf("loading '%s'", load(filename, envir=.GlobalEnv))
   printf("    %d rows, %d columns", nrow(tbl.clinical2), ncol(tbl.clinical2))

   filename <- system.file(package="Oncoscape", "extdata", "tbl.idLookupWithDzSubType.RData")
   printf("loading '%s'", load(filename, envir=.GlobalEnv))

   filename <- system.file(package="Oncoscape", "extdata", "298SamplesNanoStringExp.RData")
   printf("loading '%s' as 'tbl.nano'", load(filename))
   tbl.nano <<- nano

   #filename <- system.file(package="Oncoscape", "extdata", "BTC_clinicaldata_6-18-14.RData")
   #printf("loading '%s' as 'PatientData_json'", filename, load(filename, envir=.GlobalEnv))
   #printf("    %d length", length(PatientData_json))

   tbl.clinical <<- cleanupClinicalTable(tbl.clinical, tbl.idLookup)

   mtx.nano <<-  Oncoscape:::cleanupNanoStringMatrix(tbl.nano, tbl.idLookup)

} # .oldLoadData
#---------------------------------------------------------------------------------------------------
.setupDataProviders <- function(manifest)
{
   if(!file.exists(manifest)){
       printf("Oncoscape error.  Manifest file '%s' cannot be read.  Exiting.", manifest)
       stop()
       }

   lines <- scan(manifest, sep="\n", what=character(0))
   deleters <- grep("^ *#", lines)
   if(length(deleters) > 0)
       lines <- lines[-deleters]
       
   print(lines)

   #-------------------------- patientHistoryEvents
   signature <- "^ *patientHistoryEvents: "
   signatureLine <- grep(signature, lines, ignore.case=TRUE)
   if(length(signatureLine) > 1)
       warning(sprintf("Oncoscape::.setupDataProviders, multiple %s entries, using only the first", signature))
   
   printf("Oncoscape .setupDataProviders looking for %s:  %d", signature, length(signatureLine))

   if(length(signatureLine > 0)){
       text <- lines[signatureLine[1]]
       path <- sub(signature, "", text)
       tokens <- strsplit(path, "://")[[1]]
       if(!length(tokens) == 2){
           printf("Oncoscape error.  Manifest line for patientHistoryill-formed: '%s'", text);
           stop()
           }
       printf("patientHistory: %s", path)
       DATA.PROVIDERS$patientHistoryEvents <- PatientHistoryProvider(path);
       } # found patientHistoryEvents line

   #-------------------------- patientHistoryTable
   signature <- "^ *patientHistoryTable: "
   signatureLine <- grep(signature, lines, ignore.case=TRUE)
   if(length(signatureLine) > 1)
       warning(sprintf("Oncoscape::.setupDataProviders, multiple %s entries, using only the first", signature))
   
   printf("Oncoscape .setupDataProviders looking for %s:  %d", signature, length(signatureLine))

   if(length(signatureLine > 0)){
       text <- lines[signatureLine[1]]
       path <- sub(signature, "", text)
       tokens <- strsplit(path, "://")[[1]]
       if(!length(tokens) == 2){
           printf("Oncoscape error.  Manifest line for patientHistoryTable ill-formed: '%s'", text);
           stop()
           }
       printf("patientHistory: %s", path)
       DATA.PROVIDERS$patientHistoryTable <- PatientHistoryProvider(path);
       } # found patientHistoryEvents line

   #-------------------------- mRNA
   signature <- "^ *mRNA: *"
   signatureLine <- grep(signature, lines, ignore.case=TRUE)
   if(length(signatureLine) > 1)
       warning(sprintf("Oncoscape::.setupDataProviders, multiple %s entries, using only the first", signature))

   printf("Oncoscape .setupDataProviders looking for %s:  %d", signature, length(signatureLine))

   if(length(signatureLine > 0)){
       text <- lines[signatureLine[1]]
       path <- sub(signature, "", text)
       tokens <<- strsplit(path, "://")[[1]]
       if(!length(tokens) == 2){
           printf("Oncoscape error.  Manifest line for mRNA ill-formed: '%s'", text);
           stop()
           }
       DATA.PROVIDERS$mRNA <- Data2DProvider(path);
       } # found mRNA line

   #-------------------------- patientClassification
   signature <- "^ *patientClassification: *"
   signatureLine <- grep(signature, lines, ignore.case=TRUE)
   if(length(signatureLine) > 1)
       warning(sprintf("Oncoscape::.setupDataProviders, multiple %s entries, using only the first", signature))

   printf("Oncoscape .setupDataProviders looking for %s:  %d", signature, length(signatureLine))

   if(length(signatureLine > 0)){
       text <- lines[signatureLine[1]]
       path <- sub(signature, "", text)
       tokens <<- strsplit(path, "://")[[1]]
       if(!length(tokens) == 2){
           printf("Oncoscape error.  Manifest line for patientClassification ill-formed: '%s'", text);
           stop()
           }
       DATA.PROVIDERS$patientClassification <- Data2DProvider(path);
       } # found patientClassificationline


} # .setupDataProviders
#---------------------------------------------------------------------------------------------------
.setupUserSettings <- function(path = "")
{ 
       USER.SETTINGS$UserIDmap <- UserSettingsProvider(path);
       USER.SETTINGS$PatientSelectionHistory <- UserSelectPatientProvider(path);
       
} # .setupUserSettings
#---------------------------------------------------------------------------------------------------
# constructor
Oncoscape = function(htmlFile, mode="websockets", port=7681, openBrowser=TRUE,  manifest=NA) {

   stopifnot(mode %in% c("websockets", "LabKey"))

   if(is.na(htmlFile)) { # used rarely, in testing
       htmlFile.fullPath = system.file(package="Oncoscape", "scripts", "sample.html");
       }
   else {
       htmlFile.fullPath <- system.file(package="Oncoscape", "scripts", htmlFile);
       if(!file.exists(htmlFile.fullPath)){
          printf("--- error from Oncoscape constructor");
          printf("htmlFile '%s' cannot be read, fullPath: '%s'", htmlFile, htmlFile.fullPath);
          stop();
          }
      } # else
   dummy.server <- new.env()
   oncoscape <- new("Oncoscape", server=dummy.server,
                    htmlFile=htmlFile.fullPath,
                    mode=mode,
                    port=as.integer(port),
                    openBrowser=openBrowser)
   if(is.na(manifest))
      .oldLoadData()
   else 
      .setupDataProviders(manifest)
   
   .setupUserSettings()
   
   oncoscape
   } # ctor

#---------------------------------------------------------------------------------------------------
setMethod("getMode", signature="Oncoscape",
  function (self) {
      return (self@mode)
      })
#---------------------------------------------------------------------------------------------------
setMethod ("getServer", signature="Oncoscape",
  function (self) {
      return (self@server)
      })
#---------------------------------------------------------------------------------------------------
setMethod ("isWebSockets", signature="Oncoscape",
    function (self) {
        return (self@mode == "websockets")
    })
#---------------------------------------------------------------------------------------------------
setValidity("Oncoscape", function(object) {
    msg = NULL
    if (is.null(msg)) TRUE else msg
    })
#---------------------------------------------------------------------------------------------------
setMethod("show", "Oncoscape",

    function(object) {
        msg = sprintf("Oncoscape self in '%s' mode", object@mode)
        cat (msg, "\n", sep="")
        }) # show

#---------------------------------------------------------------------------------------------------
setMethod("setupWebServer", "Oncoscape",

   function(self) {
      
      established.callback = function(WS) {
         printf("Oncoscape websocket client connection established: %s", WS$socket)
         }
      receive.callback = function(DATA,WS,...) {
         msg <- receiveMessage(DATA)
         if (!is.null(msg))
            dispatchMessage(WS, msg)
         }
      closed.callback <- function(WS){
         printf("websocket connection closed")
         }

      tryCatch({
          server <- NULL
          server <- create_server(webpage=static_file_service(self@htmlFile), port=self@port)},
             # TODO: automatic recovery from already-claimed port, with a limit to total tries
          error=function(e) {
             error.string <- as.character(e)
             if(length(grep("Unable to bind socket", error.string))){
                compact.error.string <- strsplit(error.string, "[:;]")[[1]][2]
                message(paste("websocket creation failure: ", compact.error.string, sep="\n"))
                } # if unable to bind
             }, # error
         warning=function(warning){
            print(warning)
            },
         finally = {
             }
         ) # tryCatch
         
      if(!is.null(server)){
         set_callback("established",  established.callback, server)
         set_callback("receive",      receive.callback,     server)
         set_callback("closed",       closed.callback,      server)
         self@server <- server
         return(self)
         }

      # on.exit(close.socket())  TODO

      return(NULL)
      
      }) # setup

#---------------------------------------------------------------------------------------------------
setMethod("setup", "Oncoscape",

   function(self) {
    if (isWebSockets(self))
        return(setupWebServer(self))

    # no socket setup required for LabKey since
    return(self)
    }) # setup

#---------------------------------------------------------------------------------------------------
setMethod("runWebServer", "Oncoscape",

   function(self) {
      if(is.null(getServer(self)))
          self <- setup(self)

      if (self@openBrowser)
        browseURL(sprintf("http://localhost:%s", self@port))

      while (TRUE) service(self@server)
      })

#---------------------------------------------------------------------------------------------------
setMethod("run", "Oncoscape",

   function(self) {
        if (isWebSockets(self)) {
            runWebServer(self)
        }
        else {
            return(readLines(con=self@htmlFile))
        }
      })

#---------------------------------------------------------------------------------------------------
setMethod("close", "Oncoscape",

  function(self) {
      websocket_close(self@server)
      })

#---------------------------------------------------------------------------------------------------
# Abstraction over rserve and websockets.  If no WS is passed then assume we are using
# Rserve and return directly
sendOutput <- function(DATA, WS)
{
    if (is.null(WS))
        return (DATA)
    else
        websocket_write(DATA=DATA, WS=WS)

} #sendOutput
#---------------------------------------------------------------------------------------------------
dispatchMessage <- function(WS, msg)
{
   printf("==== dispatchMessage: %s", msg$cmd)

   if(!msg$cmd %in% ls(dispatchMap)){
       printf("dispatchMessage error!  the incoming cmd '%s' is not recognized", msg$cmd)
       return()
       }

   function.name <- dispatchMap[[msg$cmd]]
   success <- TRUE   

   if(is.null(function.name)){
       printf("Oncoscape dispatchMessage error!  cmd ('%s') not recognized", msg.cmd)
       success <- FALSE
       return()
       }
   
   tryCatch(func <- get(function.name), error=function(m) func <<- NULL)

   if(is.null(func)){
       printf("Oncoscape dispatchMessage error!  cmd ('%s') recognized but no corresponding function",
              msg$cmd)
       success <- FALSE
       }

   if(success)
       do.call(func, list(WS, msg))


} # dispatchMessage
#---------------------------------------------------------------------------------------------------
receiveMessage <- function(DATA, isRaw=TRUE)
{
    if (isRaw) {
        charData <- tryCatch(rawToChar(DATA),error=function(e) "")
        }
    else {
        charData <- DATA
        }

    msg <- as.list(fromJSON(charData))
    print("==== oncoscape receiveMessage")
    #print(msg)
    required.fields <- c("cmd", "status", "payload")
    #printf("--- browser in receiveMessage: %s", paste(names(msg), collapse=","))
    #browser()
    #x <- 99
    all.required.fields.present <- length(intersect(required.fields, names(msg))) == length(required.fields)
    printf("receivedMessage, all.required.fields.present: %s, '%s'", all.required.fields.present,
           msg$cmd)
    if(!all.required.fields.present){
        message(" -- receiveMessage ERROR! -- socket request does not have required fields: cmd, status, payload")
        print(sort(names(msg)))
        print(msg$cmd)
        return(NULL)
        }

    if(msg$cmd =="keepAlive")
        return(NULL)
    
    complete.fields <- c(required.fields, "callback")
    missing.fields <- setdiff(required.fields, names(msg))
    printf("missing.fields? %s", paste(missing.fields, collapse=", "))
    
    if(length(missing.fields) > 0){
        message(sprintf(" -- WARNING! -- socket request does not have all desired fields (%s)", paste(complete.fields, collapse=", ")))
        print(sort(names(msg)))
        print(msg$cmd)
        }
        
    printf("incoming message: %s, %s", msg$cmd, msg$status); # , msg$payload)
    return(msg)
    
} #receiveMessage
#---------------------------------------------------------------------------------------------------
# Used by LabKey over Rserve
invokeCommand <- function(DATA)
{
        msg <- receiveMessage(DATA, isRaw=FALSE)
        if (!is.null(msg))
            dispatchMessage(WS=NULL, msg=msg)
}#invokeCommand
#---------------------------------------------------------------------------------------------------
# sendClinicalData <- function(WS, msg)
# {
#    rows <- msg$payload
#    if(rows == -1)
#       rows <- nrow(tbl.clinical)
# 
#    tbl.result <- as.matrix(tbl.clinical[1:rows,])
#    colnames(tbl.result) <- NULL
# 
#    cmd = "clinicalData"
#    return.msg <- list(cmd=cmd, payload=tbl.result)
#    return.msg <- gsub("\n", "", toJSON(return.msg))
#    printf("sending 'clinicalData' to js: %d rows", nrow(tbl.result))
#    
#    websocket_write(DATA=return.msg, WS=WS)
# 
# } # sendClinicalData
#----------------------------------------------------------------------------------------------------
# the standard "toJSON" ignores rownames, so here we convert rownames into an extra column -- a trick
# which the receiver must understand.
matrixToJSON <- function(mtx, category=NA)
{
    if(!is.null(rownames(mtx)))
        mtx <- cbind(as.data.frame(mtx), rowname=rownames(mtx))

    if(!all(is.na(category))){
        if(length(category) == 1)
            category <- rep(category, nrow(mtx))
        mtx <- cbind(as.data.frame(mtx), category=category)
        }
    
    s <- "["
    max <- nrow(mtx)
    for(r in 1:max){
       new.row <- toJSON(mtx[r,])
       separator <- ","
       if(r == 1)
           separator <- ""
       s <- paste(s, new.row, sep=separator)
       } # for r
       
    s <- paste(s, "]", sep="")
    gsub("\n", "", s)

    s

} # matrixToJSON
#----------------------------------------------------------------------------------------------------
sendPatientIDsToModule <- function(WS, msg)
{
   target <- msg$payload$targetModule
   ids <- msg$payload$ids
   printf("Oncoscape::sendPatientIDsToModule received %d patientIDs for %s",
          length(ids), target);
   #print(msg)

   return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload=ids))
   sendOutput(DATA=return.msg, WS=WS)

} # sendPatientIDsToModule
#----------------------------------------------------------------------------------------------------
sendIDsToModule <- function(WS, msg)
{
   target <- msg$payload$targetModule
   ids <- msg$payload$ids
   printf("Oncoscape::sendIDsToModule received %d IDs for %s", length(ids), target);
   #print(msg)

   payload <- list(count=length(ids), ids=ids)
   return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload=payload))
   sendOutput(DATA=return.msg, WS=WS)

} # sendIDsToModule
#----------------------------------------------------------------------------------------------------
getModuleModificationDate <- function(WS, msg)
{
  folder <- msg$payload
  ModuleDate <- as.character(as.Date(file.info(paste("..",folder, sep="/"))$mtime))

   return.msg <- toJSON(list(cmd=msg$callback, callback="", status="success", payload=ModuleDate))
   sendOutput(DATA=return.msg, WS=WS)

  
  
}
#----------------------------------------------------------------------------------------------------
startWebApp <- function(file="tabsApp/index.html", port=7777L, mode="websockets", openBrowser=TRUE,
                        manifest=system.file(package="Oncoscape", "scripts", "tabsApp", "manifest.txt"))
{
    onco <- Oncoscape(file, port=port, mode=mode, openBrowser=openBrowser, manifest)
    onco <- setup(onco)

    if(is.null(onco)) {
        msg <- sprintf("\n start failed, port %d already claimed?\n", port);
        message(msg);
        stop();
        }
    
    run(onco)

} # startWebApp
#----------------------------------------------------------------------------------------------------
dataProviders <- function()
{
    DATA.PROVIDERS

} # dataProviders
#----------------------------------------------------------------------------------------------------
addRMessageHandler("sendPatientIDsToModule", "sendPatientIDsToModule");
addRMessageHandler("sendIDsToModule", "sendIDsToModule");
addRMessageHandler("getModuleModificationDate", "getModuleModificationDate");