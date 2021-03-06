% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/apply_core.R
\name{apply_core}
\alias{apply_core}
\alias{apply_core.zoocat}
\title{Apply a function over the core data matrix}
\usage{
apply_core(x, ...)

\method{apply_core}{zoocat}(x, FUN, bind, ...)
}
\arguments{
\item{x}{the object.}

\item{...}{other arguments for \code{FUN}.}

\item{FUN}{the function to apply. The \code{FUN} must return a matrix or 
a vector.}

\item{bind}{a vector of length 1 or 2 with element values to be
 'cattr' or 'index' or NA to describe how to bind the return
data with \code{cattr} or \code{index}. If \code{FUN} return a vector, set
\code{bind} to be a scalar. If \code{FUN} return a matrix, set
\code{bind} to be a vector of length 2. See details.}
}
\value{
a data frame, a "\code{zoo}" object, or a "\code{zoocat}" object.
}
\description{
Apply a function over the core data matrix of the \code{zoocat} object,
and bind the return data with \code{cattr} or \code{index}.
}
\examples{
x <- matrix(1 : 20, nrow = 5)
colAttr <- data.frame(month = c(2, 3, 5, 6), name = c(rep('xxx', 3), 'yyy'))
zc <- zoocat(x, order.by = 1991 : 1995, colattr = colAttr)

apply_core(zc, FUN = colMeans, bind = 'cattr')
apply_core(zc, FUN = rowMeans, bind = 'index')
apply_core(zc, FUN = function (x) {x*2}, bind = c('index', 'cattr'))
apply_core(zc, FUN = function (x) {t(x*2)}, bind = c('cattr', 'index'))
apply_core(zc, FUN = function (x) {x*2}, bind = c('index', NA))
apply_core(zc, FUN = function (x) {x[3:4, ]}, bind = c(NA, 'cattr'))
apply_core(zc, FUN = function (x) 
                      {r <- x[3:4, ]
                      rownames(r) <- c('a', 'b')
                      return(r)}, 
                      bind = c(NA, 'cattr'))

vec <- as.vector(zc[, 1])
apply_core(zc, FUN = function (x) {cor(x, vec)}, bind = 'cattr')

}

