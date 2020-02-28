
# butteR <img src='man/figures/logo.png' align="right" height="59.5" />

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
| 89.63140 | 20.96635 | F      |
| 92.61636 | 20.92706 | G      |
| 92.09004 | 25.28020 | F      |
| 89.60495 | 26.26237 | G      |
| 90.20565 | 26.04534 | F      |
| 88.49658 | 24.29715 | A      |

``` r
sample_frame %>% head() %>% knitr::kable()
```

| strata | sample\_size |
| :----- | -----------: |
| A      |           27 |
| B      |           44 |
| C      |           32 |
| D      |           14 |
| E      |           58 |
| F      |           63 |

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
| 1\_A        |    275408 |    6 |
| 2\_A        |    275408 |   14 |
| 3\_A        |    275408 |  118 |
| 4\_A        |    275408 |  144 |
| 5\_A        |    275408 |  160 |
| 6\_A        |    275408 |  163 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_B        |    275408 |   23 |
| 2\_B        |    275408 |   30 |
| 3\_B        |    275408 |   35 |
| 4\_B        |    275408 |   49 |
| 5\_B        |    275408 |   61 |
| 6\_B        |    275408 |  111 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_C        |    275408 |   12 |
| 2\_C        |    275408 |   48 |
| 3\_C        |    275408 |   69 |
| 4\_C        |    275408 |   92 |
| 5\_C        |    275408 |   97 |
| 6\_C        |    275408 |  115 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_D        |    275408 |   77 |
| 2\_D        |    275408 |   81 |
| 3\_D        |    275408 |  109 |
| 4\_D        |    275408 |  140 |
| 5\_D        |    275408 |  193 |
| 6\_D        |    275408 |  264 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_E        |    275408 |    7 |
| 2\_E        |    275408 |   13 |
| 3\_E        |    275408 |   15 |
| 4\_E        |    275408 |   20 |
| 5\_E        |    275408 |   45 |
| 6\_E        |    275408 |   60 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_F        |    275408 |   28 |
| 2\_F        |    275408 |   52 |
| 3\_F        |    275408 |   53 |
| 4\_F        |    275408 |   59 |
| 5\_F        |    275408 |   66 |
| 6\_F        |    275408 |   68 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_G        |    275408 |  126 |
| 2\_G        |    275408 |  129 |
| 3\_G        |    275408 |  175 |
| 4\_G        |    275408 |  208 |
| 5\_G        |    275408 |  223 |
| 6\_G        |    275408 |  295 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_H        |    275408 |    9 |
| 2\_H        |    275408 |   17 |
| 3\_H        |    275408 |   18 |
| 4\_H        |    275408 |   26 |
| 5\_H        |    275408 |   27 |
| 6\_H        |    275408 |   34 |

``` r


sampler_ouput$results$D %>% head()
#>   Description rnd_seed uuid
#> 1         1_D   275408   77
#> 2         2_D   275408   81
#> 3         3_D   275408  109
#> 4         4_D   275408  140
#> 5         5_D   275408  193
#> 6         6_D   275408  264
```

The random\_seed is saved in the list as well as an attribute of each
stratified sample. The random seed is very important for reproducibility
which is quite useful for subsequent rounds of data collection

``` r
sampler_ouput$random_seed 
#> [1] 275408
```

You can also view all of the remaining points which were not not
randomly sampled. You can choose to have these written to a shape file.
It is generally a good back up policy to write these as well.

``` r

sampler_ouput$samp_remaining %>% head() %>% knitr::kable()
```

|   |      lon |      lat | strata | uuid | rnd\_seed |
| - | -------: | -------: | :----- | ---: | --------: |
| 1 | 89.63140 | 20.96635 | F      |    1 |    275408 |
| 2 | 92.61636 | 20.92706 | G      |    2 |    275408 |
| 3 | 92.09004 | 25.28020 | F      |    3 |    275408 |
| 4 | 89.60495 | 26.26237 | G      |    4 |    275408 |
| 5 | 90.20565 | 26.04534 | F      |    5 |    275408 |
| 8 | 92.30576 | 25.65555 | C      |    8 |    275408 |

### Example using the check\_distance\_from\_target function

First I will generate 2 fake point data sets. The sf package is great\!

``` r
library(sf)

set.seed(799)
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
| 755 | C      | c(88.5246591396806, 26.0766159565661) | H        | c(88.542828683707, 25.8766529368377)  | 22228.020 |
| 798 | C      | c(91.3460825806255, 22.3494960887145) | F        | c(91.3754625593381, 22.3643193468922) |  3442.702 |
| 464 | C      | c(91.6884048353551, 26.0950136747809) | B        | c(91.6959527733822, 26.0490176807472) |  5151.514 |
| 902 | B      | c(88.782772209299, 22.2289078448025)  | C        | c(88.812609722456, 22.2312796777867)  |  3087.283 |
| 199 | B      | c(91.9385484030803, 22.9929798167442) | A        | c(92.0439420932042, 22.9314622797974) | 12776.161 |
| 419 | D      | c(88.6396377435045, 22.2862520419468) | C        | c(88.7253538271838, 22.3836231110146) | 13936.767 |

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


set.seed(799)
pts_further_than_50m_threshold_from_target<-
  butteR::check_distances_from_target(dataset = pt_sf1,target_points =pt_sf2,dataset_coordinates = coords,
                                      cols_to_report = "strata", distance_threshold = 50)
#> Warning in rtree::knn.RTree(rTree = sf2_tree, st_coordinates(sf1)[,
#> c("X", : k was cast to integer, this may lead to unexpected results.


pts_further_than_50m_threshold_from_target %>% head() %>% knitr::kable()
```

| strata |   dist\_m |
| :----- | --------: |
| C      | 22228.020 |
| C      |  3442.702 |
| C      |  5151.514 |
| B      |  3087.283 |
| B      | 12776.161 |
| D      | 13936.767 |
