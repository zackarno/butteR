#' check distance from target
#' @param dataset an sf dataset
#' @param target_points spatial points to check dataset agains
#' @param cols_to_report which columns you want to return with distnace
#' @return simplified dataset with distance to closest target point

#' @importFrom sf st_join

#' @export

check_distances_from_target<-function(dataset_sf, target_points, cols_to_report, distance_threshold=25){
  dataset_with_closest_target_distance_binded<-closest_distance_rtree(dataset_sf, target_points)
  nrow(dataset_with_closest_target_distance_binded)
  dataset_simplified<-dataset_with_closest_target_distance_binded[,c(cols_to_report, "dist_m")]
  dataset_simplified_with_threshold<-dataset_simplified %>% filter(dist_m > distance_threshold)
  return(dataset_simplified_with_threshold)
}
