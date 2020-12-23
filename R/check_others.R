#' Check variation by: check the variation of all columns by grouping var (specifically designed for the grouping var to be the data collectors identifier). Variation results are checked with resepect to standard deviations of them mean and a plot is produced to help understand issues.
#' @param df data frame
#' @param suffix suffx that ends other columns (prefere kobos to be built with _other suffix)
#' @return cleaning log
#' @export


check_others<- function(df, suffix="_other", report_cols){

  rep_cols_not_in_df<-report_cols[!report_cols %in% colnames(df)]
  message(crayon::magenta(glue::glue("{rep_cols_not_in_df}%>% paste(collapse = ", ") are not in data frame")))

  user_uuid<-grep(x = report_cols,pattern = "uuid", value=T)
  if(length(user_uuid>0)){
    data_uuid<-df %>% select(contains("uuid")) %>% colnames()
    message(crayon::blue(glue::glue("did you mean {data_uuid} as the uuid column?")))
  }
  assertthat::assert_that(length(rep_cols_not_in_df)==0,msg= "reporting cols listed above not in data frame")


  # rep_cols_not_in_df %>% select(contains("uuid"))
  uuid_col<- df %>% select(matches("uuid")) %>% colnames()

  df %>%
    filter_at(vars(ends_with(suffix)), any_vars(!is.na(.))) %>%
    purrr::discard(~all(is.na(.))) %>%
    select(uuid_col,ends_with(suffix)) %>%
    mutate(across(as.character(.data))) %>%
    pivot_longer(-uuid_col) %>%
    filter(!is.na(value))
}
