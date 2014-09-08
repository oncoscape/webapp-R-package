#                   incoming message          function to call                 return.cmd
#                   -------------------       ----------------                -------------
addRMessageHandler("predictDzSubtypes",       "predictDzSubtypes")            # samplesVsSubtypePvals
addRMessageHandler("calculateSurvivalCurves", "calculateSurvivalCurves")      # displaySurvivalCurves
addRMessageHandler("drawSurvivalBoxPlot",     "drawSurvivalBoxPlot")          # displaySurvivalBoxPlot
#----------------------------------------------------------------------------------------------------
predictDzSubtypes <- function(WS, msg)
{
   sampleNames <- msg$payload;
   printf("predictSubtypes has %d sampleNames", length(sampleNames))
   #print(sampleNames)
   #browser()
   x <- 99

   mtx <- calculateEnrichment(tbl.idLookup, sampleNames)
   mtx.char <- matrix(data=unlist(lapply(as.numeric(mtx),
                          function(el) sprintf("%5.2f", el))), nrow=4)
   colnames(mtx.char) <- colnames(mtx)
   rownames(mtx.char) <- colnames(mtx)
   print(mtx.char)
   # browser()
   html.table <- matrixToHTML(mtx.char, title="Disease Subtype pvalues")

   return.cmd = "samplesVsSubtypePvals"

   return.msg <- list(cmd=return.cmd, payload=html.table)
   return.msg <- gsub("\n", "", toJSON(return.msg))
   
   printf("survival::predictDzSubtypes sending response over socket")
   sendOutput(DATA=return.msg, WS=WS)

} # predictDzSubtypes
#-------------------------------------------------------------------------------
calculateEnrichment <- function(tbl.idLookup, observations)
{
   stopifnot(colnames(tbl.idLookup) == c("specimen", "btc", "expr.id", "dzSubType"))
   stopifnot(length(match(observations, tbl.idLookup$speciment)) == length(observations))

   all.types <- tbl.idLookup$dzSubType
   deleters <- which(all.types == "Failed")
   if (length(deleters) > 0)
       all.types <- all.types[-deleters]

   sample.types <- subset(tbl.idLookup, specimen %in% observations)$dzSubType
   deleters <- which(sample.types == "Failed")
   if (length(deleters) > 0)
       sample.types <- sample.types[-deleters]

   freqs.all <- as.list(table(all.types))
   freqs.sample <- as.list(table(sample.types))
   missing.categories <- setdiff(names(freqs.all), names(freqs.sample))
   for(i in seq_len(length(missing.categories)))
       freqs.sample[missing.categories[i]] <- 0
   # browser()
   print(sort(names(freqs.all)))
   print(sort(names(freqs.sample)))
   
   checkEquals(sort(names(freqs.all)), sort(names(freqs.sample)))
   
   mesenchymal.vec <- c(rep(1, freqs.sample$Mesenchymal),
                        rep(0, freqs.all$Mesenchymal - freqs.sample$Mesenchymal))
   classical.vec <- c(rep(1, freqs.sample$Classical),
                    rep(0, freqs.all$Classical - freqs.sample$Classical))
   neural.vec <- c(rep(1, freqs.sample$Neural),
                   rep(0, freqs.all$Neural - freqs.sample$Neural))
   proneural.vec <- c(rep(1, freqs.sample$Proneural),
                      rep(0, freqs.all$Proneural - freqs.sample$Proneural))

   mVsC <- t.test(mesenchymal.vec, classical.vec)$p.value
   mVsN <- t.test(mesenchymal.vec, neural.vec)$p.value
   mVsP <- t.test(mesenchymal.vec, proneural.vec)$p.value
   nVsC <- t.test(neural.vec, classical.vec)$p.value
   pVsC <- t.test(proneural.vec, classical.vec)$p.value
   pVsN <- t.test(proneural.vec, neural.vec)$p.value

   #browser()
   
          #  M      C     N     P
   data <- c(1.0,  mVsC, mVsN, mVsP,    # M
             mVsC, 1.0,  nVsC, pVsC,    # C
             mVsN, mVsC,  1.0, pVsN,    # N
             mVsP, pVsC,  pVsN, 1.0)    # P
   dim.names <- c("Mesenchymal", "Classical", "Neural", "Proneural")
   matrix(data, nrow=4, byrow=TRUE,
          dimnames=list(dim.names, dim.names))

} # calculateEnrichment
#----------------------------------------------------------------------------------------------------
calculateSurvivalCurves <- function(WS, msg)
{
   sampleNames <- msg$payload
   printf("calculateSurvivalCurves has %d sampleNames", length(sampleNames))
   #print(sampleNames)

   temp.file <- tempfile(fileext="jpg")

    signature <- "patientHistoryTable";
   
   patientHistoryProvider <- DATA.PROVIDERS$patientHistoryTable
   tbl <- getTable(patientHistoryProvider)

   if(!signature %in% ls(DATA.PROVIDERS)){
       error.message <- sprintf("Oncoscape DataProviderBridge error:  no %s provider defined", signature)
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
       }

      # payload must be a list
   payload <- msg$payload;
   printf("--- payload");
   print(payload)

   constraint.fields <- sort(names(payload))
   legal.constraint.fields <- constraint.fields == c("patients")
   if (!"patients" %in% names(payload)){
      status <- "failure"
      error.message <- sprintf("payload field doesn't include 'patients': %s",
                               paste(constraint.fields, collapse=", "))
      return.msg <- list(cmd=msg$callback, callback="", status="error", payload=error.message)
      sendOutput(DATA=toJSON(return.msg), WS=WS)
      return()
      }
   
   printf("extracting payload field values");
   patients <- payload$patients
   print(patients)
   if(all(nchar(patients) == 0))
      patients <- NA
       
   attribute <- NA
   if("colname" %in% names(payload)){
     attribute <- payload$colname

     if(!attribute %in% colnames(tbl)){
       error.message <- sprintf("Oncoscape DataProviderBridge patientHistoryDataVector error:  '%s' is not a column title", attribute);
       return.msg <- list(cmd=msg$callback, callback="", payload=error.message, status="error")
       sendOutput(DATA=toJSON(return.msg), WS=WS)
       return()
      } # 
   }
   fit <- survivalCurvebyAttribute(tbl = tbl, patients,attribute=attribute, filename=temp.file)
   p = base64encode(readBin(temp.file,what="raw",n=1e6))
   p = paste("data:image/jpg;base64,\n",p,sep="")

   return.cmd <- msg$callback

   return.msg <- toJSON(list(cmd=return.cmd, status="success", payload=p))
   sendOutput(DATA=return.msg, WS=WS)
   file.remove(temp.file)

} # calculateSurvivalCurves
#-------------------------------------------------------------------------------
survivalCurvebyAttribute <- function(tbl, samples=NA, attribute=NA, filename=NA)
{
    if(all(is.na(tbl))) return();
    
    if(!is.na(attribute)){ tbl <- tbl[which(!is.na(tbl[,attribute])),] 
    } else { attribute <- "FirstProgression"} 

   if(all(is.na(samples))) {

      mean.time <- mean(tbl[,attribute])  # about 20 months
      grp1.indx <- which(tbl[,attribute] < 0.5 * mean.time)
      grp2.indx<-which(tbl[,attribute] > 0.5 * mean.time)
      }
   else {
       grp1.indx <- match(samples, tbl$ID)
       grp1.indx <- grp1.indx[!is.na(grp1.indx)]
       grp2.indx <- match(setdiff(tbl$ID, samples), tbl$ID)
       grp2.indx <- grp2.indx[!is.na(grp2.indx)]
       }
  
   status <- c(tbl$Death[grp1.indx], tbl$Death[grp2.indx])
   
   Alive <- is.na(status)
   status[Alive] <- 0
   status[!Alive] <- 1
   status <- as.numeric(status)

   df <- data.frame(group=c(rep(1,length(grp1.indx)),rep(2,length(grp2.indx))),
                    status=status,
                    days=c(tbl$survival[grp1.indx],tbl$survival[grp2.indx]))

   fit <- survfit(Surv(days, status)~group, data=df)

   if(!is.na(filename))
      jpeg(file=filename, width=600,height=600,quality=100)

       
   plot(fit,col=c(4,2),conf.int=FALSE,lty=c(1,3),
	 xlab="Days",ylab="Fraction alive", 
	 main="Kaplan-Meier Survival") 

   legend("topright", legend=c("Selected Tissues", "Remaining"), lty=c(3,1), col=c(4,2)) 

   if(!is.na(filename))
       dev.off()
   
   invisible(fit)

} # survivalCurve

