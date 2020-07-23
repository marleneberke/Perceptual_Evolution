levels = [1 2 5 10 30 40 50 100]
penalties = [0, 0.001, 0.01, 0.025, 0.05, 0.075, 0.10, 0.125, 0.15, 1] #can have 12 without changing anything else
n_runs_of_each_level = 11
max_n_options_per_game = 11

outfile = string("jobfile_for_many_tasks.txt")
file = open(outfile, "w")

i = 1
for level in levels
    for run = 1:n_runs_of_each_level
        for options = 1:max_n_options_per_game
            for penalty in penalties
                print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia interface_project/execute_many_tasks_penalty_version.jl ", level, " ", i, " ", options, " ", penalty, "\n")
                global i = i+1
            end
        end
    end
end

close(file)
