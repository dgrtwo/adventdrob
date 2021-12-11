#' Given a table representing a grid, join to adjacent cells in the grid
#'
#' @param x A table with columns for row and col
#' @param y A second table with columns row and col. By default, does
#' a self-join
#' @param diagonal Whether diagonal cells are counted as adjacent
#' @param suffix By default, "" and "2"
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
