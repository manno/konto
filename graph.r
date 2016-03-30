# install.packages('ggplot2')
require('ggplot2')

# ---------------
# Parse main konto
x <- read.csv("kontoumsatz.csv", sep=';')
names(x) <- c("Buchungstag", "Wertstellung", "Umsatzart", "Buchungsdetails", "Auftraggeber", "Empfänger", "Betrag", "Saldo")

# Limit to monthly minimum
yyyymm <- paste(format(as.POSIXlt(as.Date(x$Buchungstag, '%d.%m.%Y')), format="%Y-%m"), "01", sep="-")
SALDO <- tapply(x$Saldo, yyyymm, min) # max, mean

SALDOMAX <- aggregate(x$Saldo, list(yyyymm), max) # max, mean
names(SALDOMAX) <- c("Monat", "Max")
SALDOMAX$Monat <- as.Date(SALDOMAX$Monat)
SALDOMAX$Max <- as.numeric(SALDOMAX$Max)

# ---------------
# Parse sparkonto
y <- read.csv("kontoumsatz_spar.csv", sep=';', encoding='utf-8')
names(y) <- c("Buchungstag", "Wertstellung", "Umsatzart", "Buchungsdetails", "Auftraggeber", "Empfänger", "Betrag", "Saldo")
yyyymm <- paste(format(as.POSIXlt(as.Date(y$Buchungstag, '%d.%m.%Y')), format="%Y-%m"), "01", sep="-")
SPAR <- tapply(y$Saldo, yyyymm, max)

# Merge both datasets by month
tmp <- merge(SPAR, SALDO, by=c(0), all=TRUE)
names(tmp) <- c("Monat", "Spar", "Saldo")
tmp$Spar[is.na(tmp$Spar)] <- 0
tmp$Saldo <- as.numeric(tmp$Saldo)
tmp$Monat <- as.factor(tmp$Monat)
tmp$Monat <- as.Date(tmp$Monat)

# Fix missing values
tmp[c(6),2] <- tmp[c(5),2]
tmp[c(10),2] <- tmp[c(9),2]

# Convert to long format
library(reshape2)
DF <- melt(tmp, id.var="Monat")

# ---------------
# PLOT BARS

pdf("konto.pdf")
ggplot(DF, aes(x = Monat, y = value, fill = variable)) + geom_bar(stat = "identity") + xlab('') + ylab('EUR') + scale_fill_discrete(name='', labels=c('Sparkonto','Konto'))
dev.off()
