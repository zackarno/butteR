#' Generate comparison/cleaning log between a raw/unchanged data set and a modified/cleaned data set. Only columns with the same names can be compared
#' @param raw_data raw/unchanged data set (df1)
#' @param clean_data clean/changed data set (df2)
#' @param raw_data_uuid name of unique identifier column in df1 that matches values of unique identifier in df2
#' @param clean_data_uuid name of unique identifier column in df2 that matches values of unique identifier in df1
#' @return a comparison/cleaning log that shows all changes that were made from the raw data set
#' @import dplyr purrr
#' @export
#'
df_comparison_log<-function(raw_data,clean_data,raw_data_uuid,clean_data_uuid){
  #checks/warnings
  if(ncol(raw_data)!=ncol(clean_data)){warning("dfs do not have the same columns. Only columns in both data sets will be considered")}
  raw_data<-raw_data %>% select(colnames(clean_data))

  deleted_records<-raw_data %>%
    filter(!!sym(raw_data_uuid) %in% clean_data[[clean_data_uuid]]==F) %>%
    select(raw_data_uuid) %>% mutate(change_type="record_deleted")

  raw_data<- raw_data %>%
    filter(!!sym(raw_data_uuid) %in% clean_data[[clean_data_uuid]]) %>%
    arrange(!!sym(raw_data_uuid))
  clean_data<-clean_data %>% arrange(!!sym(clean_data_uuid))

  cl_list<-map2(raw_data, clean_data,
                function(x,y){
                  index<-which((x!=y)|((is.na(x)&!is.na(y))|(is.na(y) &!is.na(x))))
                  old_value<-x[index]
                  new_value<-y[index]
                  uuid<-clean_data[index,clean_data_uuid]
                  cl1<-tibble(uuid, old_value,new_value)
                  cl1 %>% map_df(as.character)

                }
  )
  cl_list_filtered<-keep(cl_list,~nrow(.)>0)
  cl_list_filtered<-cl_list_filtered %>% map2(names(cl_list_filtered), function(x,y) x %>%
                                                mutate(change_type="value_modified",
                                                       column_changed=y) %>%
                                                select(uuid,change_type,column_changed,everything()))

  cl_list_filtered$deleted_records<- deleted_records %>% rename(uuid =raw_data_uuid)
  cl_list_full<- cl_list_filtered%>% keep(~nrow(.)>0)
  bind_rows(cl_list_full)

}
