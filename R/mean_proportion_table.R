#'
#' Generate Summary Tables For Chosen Columns/Indicators/Questions
#'
#' Add all levels from possible answer choices from choices sheet to dataset. This reduces
#' possible errors that can occur when aggregating and computing summary statistics with survey package
#' @details
#' @param design design object
#' @param list_of_Variables vector containing all variable names to analyze and include in summary table
#' @param aggregation_level aggregation level(s) to analyze data by. The default (NULL) will fully aggregate data to provide one value per variable. Argument also accepts vecors to aggregate the data using mroe than one variable.
#' @param round_to The number of digits to round reults to.
#' @param return_confidence Logical variable. TRUE (default) will return 95 \% confidence interval, FALSE returns no confidence interval
#' @param na_replace Logical variable. TRUE will replace NA with 0 for integerss and "filtered value" for categorical variables. FALSE (default) will leave NAs in dataset and thus they will automatically be removed during calculation
#' @export

mean_proportion_table<-function(design,
                                list_of_variables,
                                aggregation_level=NULL,
                                round_to=2,
                                return_confidence=TRUE,
                                na_replace=FALSE){
  design_srvy<-as_survey(design)
  integer_analysis_tables<-list()
  factor_analysis_tables<-list()
  list_of_variables<-setdiff(list_of_variables,aggregation_level)
  for(i in 1: length(list_of_variables)){
    variable_to_analyze<-list_of_variables[i]
    print(variable_to_analyze)
    if(class(design_srvy$variables[[variable_to_analyze]])=="integer"){
      if(na_replace==TRUE){
        design_srvy$variables[[variable_to_analyze]]<-ifelse(is.na(design_srvy$variables[[variable_to_analyze]]),
                                                             0,design_srvy$variables[[variable_to_analyze]])
      }
      aggregate_by<- syms(aggregation_level)
      if(is.null(aggregation_level)) {
        integers_formatted_for_analysis<-design_srvy
      }
      else {
        integers_formatted_for_analysis<-design_srvy %>%
          group_by(!!!aggregate_by,.drop=FALSE)
      }
      if(return_confidence==TRUE)
      {
        integer_analysis_tables[[i]]<-integers_formatted_for_analysis %>%
          summarise(mean.stat=survey_mean(!!sym(variable_to_analyze),na.rm=TRUE,vartype="ci")) %>%
          mutate(!!variable_to_analyze:=paste0(round(mean.stat,round_to),
                                               " (",round(mean.stat_low,round_to),
                                               ", ", round(mean.stat_upp,round_to),
                                               ")")) %>%
          dplyr::select(!!!aggregate_by, variable_to_analyze)
      }
      if(return_confidence==FALSE)
      {
        integer_analysis_tables[[i]]<-integers_formatted_for_analysis %>%
          summarise(!!variable_to_analyze:=survey_mean(!!sym(variable_to_analyze),na.rm=TRUE,vartype="ci")) %>%
          select(!!!aggregate_by, !!sym(variable_to_analyze))
      }
    }
    if(class(design_srvy$variables[[variable_to_analyze]])=="factor"){
      if(na_replace==TRUE){
        design_srvy$variables[[variable_to_analyze]]<-forcats::fct_explicit_na(design_srvy$variables[[variable_to_analyze]], "filtered_values")
      }
      if(is.null(aggregation_level)){
        aggregate_by<-syms(variable_to_analyze)
        factors_analyzed<-design_srvy %>%
          group_by(!!!aggregate_by,.drop=FALSE) %>%
          summarise(mean.stat=survey_mean(na.rm=TRUE,vartype="ci" )) %>%
          gather("question","answer_choice",variable_to_analyze) %>%
          mutate(question.response=paste0(question,".", answer_choice)) %>%
          select(question.response,mean.stat:mean.stat_upp)
      } else {
        aggregate_by<-syms(c(aggregation_level,variable_to_analyze))
        factors_analyzed<-design_srvy %>%
          group_by(!!!aggregate_by,.drop=FALSE) %>%
          summarise(mean.stat=survey_mean(na.rm=TRUE,vartype="ci" )) %>%
          gather("question","answer_choice",variable_to_analyze) %>%
          mutate(question.response=paste0(question,".", answer_choice)) %>%
          select(!!(aggregation_level), question.response, mean.stat:mean.stat_upp)
      }
      if(return_confidence==TRUE){
        factor_analysis_tables[[i]]<-factors_analyzed
      }
      if(return_confidence==FALSE){
        factor_analysis_tables[[i]]<-design_srvy %>%
          group_by(!!!aggregate_by,!!sym(variable_to_analyze),.drop=FALSE) %>%
          summarise(mean.stat=survey_mean(na.rm=TRUE,vartype="ci")) %>%
          gather("question","answer_choice",variable_to_analyze) %>%
          mutate(question.response=paste0(question,".", answer_choice))
      }
    }}
  if(length(integer_analysis_tables)>0){
    print("binding intergers")
    interger_analysis_tables_full<- integer_analysis_tables[-which(sapply(integer_analysis_tables, is.null))]
    integers_analyzed_wide<-Reduce(function(x, y) merge(x, y, by =aggregation_level, all = TRUE), interger_analysis_tables_full)
    integers_analyzed_wide<-integers_analyzed_wide %>%
      select_if(~!all(is.na(.))) %>% select(-ends_with(".NA"))}
  if(length(factor_analysis_tables)>0) {
    print("binding factors")
    factors_analyzed_long<-do.call("rbind", factor_analysis_tables)
    print("spreading factors")
    if(return_confidence==TRUE){
      if(is.null(aggregation_level)){
        factors_analyzed_wide<-factors_analyzed_long %>%
          mutate(stat_full= paste0(round(mean.stat,round_to),
                                   " (",round(mean.stat_low,round_to),
                                   ", ", round(mean.stat_upp,round_to),
                                   ")")) %>%
          select(question.response, stat_full) %>% tidyr::spread(question.response,stat_full) %>%
          select_if(~!all(is.na(.))) %>%
          select(-ends_with(".NA"))
      } else {
        factors_analyzed_wide<-factors_analyzed_long %>%
          mutate(stat_full= paste0(round(mean.stat,round_to),
                                   " (",round(mean.stat_low,round_to),
                                   ", ", round(mean.stat_upp,round_to),
                                   ")")) %>%
          select(!!(aggregation_level), question.response, stat_full) %>% tidyr::spread(question.response,stat_full) %>%
          select_if(~!all(is.na(.))) %>%
          select(-ends_with(".NA")) %>%
          filter(!is.na(!!sym(aggregation_level[length(aggregation_level)])))
      }}

    if(return_confidence==FALSE){
      if(is.null(aggregation_level)) {
        factors_analyzed_wide<-factors_analyzed_long %>%
          select(question.response, mean.stat) %>% tidyr::spread(question.response,mean.stat) %>%
          select_if(~!all(is.na(.)))%>%
          select(-ends_with(".NA"))
      } else {
        factors_analyzed_wide<-factors_analyzed_long %>%
          select(aggregation_level, question.response, mean.stat) %>% tidyr::spread(question.response,mean.stat) %>%
          select_if(~!all(is.na(.)))%>%
          select(-ends_with(".NA")) %>%
          filter(!is.na(!!sym(aggregation_level[length(aggregation_level)])))
      }
    }}
  if(length(integer_analysis_tables)>0 &length(factor_analysis_tables)>0){
    if (is.null(aggregation_level)) {
      combined_output<-cbind(factors_analyzed_wide, integers_analyzed_wide)}
    else{
      combined_output<-left_join(factors_analyzed_wide, integers_analyzed_wide, by=aggregation_level)}}
  if(length(integer_analysis_tables)>0 &length(factor_analysis_tables)==0){
    combined_output<-integers_analyzed_wide}
  if(length(integer_analysis_tables)==0 &length(factor_analysis_tables)>0){
    combined_output<-factor_analysis_tables}

}


