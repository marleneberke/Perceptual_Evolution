library(tidyverse)
library(Rfast)

raw_data <- read_delim("merged.csv",
                       "&", escape_double = FALSE, trim_ws = TRUE)

data <- raw_data %>% select(correlation_between_A_and_B, n_options_per_game, proportion_veridical_generation_1000, average_invertability_generation_1000)
data <- data %>% mutate(average_invertability_generation_1000 = as.numeric(as.character(str_sub(average_invertability_generation_1000, 1, -18))))

###################################################################
dat <- raw_data %>% filter(n_options_per_game > 1)
plot(dat$area_of_intersection, dat$proportion_veridical_generation_1000)
#^Take away is very few observations below 0.4

GetAccuracy <- function(x){
  return(dat %>% filter(area_of_intersection<x+0.01,area_of_intersection>x-0.01) %>% 
           summarize(veridicality=mean(proportion_veridical_generation_1000)))
}
Results <- map_df(seq(0.3,1.0,by=0.01),GetAccuracy)
p1 <- Results %>% ggplot(aes(seq(0.3,1.0,by=0.01),veridicality))+geom_line()+
  theme_grey()+theme(aspect.ratio=1)
#plot(seq(0.3,1.0,by=0.01), Results$veridicality)
p1
###################################################################
veridical_plot <- function(data, name){
  
  # df_veridical <-
  #   data %>% gather(
  #     correlation_between_A_and_B,
  #     proportion_veridical_generation_1000
  #     )
  
  #df_veridical <- data %>% group_by(correlation_between_A_and_B)
  
  #df_veridical <- data %>% gather(correlation_between_A_and_B)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  #unique is trying not to over count things from the same utility functions. 
  #veridicality_by_utility pools by utility.
  # toPlot_veridical <- data3 %>% group_by(binned_correlation) %>% 
  #   summarize(Mean=mean(unique(veridicality_by_utility)),Lower=GetLowerCI(unique(veridicality_by_utility)),Top=GetTopCI(unique(veridicality_by_utility)))
  # 
  toPlot_veridical <- data %>% group_by(binned_correlation) %>% 
    summarize(Mean=mean(proportion_veridical_generation_1000),Lower=GetLowerCI(proportion_veridical_generation_1000),Top=GetTopCI(proportion_veridical_generation_1000))
  
  
  p <- ggplot(
    toPlot_veridical,
    aes(
      x = binned_correlation,
      y = Mean,
      ymin = Lower,
      ymax = Top,
    )
  ) + geom_ribbon() + geom_line() + coord_cartesian(ylim = c(0, 1)) + theme(aspect.ratio=1) + ylab("Perceptage of individuals with veridical perception")
  
  ggsave(name, p)
}

###################################################################
invertibility_plot <- function(data){
  
  # df_veridical <-
  #   data %>% gather(
  #     correlation_between_A_and_B,
  #     proportion_veridical_generation_1000
  #     )
  
  #df_veridical <- data %>% group_by(correlation_between_A_and_B)
  
  #df_veridical <- data %>% gather(correlation_between_A_and_B)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_invertible <- data %>% group_by(correlation_between_A_and_B) %>% summarize(Mean=mean(average_invertability_generation_1000),Lower=GetLowerCI(average_invertability_generation_1000),Top=GetTopCI(average_invertability_generation_1000))
  
  p <- ggplot(
    toPlot_invertible,
    aes(
      x = correlation_between_A_and_B,
      y = Mean,
      ymin = Lower,
      ymax = Top,
    )
  ) + geom_ribbon() + geom_line() + coord_cartesian(ylim = c(0, 7)) + ylab("Average invertibility")
  
  ggsave("invertibility_plot.png", p)
}




###################################################################

veridical_plot(data %>% filter(n_options_per_game > 2), "veridicality_plot")
invertibility_plot(data %>% filter(n_options_per_game==1))

n_options = 10
name = paste("veridical_plot_", as.character(n_options),  "_options.png", sep = "")
veridical_plot(data %>% filter(n_options_per_game==n_options), name)


name  = "veridical_plot_options!=1or2_and_non-monotonic"
dat <- raw_data %>% filter(n_options_per_game > 2) %>% filter(how_many_functions_are_monotonic == 0)
veridical_plot(data %>% filter(n_options_per_game > 2) %>% filter(how_many_functions_are_monotonic == 0), name)

###################################################################

