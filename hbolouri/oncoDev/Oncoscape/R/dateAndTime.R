addRMessageHandler("fetchDateAndTimeString", "returnDateAndTimeString");
#---------------------------------------------------------------------------------------------------
returnDateAndTimeString <- function(WS, msg)
{
    result <- format(Sys.time(), "%b %d %Y %H:%M:%S")  # e.g., "Mar 27 2014 09:55:31"
    return.msg <- toJSON(list(cmd="dateAndTimeString", status="result", payload=result))
    sendOutput(DATA=return.msg, WS=WS)
   
} # returnDateAndTimeString
#---------------------------------------------------------------------------------------------------
