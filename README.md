<!-- README.md is generated from README.Rmd. Please edit that file -->



# DRob's Advent of Code functions

<!-- badges: start -->
<!-- badges: end -->

Personal R package meant to help me compete in [Advent of Code](https://adventofcode.com/), especially functions for working with data formats common in the puzzles such as grids. This includes:

* An `advent_input` function that reads in a one-column tibble
* Functions for parsing grids (helpful on days 3, 4, 9, and 11 of 2021)

Feel free to use it yourself! Note I don't intend to maintain or support it, but I might add to it as 2021's Advent goes along and I find other patterns that pop up multiple times.

## Installation

You can install the development version of adventdrob like so:

``` r
devtools::install_github("dgrtwo/adventdrob")
```

You'll then have to set ADVENT_SESSION in your .Renviron to your Advent of Code cookie. Example of how to get that in Chrome:

* Visit [adventofcode.com](https://adventofcode.com/), and log in
* Right click + Inspect to view Developer Tools
* Select the Network tab
* Refresh the page, and select the "adventofcode.com" request
* Under Request Headers, there should be a cookie including `session=<cookie here>`. Copy that without the session=.

## Example: 2021 Day 9

[Day 9 of the 2021 puzzle](https://adventofcode.com/2021/day/9) provides a grid of digits. `advent_input()` reads this into a one-column tibble.


```r
library(dplyr)
library(adventdrob)

input <- advent_input(9, 2021)
input
#> # A tibble: 100 × 1
#>    x                                                                   
#>    <chr>                                                               
#>  1 0198765456793498765667899895432323459895457899886789876798656767890…
#>  2 9997654345689987654345998789591014598784345798765678965987543459921…
#>  3 7898543254568998875657895679989125987653236989654567934597654567899…
#>  4 6987654123457899986767894578978939876543125878943478945698875998954…
#>  5 5698743016568996799878923489467894985432014567896567896789989899893…
#>  6 4987652123789785656999434679379993999654623478998878998894598798789…
#>  7 5699543234897654348989645789234989898965434678969989999943987656578…
#>  8 6988994345998743219978956890199878787896545989543296987659876548467…
#>  9 9877789457898754398767897921986867696789659897654345699769987434345…
#> 10 8765678998989766987657889549875456545698998789765456798978964321234…
#> # … with 90 more rows
```

### Part 1

Part 1 tasks us to find the points that are lower than any adjacent point. Excerpts from the puzzle follow.

> Your first goal is to find the low points - the locations that are lower than any of its adjacent locations... (Diagonal locations do not count as adjacent.)

> The risk level of a low point is 1 plus its height.

> Find all of the low points on your heightmap. What is the sum of the risk levels of all low points on your heightmap?

The input can be parsed with `grid_tidy` to create a tidy one-row-per-cell form of row, column and value.


```r
input %>%
  grid_tidy(x)
#> # A tibble: 10,000 × 3
#>      row value   col
#>    <int> <dbl> <int>
#>  1     1     0     1
#>  2     1     1     2
#>  3     1     9     3
#>  4     1     8     4
#>  5     1     7     5
#>  6     1     6     6
#>  7     1     5     7
#>  8     1     4     8
#>  9     1     5     9
#> 10     1     6    10
#> # … with 9,990 more rows
```

We can use `adjacent_join` to join each `row/col` pair with the adjacent `row2/col2` pair.


```r
input %>%
  grid_tidy(x) %>%
  adjacent_join()
#> # A tibble: 39,600 × 6
#>      row value   col  row2  col2 value2
#>    <int> <dbl> <int> <dbl> <dbl>  <dbl>
#>  1     1     0     1     1     2      1
#>  2     1     0     1     2     1      9
#>  3     1     0    67     1    66      9
#>  4     1     0    67     1    68      1
#>  5     1     0    67     2    67      1
#>  6     1     1     2     1     1      0
#>  7     1     1     2     1     3      9
#>  8     1     1     2     2     2      9
#>  9     1     1    68     1    67      0
#> 10     1     1    68     1    69      9
#> # … with 39,590 more rows
```

With a bit of summarizing, we can find all points that are greater than all their neighbors.


```r
input %>%
  grid_tidy(x) %>%
  adjacent_join() %>%
  group_by(row, col, value) %>%
  summarize(low = all(value2 > value), .groups = "drop") %>%
  filter(low) %>%
  summarize(sum(value + 1))
#> # A tibble: 1 × 1
#>   `sum(value + 1)`
#>              <dbl>
#> 1              526
```

### Part 2

For some problems, the best form isn't a tidy table, but a [tidygraph](https://github.com/thomasp85/tidygraph) object.

> A basin is all locations that eventually flow downward to a single low point. Therefore, every low point has a basin, although some basins are very small. Locations of height 9 do not count as being in any basin, and all other locations will always be part of exactly one basin.

> The size of a basin is the number of locations within the basin, including the low point.

> What do you get if you multiply together the sizes of the three largest basins?

This is well suited to finding connected components within a graph. (Many thanks to Jarosław Nirski on the [R for Data Science Slack](https://rfordatascience.slack.com/) for this approach!)


```r
input %>%
  grid_graph(x)
#> # A tbl_graph: 10000 nodes and 19800 edges
#> #
#> # An undirected simple graph with 1 component
#> #
#> # Node Data: 10,000 × 3 (active)
#>     row value   col
#>   <int> <dbl> <int>
#> 1     1     0     1
#> 2     1     1     2
#> 3     1     9     3
#> 4     1     8     4
#> 5     1     7     5
#> 6     1     6     6
#> # … with 9,994 more rows
#> #
#> # Edge Data: 19,800 × 2
#>    from    to
#>   <int> <int>
#> 1     1     2
#> 2     1   101
#> 3     2     3
#> # … with 19,797 more rows
```

As it happens, this lets us answer part 2 in a few lines, thanks to the `group_components()` function in tidygraph.


```r
advent_input(9) %>%
  grid_graph(x) %>%
  filter(value != 9) %>%
  mutate(component = tidygraph::group_components()) %>%
  as_tibble() %>%
  count(component, sort = TRUE) %>%
  head(3) %>%
  summarize(answer = prod(n))
#> # A tibble: 1 × 1
#>    answer
#>     <dbl>
#> 1 1123524
```

