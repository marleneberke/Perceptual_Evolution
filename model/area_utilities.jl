#File for pre-computing utility functions for area task
include("helper_functions_corr_tasks.jl")

max_n_options_per_game = 11

n_bins = 100 #n_levels
start = 0.3
by = (1-start)/n_bins
areas = collect(start:by:1)
bins = zeros(100) #will keep track of if there were enough per bin
n_repeats = 9
n_pairs_at_each_area_level = n_repeats*max_n_options_per_game #n_runs_of_each

set_size = 11
n_tasks = 2*n_pairs_at_each_area_level*n_bins

#the utilities will be arranged such that the first bin pairs come first, then the second bin pairs, etc
#so first 18 utilities are pairs from bin 1
utilities = Matrix{Float64}(undef, n_tasks, set_size)
alphas = Array{Float64}(undef, n_tasks)
betas = Array{Float64}(undef, n_tasks)

x_y = Matrix{Float64}(undef, 2, set_size)
while sum(bins .!= n_pairs_at_each_area_level) > 0 #while each bin doesn't have 9 as each value
    (x, alpha_x, beta_x) = sample_utility_function()
    (y, alpha_y, beta_y) = sample_utility_function()
    x_y[1,:] = x
    x_y[2,:] = y
    area = area_of_intersection(x_y)

    j = floor((area-start)/by)+1
    j = convert(Int64, j)
    if j > 0 #if it's less than zero, sampled below start
        @assert(areas[j] < area &&  area < areas[j+1])
        if bins[j] < n_pairs_at_each_area_level
            index = convert(Int64, (j-1)*n_pairs_at_each_area_level*2 + (2*bins[j]+1))
            alphas[index] = alpha_x
            alphas[index+1] = alpha_y
            betas[index] = beta_x
            betas[index+1] = beta_y
            utilities[index,:] = x
            utilities[index+1,:] = y

            bins[j] = bins[j]+1
        end
    end
end

outfile = string("jobfile_for_precomputed_area_tasks.txt")
file = open(outfile, "w")

utility_functions = Matrix{Float64}(undef, 2, set_size)
i = 1
for j = 1:n_bins
    k = 1
    for run = 1:n_repeats
        for options = 1:max_n_options_per_game
            index = (j-1)*n_repeats*max_n_options_per_game*2 + k
            utility_functions[1,:] = utilities[index, :]
            utility_functions[2,:] = utilities[index+1, :]
            #println("utility_functions ", utility_functions)
            alpha = hcat(alphas[index], alphas[index+1])
            beta = hcat(betas[index], betas[index+1])
            #println("alpha ", alpha)
            print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia interface_project/execute_corr_tasks_with_precomputed_utilities.jl '", utility_functions, "' '", alpha, "' '", beta, "' ", options,  " ", i, "\n")
            global i = i+1
            k = k+1
        end
    end
end

close(file)
