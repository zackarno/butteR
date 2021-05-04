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

#' lookup table to data validation
#' @param lookup_table output form xlsform_lookuptalbe
#' @return data frame that can be added as xlsx sheet to easily make data validation for kobo tool/cleaning log



lookup_to_data_validation<-function(lookup_table){
  return_list<-list()
  dv_list<-lookup %>%
    mutate(qtype= ifelse(str_detect(question_type,"select_one|select one"),"so","sm")) %>%
    select(question_type,qtype,xml_format_data_col,choice_name) %>%
    split(.$qtype)
  sm_dv<-dv_list$sm %>%
    mutate(true="TRUE", false="FALSE") %>%
    select(-choice_name) %>%
    pivot_longer(true:false, values_to="choice_name") %>%
    select(-name)
  so_dv<- dv_list$so
  bind_rows(sm_dv,so_dv)


}



#' @name mutate_batch
#' @rdname mutate_batch
#' @title Mutate multiple columns at once with same value
#'
#' @description mutating batch columns allows programmic creation of columns based
#' on an input vector or list. This was developed to add on new variables to a xlsform data
#' set which can then be systematically added to the the xlsform tool
#' @param df dataframe
#' @param names names of columns to mutate
#' @param values uniform values to mutate
mutate_batch<- function(df,nm, value=NA){
  df %>%
    tibble::add_column(!!!set_names(as.list(rep(value, length(nm))),nm=nm))

}

#' @name survey_name_choice_name_match
#' @rdname match_name_list_name
#' @title Mutate multiple columns at once with same value
#'
#' @description mutating batch columns allows programmic creation of columns based
#' on an input vector or list. This was developed to add on new variables to a xlsform data
#' set which can then be systematically added to the the xlsform tool
#' @param kobold kobold object



survey_name_choice_name_match<- function(kobold){
  kobold$survey %>%
    mutate(
      list_name= str_replace_all(string = type, pattern = "select_one|select one|select_multiple|select multiple","") %>%
        trimws()
    ) %>% select(list_name, name)

}

#' @name xlsform_add_choices
#' @rdname xlsform_add_choices
#' @title Mutate multiple columns at once with same value
#'
#' @description mutating batch columns allows programmic creation of columns based
#' on an input vector or list. This was developed to add on new variables to a xlsform data
#' set which can then be systematically added to the the xlsform tool
#' @param kobld kobold object
#' @param new_choices new choice sheet containing question name and new choices


xlsform_add_choices<- function(kobold, new_choices){
  name_list_name<-survey_name_choice_name_match(kobold)
  lookup_table<- new_choices %>%
    left_join(name_list_name, by = c("name"="name"))


  lookup_table_split<- lookup_table %>%
    select(list_name,choice) %>%
    mutate(label=choice) %>%
    split(.$list_name)
  choices_split<-kobold$choices %>%
    split(.$list_name)
  choices_relevant_split<- choices_split %>%
    keep(names(.) %in% lookup_table$list_name)

  choices_new_list<-list()
  for(i in names(choices_relevant_split)){
    choices_temp<-choices_relevant_split[i]
    lookup_temp<- lookup_table_split[i]
    choices_new_list[i]<-bind_rows(choices_temp,lookup_temp)
  }
  choices_split[names(choices_relevant_split)]<-choices_new_list
  bind_rows(choices_split)
}

#
#
# xlsform_add_choices<- function(kobold, new_choices){
#   if("list_name" %in% colnames(new_choices)){
#     # then we join directly by list_name
#     # if not we have to make survey_name, choices_name (name in choices tab)
#
#   }
#
#   name_list_name<-survey_name_choice_name_match(kobold)
#   lookup_table<- new_choices %>%
#     left_join(name_list_name, by = c("name"="name"))
#
#
#   lookup_table_split<- lookup_table %>%
#     select(list_name,choice) %>%
#     mutate(label=choice) %>%
#     split(.$list_name)
#   choices_split<-kobold$choices %>%
#     split(.$list_name)
#   choices_relevant_split<- choices_split %>%
#     keep(names(.) %in% lookup_table$list_name)
#
#   choices_new_list<-list()
#   for(i in names(choices_relevant_split)){
#     choices_temp<-choices_relevant_split[i]
#     lookup_temp<- lookup_table_split[i]
#     choices_new_list[i]<-bind_rows(choices_temp,lookup_temp)
#   }
#   choices_split[names(choices_relevant_split)]<-choices_new_list
#   bind_rows(choices_split)
# }


