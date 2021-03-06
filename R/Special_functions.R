"%>>%" <- function(x, y) { x > y & !is.na(x) }
"%<<%" <- function(x, y) { x < y & !is.na(x) }
"%>=%" <- function(x, y) { x >= y & !is.na(x) }
"%<=%" <- function(x, y) { x <= y & !is.na(x) }

# Remainder function that gives back the divisor, not zero, when evenly divisible, e.g. 14 %r1% 7 gives 7 not 0
"%r1%" <- function(e1, e2) { ifelse(e1 %% e2 == 0, e2, e1 %% e2) }
