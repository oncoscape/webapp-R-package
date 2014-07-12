DATA_DIR <- "../../../extdata"

nanostring.data.file <- file.path(DATA_DIR, "NormalizedData_LGM_BTC_Samples_Filtered_4-9-14.txt")
patient.file    <- file.path(DATA_DIR, "BTC_PatientData_All_4-4-14.txt")
nanostring.probe.file <- file.path(DATA_DIR, "NanoString_probeRegistry.txt")
# enable identifier translation: tbl.idLookup
#  colnames(tbl.idLookup) #  "specimen"  "btc"       "expr.id"   "dzSubType"
xref.file <- file.path(DATA_DIR, "tbl.idLookupWithDzSubType.RData")
load(xref.file)

nano<-read.delim(nanostring.data.file, sep="\t",header=TRUE,as.is=TRUE)
probeList<-read.delim(nanostring.probe.file,sep="\t", header=TRUE,as.is=TRUE)

indx1<-which(probeList$Classifier=="TRUE")
indx2<-match(probeList$ProbeName[indx1],colnames(nano))
indx2<-indx2[!is.na(indx2)] 			# "KIAA0746" removed

indx3<-which(!is.na(nano$BTC_ID))
indx4<-indx3[!duplicated(nano$BTC_ID[indx3])]

x<-data.matrix(nano[indx4,indx2]) 		# 375 samples, 70 genes
rownames(x)<-nano$BTC_ID[indx4]


CDEs<-read.delim(patient.file, sep="\t",header=TRUE,as.is=T)
CDEs$Ref.<-gsub("-",".",CDEs$Ref.)

i<- match(rownames(x),CDEs$Ref.)
x<-x[which(!is.na(i)),]				# 218 samples == Lisa's count, AOK
i<-i[!is.na(i)]

# find samples of interest
ages<-CDEs$age.at.diagnosis[i][CDEs$age.at.diagnosis[i]>0]
thresholds<-quantile(ages, probs=seq(0,1,0.2))
hiT<-thresholds[length(thresholds)-1]
loT<-thresholds[2]
oldAtDx<-CDEs$Ref[match(ages[ages>hiT],CDEs$age.at.diagnosis)]
youngAtDx<-CDEs$Ref[match(ages[ages<loT],CDEs$age.at.diagnosis)]

j<-which(CDEs$overall.survival[i]>0 & CDEs$overall.survival[i]!="NULL")
OS<-CDEs$overall.survival[i][j]
thresholds<-quantile(OS, probs=seq(0,1,0.2))
hiT<-thresholds[length(thresholds)-1]
loT<-thresholds[2]
longOS<-CDEs$Ref[match(OS[OS>hiT],CDEs$overall.survival)]
shortOS<-CDEs$Ref[match(OS[OS<loT],CDEs$overall.survival)]

nonOverlapping<-function(v1,v2,v3,v4) {
	allOtherSamples<-c(v2,v3,v4)
	overlapping<-intersect(v1,allOtherSamples)
	indx<-match(overlapping,v1)
	if (length(indx)>0) return(v1[-(indx)]) else
		return(v1)
}

DX.young<-nonOverlapping(youngAtDx,oldAtDx,longOS,shortOS)
DX.old<-nonOverlapping(oldAtDx,youngAtDx,longOS,shortOS)
OS.long<-nonOverlapping(longOS,youngAtDx,oldAtDx,shortOS)
OS.short<-nonOverlapping(shortOS,youngAtDx,oldAtDx,longOS)

# Now make PLS target matrix
DX.young.indx<-match(rownames(x),DX.young)
DX.young.indx<-which(!is.na(DX.young.indx))

DX.old.indx<-match(rownames(x),DX.old)
DX.old.indx<-which(!is.na(DX.old.indx))

OS.long.indx<-match(rownames(x),OS.long)
OS.long.indx<-which(!is.na(OS.long.indx))

OS.short.indx<-match(rownames(x),OS.short)
OS.short.indx<-which(!is.na(OS.short.indx))

Y<-matrix(0,nrow=dim(x)[1],ncol=4)
Y[DX.young.indx,1]<-1
Y[DX.old.indx,2]<-1
Y[OS.long.indx,3]<-1
Y[OS.short.indx,4]<-1

tbl.nano <- x
names <- rownames(tbl.nano)
names.matched <- match(names, CDEs$Ref.)


library(pls)
plsFit=plsr(Y~x,ncomp=3,scale=FALSE,validation="LOO")
plot(RMSEP(plsFit))
summary(plsFit)

dev.new(); plot.new()
biplot(plsFit$loadings[,1:2],plsFit$Yloadings[,1:2],
	   col=c("blue","red"),cex=c(0.5,1),cex.main=0.85,
	   xaxt='n',yaxt='n',
	   main="Y1=young at diagnosis, Y2=old at diagnosis, 
	   Y3=long Overall survival, Y4=short overall survival")
