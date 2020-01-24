#' Use date string to prefix file names

#' @param date date object (default = Sys.Date())
#' @return date formated ISO86031 no space
#' @export



date_file_prefix<-function(date=Sys.Date()){
  isodate_file_prefix<-date %>% stringr::str_replace_all("-","")
  return(isodate_file_prefix)
}


