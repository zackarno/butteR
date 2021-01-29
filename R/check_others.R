#' Check variation by: check the variation of all columns by grouping var (specifically designed for the grouping var to be the data collectors identifier). Variation results are checked with resepect to standard deviations of them mean and a plot is produced to help understand issues.
#' @param df data frame
#' @param suffix suffix that ends other columns. others need systematic suffix (i.e "_other")
#' @param report_cols columns to report
#' @return a useful table of other values and a cleaning log
#' @export


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
