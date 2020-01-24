#' Stratified simple random sampling.
#'
#' @param sample.target.frame data frame with strata, and sample size columns
#' @param sample.target.frame.strata name of strata column in sample.target.frame
#' @param sample.target.frame.samp.size name of sample size column in sample.target.frame
#' @param pt.data pt data object of class
#' @param pt.data.strata name of strata column in pt.data
#' @param pt.data.labels name of column to label individual kml points
#' @param target_gdb folde to output kml files  to. If empty/null (default) files will write to current working directory
#' @param seed set and save random seed (will set by default)
#' @param write_kml logical, write output to kml
#' @param write_remaining_sample_kml logical, write remaining sample to kml
#' @return list with each sample as sf object. Exports each item in list to kml file in selected directory
#' @export



stratified_sampler<-function(sample.target.frame,
                             sample.target.frame.strata,
                             sample.target.frame.samp.size,
                             pt.data,
                             pt.data.strata,
                             pt.data.labels,
                             target_gdb=NULL,
                             seed=NULL,
                             write_kml=TRUE,
                             write_remaining_sample_kml=TRUE){
  if(is.null(seed)){
    random_seed<-sample(1000000, 1)
  } else{
    random_seed<-seed
  }
  random_seed_df<-data.frame(random_seed=random_seed)
  isodate<-Sys.Date() %>% stringr::str_replace_all("-","")
  pt.data$uuid<-seq(1,nrow(pt.data),by=1)

  set.seed(random_seed)
  samp<-list()
  for(i in 1:nrow(sample.target.frame)){
    strata_temp<-sample.target.frame[[sample.target.frame.strata]][i] %>% as.character()
    sample_num_temp<-sample.target.frame[[sample.target.frame.samp.size]][i] %>% as.numeric()
    pt.data<-pt.data %>% mutate(rnd_seed=random_seed)
    pt.data_temp<-pt.data %>% filter(!!sym(pt.data.strata)==strata_temp) %>% mutate(index_1=1:nrow(.))
    pt.data_temp_id<-pt.data_temp$index_1 %>% as.character()
    sampled_index_temp<-sample(pt.data_temp_id,sample_num_temp)
    sampled_centroids<-pt.data_temp %>% filter(index_1 %in% sampled_index_temp)
    sampled_centroids<-sampled_centroids %>%
      mutate(index=1:nrow(.),
             Description=paste0(index,"_",!!sym(pt.data.labels)) %>% stringr::str_replace_all(" ","_")) %>%
      select(Description,rnd_seed)
    samp$results[[strata_temp]]<-sampled_centroids
    if(write_kml==TRUE){

      folder_name<-strata_temp%>% stringr::str_replace_all(" ","_")
      file_name_end<-paste0(folder_name,"_",sample_num_temp,"pts.kml")
      if(is.null(target_gdb)){
        target_gdb<-getwd()
        gdb<-paste0(target_gdb,"/")
      }else {
        gdb<-paste0(target_gdb,"/")
      }

      file_name<-paste0(gdb,file_name_end)

      plotKML::kml(obj=sf::as_Spatial(sampled_centroids), folder.name=folder_name,
                   file.name=file_name,
                   kmz=FALSE,altitude=0,plot.labpt=TRUE,labels=Description,LabelScale=0.5)


    }}

  samp_binded<-do.call("rbind", samp$results)
  # samp_remaining<-pt.data %>% filter(geometry %in% samp_binded$geometry==FALSE)
  samp_remaining<-pt.data[pt.data$geometry %in% samp_binded$geometry==FALSE,]
  samp_remaining<-pt.data[pt.data$uuid %in% samp_binded$uuid==FALSE,]
  samp[["samp_remaining"]]<-samp_remaining
  samp[["random_seed"]]<-random_seed
  if(write_kml==TRUE){
    write.table(random_seed_df,paste0(gdb, isodate,"_random_seed_",random_seed,".txt"))
    if(write_remaining_sample_kml==TRUE){
      write.csv(samp_remaining, paste0(gdb,isodate,"_samp_remaining.csv"))

  }}
  return(samp)


}
