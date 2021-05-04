#' Check variation by: check the variation of all columns by grouping var (specifically designed for the grouping var to be the data collectors identifier). Variation results are checked with resepect to standard deviations of them mean and a plot is produced to help understand issues.
#' @param df data frame
#' @param suffix suffix that ends other columns. others need systematic suffix (i.e "_other")
#' @param report_cols columns to report
#' @return a useful table of other values and a cleaning log



check_others<-function(df, suffix="_other", report_cols){
  res<-list()

  rep_cols_not_in_df<-report_cols[!report_cols %in% colnames(df)]
  message(crayon::magenta(glue::glue("{rep_cols_not_in_df} - not in data frame")))

  user_uuid<-grep(x = report_cols,pattern = "uuid", value=T)
  if(length(user_uuid>0)){
    data_uuid<-df %>% select(contains("uuid")) %>% colnames()
    if(user_uuid != data_uuid){
      message(crayon::blue(glue::glue("did you mean {data_uuid} as the uuid column?")))
    }
  }

  assertthat::assert_that(length(rep_cols_not_in_df)==0,msg= "reporting cols listed above not in data frame")

  report_cols<-str_replace(report_cols,user_uuid,data_uuid)



  # once across verb has any_vars equialent filter_at can be replaced
  df_table<-df %>%
    filter_at(vars(ends_with(suffix)), any_vars(!is.na(.))) %>%
    purrr::discard(~all(is.na(.))) %>%
    select(report_cols,ends_with(suffix)) %>%
    mutate(across(as.character(.data))) %>%
    pivot_longer(-report_cols,
                 names_to="other_col",
                 values_to='prev_value',
                 values_drop_na = TRUE) %>%
    mutate(type= "add_option",
           name=str_replace(other_col,suffix,"")) %>%
    select(report_cols, everything())
  df_log<- df_table[rep(seq_len(nrow(df_table)), each = 2), ]

  res$log<- df_log %>%
    group_by(uuid) %>%
    mutate(rep_num=row_number(),
           type=ifelse(rep_num==2,"remove_option",type),
           value=ifelse(rep_num==2, "other","")
    ) %>%
    select(uuid, type, name , value)
  res$table<- df_table
  return(res)
}

#' @name parent_other_q
#' @rdname parent_other_q
#' @title parent_other_q
#' @description For questions that have other free-text follow up option, get parent and child variables
#' @param df kobo/odk/xlsform style questionnaire respose data as data.frame
#' @return a long format data frame containing the collapsed data.
#' @export

parent_other_q<- function(df){
  df %>%
    select(ends_with("_other")) %>%
    colnames() %>%
    tibble() %>%
    mutate(other_parent=str_replace_all(.,"_other","")) %>%
    rename(other_text=".")
}


#' @name others_cleaning_log
#' @rdname others_cleaning_log
#' @title others_cleaning_log
#' @description generate semi-auto cleaning log for regrouping and "other" free-text responses
#' @param df data.frame kobo/odk/xlsform style questionnaire respose data as data.frame
#' @param suffix identifying suffix for "other" free-text columns (default:  "_other"-recommended tool design)
#' @param report_cols columns to report (must include uuid)
#' @param kobo_survey_sheet data.frame containing kobo/xlsForm survey tab
#' @return semi-automated cleaning log formatted for use with kobold::kobold_cleaner. This log should then
#' be manually reviewed.
#' @export

others_cleaning_log<-function(df, suffix="_other", report_cols,kobo_survey_sheet){

  report_cols_in_df<-report_cols[report_cols %in% names(df)]
  # once across verb has any_vars equialent filter_at can be replaced
  #a.
  df_other_filt<-df %>%
    filter_at(vars(ends_with(suffix)), any_vars(!is.na(.)))


  df_parent_other_table<- parent_other_q(df_other_filt)



  so_other<- ks %>%
    filter(name %in% df_parent_other_table$other_parent) %>%
    filter(str_detect(type, c("select_one|select one"))) %>%
    pull(name)
  sm_other<- ks %>%
    # mutate(type=)
    filter(name %in% df_parent_other_table$other_parent) %>%
    filter(str_detect(type, c("select_multiple|select multiple"))) %>%
    pull(name)

  df_other_long<-df_other_filt %>%
    purrr::discard(~all(is.na(.))) %>%
    select(all_of(report_cols_in_df),
           any_of(c(
             df_parent_other_table$other_text))) %>%
    mutate(across(as.character(.data))) %>%
    pivot_longer(-report_cols_in_df,
                 names_to="name",
                 values_to='other_text',
                 values_drop_na = TRUE) %>%
    mutate(
      name=str_replace_all(name,"_other","")
    )
  sm_other_long<- df_other_long %>%
    filter(name %in% sm_other) %>%
    mutate(type="add_option")

  so_other_long<- df_other_long %>%
    filter(name %in% so_other) %>%
    mutate(
      type="change_response"
    )

  sm_other_long<- sm_other_long[rep(seq_len(nrow(sm_other_long)), each = 2), ]
  sm_other_long<- sm_other_long %>%
    group_by(uuid,name) %>%
    mutate(rep_num=row_number(),
           type=ifelse(rep_num==2,"remove_option",type) %>% as.character(),
           value=ifelse(rep_num==2, "other","")
    ) %>% ungroup()

  other_log<-bind_rows(sm_other_long,so_other_long) %>%
    mutate(
      current_value="other",
      issue="other_regrouped"
    ) %>%
    select(all_of(c(report_cols_in_df,"current_value","type", "value", "issue","other_text")))

  return(other_log)
}



