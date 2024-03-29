% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/martys_format_p.r
\name{martys_format_p}
\alias{martys_format_p}
\title{martys_format_p: Formatting p-values}
\usage{
martys_format_p(p)
}
\arguments{
\item{p}{A p-value, which should ideally be of type "double".}
}
\value{
Returns the p-value formatted as a character string according
to specific rules:
\itemize{
\item If p is NA, returns "-".
\item If p is not of type "double", returns p as is.
\item If p < 0.0001, returns "<0.0001".
\item If p > 0.1, returns p rounded to 3 decimal places.
\item Otherwise, returns p rounded to 4 decimal places.
}
}
\description{
This function takes a p-value and formats it based on specific conditions.
The function aims to make p-values easier to interpret and present.
}
\examples{
martys_format_p(0.00009) # should return "<0.0001"
martys_format_p(0.5)     # should return "0.5"
martys_format_p(NA)      # should return "-"

}
