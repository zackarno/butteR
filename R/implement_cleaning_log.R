#' implement cleaning log on raw data set
#' @param df raw data (data.frame)
#' @param df_uuid column in raw data with uuid
#' @param cl cleaning log (data.frame)
#' @param cl_change_col column in cleaning log which specifies data set column to change
#' @param cl_uuid uuid in cleaning log
#' @param cl_new_val cleaning log column specifying the new correct value
#' @return clean data set
#' @export


implement_cleaning_log <- function(df,
                                   df_uuid,
                                   cl,
                                   cl_change_col,
                                   cl_uuid,cl_new_val){
  cl[[cl_change_col]]<-cl[[cl_change_col]] %>% trimws()
  cl[[cl_new_val]]<-cl[[cl_new_val]] %>% trimws()

  if(all(cl[[cl_change_col]] %in% colnames(df))==F){
    problem_question_in_cl<-cl[[cl_change_col]][cl[[cl_change_col]] %in% colnames(df)==FALSE]
    print(paste0(problem_question_in_cl,": not in data"))
  }

  if(all(cl[[cl_uuid]] %in% df[[df_uuid]])==F){
    problem_uuid_in_cl<-cl[[cl_uuid]][cl[[cl_uuid]] %in% df[[df_uuid]]==FALSE]
    print(problem_uuid_in_cl)
    print("NOT IN DATASET")

  }

  assertthat::assert_that(all(cl[[cl_change_col]] %in% colnames(df)),
                          msg="Error: Make sure all name in question label column in the cleaning log are in dataset")

  assertthat::assert_that(all(cl[[cl_uuid]] %in% df[[df_uuid]]),
                          msg="Error:Make sure all uuids in cleaing log are in data set")

  for(i in 1:nrow(cl)){
    print(cl[[cl_change_col]][i])

    df[,cl[i,][[cl_change_col]]][df[,cl_uuid]==cl[i,][[cl_uuid]]] <- cl[i,][[cl_new_val]]
  }

  return(df)
}
