# qualitative case

# set seed
set.seed(667799)

# create qualitative vector
vhs.tape.speed <- c("SP","LP","EP","none")

# create uniform probability vector
uniform <- c(1,1,1,1)

# create weights according to our wishes
vhs.tape.speed.weights <- c(10,10,2,1)
# convert to probabilities
vhs.tape.speed.probs <- vhs.tape.speed.weights/(sum(vhs.tape.speed.weights))

# check whether sum is really '1'
sum(vhs.tape.speed.probs)

# uniform sampling
# single case
sample(vhs.tape.speed, size=1, replace=TRUE)
sample(vhs.tape.speed, size=1, replace=TRUE)

# large sample size
table(sample(vhs.tape.speed, size=10e6, replace=TRUE))

# multiple cases, ie. repeated sampling with replacement
# size = 1e5
vhs.tape.speed.samp.unif1 <- sample(vhs.tape.speed, size=1e5, replace=TRUE)
# see results
table(vhs.tape.speed.samp.unif1)
# rounding
round( table(vhs.tape.speed.samp.unif1)/10e3, 0)
round( table(vhs.tape.speed.samp.unif1)/10e3, 1)

# size = 1e6
vhs.tape.speed.samp.unif2 <- sample(vhs.tape.speed, size=1e6, replace=TRUE)
# results
table(vhs.tape.speed.samp.unif2)
# rounding
round( table(vhs.tape.speed.samp.unif2)/1e5, 0)
round( table(vhs.tape.speed.samp.unif2)/1e5, 1)
floor( table(vhs.tape.speed.samp.unif2)/1e5)
ceiling( table(vhs.tape.speed.samp.unif2)/1e5)

# weighted sampling       
# size = 1e5
vhs.tape.speed.samp.probs1 <- sample(vhs.tape.speed, size=1e5, replace=TRUE, prob=vhs.tape.speed.probs)
tab1 <- table(vhs.tape.speed.samp.probs1)

# ratio to check for pre-defined weights
tab1[c(2,4)] / tab1[c(1)]
tab1[c(2,4)] / tab1[c(3)]

# size = 1e6
vhs.tape.speed.samp.probs2 <- sample(vhs.tape.speed, size=1e6, replace=TRUE, prob=vhs.tape.speed.probs)
tab2 <- table(vhs.tape.speed.samp.probs2)

# ratio to check for pre-defined weights
tab2[c(2,4)] / tab2[c(1)]
tab2[c(2,4)] / tab2[c(3)]


# quantitative case

# set seed
set.seed(667799)

# create quantitative vector
chroma_delay_vertical <- seq(-20,20)
# more values
sek <- seq(-20,20,length.out=1e4)

length(chroma_delay_vertical)
length(sek)

# using normal distribution

par(mfrow=c(2,2))
# normal distribution with mean=0, sd=1
plot(sek, dnorm(sek), type="l", col="darkred")
# normal distribution with mean=-10, sd=1
plot(sek, dnorm(sek, mean=-10, sd=1), type="l", col="darkred")
# normal distribution with mean=-10, sd=5
plot(sek, dnorm(sek, mean=-10, sd=5), type="l", col="darkred")
# empirical case 'chroma_delay_vertical'
plot(chroma_delay_vertical, dnorm(chroma_delay_vertical), type="l", col="darkred")

dev.off()

# draw random samples

probs1 <- dnorm(chroma_delay_vertical, mean=-10, sd=5)
plot(chroma_delay_vertical,probs1, type="l", col="darkred")

# single case
sample(chroma_delay_vertical, size=1, replace=TRUE, prob=probs1)
sample(chroma_delay_vertical, size=1, replace=TRUE, prob=probs1)

# multiple values
cdv.samp1 <- sample(chroma_delay_vertical, size=1e6, replace=TRUE, prob=probs1)
head(cdv.samp1)
tail(cdv.samp1)
summary(cdv.samp1)
sd(cdv.samp1)

tab.cdv <- table(cdv.samp1)
no.zeros <- 20-(max(as.integer(names(tab.cdv))))
tab.cdv <- c(tab.cdv,rep(0,no.zeros))
plot(chroma_delay_vertical,tab.cdv, type="l", col="darkred")


# normal truncated
library(EnvStats)
cdv.normtrunc <- dnormTrunc(chroma_delay_vertical, mean=-10, sd=5, min=-17, max=6)
names(cdv.normtrunc) <- seq(-20,20)
round(cdv.normtrunc,3)


# plot
zeros <- names(cdv.normtrunc)[which(cdv.normtrunc == 0)]
zeros.int <- as.integer(zeros)
plot.area <- seq(-20,20)[! seq(-20,20) %in% zeros.int]
plot(plot.area,cdv.normtrunc[cdv.normtrunc != 0], type="l", col="darkred", xlim=c(-20,20))

