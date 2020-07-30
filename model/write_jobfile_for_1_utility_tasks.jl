n_runs_of_each_level = 10000

outfile = string("jobfile_for_1_utility_tasks.txt")
file = open(outfile, "w")

for run = 1:n_runs_of_each_level
    print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia interface_project/execute_1_utility_tasks.jl ", run, "\n")
    global i = i+1
end

close(file)
