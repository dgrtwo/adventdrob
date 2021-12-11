#' Read in an Advent of Code input as a one-column tibble
#'
#' @param day Day within December
#' @param year By default, 2021
#' @param parse Whether to parse the input using \code{parse} (e.g. as a number)
#'
#' @export
advent_input <- function(day = lubridate::day(Sys.Date()),
                         year = 2021,
                         parse = FALSE) {
  session <- Sys.getenv("ADVENT_SESSION")
  if (session == "") {
    stop("Must set ADVENT_SESSION in .Renviron")
  }

  url <- paste0("https://adventofcode.com/", year, "/day/", day, "/input")

  req <- httr::GET(url,
                   httr::set_cookies(session = session))
  httr::stop_for_status(req)

  txt <- httr::content(req, encoding = "UTF-8")

  lines <- stringr::str_split(txt, "\n")[[1]]
  if (parse) {
    lines <- parse_txt(lines)
  }

  tibble::tibble(x = head(lines, -1))
}
