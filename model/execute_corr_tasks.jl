#First argument is a Float64 for the proportion of times that the task will be A
#Second argument is a number used in naming the output file

include("helper_functions_corr_tasks.jl")
include("homebrew_sampling.jl") #instead of StatsBase

#using StatsBase

n_generations = 1000

outfile = string("output", ARGS[2], ".csv")
#outfile = string("output222.csv")
correlation = parse(Float64, ARGS[1])
#correlation = 0.5
n_options_per_game = parse(Int64, ARGS[3])
#n_options_per_game = 3

file = open(outfile, "w")

#file header
print(file, "correlation_between_A_and_B", " & ")
print(file, "n_options_per_game", " & ")
for generation = 0:n_generations-1
	print(file, "frequency_table_of_perceptual_systems_generation_", generation, " & ")
	print(file, "proportion_veridical_generation_", generation, " & ")
	print(file, "average_invertability_generation_", generation, " & ")
end
print(file, "frequency_table_of_perceptual_systems_generation_", n_generations, " & ")
print(file, "proportion_veridical_generation_", n_generations, " & ")
print(file, "average_invertability_generation_", n_generations, "\n")

print(file, correlation, " & ")
print(file, n_options_per_game, " & ")

set_size = 11 #means base things off of 0,...,10

# Initialize a population of players
n_players = 1000
initial_players = Matrix{String}(undef, n_players, set_size)
colors = ["r", "g"] #the colors players can perceive
for i = 1:n_players
    initial_players[i,:] = homebrew_sample(colors, set_size)
end


n_games = 2 #number of games played per n_generations
#n_options_per_game = 5 #number of resources to choose from each games
mutation_probability_per_gene = 0.001 #probability of one of the set_size genes mutating
probability_of_task_A = 0.5

(utilities, alphas, betas) = sample_utility_function(correlation)
# utility_A = [1, 6, 10, 6, 1, 0, 0, 0, 0, 0, 0]
# utility_B = [0, 0, 0, 0, 0, 0, 1, 6, 10, 6, 1]
# utilities = hcat(utility_A, utility_B)

#simulate and print to output file
end_players = simulate(initial_players, file)

#look at end_players
processed_end_players = process_players(end_players)
println(countmemb(processed_end_players))

println("proportion of veridical strategies ", proportion_veridical(end_players))

(strategy, count) = get_mode_strategy(processed_end_players)

close(file)
