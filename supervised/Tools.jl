using Random, Distributions

# Normalize data with max|x_i| -> [-1,1] hypercube.
function normalize(data)
    return data ./ maximum(abs.(data), dims=1)
end

# Initialize a nxm matrix with [-1,1] uniformly distributed random numbers.
function init_weights(n, m; seed = nothing)
    isnothing(seed) : nothing ? Random.seed!(seed)
    return rand(Uniform(-1, 1), (n, m))
end
