#----------------------------------------------------------------------------------------------------
# tissue IDs are the shared identifier, so restrict tbl.clinical to just those rows which we can
# map using Ref === btc.
cleanupClinicalTable <- function(tbl.clinical, tbl.idLookup)
{
    documented.rows <- which(tbl.clinical$Ref %in% tbl.idLookup$btc)
    tbl.clinical[documented.rows,]

} # cleanupClinicalTable
#----------------------------------------------------------------------------------------------------
