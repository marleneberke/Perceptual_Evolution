include("helper_functions.jl")

using StatsBase

# First pass at model

set_size = 11 #means base things off of 0,...,10

# Initialize a population of players
n_players = 1000
initial_players = Matrix{String}(undef, n_players, set_size)
colors = ["r", "g"] #the colors players can perceive
for i = 1:n_players
    initial_players[i,:] = sample(colors, set_size)
end

n_generations = 1000
n_games = 1 #number of games played per n_generations
utility = [0, 1, 3, 6, 9, 10, 9, 6, 3, 1, 0] #length==set_size
n_options_per_game = 2 #number of resources to choose from each games
mutation_probability_per_gene = 0.001 #probability of one of the set_size genes mutating

end_players = simulate(initial_players)

#look at end_players
processed_end_players = Array{String}(undef, n_players)
for i = 1:n_players
    processed_end_players[i] = join(end_players[i,:])
end
println(countmemb(processed_end_players))

(strategy, count) = get_mode_strategy(processed_end_players)
