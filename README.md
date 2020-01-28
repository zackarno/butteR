
# butteR

butteR can be used to smooth out the analysis and visualization of
spatial survey data collected using mobile data collection systems
(ODK/XLSform). ButteR mainly consists of convenient wrappers and
pipelines for the survey, srvyr, sf, and rtree packages.

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

To show how the function can be used I will first simulate a spatial
data set and sample frame

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

#simulate datasets
pt_data<-data.frame(lon=lon, lat=lat, strata=sample(strata_options,1000, replace=TRUE))
sample_frame<-data.frame(strata=strata_options,sample_size=round(runif(10,100,n=8),0))
```

Here are the first six rows of data for the sample frame and data set

``` r
pt_data %>% head() %>% knitr::kable()
```

|      lon |      lat | strata |
| -------: | -------: | :----- |
| 89.07169 | 22.08302 | D      |
| 89.06120 | 25.62130 | H      |
| 88.52233 | 22.98088 | C      |
| 88.30561 | 21.55179 | D      |
| 91.73863 | 24.36058 | A      |
| 90.53446 | 24.72056 | D      |

``` r
sample_frame %>% head() %>% knitr::kable()
```

| strata | sample\_size |
| :----- | -----------: |
| A      |           46 |
| B      |           77 |
| C      |           25 |
| D      |           98 |
| E      |           47 |
| F      |           36 |

Next we will run the stratified\_sampler function using the two
simulated data sets as input.

You can check the function help file by typing ?stratified\_sampler.
There are quite a few parameters to set particularly if you want to
write out the kml file. Therefore, it is important to read the functions
documentation (it will be worth it).

``` r



sampler_ouput<-butteR::stratified_sampler(sample.target.frame = sample_frame, 
                           sample.target.frame.strata = "strata",
                           sample.target.frame.samp.size = "sample_size",pt.data =pt_data,
                           pt.data.strata = "strata",pt.data.labels = "strata" ,write_kml = FALSE 
                            )
```

The output is stored in a list. Below is the first 6 results of each
stratified sample. The results are stratified sample. They can be viewed
collectively or one at a time.

``` r
sampler_ouput$results %>% purrr:::map(head) %>% knitr::kable()
```

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_A        |    467273 |   42 |
| 2\_A        |    467273 |   47 |
| 3\_A        |    467273 |   48 |
| 4\_A        |    467273 |   74 |
| 5\_A        |    467273 |   92 |
| 6\_A        |    467273 |  105 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_B        |    467273 |   13 |
| 2\_B        |    467273 |   18 |
| 3\_B        |    467273 |   31 |
| 4\_B        |    467273 |   35 |
| 5\_B        |    467273 |   37 |
| 6\_B        |    467273 |   57 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_C        |    467273 |   16 |
| 2\_C        |    467273 |  112 |
| 3\_C        |    467273 |  123 |
| 4\_C        |    467273 |  139 |
| 5\_C        |    467273 |  151 |
| 6\_C        |    467273 |  170 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_D        |    467273 |    4 |
| 2\_D        |    467273 |    6 |
| 3\_D        |    467273 |    8 |
| 4\_D        |    467273 |   17 |
| 5\_D        |    467273 |   24 |
| 6\_D        |    467273 |   27 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_E        |    467273 |    7 |
| 2\_E        |    467273 |   14 |
| 3\_E        |    467273 |   34 |
| 4\_E        |    467273 |   45 |
| 5\_E        |    467273 |   53 |
| 6\_E        |    467273 |   75 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_F        |    467273 |    9 |
| 2\_F        |    467273 |   25 |
| 3\_F        |    467273 |   36 |
| 4\_F        |    467273 |   63 |
| 5\_F        |    467273 |   95 |
| 6\_F        |    467273 |  127 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_G        |    467273 |   19 |
| 2\_G        |    467273 |   46 |
| 3\_G        |    467273 |   65 |
| 4\_G        |    467273 |  110 |
| 5\_G        |    467273 |  152 |
| 6\_G        |    467273 |  161 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_H        |    467273 |   64 |
| 2\_H        |    467273 |  109 |
| 3\_H        |    467273 |  177 |
| 4\_H        |    467273 |  215 |
| 5\_H        |    467273 |  247 |
| 6\_H        |    467273 |  249 |

``` r


