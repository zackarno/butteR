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
#' @export


pct_change_by_groups_all_numerics<-function(df, group_var, time_id){

  res<-df %>%
    group_by(!!sym(group_var))  %>%
    arrange(!!sym(group_var), !!sym(time_id)) %>%
    summarise(across(where(is.numeric),pct_change)) %>%
    ungroup() %>%
    filter(rowAny(
      filter(across(c(-group_var), ~!is.na(.))))
    )
  return(res)
}


#' @name rowAny
#' @rdname rowAny
#' @title rowAny
#'
#' @description helper function for new dplyr across syntax
#' @param df data frame
#' @export

rowAny <- function(x) rowSums(x) > 0
