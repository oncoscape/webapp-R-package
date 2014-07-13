# test_Oncoscape.R
#---------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#---------------------------------------------------------------------------------------------------
printf <- function(...) noquote(print(sprintf(...)))
#---------------------------------------------------------------------------------------------------
runTests <- function()
{
   test.webSocketConstructor()
   #test_.setupDataProviders()
   
} # runTests
#---------------------------------------------------------------------------------------------------
test.webSocketConstructor <- function ()
{
    print("--- test.webSocketConstructor")

      # choose a port number we hope is not being used on
      # this machine.  then:
      #   1) create (but don't run) an Oncoscape test instance
      #   2) ensure that another instance cannot be created on the same port
      #   3) close the first instance
      #   4) make sure a new one CAN be created
      #   5) close the new one too, to leave a clean slate
    
    port.number <- 7681L
    
    onco <- Oncoscape(htmlFile=NA, mode="websockets", port=port.number)
    onco <- setup(onco)
    checkTrue(!is.null(onco))

    onco2 <- Oncoscape(htmlFile=NA, mode="websockets", port=port.number)
    suppressWarnings(onco2 <- setup(onco2));
    checkTrue(is.null(onco2))
    close(onco)
    onco <- Oncoscape(htmlFile=NA, mode="websockets", port=port.number)
    checkTrue(!is.null(onco))
    close(onco)

    return(TRUE)


} # test.webSocketConstructor
#---------------------------------------------------------------------------------------------------
test.addCallback <- function()
{
    print("--- test.addCallback");
    port.number <- 7589L
    onco <- Oncoscape(htmlFile=NA, mode="websockets", port=port.number)
    browser();
    x <- 99;
    
} # test.dispatcher
#---------------------------------------------------------------------------------------------------
test.runServer <- function ()
{
    print("--- test.runServer")
    onco <- Oncoscape(htmlFile=NA, mode="websockets", port=port.number)

    os <- Oncoscape(mode="websockets", "test.html")
    run(os)
    
    return (TRUE)

} # test.webSocketConstructor
#---------------------------------------------------------------------------------------------------
test.survivalBoxPlot <- function()
{
    print("--- test.survivalCurve")

   Oncoscape:::survivalBoxPlot(samples=NA)  # use the simulated samples

       # 9 of these 12 cyjs-style specimen IDs are (as btc ids in $Ref) in tbl.cde
    
    samples.1 <- c("0493.T.1",        "0513.T.1",       "0525.T.2",
                   "0531.T.1",        "0547.C.1",       "0547.T.1",
                   "0576.C.1",        "0576.T.1",       "0585.T.1",
                   "0598.T.1",        "0600.C.1",       "0600.T.1")

    Oncoscape:::survivalBoxPlot(samples.1)
    temp.file <- tempfile(fileext=".jpg")
    survivalBoxPlot(samples.1, file=temp.file)
    checkTrue(file.exists(temp.file))
    printf("temp.file: %s", temp.file)

} # test.survivalBoxPlot
#----------------------------------------------------------------------------------------------------
test_.setupDataProviders <- function()
{
   print("--- test_.setupDataProviders")

      # if the sample file is in the current directory, then we are in development mode: use it
      # if not, we are in automated testing mode, so use the one built in to the package
   
   filename <- "manifest-sample.txt"
   if(!file.exists(filename))
       filename <- system.file(package="Oncoscape", "unitTests", filename)

   printf("  using %s for .setupDataProviders test", filename)
   checkTrue(file.exists(filename))
   Oncoscape:::.setupDataProviders(filename)

   dp <- dataProviders()
   provider.types <- ls(dp)

   checkTrue(all(c("mRNA", "patientClassification", "patientHistory") %in% provider.types))

   checkTrue(is(dp$mRNA, "LocalFileData2DProvider"))
   checkTrue(is(dp$patientClassification, "LocalFileData2DProvider"))
   #checkTrue(is(dp$patientHistory, "LocalFilePreparedTablePatientHistoryProvider"))
   checkTrue(is(dp$patientHistory, "LocalFileCaisisEventsPatientHistoryProvider"))

} # test_.setupDataProviders
#----------------------------------------------------------------------------------------------------
