
#' Find and replace concatenated select multiple column with all individual select multiple options
#' @param df data frame
#' @param name_vector vector containing column names in the data set.
#' @param aggregation_level Column name to aggregate or dissagregate to OR vector of column names to dissagregate to.
#' @return dataframe with parent  (concatenate select mutiple column) and individual select multiple option columns
#' @export




extract_sm_option_columns<-function(df,name_vector){
  df_names_before_last_period<-sub('.[^.]*$', '', colnames(df))
  df_names_before_last_period<-data.frame(col_names=df_names_before_last_period[df_names_before_last_period!=""])
  select_multiple_detected<-df_names_before_last_period %>%
    group_by(col_names) %>%
    count() %>%
    filter(n>1) %>%
    pull(col_names)
  matched_vector_to_sel_mult_ind<-match(name_vector, select_multiple_detected)
  matched_vector_to_sel_mult_ind<-matched_vector_to_sel_mult[!is.na(matched_vector_to_sel_mult)]
  sm_in_vect<-select_multiple_detected[matched_vector_to_sel_mult_ind] %>% as.character()
  sm_in_vect_with_dot<-paste0(sm_in_vect,".")
  parent_option_list<-list()
  for(i in 1:length(sm_in_vect)){
    beginning_of_name<-paste0("^",sm_in_vect[i])
    sm_options<-df %>% select(matches(beginning_of_name)) %>% colnames()
    parent_option_df<-data.frame(parent_name= rep(sm_in_vect[i],length(sm_options)),sm_options=sm_options)
    parent_option_list[[i]]<-parent_option_df
  }
  parent_option_df_all<-dplyr::bind_rows(parent_option_list)
  return(parent_option_df_all)



}

