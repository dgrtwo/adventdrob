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

#' Split around commas or another delimiter, and optionally parse into numbers
#'
#' Many Advent of Code challenges have a comma-delimited input. This works on
#' either a string or a table (since some challenges are just a set of
#' comma-delimited numbers)
#'
#' @param s Either a string, or a table with one row
#' @param parse Whether to parse with \code{\text{parse_txt}}
#'
#' @examples
#'
#' # 2021 Days 6 and 7 were both just a comma-delimited vector of numbers
#' advent_input(6) %>%
#'   split_txt()
#'
#' advent_input(7) %>%
#'   split_txt()
#'
#' # So was the first line (though not the rest) of Day 4
#' advent_input(4) %>%
#'   slice(1) %>%
#'   split_txt()
#'
#' @export
split_txt <- function(s, sep = ",", parse = TRUE) {
  if (is.tbl(s)) {
    s <- s[[1]]
  }
  if (length(s) != 1) {
    stop("Expected a character vector of length 1, or table with one row")
  }

  ret <- stringr::str_split(s, sep)[[1]]

  if (parse) {
    ret <- parse_txt(ret)
  }
  ret
}
