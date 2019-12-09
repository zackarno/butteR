#' Find closest point between to spatial point objects using rtree spatial indexing
#'
#' @param sf1 simple feature 1 (point)
#' @param sf2 simple feature 2 (point).
#' @param return_distance return the closest point with a vector indicating distance (m). Default = TRUE
#' @return sf1 with closest record from sf2 attached.
#' @export

match_closest_pt_rtree <- function(sf1, sf2, return_distance=TRUE) {
  sf2_tree<- rtree::RTree(st_coordinates(sf2))
  knn1_index<- rtree::knn(rTree=sf2_tree,st_coordinates(sf1),k=1L)
  if(return_distance==TRUE){
    closest_distance<- sf::st_distance(sf1,sf2[unlist(knn1_index),], by_element = TRUE)
    dist_df<-data.frame(sf1,sf2[unlist(knn1_index),],dist_m=as.numeric(closest_distance))

  }
  if(return_distance==FALSE){
    dist_df<-data.frame(sf1, sf2[unlist(knn1_index),])}
  return(dist_df)
}


