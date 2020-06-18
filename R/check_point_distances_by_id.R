#' check distances between points by id
#' @param sf1 sf class point class object 1
#' @param sf2 sf class point class object 2
#' @param sf1_id sf1_id that links to sf_2
#' @param sf2_id sf2_id that links to sf_1
#' @param dist_threshold distance threshold to check
#' @return 1.) dataset with distance column mutated, 2.) a leaflet map, 3.) histogram of distances
#' @import dplyr tidyr leaflet ggplot2 sf
#' @export


check_point_distance_by_id<- function(sf1, sf2, sf1_id, sf2_id, dist_threshold){
  outputs<-list()
  sf1<- sf1 %>%
    butteR::st_drop_geometry_keep_coords() %>%
    rename(sf1_X="X",
           sf1_Y="Y")
  sf2<- sf2 %>%
    butteR::st_drop_geometry_keep_coords() %>%
    rename(sf2_X="X",
           sf2_Y="Y") %>%
    select(sf2_id, sf2_X, sf2_Y)

  sf_joined<-sf1 %>%
    left_join(sf2, by=setNames(sf2_id,sf1_id))

  sf_joined_gathered<-sf_joined %>%
    unite(start,sf1_X,sf1_Y) %>%
    unite(end, sf2_X, sf2_Y)%>%
    gather(start_end, coords, start, end) %>%
    separate(coords, c("LONG", "LAT"), sep = "_") %>%
    mutate_at(vars(LONG, LAT), as.numeric) %>%
    st_as_sf(coords = c("LONG", "LAT"),na.fail=FALSE) %>%
    group_by(!!sym(sf1_id)) %>%
    summarise(ids=unique(!!sym(sf1_id)))

  sf_lines<-sf_joined_gathered %>%
    filter(st_geometry_type(sf_joined_gathered)!="POINT") %>%
    st_cast("LINESTRING")

  sf_lines<-sf::st_set_crs(sf_lines, value = 4326) %>%
    ungroup() %>%
    mutate(
      dist_m= st_length(.) %>%
        as.numeric(),
      threshold= ifelse(dist_m<= dist_threshold,
                         paste0("dist <= ", dist_threshold),
                         paste0("dist > ", dist_threshold)),
      color_line= ifelse(dist_m<=dist_threshold, "blue","red"),
      popup_text =paste0('<strong>','Point ID: ', sf_lines[[sf1_id]], '</strong>',  ' ') %>%
        lapply(htmltools::HTML)
      )



  outputs$map<- leaflet::leaflet(sf_lines) %>%
    addTiles() %>%
    addPolylines(color=~color_line, label=~popup_text)

  outputs$hist<- ggplot2::ggplot(sf_lines,aes(x=dist_m))+geom_histogram()

  outputs$dataset<-sf_lines
  return(outputs)

}

