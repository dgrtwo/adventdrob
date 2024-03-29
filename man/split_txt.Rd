% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{split_txt}
\alias{split_txt}
\title{Split around commas or another delimiter, and optionally parse into numbers}
\usage{
split_txt(s, sep = ",", parse = TRUE)
}
\arguments{
\item{s}{Either a string, or a table with one row}

\item{parse}{Whether to parse with \code{\text{parse_txt}}}
}
\description{
Many Advent of Code challenges have a comma-delimited input. This works on
either a string or a table (since some challenges are just a set of
comma-delimited numbers)
}
\examples{

# 2021 Days 6 and 7 were both just a comma-delimited vector of numbers
advent_input(6) \%>\%
  split_txt()

advent_input(7) \%>\%
  split_txt()

# So was the first line (though not the rest) of Day 4
advent_input(4) \%>\%
  slice(1) \%>\%
  split_txt()

}
