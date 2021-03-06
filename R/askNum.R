askNum <- function (msg, decimalPoints = 0, verify = TRUE) 
{
    dev.new()
    while (TRUE) {
        cat("\n\n", msg, "\n\n")
        flush.console()
        plot(0:9, rep(5, 10), xlab = "0 - 9", ylab = "")
        text(3, 6, "Enter each digit in the number by clicking on the circles below:")
        Num <- NULL
        while (TRUE) {
            Pos <- locator(1)
            if (is.null(Pos)) 
                break
            N <- round(Pos$x)
            text(Pos, label = N)
            Num <- c(Num, N)
        }
        Num <- as.numeric(paste(Num, collapse = ""))
        Num <- if (is.na(Num)) 
            NULL
        else Num
        if (verify) {
            cat("\nIs this the correct number: ", Num/10^decimalPoints, "\nClick zero for FALSE or 1-9 for TRUE\n")
            flush.console()
            plot(0:9, rep(5, 10))
            text(3, 6, "Click zero for FALSE or 1-9 for TRUE")
            Pos <- locator(1)
            N <- round(Pos$x)
            text(Pos, label = ifelse(N == 0, "FALSE", "TRUE"))
            if (N) 
                break
            cat("\nTry again\n")
            flush.console()
            timer(2, silent = TRUE)
        }
        else break
    }
    dev.off()
    Num/10^decimalPoints
}


