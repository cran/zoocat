
#' Return columns with matching conditions
#' 
#' Return columns with matching conditions for the column attributes (\bold{cattr}) table.
#' 
#' For \code{filter_col}, when the argument \code{mon.repro} is not \code{NULL}, \code{reprocess_month}
#' will be called in the last step.
#' 
#' @rdname filter_col
#' @name filter_col
#' @export
#' @return a "\code{zoocat}" or "\code{zoomly}" object.
#' @param x the object.
#' @param cond logical predicates of conditions. Multiple conditions are 
#' combined with \code{&}. 
#' For \code{filter_col}, \code{cond} must be an expression, 
#' while for \code{filter_col_q}, \code{cond} must be a quoted expression.
#' @param mon.repro the reprocessing month vector, which is used for \code{\link{reprocess_month}}. 
#' See details.
#' 
#' 
#' @param ... other arguments.
#' @examples 
#' x <- matrix(1 : 20, nrow = 5)
#' colAttr <- data.frame(month = c(2, 3, 5, 6), name = c(rep('xxx', 3), 'yyy'))
#' zc <- zoocat(x, order.by = 1991 : 1995, colattr = colAttr)
#' filter_col(zc, month > 2)
#' filter_col(zc, month > 2)
#' filter_col(zc, month > 2 & name == 'yyy')
#' 
#' mat <- matrix(1:48, ncol = 12)
#' colAttr <- data.frame(month = rep(1 : 12))
#' zm <- zoomly(mat, order.by = 1991 : 1994, colattr = colAttr)
#' filter_col(zm, mon.repro = 1 : 3)
#' filter_col(zm, mon.repro = c(-9 : 8))
#' filter_col(zm, cond = month %in% 1 : 3, mon.repro = c(-24 : 3))
#' 
filter_col_q <- function (x, ...) {
    UseMethod('filter_col_q')
} 

#' @rdname filter_col
#' @export
filter_col <- function (x, ...) {
    UseMethod('filter_col')
} 

#' @rdname filter_col
#' @export
filter_col_q.zoocat <- function (x, cond, ...) {
    colAttr <- cattr(x) 
    iFilt <- eval(cond, colAttr, parent.frame())
    ret <- x[, iFilt, drop = FALSE]
    return(ret)
} 


#' @export
#' @rdname filter_col
filter_col.zoocat <- function (x, cond, ...) {
    cond_call <- substitute(cond)
    return(filter_col_q(x, cond_call))
} 


#' @export
#' @rdname filter_col
filter_col_q.zoomly <- function (x, cond = NULL, mon.repro = NULL, ...) {
    if (is.null(mon.repro)) {
        if (is.null(cond)) {
            return(x)
        } else {
            return(filter_col_q.zoocat(x, cond))
        }
    }
    
    if (!all(cattr(x)$month %in% (1 : 12))) {
        stop('When using argument mon.repro, all month values in x must be in 1 : 12.')
    }
    
    if (!is.null(cond)) {
        x <- filter_col_q.zoocat(x, cond)
    }
    ret <- reprocess_month(x, mon.repro = mon.repro)
    return(ret)
}


#' @export
#' @rdname filter_col
filter_col.zoomly <- function (x, cond = NULL, mon.repro = NULL, ...) {
    cond_call <- substitute(cond)
    return(filter_col_q(x, cond_call, mon.repro = mon.repro))
}


#' Reprocess month of \code{zoomly} objects
#' 
#' Reprocess month of "\code{zoomly}" objects, make the objects contain the data 
#' corresponding to months of previous years and following years.
#' 
#' For example, if there is a data value corresponding to year of 1990 and month of Jan, 
#' the argument \code{month} for \code{reprocess_month} can be set to be 13, and we get 
#' data of "Jan.1" (means Jan of the following year, see \link{gmon}), and the year of 
#' that data value will be 1991.
#' 
#' @examples
#' mat <- matrix(1:48, ncol = 12)
#' ctable <- data.frame(month = rep(1 : 12))
#' zm <- zoomly(mat, order.by = 1991 : 1994, colattr = ctable)
#' reprocess_month(zm, mon.repro = -11:2)
#' reprocess_month(zm, mon.repro = -24:3)
#' @param x a \code{zoomly} object.
#' @param mon.repro new setting month vector. Can be integers larger than 12 or less than 1.
#' @export
#' @return a "\code{zoomly}" object.
reprocess_month <- function (x, mon.repro) {
    if (!inherits(x, 'zoomly')) {
        stop('x must a zoomly object.')
    }
    mon.repro <- gmon(mon.repro)
    mon.true <- true_month(mon.repro)
    yr.rela <- rela_year(mon.repro)
    yr.rela.u <- unique(yr.rela)
    
    zm.ret <- zoomly()
    for (i in 1 : length(yr.rela.u)) {
        mon.true.now <- mon.true[yr.rela == yr.rela.u[i]]
        ret.now <- x[, cattr(x)$month %in% mon.true.now, drop = FALSE]
        if (length(ret.now) > 0) {
            index(ret.now) <- index(ret.now) - yr.rela.u[i]
            cattr(ret.now)$month <- 
                gmon(cattr(ret.now)$month + 12 * yr.rela.u[i])
            zm.ret <- merge(zm.ret, ret.now)
        }
    }
    attr(zm.ret, 'indname') <- attr(x, 'indname')
    zm.ret <- order_col(zm.ret)
    return(zm.ret)
}


