#'
#' BARPLOT GROUPED BINARY COLUMNS
#'
#' This function takes a list of variables from a survey object and puts them all on one barplot.
#' @details
#' @param design design object
#' @param list_of_variables list of variables that you want to plot together
#' @param aggregation_level the level to aggregate calculations to (this will ultimately be categorical on the Y-Axis)
#' @export

barplot_grouped_binaries <- function(design,list_of_variables,aggregation_level) {
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
  p1+ geom_bar(position=position_dodge(), stat="identity", colour='black') +
    geom_errorbar(aes(ymin=mean.stat_low, ymax=mean.stat_upp), width=.2,position=position_dodge(.9))+
    scale_y_continuous(breaks=seq(0,1, by=0.1),labels = scales::percent_format(accuracy = 1))+
    labs(x=aggregation_level)+
    coord_flip()

}