clean_V <- function(column){
  column <- column %>%
    lapply(function(x){gsub(pattern = "[", replacement="",x, fixed = TRUE)}) %>%
    lapply(function(x){gsub(pattern = "]", replacement="",x, fixed = TRUE)}) %>%
    lapply(function(x){gsub(pattern = ";", replacement="",x, fixed = TRUE)})
}


temp <- data3 %>% filter(binned_correlation==0.99)
#temp <- raw_data %>% filter(n_options_per_game==7) %>% filter(correlation_between_A_and_B==-1)
temp$proportion_veridical_generation_1000
utilities <- temp[84,]$utilities
temp_var <- unlist(strsplit(as.character(clean_V(utilities)), split = " "))
utility_functions <- matrix(as.numeric(temp_var), nrow=2, byrow=TRUE) #ncol or nrows
cor(utility_functions[1,], utility_functions[2,])

#Graphs for binned
set_size = 11
p = seq(0, 1, length=set_size+1)
dist = (p[2] - p[1])/2
x = vector(mode = "numeric", length=set_size)
for (j in 1:length(x)){
  x[j] = dist + p[j]
}
plot(NULL, xlim=c(0,1), ylim=c(0,0.5), ylab="y label", xlab="x lablel")
lines(x, utility_functions[1,], type ="l", col=1)
lines(x, utility_functions[2,], type ="l", col=2)



# data$utility_functions <- clean_V(data$utility_functions)
# temp_var <- unlist(strsplit(as.character(data$utility_functions), split = " "))
# utility_functions <- matrix(as.numeric(temp_var), nrow=2, byrow=TRUE)

###################################################################

#proportion task A = 0.5
#%>% filter(correlation_between_A_and_B==0.5)
data <- raw_data %>% filter(n_options_per_game==7) %>% filter(correlation_between_A_and_B==1)
data <- data %>% select(contains("proportion_veridical"))
data %>% gather(variable, value) %>% separate(variable, into = c("x","y","z", "time"), sep="_") %>%
  group_by(time) %>% summarize(veridicality = mean(value)) %>% mutate(time = as.numeric(time)) %>%
  ggplot(aes(time, veridicality)) + geom_line() + ylim(0,1)

###################################################################
#Corr plot with binning
#data <- raw_data %>% select(exact_correlation_between_A_and_B, n_options_per_game, proportion_veridical_generation_1000, alphas_of_utilities, utilities, how_many_functions_are_monotonic)
data <- raw_data %>% select(exact_correlation_between_A_and_B, n_options_per_game, proportion_veridical_generation_1000, utilities, how_many_functions_are_monotonic)


#data2 <- data %>% group_by(alphas_of_utilities) %>% mutate(veridicality_by_utility = mean(proportion_veridical_generation_1000))
#bin exact correlations
n_bins = 100 #n_levels
by = 2/n_bins
binned_corr = seq(from = -1+(by/2), to = 1-(by/2), by = by)
#data3 <- data2 %>% mutate(bin = floor((exact_correlation_between_A_and_B+1)/by)+1, binned_correlation = binned_corr[bin])
data3 <- data %>% mutate(bin = floor((exact_correlation_between_A_and_B+1)/by)+1, binned_correlation = binned_corr[bin])
#then do veridical plot
View(data3 %>% select(exact_correlation_between_A_and_B, binned_correlation))


data <- data %>% filter(n_options_per_game > 1)
hist(unique(data$veridicality_by_utility))


#I do not understand why some binned_correlation values seem to be missing
unique(data$binned_correlation)
temp2 <- data3 %>% filter(binned_correlation=="0.93") #for some reason some of them have to be in quotes

hist(unique(temp2$veridicality_by_utility))

veridical_plot(temp %>% filter(n_options_per_game > 1), "veridicality_plot")

data <- data3 %>% filter(n_options_per_game > 1)
data <- data3 %>% filter(n_options_per_game > 1) %>% filter(how_many_functions_are_monotonic == 0)
veridical_plot(data, "veridicality_plot")


plot(data3$exact_correlation_between_A_and_B, data3$how_many_functions_are_monotonic, ylab = "how_many_monotonic", xlab = "exact_correlation")

corr99 = data3 %>% filter(binned_correlation=="0.99")
corr52 = data3 %>% filter(binned_correlation=="0.51")
mean(corr99$how_many_functions_are_monotonic)
mean(corr52$how_many_functions_are_monotonic)

mean(corr99$proportion_veridical_generation_1000)
mean(corr52$proportion_veridical_generation_1000)
