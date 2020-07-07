library(tidyverse)
library(Rfast)

raw_data <- read_delim("output222.csv",
                       "&", escape_double = FALSE, trim_ws = TRUE)

data <- raw_data %>% select(proportion_task_A, proportion_veridical_generation_500, average_invertability_generation_500)
data <- data %>% mutate(average_invertability_generation_500 = as.numeric(as.character(str_sub(average_invertability_generation_500, 1, -18))))
###################################################################
veridical_plot <- function(data){

  # df_veridical <-
  #   data %>% gather(
  #     proportion_task_A,
  #     proportion_veridical_generation_500
  #     )
  
  #df_veridical <- data %>% group_by(proportion_task_A)
  
  #df_veridical <- data %>% gather(proportion_task_A)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_veridical <- data %>% group_by(proportion_task_A) %>% summarize(Mean=mean(proportion_veridical_generation_500),Lower=GetLowerCI(proportion_veridical_generation_500),Top=GetTopCI(proportion_veridical_generation_500))
  
  p <- ggplot(
    toPlot_veridical,
    aes(
      x = proportion_task_A,
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
  #     proportion_task_A,
  #     proportion_veridical_generation_500
  #     )
  
  #df_veridical <- data %>% group_by(proportion_task_A)
  
  #df_veridical <- data %>% gather(proportion_task_A)
  
  
  GetLowerCI <- function(x){return(t.test(x)$conf.int[1])}
  GetTopCI <- function(x){return(t.test(x)$conf.int[2])}
  
  toPlot_invertible <- data %>% group_by(proportion_task_A) %>% summarize(Mean=mean(average_invertability_generation_500),Lower=GetLowerCI(average_invertability_generation_500),Top=GetTopCI(average_invertability_generation_500))
  
  p <- ggplot(
    toPlot_invertible,
    aes(
      x = proportion_task_A,
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

