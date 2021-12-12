#' Hexagonal directions in a 3d grid
#'
#' Either oriented facing north/south or east/west
#'
#' @seealso \url{https://www.redblobgames.com/grids/hexagons/}
#' @export
HEX_DIRECTIONS <- tibble::tribble(
  ~ step, ~ step_alt, ~ x_delta, ~ y_delta, ~ z_delta,
  "n", "nw", 1, -1, 0,
  "ne", "ne", 0, -1, 1,
  "se", "e", -1, 0, 1,
  "s", "se", -1, 1, 0,
  "sw", "sw", 0, 1, -1,
  "nw", "w", 1, 0, -1
)
