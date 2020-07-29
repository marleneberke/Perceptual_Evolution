library(tidyverse)
library(Rfast)

setwd("~/Documents/03_Yale/Projects/004_Debunking_Interface_Theory/Interface_Project_2/Perceptual_Evolution/data/many_tasks/pentalty_lambda_1/merged_csv_directory")

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

mode <- (alphas-1)/(alphas+betas-2)
hist(mode)


#Graphs for binned
set_size = 11
p = seq(0, 1, length=set_size+1)
dist = (p[2] - p[1])/2
x = vector(mode = "numeric", length=set_size)
for (j in 1:length(x)){
  x[j] = dist + p[j]
}

y = matrix(0, length(alphas), length(x))
#y[1,] = pbeta(x+dist, alphas[i], betas[i]) - pbeta(x-dist, alphas[i], betas[i])
#plot(p, y[1,], ylab="density", type ="l", col=1, ylim=c(0,1))
plot(NULL, xlim=c(0,1), ylim=c(0,1), ylab="y label", xlab="x lablel")
for (i in 1:length(alphas)){
  y[i,] <- pbeta(x+dist, alphas[i], betas[i]) - pbeta(x-dist, alphas[i], betas[i])
  lines(x, y[i,], type ="l", col=i)
}
#legend(0.7,8, c("Be(100,100)","Be(10,10)","Be(2,2)", "Be(1,1)"),lty=c(1,1,1,1),col=c(4,3,2,1))
#add average line
lines(x, colSums(y)/length(alphas), type = "l", col=1, lwd=5)

modes_2 <- mode()

cor(y[1,], y[2,])

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
  #     proportion_veridical_generation_500
  #     )
  
  #df_veridical <- data %>% group_by(number_of_tasks)
  
  #df_veridical <- data %>% gather(number_of_tasks)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_veridical <- data %>% group_by(number_of_tasks) %>% summarize(Mean=mean(proportion_veridical_generation_500),Lower=GetLowerCI(proportion_veridical_generation_500),Top=GetTopCI(proportion_veridical_generation_500))
  
  p <- ggplot(
    toPlot_veridical,
    aes(
      x = number_of_tasks,
      y = Mean,
      ymin = Lower,
      ymax = Top,
    )
  ) + geom_ribbon() + geom_line() + coord_cartesian(ylim = c(0, 1)) + theme(aspect.ratio=1) + ylab("Perceptage of individuals with veridical perception")
  
  ggsave("veridical_plot.png", p)
}

###################################################################
invertibility_plot <- function(data){
  
  # df_veridical <-
  #   data %>% gather(
  #     number_of_tasks,
  #     proportion_veridical_generation_500
  #     )
  
  #df_veridical <- data %>% group_by(number_of_tasks)
  
  #df_veridical <- data %>% gather(number_of_tasks)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_invertible <- data %>% group_by(number_of_tasks) %>% summarize(Mean=mean(average_invertability_generation_500),Lower=GetLowerCI(average_invertability_generation_500),Top=GetTopCI(average_invertability_generation_500))
  
  p <- ggplot(
    toPlot_invertible,
    aes(
      x = number_of_tasks,
      y = Mean,
      ymin = Lower,
      ymax = Top,
    )
  ) + geom_ribbon() + geom_line() + ylab("Average invertibility")
  
  ggsave("invertibility_plot.png", p)
}




###################################################################

veridical_plot(data)
invertibility_plot(data)

veridical_plot(raw_data %>% filter(n_options_per_game>1))
veridical_plot(raw_data %>% filter(n_options_per_game>1) %>% filter(how_many_functions_are_monotonic==0))
temp <- raw_data %>% filter(n_options_per_game>1) %>% filter(how_many_functions_are_monotonic==0)
plot(temp$number_of_tasks, temp$proportion_veridical_generation_500)

###################################################################
clean_V <- function(column){
  column <- column %>%
    lapply(function(x){gsub(pattern = "[", replacement="",x, fixed = TRUE)}) %>%
    lapply(function(x){gsub(pattern = "]", replacement="",x, fixed = TRUE)}) %>%
    lapply(function(x){gsub(pattern = ";", replacement="",x, fixed = TRUE)})
}

temp <- raw_data %>% filter(number_of_tasks==100) %>% filter(n_options_per_game>1)
temp$proportion_veridical_generation_500
hist(temp$proportion_veridical_generation_500, xlim=c(0,1))

utilities <- temp[1,]$utility_functions
temp_var <- unlist(strsplit(as.character(clean_V(utilities)), split = " "))
utility_functions <- matrix(as.numeric(temp_var), ncol=100, byrow=TRUE) #ncol = number_of_tasks filtering for
#cor(utility_functions[,1], utility_functions[,2])

