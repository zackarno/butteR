#'
#' Get NA percentages and frequency for each column in the data set
#' @param data The dataset (data.frame).
#' @return frequency and proportion table of NA rates.
#' @export

get_na_response_rates<-function(data){
  na_count_per_question<-sapply(data, function(y) sum(length(which(is.na(y)))))
  na_percent_per_question <-sapply(data, function(y) ((sum(length(which(is.na(y)))))/nrow(data))*100)
  non_response_df<-data.frame(num_non_response=na_count_per_question,perc_non_response= na_percent_per_question)
  non_response_df1<-non_response_df %>%
    mutate(question=rownames(.)) %>%
    dplyr::select(question, everything()) %>%
    arrange(num_non_response, question)
}




