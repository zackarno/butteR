stratified_sampler<-function(spatial_data, sampling_frame){
  if(class(spatial_data$geometry)[1]%in% c( "sfc_MULTIPOLYGON", "other polygon sp package")){
    spatial_data<-sf::st_centroid(spatial_data)
    # sf::st_sample(x = spatial_data, size = 10,type = "random")
  }
  spatial_data
}

?sf::st_centroid
asdf<-stratified_sampler(spatial_data)
class(asdf)
asdf$cmp_name
library(dplyr)
asdf %>% group_by(cmp_name) %>%
  sf::st_sample(size = 20)
asdf$cmp_name

# education_lsg<-as.integer(c(1,2,5))
# education_lsg<-education_lsg %>% as.factor()
#
# factorerror <- function(name) {
#   paste(name, "must not be a factor. Use as.numeric() to convert _factor level indexes_ to numbers; use as.numeric(as.character()) to convert factors with numbers as labels ")
# }
# assertthat::assert_that(!is.factor(education_lsg), msg = factorerror("education_lsg"))
# spatial_data<-sf::st_read(dsn = "C:/01_REACH_BGD/02_GIS_DataUnit/01_GIS_BASE_Data/02_landscape/01_infrastructure/01_shelter_footprint/03_unosat_footprints",
#             layer="BGD_Camp_ShelterFootprint_UNOSAT_REACH_v1_07may2019")
# library(dplyr)
# spatial_data$geometry %>% class() %>% length()
#
# asdf<-function(spatial_data){
#   class_data<-class(spatial_data)
#   if(class_data %in% c("sf", "data.frame")==FALSE)
#     stop("spatial_data needs to be in spatial format (sf, sp)")
#   else{(print(head(spatial_data)))
# }}
# asdf(spatial_data)
# assertthat::assert_that(!is.factor(education_lsg), msg = factorerror(education_lsg))
# assertthat::assert_that(!is.factor(fsl_lsg), msg = factorerror(fsl_lsg))
# assertthat::assert_that(!is.factor(health_lsg), msg = factorerror(health_lsg))
# assertthat::assert_that(!is.factor(protection_lsg), msg = factorerror(protection_lsg))
# assertthat::assert_that(!is.factor(shelter_lsg), msg = factorerror(shelter_lsg))
# assertthat::assert_that(!is.factor(wash_lsg), msg = factorerror(wash_lsg))
# assertthat::assert_that(!is.factor(capacity_gaps), msg = factorerror(capacity_gaps))
#
# class(spatial_data)= c("sf")
# library(sf)
# sf::st_read
# methods(sf::st_read(spatial_data))
