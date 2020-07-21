#All arguments are strings. The ones with brackets (Args 1-3) have to be in quotations.
#First argument is a matrix where the top row is utility function A,
#and the second row is utility function B.
#Second argument is a list of alpha_A and alpha_B
#Third argument is a list of beta_A and beta_B
#Fourth argument is the number of options per game
#Fifth argument is a number used in naming the output file

using Distributions

include("helper_functions_corr_tasks.jl")
include("homebrew_sampling.jl") #instead of StatsBase

n_generations = 10
set_size = 11
n_tasks = 2

utilities = Matrix{Float64}(undef, n_tasks, set_size)
s = split(strip(ARGS[1], ['[',']']), ";")
utilities[1,:] = parse.(Float64, split(s[1]))
utilities[2,:] = parse.(Float64, split(s[2]))
println("utilities ", utilities)
#outfile = string("output", ARGS[2], ".csv")
#outfile = string("output222.csv")
#correlation = parse(Float64, ARGS[1])
#correlation = 0.5

alphas = parse.(Float64, split(strip(ARGS[2], ['[',']'])))
betas = parse.(Float64, split(strip(ARGS[3], ['[',']'])))

n_options_per_game = parse(Int64, ARGS[4])
#n_options_per_game = 3

outfile = string("output", ARGS[5], ".csv")
#outfile = string("output222.csv")

file = open(outfile, "w")

#file header
print(file, "exact_correlation_between_A_and_B", " & ")
#print(file, "binned_correlation_between_A_and_B", " & ")
print(file, "n_options_per_game", " & ")
print(file, "utilities", " & ")
print(file, "alphas_of_utilities", " & ")
print(file, "betas_of_utilities", " & ")
print(file, "how_many_functions_are_monotonic", " & ")
print(file, "area_of_intersection", " & ")
for generation = 0:n_generations-1
	print(file, "proportion_veridical_generation_", generation, " & ")
	print(file, "average_invertability_generation_", generation, " & ")
end
print(file, "frequency_table_of_perceptual_systems_generation_", n_generations, " & ")
print(file, "proportion_veridical_generation_", n_generations, " & ")
print(file, "average_invertability_generation_", n_generations, "\n")

rho = cor(utilities[1,:], utilities[2,:])
print(file, rho, " & ")
# j = floor((rho + 1)/by)+1
# j = convert(Int64, j)
# print(file, j, " & ")
print(file, n_options_per_game, " & ")

set_size = 11 #means base things off of 0,...,10

# Initialize a population of players
n_players = 1000
initial_players = Matrix{String}(undef, n_players, set_size)
colors = ["r", "g"] #the colors players can perceive
for i = 1:n_players
    initial_players[i,:] = homebrew_sample(colors, set_size)
end

n_tasks = 2
n_games = 2 #number of games played per n_generations
#n_options_per_game = 5 #number of resources to choose from each games
mutation_probability_per_gene = 0.001 #probability of one of the set_size genes mutating
probability_of_task_A = 0.5

is_monotonic_utility = Array{Bool}(undef, n_tasks)
for task = 1:n_tasks
	is_monotonic_utility[task] = is_monotonic(utilities[task, :])
end
print(file, utilities, " & ")
print(file, alphas, " & ")
print(file, betas, " & ")
print(file, sum(is_monotonic_utility), " & ")
print(file, area_of_intersection(utilities), " & ")

#simulate and print to output file
end_players = simulate(initial_players, file)

#look at end_players
processed_end_players = process_players(end_players)
println(countmemb(processed_end_players))

println("proportion of veridical strategies ", proportion_veridical(end_players))

(strategy, count) = get_mode_strategy(processed_end_players)

close(file)
