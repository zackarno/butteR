#' check_reported_strata_against_spatial_poly
#'
#' @param dataset data set with coordinates
#' @param strata_poly polygon (converted to sf object) which defines strata (administrative unit, camp boundary, etc.)
#' @param dataset_coordinates columns in dataset with hold longitude latitude in that order. default is c("X_gps_reading_longitude" , "X_gps_reading_latitude")
#' @param dataset_strata_name column name which hold the strata in the datset
#' @param poly_strata_name column which hold the strata in the polygon file
#' @param cols_to_report columns which you want to report along with mismatched strata. default is c("X_uuid","enumerator_id")

#' @return dataframe where strata reported in dataset do not match strata in spatial admin file according to  coordinates in data set
#' @export


check_reported_strata_against_spatial_poly<- function(dataset,
                                                      strata_poly,
                                                      dataset_coordinates=c("X_gps_reading_longitude" , "X_gps_reading_latitude"),
                                                      dataset_strata_name,
                                                      poly_strata_name,
                                                      cols_to_report=c("X_uuid","enumerator_id")){
 dataset[[dataset_strata_name]]<-tolower(dataset[[dataset_strata_name]])
 strata_poly[[poly_strata_name]]<-tolower(strata_poly[[poly_strata_name]])
 
  dataset_sf<-sf::st_as_sf(dataset,coords= dataset_coordinates, crs=4326)
  data_poly_joined<-sf::st_join(dataset_sf, strata_poly)
  strata_that_dont_match_spatial_poly<-data_poly_joined %>%
    st_drop_geometry() %>%
    filter(!!sym(dataset_strata_name)!=!!sym(poly_strata_name)) %>%
    select(cols_to_report,dataset_strata_name, poly_strata_name)
  return(strata_that_dont_match_spatial_poly)


}
