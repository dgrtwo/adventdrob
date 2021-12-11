#' Parse a table with a string column that represents rows in a grid
#'
#' Many Advent of Code challenges involve parsing a grid where each row
#' of the input represents one row of the grid. These turn such inputs into
#' a tidy table, a matrix, or a tidygraph object.
#'
#' @param d A table
#' @param var The name of a string column
#' @param sep A string separator to use for splitting columns
#' @param parse Whether to parse the input by guessing its format
#' @param ... Any of the above arguments
#'
#' @import dplyr
#'
#' @export
grid_tidy <- function(d, var, sep = "", parse = TRUE) {
  ret <- d %>%
    mutate(row = row_number()) %>%
    mutate(value = stringr::str_split({{ var }}, sep)) %>%
    select(-{{ var }}) %>%
    tidyr::unnest(value) %>%
    group_by(row) %>%
    mutate(col = row_number()) %>%
    ungroup()

  if (parse) {
    ret <- ret %>%
      mutate(value = parse_txt(value))
  }

  ret
}

#' @rdname grid_tidy
#' @export
grid_matrix <- function(d, var, sep = "", parse = TRUE) {
  ret <- d %>%
    pull({{ var }}) %>%
    stringr::str_split(sep)

  if (parse) {
    ret <- purrr::map(ret, parse_txt)
  }

  do.call(rbind, .)
}

#' @rdname grid_tidy
#' @export
grid_graph <- function(d, ...) {
  td <- grid_tidy(d, ...)
  dimensions <- c(max(td$row), max(td$col))

  tidygraph::create_lattice(dimensions) %>%
    mutate(!!!td)
}
