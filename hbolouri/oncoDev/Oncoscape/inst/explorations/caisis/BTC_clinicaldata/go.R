# go.R
#------------------------------------------------------------------------------------------------------------------------
library(RJSONIO)
#------------------------------------------------------------------------------------------------------------------------
options(stringsAsFactors=FALSE)
#------------------------------------------------------------------------------------------------------------------------
run = function (levels)
{
  if (0 %in% levels) {
    load("BTC_clinicaldata_6-18-14.RData")
    pData <<- PatientData_json   # list of 2851 named lists
    table.names <<- unlist(unique(lapply(pData, function(element) element$Name))) # 9
      # Chemo, Radiation, DOB, Encounter, Diagnosis, OR, MRI, Progression, Death
    } # 0

  if (1 %in% levels) {
    } # 1

  if (2 %in% levels) {
    } # 2

  if (3 %in% levels) {
    } # 3

  if (4 %in% levels) {
    } # 4

  if (5 %in% levels) {
    } # 5

  if (6 %in% levels) {
    } # 6

  if (7 %in% levels) {
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
