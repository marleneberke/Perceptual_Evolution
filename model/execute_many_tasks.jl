#First argument is an Int64 for the number of tasks
#Second argument is a number used in naming the output file

using Distributions

include("helper_functions_many_tasks.jl")
include("homebrew_sampling.jl") #instead of StatsBase

#using StatsBase

n_generations = 10

#outfile = string("output", ARGS[2], ".csv")
outfile = string("output222.csv")
file = open(outfile, "w")

#n_tasks = parse(Int64, ARGS[1])
n_tasks = 5

#file header
print(file, "number_of_tasks", " & ")
print(file, "utility_functions", " & ")
print(file, "how_many_functions_are_monotonic", " & ")
for generation = 0:n_generations-1
	print(file, "frequency_table_of_perceptual_systems_generation_", generation, " & ")
	print(file, "proportion_veridical_generation_", generation, " & ")
	print(file, "average_invertability_generation_", generation, " & ")
end
print(file, "frequency_table_of_perceptual_systems_generation_", n_generations, " & ")
print(file, "proportion_veridical_generation_", n_generations, " & ")
print(file, "average_invertability_generation_", n_generations, "\n")

print(file, n_tasks, " & ")

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

utilities = Matrix{Float64}(undef, n_tasks, set_size)
is_monotonic_utility = Array{Bool}(undef, n_tasks)
for task = 1:n_tasks
	utilities[task, :] = sample_utility_function()
	is_monotonic_utility[task] = is_monotonic(utilities[task, :])
end
print(file, utilities, " & ")
print(file, sum(is_monotonic_utility), " & ")

#simulate and print to output file
end_players = simulate(initial_players, file)

#look at end_players
processed_end_players = process_players(end_players)
println(countmemb(processed_end_players))

println(proportion_veridical(end_players))

(strategy, count) = get_mode_strategy(processed_end_players)

close(file)
