n_levels = 100
n_runs_of_each = 9
max_n_options_per_game = 11

outfile = string("jobfile_for_corr_tasks.txt")
file = open(outfile, "w")

#correlation should range from [-1, 1]
corr = [-1:2/n_levels:1;]

i = 1
for level = 1:n_levels+1
    for run = 1:n_runs_of_each
        for options = 1:max_n_options_per_game
            print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia interface_project/execute_corr_tasks.jl ", corr[level], " ", i, " ", options,"\n")
            global i = i+1
        end
    end
end

close(file)
