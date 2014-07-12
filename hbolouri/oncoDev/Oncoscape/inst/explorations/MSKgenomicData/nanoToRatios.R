# nanoToRatios.R
#------------------------------------------------------------------------------------------------------------------------
options(stringsAsFactors=FALSE)
library(RUnit)
library(Oncoscape)
#------------------------------------------------------------------------------------------------------------------------
reload <- function (levels = NULL) 
{
    base::source("nanoToRatios.R")
    if (length(levels) > 0) 
        run(levels)
}
#------------------------------------------------------------------------------------------------------------------------
run = function (levels)
{
  if("redo" %in% levels){

     } # redo

  if (0 %in% levels) {
    print(load("../../extdata/nanoStringMatrixClean.RData", envir=.GlobalEnv))
    print(dim(mtx))
    } # 0

  if (1 %in% levels) {
     variance.nano <<- apply (mtx, 2, var)
     mean.nano <<- apply (mtx, 2, mean)
     cv.nano <<- sqrt (variance.nano)/mean.nano
     fivenum(cv.nano)   #        TBP     CDKN2C       RTN1       AVIL  PDGFRAD89 
                        #  0.5494187  0.9071655  1.3065432  2.0847139 10.1114843 
     } # 1

  if (2 %in% levels) {
     egfr <<- mtx[, "EGFR"]
     egfr.sd <<- sd(egfr)
     egfr <<- egfr - mean(egfr)
     egfr.norm <<- egfr/egfr.sd
     fivenum(egfr.norm) #     1234.T.1     958.T.1    1124.T.1    286X.T.1     998.T.1 
                        #  -0.51581624 -0.48911755 -0.43381315  0.04680724  6.34757348 
     } # 2

  if (3 %in% levels) {  # get a sense of tcga distributions, 
    dp <- DataProvider("TCGA_GBM_mRNA")
    mtx.tcga <<- getData(dp)
    egfr.tcga <<- mtx.tcga[,"EGFR"]
    fivenum(egfr.tcga)   # [1] -1.9651 -0.2606  1.0033  2.7290  4.4543
    } # 3

  if (4 %in% levels) {
    mtx.norm <<- apply(mtx, 2, function(col) {
                                  col.sd <- sd(col);
                                  col.meanSubtracted <- col - mean(col)
                                  col.meanSubtracted/col.sd
                              })
    
    } # 4

  if (5 %in% levels) {
    mtx.rat <<- apply(mtx, 2, function(col) {
                                  col.sd <- sd(col);
                                  col.meanSubtracted <- col - mean(col)
                                  col.meanSubtracted/col.sd
                              })

    } # 5

  if (6 %in% levels) {
    fivenum(mtx.norm) # [1] -1.8201054 -0.4633567 -0.2477397  0.1169930 16.3907940
    fivenum(mtx.tcga) # [1] -5.82520   -0.63440   -0.01585    0.59170   13.24360
    } # 6

  if (7 %in% levels) {
    mtx.mrna <- mtx.norm
    save(mtx.mrna, file="../../extdata/mskGBM/mtx.mrna.RData")
    } # 7

  if (8 %in% levels) {
    } # 8

  if (9 %in% levels) {
    } # 9

  if (10 %in% levels) {
    } # 10

  if (11 %in% levels) {
    } # 11

  if (12 %in% levels) {
    } # 12

  if (13 %in% levels) {
    } # 13

  if (14 %in% levels) {
    } # 14

  if (15 %in% levels) {
    } # 15

  if (16 %in% levels) {
    } # 16

  if (17 %in% levels) {
    } # 17

  if (18 %in% levels) {
    } # 18

  if (19 %in% levels) {
    } # 19

  if (20 %in% levels) {
    } # 20


} # run
#------------------------------------------------------------------------------------------------------------------------
