#' read_all_csvs_in_folder
#'
#' @param input_csv_folder folder containing csvs of interest

#' @return a list of data frames, each one named after the file name
#' @export


read_all_csvs_in_folder<- function(input_csv_folder){
  filenames_long<-list.files(input_csv_folder,full.names = TRUE,pattern = "*.csv")
  filenames_short<-list.files(input_csv_folder,full.names = FALSE,pattern = "*.csv")
  all_csvs<-list()
  for (i in 1: length(filenames_long)){
    file_of_interest<- filenames_long[i]
    file_of_interest_short_name<- filenames_short[i]
    data<- read.csv(file_of_interest,
                    stringsAsFactors = FALSE,
                    row.names = NULL, na.strings = c(""," ",NA, "NA"),
                    strip.white = TRUE)
    all_csvs[[file_of_interest_short_name]]<-data
  }
  return(all_csvs)
}

#' readr_all_csvs_in_folder
#'
#' @param input_csv_folder folder containing csvs of interest

#' @return a list of data frames, each one named after the file name (uses readr)
#' @export


readr_all_csvs_in_folder<- function(input_csv_folder){
  filenames_long<-list.files(input_csv_folder,full.names = TRUE,pattern = "*.csv")
  filenames_short<-list.files(input_csv_folder,full.names = FALSE,pattern = "*.csv")
  all_csvs<-list()
  for (i in 1: length(filenames_long)){
    file_of_interest<- filenames_long[i]
    file_of_interest_short_name<- filenames_short[i]
    data<-readr::read_delim(file_of_interest, delim=",", trim_ws=TRUE)

    all_csvs[[file_of_interest_short_name]]<-data
  }
  return(all_csvs)
}




