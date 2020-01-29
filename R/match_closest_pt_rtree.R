#' Find closest point between to spatial point objects using rtree spatial indexing
#'
#' @param sf1 simple feature 1 (point)
#' @param sf2 simple feature 2 (point).
#' @param return_distance return the closest point with a vector indicating distance (m). Default = TRUE
#' @return sf1 with closest record from sf2 attached.
#' @export
#' @importFrom rtree Rtree knn knn.Rtree
#' @importFrom sf st_distance

match_closest_pt_rtree <- function(sf1, sf2, return_distance=TRUE, k=1) {
  sf2_tree<- rtree::RTree(st_coordinates(sf2))
  knn1_index<- rtree::knn(rTree=sf2_tree,st_coordinates(sf1),k=1)
  if(return_distance==TRUE){
    closest_distance<- sf::st_distance(sf1,sf2[unlist(knn1_index),], by_element = TRUE)
    dist_df<-data.frame(sf1,sf2[unlist(knn1_index),],dist_m=as.numeric(closest_distance))

  }
  if(return_distance==FALSE){
    dist_df<-data.frame(sf1, sf2[unlist(knn1_index),])}
  return(dist_df)}

#' closest_distance_rtree
#' @param sf1 simple feature 1 (point)
#' @param sf2 simple feature 2 (point).
#' @return sf1 with closest record from sf2 attached.
#' @export
#' @importFrom rtree Rtree knn knn.Rtree
#' @importFrom sf st_distance


closest_distance_rtree<-function(sf1, sf2, k=1,sf1_coords=c("X","Y")) {
  sf2_tree<- rtree::RTree(st_coordinates(sf2)[,c("X", "Y")])
  knn1_index<-rtree::knn.RTree(rTree=sf2_tree,st_coordinates(sf1)[,c("X", "Y")], k=1)
  closest_distance<- sf::st_distance(sf1,sf2[unlist(knn1_index),], by_element = TRUE)
  dist_df<-data.frame(sf1,sf2[unlist(knn1_index),],dist_m=as.numeric(closest_distance))
  return(dist_df)
}

