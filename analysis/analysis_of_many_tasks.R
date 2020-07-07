library(tidyverse)
library(Rfast)

raw_data <- read_delim("output222.csv",
                       "&", escape_double = FALSE, trim_ws = TRUE)

to_vector <- function(column){
  without_brackets <- str_sub(column, 2, -2)
  return(as.numeric(unlist(str_split(without_brackets, ","))))
}

alphas <- to_vector(raw_data$alphas_of_utility_functions)
betas <- to_vector(raw_data$betas_of_utility_functions)


p = seq(0,1, length=11)
y = matrix(0, length(alphas), length(p))
y[1,] = dbeta(p, alphas[1], betas[1])
plot(p, y[1,], ylab="density", type ="l", col=1, ylim=c(0,10))
for (i in 2:length(alphas)){
  y[i,] = dbeta(p, alphas[i], betas[i])
  lines(p, y[i,], type ="l", col=i)
}
#legend(0.7,8, c("Be(100,100)","Be(10,10)","Be(2,2)", "Be(1,1)"),lty=c(1,1,1,1),col=c(4,3,2,1))
rowSums(y)
lines(p, )