#' Use date string to prefix file names

#' @param days_from_present number of days from present. Default is today 0. Tomorrow would be 1, yesterday= -1
#' @return date formated ISO86031 no space
#' @export


date_file_prefix<-function(days_from_present=0){
  isodate_file_prefix<-(Sys.Date()+days_from_present) %>%
    stringr::str_replace_all("-","")
  return(isodate_file_prefix)
}


