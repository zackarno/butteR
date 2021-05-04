#' @name mutate_nearest_feature
#' @rdname mutate_nearest_feature
#' @title mutate_nearest_feature
#' @description convenience wrapper for st_nearest_feature & st_distance
#' @param x sf object to measure by element closest distance to all y features
#' @param y sf object to query against each row feature in x
#' @return x with the distance to the closest feature from y (distance) and its index (y_index) mutated as
#' two columns of the data set
#' @export


mutate_nearest_feature<- function(x, y){
  y_index <- st_nearest_feature(x= x, y= y)
  distance <- st_distance(x= x, y= y[y_index,], by_element=T)
  x %>%
    cbind(y_index= y_index, distance= distance)
}

