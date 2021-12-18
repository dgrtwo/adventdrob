#' Given a table representing a grid, join to adjacent cells in the grid
#'
#' @param x A table with columns for row and col
#' @param y A second table with columns row and col. By default, does
#' a self-join
#' @param diagonal Whether diagonal cells are counted as adjacent
#' @param suffix By default, "" and "2"
#'
#' @export
adjacent_join <- function(x, y = x, diagonal = FALSE, suffix = c("", "2")) {
  adj <- tibble(row_delta = c(-1, 1, 0, 0),
                col_delta = c(0, 0, -1, 1))

  if (diagonal) {
    adj <- bind_rows(adj,
                     tibble(row_delta = c(-1, -1, 1, 1),
                            col_delta = c(-1, 1, -1, 1)))
  }

  x %>%
    tidyr::crossing(adj) %>%
    mutate(row2 = row + row_delta,
           col2 = col + col_delta) %>%
    inner_join(y, by = c(row2 = "row", col2 = "col"), suffix = suffix) %>%
    filter(row != row2 | col != col2) %>%
    select(-row_delta, -col_delta)
}

#' Nest a column with adjacent values
#'
#' @param x A table with columns for row and col
#' @param y A second table with columns row and col. By default, does
#' a self-join
#' @param diagonal Whether diagonal cells are counted as adjacent
#'
#' @examples
#'
#' library(purrr)
#' library(dplyr)
#' grid11 <- advent_input(11) %>%
#'   grid_tidy(x)
#'
#' # One "flash": any cells with a value above 9 cause neighbors to increase
#' grid11 %>%
#'   mutate(value = value + 1) %>%
#'   adjacent_nest(diagonal = TRUE) %>%
#'   mutate(value = value + map_dbl(adjacent_value, ~ sum(. > 9)))
#'
#' @export
adjacent_nest <- function(x, y = x, diagonal = FALSE) {
  x %>%
    adjacent_join(y, diagonal = diagonal) %>%
    select(!!!syms(colnames(x)), value2) %>%
    tidyr::nest(adjacent_value = value2) %>%
    mutate(adjacent_value = purrr::map(adjacent_value, 1))
}
