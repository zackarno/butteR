#' tolower_rm_special
#'
#' @param string character string
#' @return lower case string all special characters and white space removed
#' @export


tolower_rm_special<-function(string){
  string %>% gsub("[[:punct:]]","",.) %>%
    gsub(" ","",.) %>% trimws() %>%
    tolower() %>% return()
}
