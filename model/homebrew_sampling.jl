#Sample n times from the array_to_sample_from with replacement
function homebrew_sample(array_to_sample_from::Array, n::Int)
    array_to_return = []
    for i=1:n
        push!(array_to_return, rand(array_to_sample_from))
    end
    return array_to_return
end

#Sample n times from the array_to_sample_from with replacement. Weight each element
#in array_to_sample_from with a weight
function homebrew_sample(array_to_sample_from::Array, weights::Array, n::Int)
    weights = weights/sum(weights) #normalize just in case
    array_to_return = []
    for i=1:n
        r = rand() #produce a random number between 0 and 1
        w = 1
        while rand() > sum(weights[1:w])
            w = w+1
        end
        push!(array_to_return, array_to_sample_from[w])
    end
    return array_to_return
end
