library(tidyverse)
library(Rfast)

raw_data <- read_delim("merged.csv",
                       "&", escape_double = FALSE, trim_ws = TRUE)

data <- raw_data %>% select(correlation_between_A_and_B, n_options_per_game, proportion_veridical_generation_1000, average_invertability_generation_1000)
data <- data %>% mutate(average_invertability_generation_1000 = as.numeric(as.character(str_sub(average_invertability_generation_1000, 1, -18))))
###################################################################
veridical_plot <- function(data){
  
  # df_veridical <-
  #   data %>% gather(
  #     correlation_between_A_and_B,
  #     proportion_veridical_generation_1000
  #     )
  
  #df_veridical <- data %>% group_by(correlation_between_A_and_B)
  
  #df_veridical <- data %>% gather(correlation_between_A_and_B)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_veridical <- data %>% group_by(correlation_between_A_and_B) %>% summarize(Mean=mean(proportion_veridical_generation_1000),Lower=GetLowerCI(proportion_veridical_generation_1000),Top=GetTopCI(proportion_veridical_generation_1000))
  
  p <- ggplot(
    toPlot_veridical,
    aes(
      x = correlation_between_A_and_B,
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

veridical_plot(data %>% filter(n_options_per_game==1))
invertibility_plot(data %>% filter(n_options_per_game==1))

veridical_plot(data %>% filter(n_options_per_game==5))
invertibility_plot(data %>% filter(n_options_per_game==10))

temp <- raw_data %>% filter(n_options_per_game==10) %>% filter(correlation_between_A_and_B==0.5) %>% select(frequency_table_of_perceptual_systems_generation_1000, proportion_veridical_generation_1000)

#proportion task A = 0.5
#%>% filter(correlation_between_A_and_B==0.5)
data <- raw_data %>% filter(n_options_per_game==3) %>% filter(correlation_between_A_and_B==1)
data <- data %>% select(contains("proportion_veridical"))
data %>% gather(variable, value) %>% separate(variable, into = c("x","y","z", "time"), sep="_") %>%
  group_by(time) %>% summarize(veridicality = mean(value)) %>% mutate(time = as.numeric(time)) %>%
  ggplot(aes(time, veridicality)) + geom_line() + ylim(0,1)
