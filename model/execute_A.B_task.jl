#First argument is a Float64 for the proportion of times that the task will be A
#Second argument is a number used in naming the output file

include("helper_functions_A.B_task.jl")
include("homebrew_sampling.jl") #instead of StatsBase

#using StatsBase

n_generations = 10

#outfile = string("output", ARGS[2], ".csv")
outfile = string("output222.csv")
file = open(outfile, "w")

#file header
print(file, "proportion_task_A", " & ")
for generation = 0:n_generations-1
	print(file, "frequency_table_of_perceptual_systems_generation_", generation, " & ")
	print(file, "proportion_veridical_generation_", generation, " & ")
	print(file, "average_invertability_generation_", generation, " & ")
end
print(file, "frequency_table_of_perceptual_systems_generation_", n_generations, " & ")
print(file, "proportion_veridical_generation_", n_generations, " & ")
print(file, "average_invertability_generation_", generation, "\n")

probability_of_task_A = 0.5
#probability_of_task_A = parse(Float64, ARGS[1])
print(file, probability_of_task_A, " & ")

set_size = 11 #means base things off of 0,...,10

# Initialize a population of players
n_players = 1000
initial_players = Matrix{String}(undef, n_players, set_size)
colors = ["r", "g"] #the colors players can perceive
for i = 1:n_players
    initial_players[i,:] = homebrew_sample(colors, set_size)
end


n_games = 2 #number of games played per n_generations
n_options_per_game = 5 #number of resources to choose from each games
mutation_probability_per_gene = 0.001 #probability of one of the set_size genes mutating


#utilities = [0, 1, 3, 6, 9, 10, 9, 6, 3, 1, 0; 0, 1, 3, 6, 9, 10, 9, 6, 3, 1, 0] #length==set_size

#dist_between_utilities = 5
utility_A = [1, 6, 10, 6, 1, 0, 0, 0, 0, 0, 0]
utility_B = [0, 0, 0, 0, 0, 0, 1, 6, 10, 6, 1]
utilities = hcat(utility_A, utility_B)

#simulate and print to output file
end_players = simulate(initial_players, file)

#look at end_players
processed_end_players = process_players(end_players)
println(countmemb(processed_end_players))

(strategy, count) = get_mode_strategy(processed_end_players)

close(file)
