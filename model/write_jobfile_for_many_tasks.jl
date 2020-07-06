n_levels = 100
n_runs_of_each_level = 10

outfile = string("jobfile_for_many_tasks.txt")
file = open(outfile, "w")

i = 1
for level = 1:n_levels
    for run = 1:n_runs_of_each_level
        print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia interface_project/execute_A.B_task.jl ", level, " ", i, "\n")
        global i = i+1
    end
end

close(file)
