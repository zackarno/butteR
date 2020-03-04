
# butteR <img src='man/figures/logo.png' align="right" height="64.5" />

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
when I have shelter footprint data that I want to sample. For now, the
function only reads in point data. Therefore, if the footprint data you
have is polygons it should first be converted to points (centroids).

I believe the most useful/powerful aspect of this function is the
ability to write out well labelled kml/kmz files that can be loaded onto
phone and opened with maps.me or other applications. To use this
function properly it is important that you first familiarize yourself
with some of the theory that underlies random sampling and that you
learn how “seeds” can be used/set in R to make random sampling
reproducible. The function generates random seeds and stores it as a an
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
library(sf)
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
| 88.21260 | 25.12462 | F      |
| 88.38863 | 22.14892 | G      |
| 91.14093 | 23.49458 | H      |
| 89.72288 | 22.25252 | G      |
| 89.90292 | 22.34828 | D      |
| 89.84144 | 23.05792 | B      |

``` r
sample_frame %>% head() %>% knitr::kable()
```

| strata | sample\_size |
| :----- | -----------: |
| A      |           63 |
| B      |           58 |
| C      |           28 |
| D      |           85 |
| E      |           60 |
| F      |           45 |

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

The output is stored in a list of data frames. Each data frame consists
of the sample for one strata. Below I have printed the table of the
first 6 results for strata A,B, and C in our example.

``` r
sampler_ouput$results[1:3] %>% purrr:::map(head) %>% knitr::kable()
```

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_A        |    643039 |   17 |
| 2\_A        |    643039 |   23 |
| 3\_A        |    643039 |   58 |
| 4\_A        |    643039 |   69 |
| 5\_A        |    643039 |   77 |
| 6\_A        |    643039 |   90 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_B        |    643039 |   28 |
| 2\_B        |    643039 |   43 |
| 3\_B        |    643039 |   49 |
| 4\_B        |    643039 |   84 |
| 5\_B        |    643039 |   88 |
| 6\_B        |    643039 |  116 |

| Description | rnd\_seed | uuid |
| :---------- | --------: | ---: |
| 1\_C        |    643039 |   12 |
| 2\_C        |    643039 |   37 |
| 3\_C        |    643039 |   48 |
| 4\_C        |    643039 |   81 |
| 5\_C        |    643039 |  107 |
| 6\_C        |    643039 |  122 |

``` r


sampler_ouput$results$D %>% head()
#>   Description rnd_seed uuid
#> 1         1_D   643039   10
#> 2         2_D   643039   29
#> 3         3_D   643039   33
#> 4         4_D   643039   38
#> 5         5_D   643039   68
#> 6         6_D   643039   71
```

The random\_seed is saved in the list as well as an attribute of each
stratified sample. The random seed is very important to be able to
reproduce you work. This is particularly useful when you need to perform
additional rounds (sometimes unexpected) of sampling for an assessment.

``` r
sampler_ouput$random_seed 
#> [1] 643039
```

The output of the stratified sampler object also stores the remaining
sample as a separate data frame. It is often a good idea to write these
to a shapefile or csv as back up, especially if you are not 100 % sure
how to use the random seeds to reproduce your sampling.

``` r

sampler_ouput$samp_remaining %>% head() %>% knitr::kable()
```

|   |      lon |      lat | strata | uuid | rnd\_seed |
| - | -------: | -------: | :----- | ---: | --------: |
| 2 | 88.38863 | 22.14892 | G      |    2 |    643039 |
| 4 | 89.72288 | 22.25252 | G      |    4 |    643039 |
| 5 | 89.90292 | 22.34828 | D      |    5 |    643039 |
| 6 | 89.84144 | 23.05792 | B      |    6 |    643039 |
| 8 | 90.72916 | 21.23794 | G      |    8 |    643039 |
| 9 | 92.38461 | 22.17366 | A      |    9 |    643039 |

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
indexing so it will work quickly on fairly large data sets.

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

You could easily just filter the “closest\_pts” output by a distance
threshold of your choice. However to make it simpler I have wrapped this
function in the function “check\_distances\_from\_target” (I need to
come up with a better name for this function). It will return all of the
points in from “data set”that are further than the set threshold from
any point in the “target\_points”. It will also show you the distance to
the closest target point. Obviously this is fake data so there are a ton
of points returned (I will just display the first 6 rows). In your
assessment data there should obviously be much less.

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
