
# butteR

butteR can be used to smooth out the analysis and visualization of
spatial survey data collected using odk. ButteR mainly consists of
convenient wrappers and pipelines for the survey, srvyr, sf, and rtree
packages.

## Installation

You can install the the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("zackarno/butteR")
## Example
```

### Example using the stratified sampler function

The stratified sampler function can be useful if you want to generate
random samples from spatial point data. It has been most useful for me
when I have shelter footparint data that I want to sample. For now, the
function only reads in point data. Therefore, if the footprint data you
have is polygons it should first be converted to points (centroids).

I believe the most useful/powerful aspect of this function is the
ability to write out well labelled kml/kmz files that can be loaded onto
phone and opened with maps.me or other applications. To use this
function properly it is important that you first familiarize yourself
with some of the theory that underlies random sampling and that you
learn how “seeds” can be used/set in R to make random sampling
reproducible. The function generates randome seeds and stores it as a an
attribute field of the spatial sample. There is also the option to write
the seed to the working directory as text file. Understanding how to use
the seeds becomes important if you want to reproduce your results, or if
you need to do subsequent rounds of sampling where you want to exclude
the previous sample without having to read in the previous samples.

``` r
library(butteR)
library(dplyr)
#> Warning: package 'dplyr' was built under R version 3.6.1
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
library(sf)
#> Linking to GEOS 3.6.1, GDAL 2.2.3, PROJ 4.9.3
lon<-runif(min=88.00863,max=92.68031, n=1000)
lat<-runif(min=20.59061,max=26.63451, n=1000)
strata_options<-LETTERS[1:8]

#make a simulated dataset
pt_data<-data.frame(lon=lon, lat=lat, strata=sample(strata_options,1000, replace=TRUE))
sample_frame<-data.frame(strata=strata_options,sample_size=round(runif(10,100,n=8),0))
```

Here are the first six rows of data for the sample frame and data set

``` r
pt_data %>% head() %>% knitr::kable()
```

|      lon |      lat | strata |
| -------: | -------: | :----- |
| 92.25208 | 23.92097 | D      |
| 89.06086 | 25.95947 | G      |
| 91.52140 | 25.04804 | H      |
| 92.20923 | 22.37218 | G      |
| 89.39273 | 23.60435 | E      |
| 89.75321 | 24.15566 | G      |

``` r
sample_frame %>% head() %>% knitr::kable()
```

| strata | sample\_size |
| :----- | -----------: |
| A      |           71 |
| B      |           99 |
| C      |           34 |
| D      |           89 |
| E      |           84 |
| F      |           95 |

Next we will produce the stratified sample. Y

ou can check the function help file by typing ?stratified\_sampler. If
you want the samples writtent to kmz you will need to change write\_kml
to FALSE.

``` r



sampler_ouput<-butteR::stratified_sampler(sample.target.frame = sample_frame, 
                           sample.target.frame.strata = "strata",
                           sample.target.frame.samp.size = "sample_size",pt.data =pt_data,
                           pt.data.strata = "strata",pt.data.labels = "strata" ,write_kml = FALSE,target_gdb = 
                            )
```

The output is stored in a list. Below is the first 6 results of each
stratified sample. The results are stratified sample. They can be viewed
collectively or one at a time.

``` r
sampler_ouput$results %>% purrr:::map(head) %>% knitr::kable()
```

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_A        |     64321 |
| 2\_A        |     64321 |
| 3\_A        |     64321 |
| 4\_A        |     64321 |
| 5\_A        |     64321 |
| 6\_A        |     64321 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_B        |     64321 |
| 2\_B        |     64321 |
| 3\_B        |     64321 |
| 4\_B        |     64321 |
| 5\_B        |     64321 |
| 6\_B        |     64321 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_C        |     64321 |
| 2\_C        |     64321 |
| 3\_C        |     64321 |
| 4\_C        |     64321 |
| 5\_C        |     64321 |
| 6\_C        |     64321 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_D        |     64321 |
| 2\_D        |     64321 |
| 3\_D        |     64321 |
| 4\_D        |     64321 |
| 5\_D        |     64321 |
| 6\_D        |     64321 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_E        |     64321 |
| 2\_E        |     64321 |
| 3\_E        |     64321 |
| 4\_E        |     64321 |
| 5\_E        |     64321 |
| 6\_E        |     64321 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_F        |     64321 |
| 2\_F        |     64321 |
| 3\_F        |     64321 |
| 4\_F        |     64321 |
| 5\_F        |     64321 |
| 6\_F        |     64321 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_G        |     64321 |
| 2\_G        |     64321 |
| 3\_G        |     64321 |
| 4\_G        |     64321 |
| 5\_G        |     64321 |
| 6\_G        |     64321 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_H        |     64321 |
| 2\_H        |     64321 |
| 3\_H        |     64321 |
| 4\_H        |     64321 |
| 5\_H        |     64321 |
| 6\_H        |     64321 |

``` r


