n_runs = 10

outfile = string("jobfile.txt")
file = open(outfile, "w")

for i = 1:n_runs
    print(file, "singularity exec julia_test.sif /usr/local/julia/bin/julia execute_with_fully_trained_metagen_percept0.jl ", i, "\n")
end

close(file)
