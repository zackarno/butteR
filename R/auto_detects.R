#' @name auto_detect_sm_parents
#' @rdname auto_detect_sm_parents
#' @title Detect select multiple parent columns
#'
#' @description `auto_detect_sm_parents` is mean to detect select multiple parent columns in a way that does
#' not rely on the XLSForm as the input
#'
#' @param df a survey object or dataframe
#' @param sm_sep select multiple parent child separator. This is specific for XLSForm data (default = /).
#'  If using read_csv to read in data the separator will most likely be '/' where as if using read.csv it will likely be '.'
#' @return a list of select multiple parent columns in data set.
#'
#'
#' @export
auto_detect_sm_parents<- function(df, sm_sep="/"){
  sm_parents<-sub(glue::glue('.[^\\{sm_sep}]*$'), '', colnames(df))
  sm_parents<-data.frame(col_names=sm_parents[sm_parents!=""])
  select_multiple_detected<-sm_parents %>%
    group_by(col_names) %>%
    summarise(n=n()) %>%
    filter(n>1) %>%
    select(col_names)
  return(as.character(select_multiple_detected$col_names))

}
#' @name auto_sm_parent_child
#' @rdname auto_sm_parent_child
#' @title detect and group together select multiple parent and children columns
#' @description `auto_sm_parent_child` is mean to detect select multiple parent columns & children columns in a way that does
#' not rely on the XLSForm as the input
#' @param df a survey object or dataframe
#' @param sm_sep select multiple parent child separator. This is specific for XLSForm data (default = /).
#'  If using read_csv to read in data the separator will most likely be '/' where as if using read.csv it will likely be '.'
#' @return a data frame containing the the child select multiple columns alongside there parents
#' @export


auto_sm_parent_child<- function(df, sm_sep="/"){
  sm_parents<-auto_detect_sm_parents(df, sm_sep)
  sm_child<- df %>%
    select(starts_with(glue::glue("{sm_parents}{sm_sep}"))) %>%
    colnames()
  tibble(
    sm_parent=sub(glue::glue('.[^\\{sm_sep}]*$'),'',sm_children),
    sm_child
  )

}
