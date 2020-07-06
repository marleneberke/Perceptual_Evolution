include("homebrew_sampling.jl")

#Main function for simulating the games
function simulate(current_players, file)
    selected_parents = 1:n_players #just initializing to make this global

    #print initial population to file
    print_to_file(file, current_players)

    for generation = 1:n_generations
        fitness_payoffs = zeros(n_players) #tracks average fitness payoffs from each game
        for game = 1:n_games
            options = rand(1:set_size, n_options_per_game)
            #players choose which option to take. their payoff is the utility of their choice
            #utility = utilities[:, game] #each game uses a different utility function

            task = homebrew_sample(collect(1:n_tasks), 1) #equal probability of selecting each task
            utility = utilities[task, :]

            for i = 1:n_players
                fitness_payoffs[i] = fitness_payoffs[i] + player_makes_choice(current_players[i,:], utility, options)
            end
        end

        #reproduce
        selected_parents = select_parents(current_players, fitness_payoffs)
        println("num strategies before mutation: ", count_strategies(current_players[selected_parents, :]))
        next_players = mutate(current_players, selected_parents)
        println("num strategies after mutation: ", count_strategies(next_players))

        if generation < n_generations #skip this the last time
            current_players = next_players
            #print population to file
            print_to_file(file, current_players)
        else #last time
            print_to_file(file, current_players, true)
        end
    end

    #end_players are weighted sample, not mutated
    #like taking a weighted sample in particle filtering
    end_players = current_players[selected_parents, :]
    println("num strategies at end: ", count_strategies(end_players))

    return end_players
end

#Returns the color preferences of a player in rank order
#Inputs:
#player is the perceptual system
#utility is the utility function
function rank_preferences(player, utility)
    #which color has the highest expected utility?
    exp_utilities = zeros(length(colors))
    for c = 1:length(colors)
        color = colors[c]
        tf = player.==color
        exp_utilities[c] = sum(utility[tf])/sum(tf) #mean
    end
    ordered = sortperm(exp_utilities, rev=true) #sorted in order of preference
    ranked_preferences = colors[ordered]
    return ranked_preferences
end

#Returns the utility associated with the choice the player makes
#Inputs:
#player is the perceptual system
#utility is the utility function
#options are the options the player gets to choose between
function player_makes_choice(player, utility, options)
    #which color has the highest expected utility?
    ranked_preferences = rank_preferences(player, utility)
    perceived_options = player[options]

    i = 1
    matches = perceived_options.==ranked_preferences[i]
    while sum(matches)==0 #if the best color isn't among the options, go to next best
        i = i+1
        matches = perceived_options.==ranked_preferences[i]
    end
    selected_option = rand(options[matches]) #choose one of those options of that color

    return utility[selected_option]
end

#Returns the selected parents by sampling from current_players weighted by their payoff function
#Inputs:
#current_players is the perceptual system
#fitness_payoff is the fitness of each of the current_players
function select_parents(current_players, fitness_payoffs)
    n_players = size(current_players)[1]

    if sum(fitness_payoffs)==0 #if all the payoffs were 0, make all the fitnesses equal
        fitness_payoffs = repeat([1], n_players)
    end
    #have number of offspring proportional to fitness_payoff
    #resample players with weights proportional to fitness_payoff
    selected_parents = homebrew_sample(collect(1:n_players), fitness_payoffs, n_players)
    return selected_parents
end

#Returns mutated version of selected selected_parents
#Inputs:
#current_players is the perceptual system
#selected_parents are the ones that are going to reproduce
function mutate(current_players, selected_parents)
    set_size = size(current_players)[2]
    next_players = Matrix{String}(undef, n_players, set_size)
    for i=1:length(selected_parents)
        for j=1:set_size
            if rand()<mutation_probability_per_gene #pick randomly from colors
                next_players[i,j] = rand(colors)
            else
                next_players[i,j] = current_players[selected_parents[i],j]
            end
        end
    end
    return next_players
end

#Useful for processing
function countmemb(itr)
    d = Dict{String, Int}()
    for val in itr
        if isa(val, Number) && isnan(val)
            continue
        end
        d[string(val)] = get!(d, string(val), 0) + 1
    end
    return d
end

#Just joins the "r" and "g"s into one big string
function process_players(players)
    processed_players = Array{String}(undef, n_players)
    for i = 1:n_players
        processed_players[i] = join(players[i,:])
    end
    return processed_players
end

