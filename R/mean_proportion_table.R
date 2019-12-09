#' Analyze and aggregate weighted categorical data into clean tables
#' @param design Design object from survey or srvyr package.
#' @param list_of_variables Vector containing column names to analyze.
#' @param aggregation_level Column name to aggregate or dissagregate to OR vector of column names to dissagregate to.
#' @param round_to Decimal place to round to.
#' @param return_confidence Logical value specifying whether to return confidence interval.
#' @param na_replace Logical value (default = FALSE) of whether to replace NA with 0 (numerical) or "filtered" (categorical)
#' @param questionnaire Questionnaire generated from koboquest. If NULL (default) function will attempt to detect select multiple questions automatically. If you have made new indicators which use periods in there names you must remove them from the list_of_variables if you do not supply the koboquest generated questionnaire.
#' @return Analyzed table of variables.
#' @export
#'
#'

mean_proportion_table<-function(design,
                                list_of_variables,
                                aggregation_level=NULL,
                                round_to=2,
                                return_confidence=TRUE,
                                na_replace=FALSE,
                                questionnaire=NULL){
  design_srvy<-srvyr::as_survey(design)
  if(is.null(questionnaire)==TRUE){
    select_multiple_in_data<-auto_detect_select_multiple(design$variables)
  }
  if(is.null(questionnaire)==FALSE){
  which_are_select_multiple<-which(
    sapply(names(design_srvy$variables), questionnaire$question_is_select_multiple))
  select_multiple_in_data<-names(which_are_select_multiple)}

  select_multiples_in_list_of_variables<-list_of_variables[which(list_of_variables%in%select_multiple_in_data)]
  if(length(select_multiples_in_list_of_variables)>0){
  select_multiples_in_data_with_dot<-paste0(select_multiple_in_data,".")
  select_multiples_in_given_list_with_dot<-paste0(select_multiples_in_list_of_variables, ".")
  vars_selection_helper <- paste0("^(", paste(select_multiples_in_given_list_with_dot, collapse="|"), ")")
  # vars_selection_helper <- paste0("^(", paste(select_multiples_in_data_with_dot, collapse="|"), ")")
  select_multiple_logical_names<-select(design_srvy$variables, matches(vars_selection_helper)) %>%
    select(-ends_with("_other")) %>% colnames()
  list_of_variables_no_concatenated_select_multiple<-list_of_variables [which(list_of_variables%in%select_multiple_in_data==FALSE)]
  list_of_variables<-c(list_of_variables_no_concatenated_select_multiple,select_multiple_logical_names)
  }
  if(length(select_multiples_in_list_of_variables)==0){
    list_of_variables<-list_of_variables
  }
  if(is.null(questionnaire)==TRUE){
    design_srvy$variables<-design_srvy$variables[,colnames(design_srvy$variables) %in% select_multiple_in_data==FALSE]
    design_srvy$variables<-design_srvy$variables %>%
      mutate_if(sapply(design_srvy$variables, is.character),as.factor)
  }
  if(is.null(questionnaire)==FALSE){
  design_srvy$variables<-butteR::questionnaire_factorize_categorical(design_srvy$variables,questionnaire = questionnaire,return_full_data = TRUE)
  }

  integer_analysis_tables<-list()
  factor_analysis_tables<-list()
  list_of_variables<-setdiff(list_of_variables,aggregation_level)
  for(i in 1: length(list_of_variables)){
    variable_to_analyze<-list_of_variables[i]
    print(variable_to_analyze)
    if(class(design_srvy$variables[[variable_to_analyze]])%in% c("integer", "numeric")){
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
        if(is.null(aggregation_level)) {
          integer_analysis_tables[[i]]<-integers_formatted_for_analysis %>%
            summarise(!!variable_to_analyze:=survey_mean(!!sym(variable_to_analyze),na.rm=TRUE,vartype="ci")) %>%
            select(!!sym(variable_to_analyze))} else {
        integer_analysis_tables[[i]]<-integers_formatted_for_analysis %>%
          summarise(!!variable_to_analyze:=survey_mean(!!sym(variable_to_analyze),na.rm=TRUE,vartype="ci")) %>%
          select(!!!aggregate_by, !!sym(variable_to_analyze))
      }
    }}
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
    integer_analysis_tables_full<-integer_analysis_tables
    # integer_analysis_tables_full<- Filter(function(x) dim(x)[1] > 0, integer_analysis_tables)#integer_analysis_tables[-which(sapply(integer_analysis_tables, is.null))]
    integer_analysis_tables_full<-integer_analysis_tables_full[!sapply(integer_analysis_tables_full, is.null)]
    integers_analyzed_wide<-Reduce(function(x, y) merge(x, y, by =aggregation_level, all = TRUE,sort=FALSE), integer_analysis_tables_full)
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
          select(factors_analyzed_long$question.response) %>%
          select_if(~!all(is.na(.))) %>%
          select(-ends_with(".NA"))
      } else {
        factors_analyzed_wide<-factors_analyzed_long %>%
          mutate(stat_full= paste0(round(mean.stat,round_to),
                                   " (",round(mean.stat_low,round_to),
                                   ", ", round(mean.stat_upp,round_to),
                                   ")")) %>%
          select(!!(aggregation_level), question.response, stat_full) %>% tidyr::spread(question.response,stat_full) %>%
          select({aggregation_level},factors_analyzed_long$question.response) %>%
          select_if(~!all(is.na(.))) %>%
          select(-ends_with(".NA")) %>%
          filter(!is.na(!!sym(aggregation_level[length(aggregation_level)])))
      }}
    if(return_confidence==FALSE){
      if(is.null(aggregation_level)) {
        factors_analyzed_wide<-factors_analyzed_long %>%
          select(question.response, mean.stat) %>% tidyr::spread(question.response,mean.stat) %>%
          select({aggregation_level},factors_analyzed_long$question.response) %>%
          select_if(~!all(is.na(.)))%>%
          select(-ends_with(".NA"))
      } else {
        factors_analyzed_wide<-factors_analyzed_long %>%
          select(aggregation_level, question.response, mean.stat) %>% tidyr::spread(question.response,mean.stat) %>%
          select({aggregation_level},factors_analyzed_long$question.response) %>%
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
    combined_output<-factors_analyzed_wide}
  return(combined_output)
}



