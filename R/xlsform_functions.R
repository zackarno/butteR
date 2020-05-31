#' Make XlsForm lookup table from tool
#' @param  kobo_survey survey sheet from tool
#' @param kobo_choices choices sheet from tool
#' @param label_column label column used in tool
#' @return will return a lookup table with columns containing mergeable columns with the data set as well as butteR/survey package analyzed dataset
#' @export


make_xlsform_lookup_table<- function(kobo_survey, kobo_choices, label_column){
  question_label_col<- paste0("question_",label_column)
  choice_label_col<- paste0("choice_",label_column)
  kobo_survey %>%
    select(type, name,all_of(label_column), relevant) %>%
    rename_all(,.funs = function(x){paste0("question_",x)}) %>%
    filter(str_detect(question_type, "select")) %>%
    select(1:3,question_relevant) %>%
    mutate(question_list_name=str_replace_all(question_type,
                                              c("select_one"="", "select_multiple"="")) %>% trimws()) %>%
    right_join(kobo_choices %>% select(1:3) %>%
                 rename_all(,.funs = function(x){paste0("choice_",x)}),
               by=c("question_list_name"= "choice_list_name")) %>%
    mutate(
      xml_format_analysis=paste0(question_name,".",choice_name),
      xml_format_data_col=ifelse(str_detect(question_type,"^select_multiple|^select multiple"), xml_format_analysis, question_name)
    )
}

#' refactor to xlsform
#' @param data data set
#' @param kobo_choices choices sheet from tool
#' @param label_column label column used in tool
#' @return data set with select one questions refactored to kobo tool
#' @export

refactor_to_xlsform<-function(data,kobo_survey,kobo_choices ,label_column = "label::english" ){
  xls_lt<-make_xlsform_lookup_table(kobo_survey ,kobo_choices,label_column )
  xls_lt_select_questions<-xls_lt %>%
    filter(str_detect(question_type,"select")) %>%
    filter(xml_format_data_col %in% colnames(data))
  for(i in 1: length(unique(xls_lt_select_questions$question_name))){
    col_temp <- unique(xls_lt_select_questions$question_name)[i]
    print(col_temp)
    choices_temp<-xls_lt_select_questions %>% filter(question_name==col_temp) %>% pull(choice_name)
    data<-data %>%
      mutate(!!col_temp:= forcats::fct_expand(as.factor(!!sym(col_temp)), choices_temp))
  }
  return(data)

}
