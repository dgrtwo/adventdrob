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
#' @examples
#'
#' # 2021 Day 3 Part 1
#' grid_day3 <- advent_input(3) %>%
#'   grid_tidy(x)
#'
#' grid_day3 %>%
#'   group_by(col) %>%
#'   summarize(gamma = round(mean(value)),
#'             epsilon = 1 - gamma) %>%
#'   mutate(power = 2 ^ (rev(col) - 1)) %>%
#'   summarize(gamma = sum(gamma * power),
#'             epsilon = sum(epsilon * power),
#'             answer = gamma * epsilon)
#'
#' # 2021 Day 4 Part 1 (includes a third dimension of "board")
#' input4 <- advent_input(4)
#' grid_day4 <- advent_input(4) %>%
#'   slice(-1) %>%
#'   mutate(board = cumsum(x == "")) %>%
#'   filter(x != "") %>%
#'   grid_tidy(x, sep = " +")
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

  do.call(rbind, ret)
}

#' @rdname grid_tidy
#'
#' @param directed Passed on to \code{\link[tidygraph]{create_lattice}}
#' @param mutual Passed on to \code{\link[tidygraph]{create_lattice}}
#' @param circular Passed on to \code{\link[tidygraph]{create_lattice}}
#'
#' @export
grid_graph <- function(d,
                       ...,
                       directed = FALSE,
                       mutual = FALSE,
                       circular = FALSE) {
  td <- grid_tidy(d, ...)
  dimensions <- c(max(td$row), max(td$col))

  tidygraph::create_lattice(dimensions,
                            directed = directed,
                            mutual = mutual,
                            circular = circular) %>%
    mutate(!!!td)
}

#' @export
grid_print <- function(x, ...) UseMethod("grid_print")

#' @export
grid_print.tbl_df <- function(x, sep = "", ...) {
  ret <- x %>%
    arrange(row, col) %>%
    group_by(row) %>%
    summarize(value = paste0(value, collapse = sep))

  cat(ret$value, sep = "\n")
}

#' @export
grid_print.tbl_graph <- function(x, sep = "", ...) {
  x %>%
    as_tibble("nodes") %>%
    grid_print()
}

#' @export
grid_print.matrix <- function(x, sep = "", ...) {
  apply(x, 1, paste0, collapse = sep) %>%
    cat(sep = "\n")
}

#' @export
grid_plot <- function(x, ...) UseMethod("grid_plot")

#' @export
grid_plot.tbl_df <- function(x, ...) {
  x %>%
    ggplot2::ggplot(aes(col, row)) +
    ggplot2::geom_text(aes(label = value)) +
    ggplot2::scale_y_reverse()
}
