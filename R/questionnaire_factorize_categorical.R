#' Factorize all categorical data in data set according to questionnaire options.
#'
#' @param data the data set
#' @param questionnaire Questionnaire genereated from kobo quest package.
#' @param return_full_data Logical (default=FALSE). If TRUE refactored data will be inserted back into original dataset. If FALSE (default), only the refactored data will be returned.
#' @param round_to Decimal place to round to.
#' @param return_confidence Logical value specifying whether to return confidence interval.
#' @param na_replace Logical value (default = FALSE) of whether to replace NA with 0 (numerical) or "filtered" (categorical)
#' @param questionnaire Questionnaire genereated from kobo quest package.
#' @return Dataset with cateogrical data factorized according to questionnaire.
#' @export


questionnaire_factorize_categorical<-function(data, questionnaire,return_full_data=FALSE){
  which_are_select_multiple<-which(
    sapply(names(data), questionnaire$question_is_select_multiple)
  )
  if(length(which_are_select_multiple)!=0){
    data<-data[,-which_are_select_multiple]
  }
  categorical_variables<-which(
    sapply(names(data), questionnaire$question_is_categorical)
  )
  categorical_data<-data[,categorical_variables]
  categorical_levels<-sapply(names(categorical_data),questionnaire$question_get_choices)
  categorical_data_factored<-sapply(categorical_data,factor) %>% data.frame()
  for(i in 1: ncol(categorical_data_factored)){
    levels_in_data_set<-data.frame(levels_in_dataset=levels(categorical_data_factored[[i]]))
    levels_in_questionnaire<-data.frame(levels_in_questionnaire=categorical_levels[[i]])
    levels_in_questionnaire_properly_ordered<-
      dplyr::full_join(levels_in_data_set, levels_in_questionnaire, by= c("levels_in_dataset"= "levels_in_questionnaire"))
    levels(categorical_data_factored)<-levels_in_questionnaire$levels_in_questionnaire
  }
  if(return_full_data==FALSE){
    return(categorical_data_factored)}
  if(return_full_data==TRUE){
    data[,colnames(categorical_data_factored)]<-categorical_data_factored
    data<-data %>%
      mutate_if(sapply(data, is.character),as.factor)
    return(data)
  }
}


