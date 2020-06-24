#Main function for simulating the games
function simulate(initial_players)
    next_players = initial_players

    for generation = 1:n_generations
        println("num strategies: ", count_strategies(next_players))
        current_players = next_players

        fitness_payoffs = zeros(n_players) #tracks average fitness payoffs from each game
        for game = 1:n_games
            options = rand(1:set_size, n_options_per_game)
            #players choose which option to take. their payoff is the utility of their choice
            for i = 1:n_players
                fitness_payoffs[i] = fitness_payoffs[i] + player_makes_choice(current_players[i,:], utility, options)
            end
        end
        #fitness_payoffs = fitness_payoffs./n_games

        #reproduce
        selected_parents = select_parents(current_players, fitness_payoffs)
        next_players = mutate(current_players, selected_parents)
    end

    #end_players are weighted sample, not mutated
    #like taking a weighted sample in particle filtering
    #println("num strategies: ", count_strategies(current_players[selected_parents, :]))
    #end_players = current_players[selected_parents, :]
    #println(countmemb(selected_parents))

    println("num strategies: ", count_strategies(next_players))
    end_players = next_players

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
        exp_utilities[c] = mean(utility[tf]) #mean or mode? mean right?
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
    selected_option = sample(options[matches]) #choose one of those options of that color

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
    normalized_fitness_payoffs = fitness_payoffs/sum(fitness_payoffs) #just in case all the payoffs are zeros

    #have number of offspring proportional to fitness_payoff
    #resample players with weights proportional to fitness_payoff

    selected_parents = sample(1:n_players, Weights(normalized_fitness_payoffs), n_players, replace = true)
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

#how many different strategies are there?
function count_strategies(players)
    n_players = size(players)[1]
    processed_players = Array{String}(undef, n_players)
    for i = 1:n_players
        processed_players[i] = join(players[i,:])
    end
    return length(unique(processed_players))
end
