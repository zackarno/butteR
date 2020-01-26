
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
| 91.55454 | 24.00920 | A      |
| 92.66323 | 25.02535 | E      |
| 91.81419 | 21.01008 | C      |
| 90.96015 | 26.06549 | E      |
| 92.33163 | 23.48827 | F      |
| 91.43074 | 25.72843 | F      |

``` r
sample_frame %>% head() %>% knitr::kable()
```

| strata | sample\_size |
| :----- | -----------: |
| A      |           63 |
| B      |           26 |
| C      |           46 |
| D      |           18 |
| E      |           31 |
| F      |           21 |

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
| 1\_A        |    983939 |
| 2\_A        |    983939 |
| 3\_A        |    983939 |
| 4\_A        |    983939 |
| 5\_A        |    983939 |
| 6\_A        |    983939 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_B        |    983939 |
| 2\_B        |    983939 |
| 3\_B        |    983939 |
| 4\_B        |    983939 |
| 5\_B        |    983939 |
| 6\_B        |    983939 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_C        |    983939 |
| 2\_C        |    983939 |
| 3\_C        |    983939 |
| 4\_C        |    983939 |
| 5\_C        |    983939 |
| 6\_C        |    983939 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_D        |    983939 |
| 2\_D        |    983939 |
| 3\_D        |    983939 |
| 4\_D        |    983939 |
| 5\_D        |    983939 |
| 6\_D        |    983939 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_E        |    983939 |
| 2\_E        |    983939 |
| 3\_E        |    983939 |
| 4\_E        |    983939 |
| 5\_E        |    983939 |
| 6\_E        |    983939 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_F        |    983939 |
| 2\_F        |    983939 |
| 3\_F        |    983939 |
| 4\_F        |    983939 |
| 5\_F        |    983939 |
| 6\_F        |    983939 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_G        |    983939 |
| 2\_G        |    983939 |
| 3\_G        |    983939 |
| 4\_G        |    983939 |
| 5\_G        |    983939 |
| 6\_G        |    983939 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_H        |    983939 |
| 2\_H        |    983939 |
| 3\_H        |    983939 |
| 4\_H        |    983939 |
| 5\_H        |    983939 |
| 6\_H        |    983939 |

``` r


sampler_ouput$results$D %>% head()
#>   Description rnd_seed
#> 1         1_D   983939
#> 2         2_D   983939
#> 3         3_D   983939
#> 4         4_D   983939
#> 5         5_D   983939
#> 6         6_D   983939
```

The random\_seed is saved in the list as well as an attribute of each
stratified sample. The random seed is very important for reproducibility
which is quite useful for subsequent rounds of data collection

``` r
sampler_ouput$random_seed 
#> [1] 983939
```

You can also view all of the remaining points which were not not
randomly sampled. You can choose to have these written to a shape file.
It is generally a good back up policy to write these as well.

``` r

sampler_ouput$samp_remaining %>% head() %>% knitr::kable()
```

|      lon |      lat | strata | uuid | rnd\_seed |
| -------: | -------: | :----- | ---: | --------: |
| 91.55454 | 24.00920 | A      |    1 |    983939 |
| 92.66323 | 25.02535 | E      |    2 |    983939 |
| 91.81419 | 21.01008 | C      |    3 |    983939 |
| 90.96015 | 26.06549 | E      |    4 |    983939 |
| 92.33163 | 23.48827 | F      |    5 |    983939 |
| 91.43074 | 25.72843 | F      |    6 |    983939 |

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

| strata |    dist\_m |
| :----- | ---------: |
| H      | 10938.6456 |
| H      | 16596.5112 |
| F      |  1811.1221 |
| H      |  9119.0870 |
| C      |   985.1174 |
| H      | 16024.2736 |
