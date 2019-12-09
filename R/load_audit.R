#'
#' Load audit files
#' @param data data set
#' @param path.to.zip where audit zip file is stored
#' @param copy.zip logical whether or not to copy zip (logical = TRUE, yes copy zip)
#' @param path.to.copy.zip where you want to copy zip (dropbox)
#' @param filter.column column to filter data set (informed consent usually)
#' @param filter.on  filter value to remove
#' @param uuid.column  column contining unique identifier
#' @param delete.unzipped  logical- delete unzipped file (TRUE default= delete)
#' @param days.ago.reported  days since data was reported (default = 0)
#' @return audit data
#' @export
#'
#'

load_audit<-function(data,
                     path.to.zip,path.to.unzip,
                     copy.zip=TRUE,
                     path.to.copy.zip,
                     filter.column="informed_consent",
                     filter.on= "yes",
                     uuid.column="X_uuid",
                     delete.unzipped=TRUE,
                     days.ago.reported=0){
  if(copy.zip==TRUE){
    file.copy(path.to.zip, path.to.copy.zip)}

  unzip(path.to.zip, exdir = path.to.unzip)
  all_uuid_df<-data.frame(all_uuids=basename(dirname(list.files(path_unzip, recursive=TRUE))),
                          all_paths=dirname(list.files(path_unzip, recursive=TRUE, full.names = TRUE)))
  data$filter.col<- data[[filter.column]]
  filtered_uuid_df<- all_uuid_df[all_uuid_df$all_uuids %in% data[data$filter.col==filter.on,uuid.column],]
  filtered_audit_dirs<-filtered_uuid_df[,"all_paths"] %>% as.character()
  filtered_audit_csvs<-list.files(filtered_audit_dirs, recursive = TRUE, full.names=TRUE)
  data<-filtered_audit_csvs %>%
    purrr::map(readr::read_csv)
  names(data)<-filtered_uuid_df$all_uuids
  if(delete.unzipped==TRUE){
    delete_dir<-list.files(path_unzip,full.names = TRUE)
    unlink(delete_dir, recursive=TRUE)
  }
  return(data)

}

