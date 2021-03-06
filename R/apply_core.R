

#' Apply a function over the core data matrix
#' 
#' Apply a function over the core data matrix of the \code{zoocat} object,
#' and bind the return data with \code{cattr} or \code{index}.
#' @export
#' @name apply_core
#' @rdname apply_core
apply_core <- function (x, ...) {
    UseMethod('apply_core')
}

#' @export
#' @return a data frame, a "\code{zoo}" object, or a "\code{zoocat}" object. 
#' @rdname apply_core
#' @param x the object.
#' @param FUN the function to apply. The \code{FUN} must return a matrix or 
#' a vector.
#' @param bind a vector of length 1 or 2 with element values to be
#'  'cattr' or 'index' or NA to describe how to bind the return
#' data with \code{cattr} or \code{index}. If \code{FUN} return a vector, set
#' \code{bind} to be a scalar. If \code{FUN} return a matrix, set
#' \code{bind} to be a vector of length 2. See details.
#' @param ... other arguments for \code{FUN}.
#' @examples 
#' x <- matrix(1 : 20, nrow = 5)
#' colAttr <- data.frame(month = c(2, 3, 5, 6), name = c(rep('xxx', 3), 'yyy'))
#' zc <- zoocat(x, order.by = 1991 : 1995, colattr = colAttr)
#' 
#' apply_core(zc, FUN = colMeans, bind = 'cattr')
#' apply_core(zc, FUN = rowMeans, bind = 'index')
#' apply_core(zc, FUN = function (x) {x*2}, bind = c('index', 'cattr'))
#' apply_core(zc, FUN = function (x) {t(x*2)}, bind = c('cattr', 'index'))
#' apply_core(zc, FUN = function (x) {x*2}, bind = c('index', NA))
#' apply_core(zc, FUN = function (x) {x[3:4, ]}, bind = c(NA, 'cattr'))
#' apply_core(zc, FUN = function (x) 
#'                       {r <- x[3:4, ]
#'                       rownames(r) <- c('a', 'b')
#'                       return(r)}, 
#'                       bind = c(NA, 'cattr'))
#' 
#' vec <- as.vector(zc[, 1])
#' apply_core(zc, FUN = function (x) {cor(x, vec)}, bind = 'cattr')
#' 
apply_core.zoocat <- function (x, FUN, bind, ...) {
    stopifnot(length(bind) %in% c(1, 2))
    stopifnot(all(bind %in% c('cattr', 'index', NA)))
    
    data.ret <- FUN(as.matrix(x), ...)
    if (is.data.frame(data.ret)) {
        data.ret <- as.matrix(data.ret)
    }
    stopifnot(is.matrix(data.ret) | is.vector(data.ret))
    
    if (all(is.na(bind))) {
        return(data.ret)
    }
    
    stopifnot(is.matrix(data.ret) | is.vector(data.ret))
    
    if (length(bind) == 2 & !any(is.na(bind))) {
        if (all(bind == c('index', 'cattr'))) {
            stopifnot(nrow(data.ret) == nrow(x))
            stopifnot(ncol(data.ret) == ncol(x))
            ret <- zoocat(data.ret, order.by = index(x), colattr = cattr(x))
        } else if (all(bind == c('cattr', 'index'))) {
            stopifnot(ncol(data.ret) == nrow(x))
            stopifnot(nrow(data.ret) == ncol(x))
            ret <- zoocat(t(data.ret), order.by = index(x), colattr = cattr(x))
        }
    }
    
    if ((length(bind) == 2 & any(is.na(bind))) |
        length(bind) == 1) {
            if ((length(bind) == 2) & is.na(bind[1])) {
                data.ret <- t(data.ret)
            } else if (length(bind) == 1) {
                stopifnot(any(dim(data.ret) == 1) | is.vector(data.ret))
            }
            if ('cattr' %in% bind) {
                if (is.vector(data.ret)) {
                    stopifnot(ncol(x) == length(data.ret)) 
                } else {
                    stopifnot(ncol(x) == nrow(data.ret))
                }
                ret <- cbind(cattr(x), data.ret)
                rownames(ret) <- NULL
            } else if ('index' %in% bind) {
                if (is.vector(data.ret)) {
                    stopifnot(nrow(x) == length(data.ret)) 
                } else {
                    stopifnot(nrow(x) == nrow(data.ret))
                }
                ret <- zoo(data.ret, order.by = index(x))
            }
    }
    
    return(ret)

}