#-------------------------------------------------------------------------------
survivalCurve <- function(samples=NA, attribute=NA, filename=NA)
{
      # add error jpg, to be returned if inputs are unusable
   filter <- which(!is.na(tbl.clinical2$FirstProgression))   # 186

   if(all(is.na(samples))) {
      mean.time <- mean(tbl.clinical2$FirstProgression[filter])  # about 20 months
      grp1.indx <- which(tbl.clinical2$FirstProgression[filter] < 0.5 * mean.time)
      grp2.indx<-which(tbl.clinical2$FirstProgression[filter] > 0.5 * mean.time)
      }
   else {
       lookup.indices <- match(samples, tbl.idLookup$specimen)
       lookup.indices <- lookup.indices[!is.na(lookup.indices)]
          # need graceful failure here if webpage provides unmappapble sample ids
       stopifnot(length(lookup.indices) > 0)
       samples.as.btc <- tbl.idLookup$btc[lookup.indices]
       grp1.indx <- match(samples.as.btc, tbl.clinical2$Ref[filter])
       grp1.indx <- grp1.indx[!is.na(grp1.indx)]
       grp2.indx <- setdiff(filter, grp1.indx)
       grp2.indx <- grp2.indx[!is.na(grp2.indx)]
       }

   status <- c(tbl.clinical2$Vital[grp1.indx], tbl.clinical2$Vital[grp2.indx])
   status <- gsub("Dead", 0, status)
   status <- gsub("Alive", 1, status)
   status <- as.numeric(status)

   df <- data.frame(group=c(rep(1,length(grp1.indx)),rep(2,length(grp2.indx))),
                    status=status,
                    days=c(tbl.clinical2$overallSurvival[grp1.indx],tbl.clinical2$overallSurvival[grp2.indx]))

   fit <- survfit(Surv(days, status)~group, data=df)

   if(!is.na(filename))
      jpeg(file=filename, width=600,height=600,quality=100)

       
   plot(fit,col=c(4,2),conf.int=FALSE,lty=c(1,3),
	 xlab="Days",ylab="Fraction alive", 
	 main="Kaplan-Meier Survival") 

   legend("topright", legend=c("Selected Tissues", "All"), lty=c(3,1), col=c(4,2)) 

   if(!is.na(filename))
       dev.off()
   
   invisible(fit)

} # survivalCurve
#----------------------------------------------------------------------------------------------------
drawSurvivalBoxPlot <- function(WS, msg)
{
   sampleNames <- msg$payload
   printf("drawSurvivalBoxPlot has %d sampleNames", length(sampleNames))
   # print(sampleNames)

   temp.file <- tempfile(fileext="jpg")
   
   fit <- survivalBoxPlot(sampleNames, file=temp.file)
   p = base64encode(readBin(temp.file,what="raw",n=1e6))
   p = paste("data:image/jpg;base64,\n",p,sep="")

   return.cmd <- "displaySurvivalBoxPlot"
   
   return.msg <- toJSON(list(cmd=return.cmd, payload=p))
   sendOutput(DATA=return.msg, WS=WS)
   file.remove(temp.file)

} # drawSurvivalBoxPlot
#-------------------------------------------------------------------------------
survivalBoxPlot <- function(samples=NA, filename=NA)
{
      # add error jpg, to be returned if inputs are unusable
   filter <- which(!is.na(tbl.clinical2$monthsTo1stProgression))   # 186
   tbl <- subset(tbl.clinical2, !is.na(monthsTo1stProgression))

   if(all(is.na(samples))) {
      mean.time <- mean(tbl$monthsTo1stProgression)  # about 20 months
      grp1.indx <- which(tbl$monthsTo1stProgression < 0.5 * mean.time)
      grp2.indx <- which(tbl$monthsTo1stProgression >= 0.5 * mean.time)
      }
   else {
       lookup.indices <- match(samples, tbl.idLookup$specimen)
       lookup.indices <- lookup.indices[!is.na(lookup.indices)]
          # need graceful failure here if webpage provides unmappapble sample ids
       stopifnot(length(lookup.indices) > 0)
       samples.as.btc <- tbl.idLookup$btc[lookup.indices]
       grp1.indx <- match(samples.as.btc, tbl$Ref)
       grp1.indx <- grp1.indx[!is.na(grp1.indx)]
       all.rows <- 1:nrow(tbl)
       grp2.indx <- setdiff(all.rows, grp1.indx)
       grp2.indx <- grp2.indx[!is.na(grp2.indx)]
       }

   population.1 <- as.numeric(tbl$monthsTo1stProgression[grp1.indx])
   population.2 <- as.numeric(tbl$monthsTo1stProgression[grp2.indx])

   conds <- c(rep("Selected Tissues", length(population.1)),
              rep("Remainder", length(population.2)))
   times <- c(population.1, population.2)
   df <- data.frame(population=conds, time=times)

      #P<-ggplot(d,aes(x = group, y = x)) + 
      #      geom_boxplot(fill=makeTransparent("skyblue"),notch=TRUE) + 
      #      geom_jitter(color=makeTransparent("blue"),
      #		position=position_jitter(width=0.25)) +
      #      ylab(Y.lab) +
      #      xlab("") # + ggtitle(myHeader) # optional figure caption
    
   if(!is.na(filename))
      jpeg(file=filename, width=600,height=600,quality=100)

   plot <- ggplot(df, aes(x=population, y=time)) + 
                  geom_boxplot(fill=makeTransparent("skyblue"), notch=TRUE) +
                  geom_jitter(color=makeTransparent("blue"),
                              position=position_jitter(width=0.25)) +
                  ylab("Months to 1st progression") +
                  geom_point(color=makeTransparent("tomato",alpha=75))
   
   print(plot)
   
   if(!is.na(filename))
       dev.off()
   

} # survivalBoxPlot
#----------------------------------------------------------------------------------------------------
makeTransparent<-function(someColor,alpha=110)
{
   newColor<-col2rgb(someColor)
   apply(newColor,2,function(currCols){rgb(red=currCols[1],green=currCols[2],
         blue=currCols[3],alpha=alpha, maxColorValue=255)})
}
#----------------------------------------------------------------------------------------------------
# number/color map idea:
#  < 0.01  red
#  < 0.05  less red
#  all else white
matrixToHTML <- function(mtx, title)
{
   column.names <- colnames(mtx)
   row.names <- rownames(mtx)
   # st <- sprintf("<h4> %s </h4>", title)
   s0 <- "<table border=0>"
   # s1 <- sprintf("<caption>%s<br><br></caption>", title)
   s2 <- "<thead>"
   s3 <- "<tr>"
   s3 <- paste(s3, "<th> &nbsp; </th>") # empty top left corner
   for(col in 1:ncol(mtx))
      s3 <- paste(s3, sprintf("<th>%s</th>", column.names[col]))
   s3 <- paste(s3, "</tr></thead>");
   s4 <- "<tbody>"

   s5 <- ""
   for(row in 1:nrow(mtx)){
     s5 <- paste(s5,"<tr>");
     s5 <- paste(s5, sprintf("<th>%s</th>", row.names[row]))
     for(col in 1:ncol(mtx)){
        value <- as.numeric(mtx[row, col])
        bgcolor <- "#FFFFFF"
        if(!is.nan(value)){
           if(value <= 0.05)
               bgcolor <- "#FFE6E6"
           if(value <= 0.01)
               bgcolor <- "#FFB2B2"
           } # !is.nan
        s5 <- paste(s5, sprintf("<td bgcolor='%s'>%s</td>", bgcolor, mtx[row, col]))
        }
     s5 <- paste(s5, "</tr>");
     } # for row

   s6 <- "</tbody></table>"
   returnText <- paste(s0, s2,s3,s4,s5,s6, sep="\n")
   returnText

} # matrixToHTML
#----------------------------------------------------------------------------------------------------
