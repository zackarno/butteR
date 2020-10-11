#' Check variation by: check the variation of all columns by grouping var (specifically designed for the grouping var to be the data collectors identifier). Variation results are checked with resepect to standard deviations of them mean and a plot is produced to help understand issues.
#' @param df data frame
#' @param by What you want to check by (designed specifically with enumerator in mind)
#' @param zscore_threshold How many standard deviations to consider outlier (default 3)
#' @return ggplot bar graph showing top problematic groups (enumerators), table of issues
#' @export




check_variation_by<-function(df, by="enumerator_id",zscore_threshold=3){
  options(dplyr.summarise.inform = FALSE)
  output_list<-list()
  by<-rlang::arg_match(by)

  crayon::green(cat("removing columns that only have one unique column value"))
  cols_to_assess<- df %>%
    summarise(across(everything(),n_distinct)) %>%
    pivot_longer(everything()) %>%
    filter(value!=1) %>%
    pull(name)

  crayon::green(cat("removing records where enumerator has less than 5 valid entries"))
  enum_survey_count<- df %>%
    count(.data[[by]]) %>%
    filter(n>5)

  df<- df %>% select(cols_to_assess) %>%
    filter(.data[[by]] %in% enum_survey_count[[by]])


  enum_n_distinct<-df %>%
    group_by(.data[[by]]) %>%
    summarise(across(everything(),n_distinct))

  enum_n_distinct_long<-enum_n_distinct %>%
    pivot_longer(-by, values_to="n_dist")

  sd_upp_long<- enum_n_distinct %>%
    summarise(across(everything(),~mean(.x,na.rm=T)+(sd(.x,na.rm=T)*zscore_threshold)
    )
    )  %>%
    select(-by) %>%
    pivot_longer(everything(),values_to="sd_upp")

  sd_low_long<-enum_n_distinct %>%
    summarise(across(everything(),~mean(.x,na.rm=T)-(sd(.x,na.rm=T)*zscore_threshold)
    )
    ) %>%
    select(-by) %>%
    pivot_longer(everything(),values_to="sd_low")
  mean_long<-enum_n_distinct %>%
    summarise(across(everything(),~mean(.x,na.rm=T))) %>%
    select(-by) %>%
    pivot_longer(everything(),values_to="mean")

  qstats<-suppressMessages(reduce(list(enum_n_distinct_long,mean_long,sd_upp_long,sd_low_long),left_join) )

  outlier_table<-qstats %>%
    mutate(issue=case_when(n_dist>sd_upp~"high outlier",
                           n_dist<sd_low~"low outlier",
                           TRUE~ "not outlier"
    )) %>%
    filter(issue !="not outlier")
  low_outliers<-outlier_table %>%
    filter(issue=="low outlier")
  low_outliers_summary<-low_outliers %>% count(!!sym(by)) %>% arrange(desc(n)) %>%
    mutate(cum_percent= cumsum(n)/sum(n))
  top3_percent<-low_outliers_summary %>% slice(3) %>% pull(cum_percent) %>% round(2)*100

  crayon::green(cat(glue::glue("appoximately {top3_percent} percent of issues are cause by 3 individuals")))
  plot_output<-low_outliers %>%
    count(.data[[by]]) %>%
    ggplot(aes(x=reorder(.data[[by]],-n),n))+geom_bar(stat="identity")+
    labs(x=by, y="Number of occurences")+
    ggtitle(label = "# of times an answer had less variation than 3 standard deviations\n below the mean by enumerator")+
    theme_bw()+
    theme(axis.text = element_text(angle=90))

  output_list$plot<- plot_output
  output_list$table<- low_outliers_summary
  return(output_list)
}
