#' Parse an input that may be a number
#'
#' Uses \code{\link[readr]{parse_guess}}, but ignores commas (commas in
#' Advent of Code are almost always delimiters)
#'
#' @param s A character vector
#' @param ... Extra arguments passed on to parse_guess
parse_txt <- function(s, ...) {
  readr::parse_guess(s, locale = readr::locale("en", grouping_mark = ""))
}
