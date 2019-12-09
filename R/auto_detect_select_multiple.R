#' Auto Detect Select Multiple Questions
#' @param df dataset (data frame)
#' @return vector of character column names detected as select multiple
#' @export
#'

auto_detect_select_multiple<-function(df){
  df_names_before_last_period<-sub('.[^.]*$', '', colnames(df))
  df_names_before_last_period<-data.frame(col_names=df_names_before_last_period[df_names_before_last_period!=""])
  select_multiple_detected<-df_names_before_last_period %>%
    group_by(col_names) %>%
    count() %>%
    filter(n>1) %>%
    select(col_names)
  return(as.character(select_multiple_detected$col_names))

}
