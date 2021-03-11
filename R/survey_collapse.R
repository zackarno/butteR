#' @name survey_collapse_binary_long
#' @rdname survey_collapse_binary_long
#' @title Collapse logical binary columns into tidy long format
#'
#' @description `survey_collapse_binary_long()` uses the srvyr [srvyr::survey_mean] & survey package [survey::svymean]   methods
#' to collapse/or aggregate binary logical data. This function can be used on its own, but was build mainly to for its use in [butteR::survey_collapse]
#' which is meant to help batch analyze data
#'
#' @param dfsvy a survey or preferably srvyr object
#' @param x columns to collapse
#' @param disag the columns to collapse/ subset by(analagous to [[dplyr::group_by]] to [[dplyr::summarise]]) flow
#' @param na_val if you want NA replaced by value. By default NA values will be removed prior to aggregation. It is recommended
#' that you do not adjust this value and deal with na values as a separate step
#' @param sm_sep select multiple parent child separator. This is specific for XLSForm data (default = /).

#'  If using read_csv to read in data the separator will most likely be '/' where as if using read.csv it will likely be '.'
#' @return a long format data frame containing the collapsed data.
#'
#'
#' @export


survey_collapse_binary_long<- function(df,
                                       x,
                                       disag=NULL,
                                       na_val=NA_real_,
                                       sm_sep="/" ) {
  if(is.na(na_val)){
    df<- df %>%
      filter(!is.na(x))
  }
  if(!is.na(na_val)){
    df %>%
      mutate(
        !!x:=ifelse(is.na(x), na_val,x)
      )
  }
  if(!is.null(disag)){
    disag_syms<-syms(disag)
    df<-df %>%
      group_by(!!!disag_syms,.drop=F)
  }

  res<-df %>%
    summarise(`mean/pct`=survey_mean(!!sym(x),na.rm=TRUE,vartype="ci")) %>%
    mutate(variable_value=x)

  if(!is.null(disag)){
    class(disag)
    res<-res %>%
      pivot_longer(disag,
                   names_to="subset_name",
                   values_to= "subset_value") %>%
      mutate(subset_value=as.character(subset_value))


  }
  res %>%
    mutate(variable=sub(glue::glue('.[^\\{sm_sep}]*$'), '',
                        variable_value)) %>%
    dplyr::select(any_of(
      c("variable","variable_value","subset_name", "subset_value")
    ),
    everything())


}




#' @name survey_collapse_categorical_long
#' @rdname survey_collapse_categorical_long
#' @title Collapse categorical data into tidy long format
#'
#' @description `survey_collapse_categorical)long()` uses the srvyr [srvyr::survey_mean] & survey package [survey::svyciprop]   methods
#' to collapse/or aggregate cateogrical data. This function can be used on its own, but was build mainly to for its use in [butteR::survey_collapse]
#' which is meant to help batch analyze data
#'
#' @param dfsvy a survey or preferably srvyr object
#' @param x columns to collapse
#' @param disag the columns to collapse/ subset by(analagous to [[dplyr::group_by]] to [[dplyr::summarise]]) flow
#' #' @param na_val if you want NA replaced by value. By default NA values will be removed prior to aggregation. It is recommended
#' that you do not adjust this value and deal with na values as a separate step
#' @param sm_sep select multiple parent child separator. This is specific for XLSForm data (default = /).
#'  If using read_csv to read in data the separator will most likely be '/' where as if using read.csv it will likely be '.'
#' @return a long format data frame containing the collapsed data.
#'
#'
#' @export

survey_collapse_categorical_long<- function(df, x,disag=NULL,na_val=NA_character_) {
  if(is.na(na_val)){
    df<- df %>%
      filter(!is.na(x))
  }
  if(!is.na(na_val)){
    df %>%
      mutate(
        !!x:=ifelse(is.na(x), na_val,x)
      )
  }

  if(!is.null(disag)){
    group_by_vars<-syms(c(x,disag))
  }else{
    group_by_vars<-syms(c(x))
  }

  df<-df %>%
    group_by(!!!group_by_vars,.drop=F)
  ?pivot_longer

  res<-df %>%
    summarise(`mean/pct`=survey_mean(na.rm=TRUE,vartype="ci")) %>%
    mutate(variable=x) %>%
    rename(variable_value=x)

  if(!is.null(disag)){
    # res<-res %>%
    #   rename(subset_name=3,
    #          subset_value=4) %>%
    #   mutate(subset_value=as.character(subset_value))
   res<-res %>%
      pivot_longer(c(disag), names_to= "subset_name",
                   values_to="subset_value")
   }
  res %>%
    select(any_of(c ("variable",
                     "variable_value",
                     "subset_name",
                     "subset_value")),everything())
}

#' @name survey_collapse
#' @rdname survey_collapse
#' @title Batch Collapse Survey Data into tidy long format
#'
#' @description `survey_collapse` uses the srvyr [srvyr::survey_mean] & survey package [survey::svymean]   methods
#' to collapse/or aggregate survey data. This function uses `survey_collapse_categorical_long` and `survey_collapse_binary_long`
#' to perform the batch analysis
#'
#' @param df a survey or preferably srvyr object
#' @param vars_to_analyze columns to collapse
#' @param disag the columns to collapse/ subset by(analagous to [[dplyr::group_by]] to [[dplyr::summarise]]) flow
#' @param na_val if you want NA replaced by value. By default NA values will be removed prior to aggregation. It is recommended
#' that you do not adjust this value and deal with na values as a separate step
#' @param sm_sep select multiple parent child separator. This is specific for XLSForm data (default = /).

#'  If using read_csv to read in data the separator will most likely be '/' where as if using read.csv it will likely be '.'
#' @return a long format data frame containing the collapsed data.
#'
#'
#' @export


survey_collapse<-function(df,
                          vars_to_analyze,
                          disag=NULL,
                          na_val,
                          sm_sep="/"){
  sm_parent_child_all<-auto_sm_parent_child(df$variables)
  sm_parent_child_vars<- sm_parent_child_all %>%
    filter(sm_parent %in% vars_to_analyze)
  not_sm<-vars_to_analyze[!vars_to_analyze %in% sm_parent_child_vars$sm_parent]
  vars_to_analyze<- c(not_sm, sm_parent_child_vars$sm_child)
  res_list<-list()
  for(i in vars_to_analyze){
    print(i)
    if(is.character(df$variables[[i]])|is.factor(df$variables[[i]])){
      res_list[[i]]  <-survey_collapse_categorical_long(df = df,
                                                        x = i,
                                                        disag = disag,
                                                        na_val = NA_character_
      )
    }
    if(is.logical(df$variables[[i]])){
      res_list[[i]]  <-survey_collapse_binary_long(df = df,
                                                   x = i,
                                                   disag = disag,
                                                   na_val = NA_real_,
                                                   sm_sep = sm_sep
      )
    }

  }
  bind_rows(res_list)

}



