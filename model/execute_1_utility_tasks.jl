#First argument is an Int64 for the number of tasks
#Second argument is a number used in naming the output file
#Third argument is a number of options to give

using Distributions

include("helper_functions_1_utility_tasks.jl")
include("homebrew_sampling.jl") #instead of StatsBase

n_generations = 1000

#outfile = string("output", ARGS[1], ".csv")
#outfile = string("output222.csv")
#n_tasks = parse(Int64, ARGS[1])
n_tasks = 1

# file = open(outfile, "w")
#
# #file header
# print(file, "number_of_tasks", " & ")
# print(file, "utility_functions", " & ")
# print(file, "alphas_of_utility_functions", " & ")
# print(file, "betas_of_utility_functions", " & ")
# print(file, "how_many_functions_are_monotonic", " & ")
# for generation = 0:n_generations-1
# 	print(file, "proportion_veridical_generation_", generation, " & ")
# 	print(file, "average_invertability_generation_", generation, " & ")
# 	print(file, "mode_veridical?_generation_", generation, " & ")
# end
# print(file, "proportion_veridical_generation_", n_generations, " & ")
# print(file, "average_invertability_generation_", n_generations, " & ")
# print(file, "mode_veridical?_generation_", n_generations, " & ")
# print(file, "frequency_table_of_perceptual_systems_generation_", n_generations, "\n")
#
# print(file, n_tasks, " & ")

set_size = 11 #means base things off of 0,...,10

# Initialize a population of players
n_players = 1000
initial_players = Matrix{String}(undef, n_players, set_size)
colors = ["r", "g"] #the colors players can perceive
for i = 1:n_players
    initial_players[i,:] = homebrew_sample(colors, set_size)
end


n_games = 100
mutation_probability_per_gene = 0.001 #probability of one of the set_size genes mutating

utilities = Matrix{Float64}(undef, n_tasks, set_size)
alphas = Array{Float64}(undef, n_tasks)
betas = Array{Float64}(undef, n_tasks)
is_monotonic_utility = Array{Bool}(undef, n_tasks)
for task = 1:n_tasks
	utilities[task, :], alphas[task], betas[task] = sample_utility_function_non_monotonic()
	is_monotonic_utility[task] = is_monotonic(utilities[task, :])
end
# print(file, utilities, " & ")
# print(file, alphas, " & ")
# print(file, betas, " & ")
# print(file, sum(is_monotonic_utility), " & ")

#simulate and print to output file
end_players = simulate(initial_players)

#look at end_players
processed_end_players = process_players(end_players)
println(countmemb(processed_end_players))

println(proportion_veridical(end_players))

#print utilities, alpha, and beta to a file if <0.02 veridical at end of simulation
if proportion_veridical(end_players) < 0.02
	name = string("utility", ARGS[1], ".csv")
	#name = "utility222.csv"
	utility_file = open(name, "w")
	print(utility_file, "utility_function", " & ")
	print(utility_file, "alpha_of_utility_function", " & ")
	print(utility_file, "beta_of_utility_function", "\n")
	print(utility_file, utilities, " & ") #there's just one. left over names
	print(utility_file, alphas, " & ")
	print(utility_file, betas)
	close(utility_file)
end

(strategy, count) = get_mode_strategy(processed_end_players)

# close(file)
