
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

First I will make a fake data set and sample frame

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
lon<-runif(min=88.00863,max=92.68031, n=100)
lat<-runif(min=20.59061,max=26.63451, n=100)
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
| 92.58735 | 21.42463 | A      |
| 89.01940 | 22.06237 | H      |
| 91.92937 | 22.06339 | B      |
| 91.00606 | 23.08193 | A      |
| 89.78775 | 24.60514 | G      |
| 91.39092 | 23.43422 | D      |

``` r
sample_frame %>% head() %>% knitr::kable()
```

| strata | sample\_size |
| :----- | -----------: |
| A      |           25 |
| B      |           27 |
| C      |           84 |
| D      |           46 |
| E      |           83 |
| F      |           22 |

Next we will produce the stratified sample. Y

ou can check the function help file by typing ?stratified\_sampler. If
you want the samples writtent to kmz you will need to change write\_kml
to FALSE.

``` r
?butteR::stratified_sampler
#> starting httpd help server ... done


sampler_ouput<-butteR::stratified_sampler(sample.target.frame = sample_frame, 
                           sample.target.frame.strata = "strata",
                           sample.target.frame.samp.size = "sample_size",pt.data =pt_data,
                           pt.data.strata = "strata",pt.data.labels = "strata" ,write_kml = FALSE,target_gdb = 
                            )
```

The output is stored in a list. Here we can look at what is returned.
The results are stratified sample. They can be viewed collectively or
one at a time.

``` r
sampler_ouput$results %>% purrr:::map(head) %>% knitr::kable()
```

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_A        |    533179 |
| 2\_A        |    533179 |
| 3\_A        |    533179 |
| 4\_A        |    533179 |
| 5\_A        |    533179 |
| 6\_A        |    533179 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_B        |    533179 |
| 2\_B        |    533179 |
| 3\_B        |    533179 |
| 4\_B        |    533179 |
| 5\_B        |    533179 |
| 6\_B        |    533179 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_C        |    533179 |
| 2\_C        |    533179 |
| 3\_C        |    533179 |
| 4\_C        |    533179 |
| 5\_C        |    533179 |
| 6\_C        |    533179 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_D        |    533179 |
| 2\_D        |    533179 |
| 3\_D        |    533179 |
| 4\_D        |    533179 |
| 5\_D        |    533179 |
| 6\_D        |    533179 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_E        |    533179 |
| 2\_E        |    533179 |
| 3\_E        |    533179 |
| 4\_E        |    533179 |
| 5\_E        |    533179 |
| 6\_E        |    533179 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_F        |    533179 |
| 2\_F        |    533179 |
| 3\_F        |    533179 |
| 4\_F        |    533179 |
| 5\_F        |    533179 |
| 6\_F        |    533179 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_G        |    533179 |
| 2\_G        |    533179 |
| 3\_G        |    533179 |
| 4\_G        |    533179 |
| 5\_G        |    533179 |
| 6\_G        |    533179 |

| Description | rnd\_seed |
| :---------- | --------: |
| 1\_H        |    533179 |
| 2\_H        |    533179 |
| 3\_H        |    533179 |
| 4\_H        |    533179 |
| 5\_H        |    533179 |
| 6\_H        |    533179 |

``` r


sampler_ouput$results$D %>% head()
#>   Description rnd_seed
#> 1         1_D   533179
#> 2         2_D   533179
#> 3         3_D   533179
#> 4         4_D   533179
#> 5         5_D   533179
#> 6         6_D   533179
```

The random\_seed is saved in the list as well as an attribute of each
stratified sample. The random seed is very important for reproducibility
which is quite useful for subsequent rounds of data collection

``` r
sampler_ouput$random_seed 
#> [1] 533179
```

You can also view all of the remaining points which were not not
randomly sampled. You can choose to have these written to a shape file.
It is generally a good back up policy to write these as well.

``` r

sampler_ouput$samp_remaining %>% head() %>% knitr::kable()
```

|      lon |      lat | strata | uuid | rnd\_seed |
| -------: | -------: | :----- | ---: | --------: |
| 92.58735 | 21.42463 | A      |    1 |    533179 |
| 89.01940 | 22.06237 | H      |    2 |    533179 |
| 91.92937 | 22.06339 | B      |    3 |    533179 |
| 91.00606 | 23.08193 | A      |    4 |    533179 |
| 89.78775 | 24.60514 | G      |    5 |    533179 |
| 91.39092 | 23.43422 | D      |    6 |    533179 |