#Graphs for binned
set_size = 11
p = seq(0, 1, length=set_size+1)
dist = (p[2] - p[1])/2
x = vector(mode = "numeric", length=set_size)
for (j in 1:length(x)){
  x[j] = dist + p[j]
}
plot(NULL, xlim=c(0,1), ylim=c(0,0.5), ylab="y label", xlab="x lablel")
for (i in 1:100){
  lines(x, utility_functions[,i], type ="l", col=i)
}


###################################################################

raw_data <- read_delim("merged.csv",
                       "&", escape_double = FALSE, trim_ws = TRUE)
data <- raw_data %>% select(number_of_tasks, n_options_per_game, proportion_veridical_generation_500, average_invertability_generation_500)
data <- data %>% mutate(average_invertability_generation_500 = as.numeric(as.character(str_sub(average_invertability_generation_500, 1, -18))))


#proportion task A = 0.5
#%>% filter(proportion_task_A==0.5)
#data <- raw_data %>% filter(number_of_tasks==2) %>% filter(n_options_per_game==10)
data <- raw_data %>% filter(number_of_tasks==100)  %>% filter(n_options_per_game!=1)
data <- data %>% select(contains("proportion_veridical"))
data %>% gather(variable, value) %>% separate(variable, into = c("x","y","z", "time"), sep="_") %>%
  group_by(time) %>% summarize(veridicality = mean(value)) %>% mutate(time = as.numeric(time)) %>%
  ggplot(aes(time, veridicality)) + geom_line() + ylim(0,1)


###################################################################
#make a plot with a line for each number of tasks with error bars
n_tasks = c(1,2,5,10,20,30,50,100, 250)
data1 <- raw_data %>% filter(number_of_tasks %in% n_tasks)  %>% 
  filter(n_options_per_game!=1) %>% 
  #filter(penalty_value==0.15) %>% 
  #filter(n_options_per_game==9) %>%
  select(number_of_tasks, contains("proportion_veridical"))

dim(data1)[2]-1 #1001

temp <- data1 %>% select(contains("proportion_veridical")) %>% gather(variable, value) %>%
  separate(variable, into = c("x","y","z", "time"), sep="_")

GetMean <- function(x){return(t.test(x)$estimate)}
GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
GetTopCI <- function(x){return(t.test(x)$conf.int[2])}

number_of_tasks <- rep(data1$number_of_tasks, 1001)
to_plot <- cbind(number_of_tasks, temp) %>% group_by(time, number_of_tasks) %>% 
  summarize(Mean=GetMean(value),Lower=GetLowerCI(value),Top=GetTopCI(value))
ggplot(data = to_plot, aes(x = as.numeric(time), y = Mean, ymin = Lower, ymax = Top, color = as.factor(number_of_tasks))) + 
  geom_ribbon() + geom_line() + ylim(0,1) + guides(color = guide_legend(reverse = TRUE)) + theme(aspect.ratio=1) +
  ylab("proportion veridical")

###################################################################
#make a plot with a line for each number of tasks. Invertibility version with errorbars
n_tasks = c(1,2,5,10,20,30,50,100,250)
data1 <- raw_data %>% filter(number_of_tasks %in% n_tasks)  %>% 
  filter(n_options_per_game!=1) %>% 
  select(number_of_tasks, contains("average_invertability"))
#select(contains("proportion_veridical"))

dim(data1)[2]-1 #1001

temp <- data1 %>% select(contains("average_invertability")) %>% gather(variable, value) %>%
  separate(variable, into = c("x","y","z", "time"), sep="_")

GetMean <- function(x){return(t.test(x)$estimate)}
GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
GetTopCI <- function(x){return(t.test(x)$conf.int[2])}

number_of_tasks <- rep(data1$number_of_tasks, 1001)
to_plot <- cbind(number_of_tasks, temp) %>% group_by(time, number_of_tasks) %>% 
  summarize(Mean=GetMean(value),Lower=GetLowerCI(value),Top=GetTopCI(value))
ggplot(data = to_plot, aes(x = as.numeric(time), y = Mean, ymin = Lower, ymax = Top, color = as.factor(number_of_tasks))) + 
  geom_ribbon() + geom_line() + ylim(0,7) + guides(color = guide_legend(reverse = TRUE)) + theme(aspect.ratio=1) +
  ylab("invertibility") + geom_hline(yintercept=5.5)

###################################################################
#make a plot with a line for each number of tasks. Mode version with error bars
n_tasks = c(1,2,5,10,20,30,50,100,250)
data1 <- raw_data %>% filter(number_of_tasks %in% n_tasks)  %>% 
  filter(n_options_per_game!=1) %>% 
  select(number_of_tasks, contains("mode_veridical?"))
#select(contains("proportion_veridical"))

