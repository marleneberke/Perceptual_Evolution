alphas = c(1,3)
betas = c(4,5)

set_size = 11
p = seq(0, 1, length=set_size+1)
dist = (p[2] - p[1])/2
x = vector(mode = "numeric", length=set_size)
for (j in 1:length(x)){
  x[j] = dist + p[j]
}
mat = matrix(0, length(alphas), length(x))
#y[1,] = pbeta(x+dist, alphas[i], betas[i]) - pbeta(x-dist, alphas[i], betas[i])
#plot(p, y[1,], ylab="density", type ="l", col=1, ylim=c(0,1))
for (i in 1:length(alphas)){
  mat[i,] <- pbeta(x+dist, alphas[i], betas[i]) - pbeta(x-dist, alphas[i], betas[i])
}

x <- mat[1,]
y <- mat[2,]

complement <- function(y, rho, x) {
  if (missing(x)) x <- rnorm(length(y)) # Optional: supply a default if `x` is not given
  y.perp <- residuals(lm(x ~ y))
  rho * sd(y.perp) * y + y.perp * sd(y) * sqrt(1 - rho^2)
}

#y <- rnorm(50, sd=10)
#x <- 1:50 # Optional
rho <- seq(0, 1, length.out=6) * rep(c(-1,1), 3)
X <- data.frame(z=as.vector(sapply(rho, function(rho) complement(y, rho, x))),
                rho=ordered(rep(signif(rho, 2), each=length(y))),
                y=rep(y, length(rho)))

library(ggplot2)
ggplot(X, aes(y,z, group=rho)) + 
  geom_smooth(method="lm", color="Black") + 
  geom_rug(sides="b") + 
  geom_point(aes(fill=rho), alpha=1/2, shape=21) +
  facet_wrap(~ rho, scales="free")

     
library(tidyverse)

temp <- X %>% filter(rho==0.2)
min(temp$y)
min(temp$z)

#shift to be positive
positive_y <- temp$y + abs(min(temp$y))
positive_z <- temp$z + abs(min(temp$z))

#normalize
normalized_y <- positive_y / sum(positive_y)
normalized_z <- positive_z / sum(positive_z)

cor(normalized_y, normalized_z)

plot(normalized_y)
plot(normalized_z)
