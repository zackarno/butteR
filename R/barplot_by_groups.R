#' Barplot grouped binary columns
#' @param design Design object from survey or srvyr package.
#' @param list_of_variables Vector containing column names to analyze.
#' @param aggregation_level Column name to aggregate or dissagregate to OR vector of column names to dissagregate to.
#' @param binary Logical (default=TRUE) if the columns are binary or numeric.
#' @export

barplot_by_group <- function(design,list_of_variables,aggregation_level, binary=TRUE) {
  design_srvy<-srvyr::as_survey(design)
  severity_int_component_health_graphs<-list()
  int_component_summary<-list()
  aggregate_by<- syms(aggregation_level)
  if(is.null(aggregation_level)) {
    design_srvy<-design_srvy
  }
  else {
    design_srvy<-design_srvy %>%
      group_by(!!!aggregate_by,.drop=FALSE)
  }
  for(i in 1:length(list_of_variables)){
    variable_of_interest<-list_of_variables[i]
    int_component_summary[[i]]<-design_srvy %>%
      summarise(mean.stat=survey_mean(!!sym(variable_of_interest),na.rm=TRUE, vartype="ci")) %>%
      mutate(colname=variable_of_interest)
  }
  int_component_summaries_binded<-do.call("rbind", int_component_summary)

  if(is.null(aggregation_level)) {
    p1=int_component_summaries_binded %>% ggplot(aes(x=colname, y=mean.stat, fill=colname))+
      colorspace::scale_fill_discrete_qualitative(guide=FALSE)
  } else{
    p1=int_component_summaries_binded %>% ggplot(aes(x=as.factor(!!sym(aggregation_level)),
                                                     y=mean.stat,
                                                     fill=colname))+
      colorspace::scale_fill_discrete_qualitative()
  }
  if(binary==TRUE){
    p2<-p1+ geom_bar(position=position_dodge(), stat="identity", colour='black') +
      geom_errorbar(aes(ymin=mean.stat_low, ymax=mean.stat_upp), width=.2,position=position_dodge(.9))+
      scale_y_continuous(breaks=seq(0,1, by=0.1),labels = scales::percent_format(accuracy = 1))+
      labs(x=aggregation_level)+
      coord_flip()}
  if(binary==FALSE){
    range_of_data<-design_srvy$variables[,list_of_variables] %>% range()
    p2<-p1+ geom_bar(position=position_dodge(), stat="identity", colour='black') +
      geom_errorbar(aes(ymin=mean.stat_low, ymax=mean.stat_upp), width=.2,position=position_dodge(.9))+
      scale_y_continuous(breaks=seq(min(range_of_data),max(range_of_data), by=0.5))+
      labs(x=aggregation_level)+
      coord_flip()}
  p2
}





