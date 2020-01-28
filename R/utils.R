#' Remove grouper added to kobo dataset when downloaded
#'
#' @param colname colname vector
#' @return colname vector without grouper
#' @export



remove_kobo_grouper<-function(colname){
  sub(".*?\\.", '', colname)
}
