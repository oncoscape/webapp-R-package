# test_MSK_DataProviders
#----------------------------------------------------------------------------------------------------
library(RUnit)
library(Oncoscape)
#----------------------------------------------------------------------------------------------------
runTests <- function()
{
    test_constructor();
   
} # runTests
#----------------------------------------------------------------------------------------------------
test_constructor <- function()
{
    print("--- test_constructor")

    dp <- CaisisData("../explorations/caisis/Caisis_BrainTables_5-28-14");
    checkTrue(is(dp, "CaisisData"))

} # test_constructor
#----------------------------------------------------------------------------------------------------
