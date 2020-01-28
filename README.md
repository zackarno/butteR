
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
| 90.86124 | 23.61462 | D      |
| 90.92511 | 23.79125 | F      |
| 88.17487 | 25.19714 | G      |
| 89.01608 | 26.33037 | B      |
| 88.79694 | 23.40043 | A      |
| 89.81085 | 22.79984 | H      |

``` r
sample_frame %>% head() %>% knitr::kable()
```

| strata | sample\_size |
| :----- | -----------: |
| A      |           54 |
| B      |           35 |
| C      |           58 |
| D      |           36 |
| E      |           96 |
| F      |           18 |

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
| 1\_A        |    391171 |   13 |
| 2\_A        |    391171 |   18 |
| 3\_A        |    391171 |   33 |
| 4\_A        |    391171 |   37 |
| 5\_A        |    391171 |   38 |
| 6\_A        |    391171 |   43 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_B        |    391171 |   52 |
| 2\_B        |    391171 |   58 |
| 3\_B        |    391171 |  119 |
| 4\_B        |    391171 |  163 |
| 5\_B        |    391171 |  197 |
| 6\_B        |    391171 |  209 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_C        |    391171 |   16 |
| 2\_C        |    391171 |   91 |
| 3\_C        |    391171 |  107 |
| 4\_C        |    391171 |  136 |
| 5\_C        |    391171 |  155 |
| 6\_C        |    391171 |  183 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_D        |    391171 |   31 |
| 2\_D        |    391171 |   62 |
| 3\_D        |    391171 |   63 |
| 4\_D        |    391171 |   71 |
| 5\_D        |    391171 |   73 |
| 6\_D        |    391171 |  128 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_E        |    391171 |   20 |
| 2\_E        |    391171 |   34 |
| 3\_E        |    391171 |   42 |
| 4\_E        |    391171 |   45 |
| 5\_E        |    391171 |   74 |
| 6\_E        |    391171 |   83 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_F        |    391171 |    2 |
| 2\_F        |    391171 |   19 |
| 3\_F        |    391171 |   23 |
| 4\_F        |    391171 |   40 |
| 5\_F        |    391171 |   53 |
| 6\_F        |    391171 |  168 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_G        |    391171 |    3 |
| 2\_G        |    391171 |   17 |
| 3\_G        |    391171 |   27 |
| 4\_G        |    391171 |   49 |
| 5\_G        |    391171 |   64 |
| 6\_G        |    391171 |   81 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_H        |    391171 |  116 |
| 2\_H        |    391171 |  134 |
| 3\_H        |    391171 |  138 |
| 4\_H        |    391171 |  191 |
| 5\_H        |    391171 |  253 |
| 6\_H        |    391171 |  256 |

``` r


sampler_ouput$results$D %>% head()
#>   Description rnd_seed uuid
#> 1         1_D   391171   31
#> 2         2_D   391171   62
#> 3         3_D   391171   63
#> 4         4_D   391171   71
#> 5         5_D   391171   73
#> 6         6_D   391171  128
```

The random\_seed is saved in the list as well as an attribute of each
stratified sample. The random seed is very important for reproducibility
which is quite useful for subsequent rounds of data collection

``` r
sampler_ouput$random_seed 
#> [1] 391171
```

You can also view all of the remaining points which were not not
randomly sampled. You can choose to have these written to a shape file.
It is generally a good back up policy to write these as well.

``` r

sampler_ouput$samp_remaining %>% head() %>% knitr::kable()
```

|   |      lon |      lat | strata | uuid | rnd\_seed |
| - | -------: | -------: | :----- | ---: | --------: |
| 1 | 90.86124 | 23.61462 | D      |    1 |    391171 |
| 4 | 89.01608 | 26.33037 | B      |    4 |    391171 |
| 5 | 88.79694 | 23.40043 | A      |    5 |    391171 |
| 6 | 89.81085 | 22.79984 | H      |    6 |    391171 |
| 7 | 91.63965 | 22.50374 | C      |    7 |    391171 |
| 8 | 88.33723 | 25.06050 | H      |    8 |    391171 |

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

Next I will run the check\_distances\_from\_target function (I need to
come up with a better name for this function). It will return all of the
points in from “dataset”that are further than the set threshold from any
point in the “target\_points”. It will also show you the distance to the
closest target point. Obviously this is fake data so there are a ton of
points returned (I will just display the first 6 rows). In your
assessment dat there should obviously be much less.

This functino uses rtree spatial indexing which is the fastest way I
have found to measure the closest distances between point data
(especially when there are \>1000 points in either data set)

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
| G      |  8879.354 |
| G      | 11714.494 |
| F      | 18069.142 |
| D      |  7706.795 |
| A      | 11031.078 |
| D      | 11532.647 |
