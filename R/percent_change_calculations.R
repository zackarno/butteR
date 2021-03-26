#' @name pct_change
#' @rdname pct_change
#' @title Percent change of a variable compared to previous
#' @description calculate percent change for a particular numeric variable compared to a previous time-step
#' @param x variable name

pct_change<- function(x){(x/lag(x)-1)*100}

#' @name pct_change_by_groups_all_numerics
#' @rdname pct_change_by_groups_all_numerics
#' @title Percent change by groups for all numerics in dataframe
#'
#' @description Used to calculate percent change of all numeric data by a group/strata level.
#' Created specifically for calculating price % change for many items across months
#' @param df data frame
#' @param group_var the variable to group_by. This column will be reported in final data.
#' @param time_id column name containing the time_id (i.e month, year, etc.)
#' @return data.frame with grouping var and all the same columns but half the number of rows
#' containing the % change for each value.


pct_change_by_groups_all_numerics<-function(df, group_var, time_id){
  group_var<- enquo(group_var)
  time_id<- enquo(time_id)
  df %>%
    group_by(!!aggregation_level ) %>%
    arrange(!!aggregation_level, !!time_id) %>%
    summarise(across(is.numeric,pct_change)) %>%
    filter(!is.na(!!time_id)) %>%
    select(-time_id)
}