#function for printing a frequency table to the file
#inputs are the file to print to, the players, and a boolean for whether this is the last thing to print or not
function print_to_file(file, players, last_time::Bool=false)
    processed_players = process_players(players)
    if ~last_time
        print(file, countmemb(processed_players), " & ")
        print(file, proportion_veridical(players), " & ")
        print(file, average_invertability(players), " & ")
    else
        print(file, countmemb(processed_players), " & ")
        print(file, proportion_veridical(players), " & ")
        print(file, average_invertability(players))
    end
end

#Get mode strategy from a dictionary
#Returns the mode strategy strategyand the number of players count with that strategy
#Input is the players processed such that each player is an element of type string in an array
function get_mode_strategy(processed_players::Array{String})
    dictionary = countmemb(processed_players)
    frequency = Dict()
    for (k, v) in dictionary
        if haskey(frequency, v)
            push!(frequency[v],k)
        else
            frequency[v] = [k]
        end
    end

    arr = collect(keys(frequency))
    arr_as_numeric = convert(Array{Int64,1}, arr)
    count = maximum(arr_as_numeric) #finding mode
    #length(frequency_Vs[m])==1 ? V = frequency_Vs[m] : V = frequency_Vs[m][1] #in case of tie, take the first V
    strategy = frequency[count][1]
    return (strategy, count)
end

#how many different strategies are there?
function count_strategies(players)
    n_players = size(players)[1]
    processed_players = Array{String}(undef, n_players)
    for i = 1:n_players
        processed_players[i] = join(players[i,:])
    end
    return length(unique(processed_players))
end

#Given a player, says whether they are veridical or not
function is_veridical(player)
    color_order = []
    push!(color_order, player[1])
    i = 2
    while length(color_order) < 3 & i <= length(player)
        if player[i] !== color_order[length(color_order)]
            push!(color_order, player[i])
        end
        i = i+1
    end
    return length(color_order) < 3
end

#Given a matrix of players, returns the percentage that are veridical
function proportion_veridical(players)
    n_players = size(players)[1]
    how_many_veridical = 0
    for i = 1:n_players
        how_many_veridical = how_many_veridical + is_veridical(players[i,:])
    end
    return how_many_veridical/n_players
end

#Calculates a metric of how invertable a player's represention of the
#world (the set) is
#When two colors, it's how different the guesses would be. When three or more colors... unsure.
#Only implemented for two colors
function invertability(player)
    set = collect(1:set_size)
    @assert length(colors)==2
    guesses = Array{Float64}(undef, 2)
    for c = 1:length(colors)
        color = colors[c]
        if sum(player.==color)==0 #if one of the colors isn't present. preventing NANs
            guesses[c] = sum(set)/set_size #mean of the whole set
        else
            guesses[c] = sum(set[player.==color])/sum(player.==color) #guess as to value in set when you see that color
        end
    end
    return abs(guesses[1]-guesses[2])
end

#Given a matrix of players, returns the average invertability of the group
function average_invertability(players)
    n_players = size(players)[1]
    total_invertability = 0
    for i = 1:n_players
        total_invertability = total_invertability + invertability(players[i,:])
    end
    return total_invertability/n_players
end

#samples a utility function that approximates a beta distribution
function sample_utility_function()
    utility = Array{Float64}(undef, set_size)

    #sample alpha and beta between 0 and max. max seems to effect the shape of the average of utility functions
    max = 10
    alpha = rand()*max
    beta = rand()*max
    B = Beta(alpha, beta)

    for x = 0:(set_size-1) #making sure to include 0 and 1
        utility[x+1] = min(pdf(B, x/(set_size-1)), 99999999) #addresses Inf
    end

    #normalize the utility function so it sums to 1 (to prevent one task from outweighing the others)
    utility = utility/sum(utility)
    return utility
end

#checks if a utility function is monotonic
function is_monotonic(utility::Array{Float64})
    i = 2
    while utility[i-1] == utility[i]
        i = i+1
    end #now utility[i-1] != utility[i]
    increasing = utility[i-1] < utility[i]
    if increasing
        while (i <= set_size) && (utility[i-1] < utility[i])
            i = i+1
        end
    else #decreasing
        while (i <= set_size) && (utility[i-1] > utility[i])
            i = i+1
        end
    end
    return i>set_size #if made it all the way to set_size, it's monotonic
end

#just out of curiosity, what would the average of current way of sampling the utility function look like?
function check()
    avg_utility = zeros(set_size)
    n = 10000
    for i = 1:n
        avg_utility = avg_utility + sample_utility_function()
    end
    return avg_utility/n
end
