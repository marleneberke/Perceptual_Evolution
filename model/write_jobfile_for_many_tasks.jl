n_levels = 100
n_runs_of_each_level = 10
max_n_options_per_game = 10

outfile = string("jobfile_for_many_tasks.txt")
file = open(outfile, "w")

i = 1
for level = 1:n_levels
    for run = 1:n_runs_of_each_level
        for options = 1:max_n_options_per_game
            print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia interface_project/execute_many_tasks.jl ", level, " ", i, " ", options, "\n")
            global i = i+1
        end
    end
end

close(file)
