#'
#' Check consistencies between main data set and repeat data set
#' @param main_dataset main data set
#' @param main_col1 column 1 in main data
#' @param main_col2 column 2 in main data
#' @param main_uuid unique identifier in main data set to match unique identifier in repeat
#' @param repeat_dataset repeat data set
#' @param repeat_col1  column 1 in repeat data
#' @param repeat_col2  column 2 in repeat data
#' @param repeat_uuid  unique identifier in repeat data set to match unique identifier in repeat
#' @return uuids of non consistent results
#' @export


check_main_repeat_consistency<-function(main_dataset,
                                          main_col1,
                                          main_col2,
                                          main_uuid,
                                          repeat_dataset,
                                          repeat_col1,
                                          repeat_col2,
                                          repeat_uuid){
  main_dataset[["uuid_col1_col2"]]= paste0(main_dataset[[main_uuid]], "_", main_dataset[[main_col1]],"_", main_dataset[[main_col2]]) %>%
    trimws()
  repeat_dataset[["uuid_col1_col2"]]=paste0(repeat_dataset[[repeat_uuid]],"_",repeat_dataset[[repeat_col1]],"_", repeat_dataset[[repeat_col2]]) %>% trimws()
  main_repeat_joined<-left_join(main_dataset, repeat_dataset %>% select(uuid_col1_col2, repeat_col1, repeat_col2), by= "uuid_col1_col2")
  non_matches<-main_repeat_joined %>%
    filter(is.na(uuid_col1_col2)) %>%
    select(main_uuid,main_col1, main_col2)

  return(non_matches)
}