sampler_ouput$results$D %>% head()
#>   Description rnd_seed uuid
#> 1         1_D   467273    4
#> 2         2_D   467273    6
#> 3         3_D   467273    8
#> 4         4_D   467273   17
#> 5         5_D   467273   24
#> 6         6_D   467273   27
```

The random\_seed is saved in the list as well as an attribute of each
stratified sample. The random seed is very important for reproducibility
which is quite useful for subsequent rounds of data collection

``` r
sampler_ouput$random_seed 
#> [1] 467273
```

You can also view all of the remaining points which were not not
randomly sampled. You can choose to have these written to a shape file.
It is generally a good back up policy to write these as well.

``` r

sampler_ouput$samp_remaining %>% head() %>% knitr::kable()
```

|    |      lon |      lat | strata | uuid | rnd\_seed |
| -- | -------: | -------: | :----- | ---: | --------: |
| 1  | 89.07169 | 22.08302 | D      |    1 |    467273 |
| 2  | 89.06120 | 25.62130 | H      |    2 |    467273 |
| 3  | 88.52233 | 22.98088 | C      |    3 |    467273 |
| 5  | 91.73863 | 24.36058 | A      |    5 |    467273 |
| 10 | 89.53481 | 24.18118 | E      |   10 |    467273 |
| 11 | 92.59282 | 23.82064 | F      |   11 |    467273 |

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

Next I will show two spatial verification functions. The first one just
finds the closest distance between points. It uses rTree spatial
indexing so it will work quickly on fairly large datasets.

``` r

closest_pts<- butteR::closest_distance_rtree(pt_sf1, pt_sf2)
#> Warning in rtree::knn.RTree(rTree = sf2_tree, st_coordinates(sf1)[,
#> c("X", : k was cast to integer, this may lead to unexpected results.

closest_pts %>% head() %>% knitr::kable()
```

|     | strata | geometry                              | strata.1 | geometry.1                            |   dist\_m |
| --- | :----- | :------------------------------------ | :------- | :------------------------------------ | --------: |
| 564 | A      | c(91.0945985394406, 25.3172077776298) | C        | c(91.0900734983338, 25.1887870116862) | 14233.327 |
| 348 | G      | c(89.7918454457294, 24.3022634395345) | E        | c(89.7715653696236, 24.3359070868734) |  4257.184 |
| 531 | H      | c(89.5891668225688, 24.2547000117762) | A        | c(89.5680460236584, 24.2121935684295) |  5173.765 |
| 844 | A      | c(89.8610885371115, 21.597871026245)  | A        | c(89.8879964168891, 21.6249470741691) |  4092.699 |
| 865 | G      | c(89.0837166745749, 24.4763565831415) | F        | c(89.0265504835223, 24.3371435037359) | 16473.960 |
| 438 | A      | c(88.2813882996975, 21.0588082609256) | H        | c(88.3817752257694, 21.0861426773399) | 10862.340 |

You could easily just filter the “closest\_pts” ouput by a distance
threshold of your choice. However to make it simpler I have wrapped this
function in the function “check\_distances\_from\_target” (I need to
come up with a better name for this function). It will return all of the
points in from “dataset”that are further than the set threshold from any
point in the “target\_points”. It will also show you the distance to the
closest target point. Obviously this is fake data so there are a ton of
points returned (I will just display the first 6 rows). In your
assessment dat there should obviously be much less.

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
| A      | 14233.327 |
| G      |  4257.184 |
| H      |  5173.765 |
| A      |  4092.699 |
| G      | 16473.960 |
| A      | 10862.340 |