sampler_ouput$results$D %>% head()
#>   Description rnd_seed
#> 1         1_D    64321
#> 2         2_D    64321
#> 3         3_D    64321
#> 4         4_D    64321
#> 5         5_D    64321
#> 6         6_D    64321
```

The random\_seed is saved in the list as well as an attribute of each
stratified sample. The random seed is very important for reproducibility
which is quite useful for subsequent rounds of data collection

``` r
sampler_ouput$random_seed 
#> [1] 64321
```

You can also view all of the remaining points which were not not
randomly sampled. You can choose to have these written to a shape file.
It is generally a good back up policy to write these as well.

``` r

sampler_ouput$samp_remaining %>% head() %>% knitr::kable()
```

|      lon |      lat | strata | uuid | rnd\_seed |
| -------: | -------: | :----- | ---: | --------: |
| 92.25208 | 23.92097 | D      |    1 |     64321 |
| 89.06086 | 25.95947 | G      |    2 |     64321 |
| 91.52140 | 25.04804 | H      |    3 |     64321 |
| 92.20923 | 22.37218 | G      |    4 |     64321 |
| 89.39273 | 23.60435 | E      |    5 |     64321 |
| 89.75321 | 24.15566 | G      |    6 |     64321 |

### Example using the check\_distance\_from\_target function

First I will generate 2 fake point data sets. The sf package is great\!

``` r
library(sf)
lon1<-runif(min=88.00863,max=92.68031, n=1000)
lat1<-runif(min=20.59061,max=26.63451, n=1000)
lon2<-runif(min=88.00863,max=92.68031, n=1000)
lat2<-runif(min=20.59061,max=26.63451, n=1000)
strata_options<-LETTERS[1:8]

#make a simulated dataset
pt_data1<-data.frame(lon=lon1, lat=lat1, strata=sample(strata_options,1000, replace=TRUE))
pt_data2<-data.frame(lon=lon2, lat=lat2, strata=sample(strata_options,1000, replace=TRUE))

# convert to simple feature object
coords<- c("lon", "lat")
pt_sf1<- sf::st_as_sf(x = pt_data1, coords=coords, crs=4326)
pt_sf2<- sf::st_as_sf(x = pt_data2, coords=coords, crs=4326)
```

Next I will run the check\_distances from target function. It will
return all of the points in from “dataset”that are further than the set
threshold from any point in the “target\_points”. It will also show you
the distance to the closest target point. Obviously this is fake data so
there are a ton of points returned (I will just display the first 6
rows). In your assessment dat there should obviously be much less.

``` r
pts_further_than_50m_threshold_from_target<-
  butteR::check_distances_from_target(dataset = pt_sf1,target_points =pt_sf2,dataset_coordinates = coords,
                                      cols_to_report = "strata", distance_threshold = 50)
#> Warning in rtree::knn.RTree(rTree = sf2_tree, st_coordinates(sf1)[,
#> c("X", : k was cast to integer, this may lead to unexpected results.


pts_further_than_50m_threshold_from_target %>% head() %>% knitr::kable()
```

| strata |   dist\_m |
| :----- | --------: |
| F      |  3753.087 |
| H      |  6449.405 |
| E      |  4595.515 |
| F      | 16846.980 |
| C      |  8947.927 |
| C      | 11452.614 |
