#' Wraps SF st_drop_geometry but retains coordinates as first column in data.frame
#' @param sf_objec simple_feature object
#' @return sf object as data frame with coordinates as first column
#' @export


st_drop_geometry_keep_coords<-function(sf_object){
  coords<-sf::st_coordinates(sf_object)
  df_object<-sf_object %>% st_drop_geometry()
  df_object[,colnames(coords)]<-coords
  df_object<- df_object %>% dplyr::select(colnames(coords), everything())
  return(df_object)
}
