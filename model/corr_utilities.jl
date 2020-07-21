#File for pre-computing utility functions for correlation task
include("helper_functions_corr_tasks.jl")

n_bins = 100 #n_levels
by = 2/n_bins
correlations = collect(-1:by:1)
bins = zeros(100) #will keep track of if there were enough per bin
n_pairs_at_each_correlation_level = 9 #n_runs_of_each

set_size = 11
n_tasks = 2*n_pairs_at_each_correlation_level*n_bins

#the utilities will be arranged such that the first bin pairs come first, then the second bin pairs, etc
#so first 18 utilities are pairs from bin 1
utilities = Matrix{Float64}(undef, n_tasks, set_size)
alphas = Array{Float64}(undef, n_tasks)
betas = Array{Float64}(undef, n_tasks)

while sum(bins .!= n_pairs_at_each_correlation_level) > 0 #while each bin doesn't have 9 as each value
    (x, alpha_x, beta_x) = sample_utility_function()
    (y, alpha_y, beta_y) = sample_utility_function()
    rho = cor(x, y)

    j = floor((rho + 1)/by)+1
    j = convert(Int64, j)
    @assert(correlations[j] < rho &&  rho < correlations[j+1])
    if bins[j] < n_pairs_at_each_correlation_level
        index = convert(Int64, (j-1)*n_pairs_at_each_correlation_level*2 + (2*bins[j]+1))
        alphas[index] = alpha_x
        alphas[index+1] = alpha_y
        betas[index] = beta_x
        betas[index+1] = beta_y
        utilities[index,:] = x
        utilities[index+1,:] = y

        bins[j] = bins[j]+1
    end
end

max_n_options_per_game = 11

outfile = string("jobfile_for_precomputed_corr_tasks.txt")
file = open(outfile, "w")


utility_functions = Matrix{Float64}(undef, 2, set_size)
i = 1
for j = 1:n_bins
    for run = 1:n_pairs_at_each_correlation_level
        for options = 1:max_n_options_per_game
            index = (j-1)*n_pairs_at_each_correlation_level*2 + (2*run-1)
            utility_functions[1,:] = utilities[index, :]
            utility_functions[2,:] = utilities[index+1, :]
            #println("utility_functions ", utility_functions)
            alpha = hcat(alphas[index], alphas[index+1])
            beta = hcat(betas[index], betas[index+1])
            #println("alpha ", alpha)
            print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia interface_project/execute_corr_tasks_with_precomputed_utilities.jl '", utility_functions, "' '", alpha, "' '", beta, "' ", options,  " ", i, "\n")
            global i = i+1
        end
    end
end

close(file)
