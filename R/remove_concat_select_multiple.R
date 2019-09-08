#'
#'REMOVE CONCATENATED SELECT MULTIPLE COLUMNS FROM DATA SET
#'
#' returns the input data frame with concatenated select multiple questions
#' removed
#'
#' @param data the dataset (data frame). Does not yet support design objects
#' @param questionnaire questionnaire object created by the koboquest package
#' @details
#' @export
#'
#'

remove_concat_select_multiple<-function(data, questionnaire){
  which_are_select_multiple<-which(
    sapply(names(data), questionnaire$question_is_select_multiple)
  )
  if(length(which_are_select_multiple)!=0){
    data<-data[,-which_are_select_multiple]
  }
  data

}
