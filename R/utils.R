#' Remove grouper added to kobo dataset when downloaded
#'
#' @param colname colname vector
#' @return colname vector without grouper
#' @export



remove_kobo_grouper<-function(colname, max_prefix_length){
  new_name<-sub(".*?\\.", '', colname)
  name_df<-data.frame(old_name=colname, new_name=new_name)
  name_df<-name_df %>%
    mutate(
      char_diff=stringr::str_length(old_name)-stringr::str_length(new_name),
      new_col_name=if_else(char_diff<=max_prefix_length, as.character(new_name),as.character(old_name))
    )
  name_df$new_col_name %>% return()
}


#old one
# remove_kobo_grouper<-function(colname){
#   sub(".*?\\.", '', colname)
# }
