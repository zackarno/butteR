#' check distance from target
#' @param dataset dataset
#' @param target_points spatial points to check data set agains
#' @param dataset_coordinates column names for coordinates in dataset
#' @param cols_to_report which columns you want to return with distnace
#' @return simplified dataset with distance to closest target point
#' @export
#'
check_distances_from_target<-function(dataset, target_points, dataset_coordinates, cols_to_report, distance_threshold=25){
  dataset_sf<-sf::st_as_sf(dataset, coords= dataset_coordinates, crs=4326 )
  target_points<- sf::st_transform(target_points, sf::st_crs(dataset_sf))
  dataset_with_closest_target_distance_binded<-closest_distance_rtree(dataset_sf, target_points)
  nrow(dataset_with_closest_target_distance_binded)
  dataset_simplified<-dataset_with_closest_target_distance_binded[,c(cols_to_report, "dist_m")]
  dataset_simplified_with_threshold<-dataset_simplified %>% filter(dist_m > distance_threshold)
  return(dataset_simplified_with_threshold)


}