dim(data1)[2]-1 #1001

temp <- data1 %>% select(contains("mode_veridical?")) %>% gather(variable, value) %>%
  separate(variable, into = c("x","y","z", "time"), sep="_")

#data is 0 or 1 so use prop.test
GetLowerCI <- function(x,y){return(prop.test(x,y)$conf.int[1])}
GetTopCI <- function(x,y){return(prop.test(x,y)$conf.int[2])}

number_of_tasks <- rep(data1$number_of_tasks, 1001)
to_plot <- cbind(number_of_tasks, temp) %>% group_by(time, number_of_tasks) %>% 
  summarize(Samples=n(),Hits=sum(value),Mean=mean(value),Lower=GetLowerCI(Hits,Samples),Top=GetTopCI(Hits,Samples))
ggplot(data = to_plot, aes(x = as.numeric(time), y = Mean, ymin = Lower, ymax = Top, color = as.factor(number_of_tasks))) + 
  geom_ribbon() + geom_line() + ylim(0,1) + guides(color = guide_legend(reverse = TRUE)) + theme(aspect.ratio=1) +
  ylab("proportion runs where mode strategy is veridical")

###################################################################
#veridicality
#make a plot with a line for each number of tasks. For number of options with error bars
n_tasks = c(1,2,5,10,20,30,50,100,250)
data1 <- raw_data %>% filter(number_of_tasks %in% n_tasks)  %>% 
  select(number_of_tasks, n_options_per_game, proportion_veridical_generation_1000)
#select(contains("proportion_veridical"))

GetMean <- function(x){return(t.test(x)$estimate)}
GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
GetTopCI <- function(x){return(t.test(x)$conf.int[2])}

to_plot <- data1 %>% group_by(n_options_per_game, number_of_tasks) %>% 
  summarize(Mean=GetMean(proportion_veridical_generation_1000),Lower=GetLowerCI(proportion_veridical_generation_1000),Top=GetTopCI(proportion_veridical_generation_1000))
ggplot(data = to_plot, aes(x = n_options_per_game, y = Mean, ymin = Lower, ymax = Top, color = as.factor(number_of_tasks))) + 
  geom_ribbon() + geom_line() + ylim(0,1) + guides(color = guide_legend(reverse = TRUE)) + theme(aspect.ratio=1) +
  ylab("proportion veridical")


###################################################################
#invertibility
#make a plot with a line for each number of tasks. For number of options with error bars
n_tasks = c(1,2,5,10,20,30,50,100,250)
data1 <- raw_data %>% filter(number_of_tasks %in% n_tasks)  %>% 
  select(number_of_tasks, n_options_per_game, average_invertibility_generation_1000)
#select(contains("proportion_veridical"))

GetMean <- function(x){return(t.test(x)$estimate)}
GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
GetTopCI <- function(x){return(t.test(x)$conf.int[2])}

to_plot <- data1 %>% group_by(n_options_per_game, number_of_tasks) %>% 
  summarize(Mean=GetMean(average_invertibility_generation_1000),Lower=GetLowerCI(proportion_veridical_generation_1000),Top=GetTopCI(proportion_veridical_generation_1000))
ggplot(data = to_plot, aes(x = n_options_per_game, y = Mean, ymin = Lower, ymax = Top, color = as.factor(number_of_tasks))) + 
  geom_ribbon() + geom_line() + ylim(0,1) + guides(color = guide_legend(reverse = TRUE)) + theme(aspect.ratio=1) +
  ylab("average invertibility")

###################################################################
#mode
#make a plot with a line for each number of tasks. For number of options with error bars
n_tasks = c(1,2,5,10,20,30,50,100,250)
data1 <- raw_data %>% filter(number_of_tasks %in% n_tasks)  %>% 
  select(number_of_tasks, n_options_per_game, `mode_veridical?_generation_1000`)
#select(contains("proportion_veridical"))

GetLowerCI <- function(x,y){return(prop.test(x,y)$conf.int[1])}
GetTopCI <- function(x,y){return(prop.test(x,y)$conf.int[2])}

to_plot <- data1 %>% group_by(n_options_per_game, number_of_tasks) %>% 
  summarize(Samples=n(),Hits=sum(`mode_veridical?_generation_1000`),Mean=mean(`mode_veridical?_generation_1000`),Lower=GetLowerCI(Hits,Samples),Top=GetTopCI(Hits,Samples))
ggplot(data = to_plot, aes(x = n_options_per_game, y = Mean, ymin = Lower, ymax = Top, color = as.factor(number_of_tasks))) + 
  geom_ribbon() + geom_line() + ylim(0,1) + guides(color = guide_legend(reverse = TRUE)) + theme(aspect.ratio=1) +
  ylab("proportion runs where mode strategy is veridical")



