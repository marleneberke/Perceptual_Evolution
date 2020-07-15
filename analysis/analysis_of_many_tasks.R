library(tidyverse)
library(Rfast)

raw_data <- read_delim("merged.csv",
                       "&", escape_double = FALSE, trim_ws = TRUE)

to_vector <- function(column){
  without_brackets <- str_sub(column, 2, -2)
  return(as.numeric(unlist(str_split(without_brackets, ","))))
}

alphas <- to_vector(raw_data$alphas_of_utility_functions)
betas <- to_vector(raw_data$betas_of_utility_functions)

exp <- alphas/(alphas+betas)
hist(exp)

p = seq(0,1, length=11)
y = matrix(0, length(alphas), length(p))
y[1,] = dbeta(p, alphas[1], betas[1])
#plot(p, y[1,], ylab="density", type ="l", col=1, ylim=c(0,1))
plot(NULL, xlim=c(0,1), ylim=c(0,1), ylab="y label", xlab="x lablel")
for (i in 1:length(alphas)){
  density <- dbeta(p, alphas[i], betas[i])
  density[!is.finite(density)] <- 99999999 #replace infs
  y[i,] = density/sum(density) #normalize as is done in sampling utility function
  lines(p, y[i,], type ="l", col=i)
}
#legend(0.7,8, c("Be(100,100)","Be(10,10)","Be(2,2)", "Be(1,1)"),lty=c(1,1,1,1),col=c(4,3,2,1))
#add average line
lines(p, colSums(y)/length(alphas), type = "l", col=1, lwd=5)

####################################################################################

###################################################################
veridical_plot <- function(data){
  
  # df_veridical <-
  #   data %>% gather(
  #     number_of_tasks,
  #     proportion_veridical_generation_1000
  #     )
  
  #df_veridical <- data %>% group_by(number_of_tasks)
  
  #df_veridical <- data %>% gather(number_of_tasks)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_veridical <- data %>% group_by(number_of_tasks) %>% summarize(Mean=mean(proportion_veridical_generation_1000),Lower=GetLowerCI(proportion_veridical_generation_1000),Top=GetTopCI(proportion_veridical_generation_1000))
  
  p <- ggplot(
    toPlot_veridical,
    aes(
      x = number_of_tasks,
      y = Mean,
      ymin = Lower,
      ymax = Top,
    )
  ) + geom_ribbon() + geom_line() + coord_cartesian(ylim = c(0, 1)) + theme(aspect.ratio=1) + ylab("Perceptage of individuals with veridical perception")
  
  ggsave("veridical_plot.pdf", p)
}

###################################################################
invertibility_plot <- function(data){
  
  # df_veridical <-
  #   data %>% gather(
  #     number_of_tasks,
  #     proportion_veridical_generation_1000
  #     )
  
  #df_veridical <- data %>% group_by(number_of_tasks)
  
  #df_veridical <- data %>% gather(number_of_tasks)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_invertible <- data %>% group_by(number_of_tasks) %>% summarize(Mean=mean(average_invertability_generation_1000),Lower=GetLowerCI(average_invertability_generation_1000),Top=GetTopCI(average_invertability_generation_1000))
  
  p <- ggplot(
    toPlot_invertible,
    aes(
      x = number_of_tasks,
      y = Mean,
      ymin = Lower,
      ymax = Top,
    )
  ) + geom_ribbon() + geom_line() + ylab("Average invertibility")
  
  ggsave("invertibility_plot.pdf", p)
}




###################################################################

veridical_plot(data)
invertibility_plot(data)

raw_data <- read_delim("merged.csv",
                       "&", escape_double = FALSE, trim_ws = TRUE)
data <- raw_data %>% select(number_of_tasks, n_options_per_game, proportion_veridical_generation_1000, average_invertability_generation_1000)
data <- data %>% mutate(average_invertability_generation_1000 = as.numeric(as.character(str_sub(average_invertability_generation_1000, 1, -18))))


#proportion task A = 0.5
#%>% filter(proportion_task_A==0.5)
#data <- raw_data %>% filter(number_of_tasks==2) %>% filter(n_options_per_game==10)
data <- raw_data %>% filter(number_of_tasks==100)  %>% filter(n_options_per_game==1)
data <- data %>% select(contains("proportion_veridical"))
data %>% gather(variable, value) %>% separate(variable, into = c("x","y","z", "time"), sep="_") %>%
  group_by(time) %>% summarize(veridicality = mean(value)) %>% mutate(time = as.numeric(time)) %>%
  ggplot(aes(time, veridicality)) + geom_line() + ylim(0,1)

