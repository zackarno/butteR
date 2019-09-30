#' Remove concatenated select multiple columns from data set
#' @param data The dataset (data frame).
#' @param questionnaire questionnaire object created by the koboquest package
#' @return data set without concatenated select multiple columns
#' @export

remove_concat_select_multiple<-function(data, questionnaire){
  which_are_select_multiple<-which(
    sapply(names(data), questionnaire$question_is_select_multiple)
  )
  if(length(which_are_select_multiple)!=0){
    data<-data[,-which_are_select_multiple]
  }
  data
}
