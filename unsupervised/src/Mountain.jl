include("Tools.jl")

# Construct grid
#   data -> (n, p) dataset matrix
#   n_grid -> Number of points on each dimension
function construct_grid(data, n_grid)
    n, p = size(data)
    uppers = data[argmax(data, dims=1)]
    lowers = data[argmin(data, dims=1)]
    aux = []
    for i in 1:p
        h = (uppers[i] - lowers[i]) / n_grid
        push!(aux, lowers[i]:h:uppers[i])
    end
    grid = collect(Iterators.product(aux...))
    return grid, aux
end

# Evaluate function with each point on the grid
#   grid -> (n₁,...,nₚ) matrix
#   f -> Function to apply
function eval_grid(grid, f)
    return f.(grid)
end

# Algorithm
# Algorithm
#   data -> (n, p) dataset matrix
#   dist -> Similarity function
#   n_grid -> Number of points on each dimension
#   σ -> Original neighborhood parameter in initial density
#   β -> Update neighborhood in new density
#   n_it -> Maximum number of iterations
#   arg -> Additional parameter for similarity function
#   γ -> Tolerance for stop criterion
#   norm -> Whether the data will be normalized or not
function mountain_cluster(data, dist, n_grid, σ, β;
    n_it = 10, γ=0.4, arg=nothing, norm=true
)
    # Normalize data
    data = norm ? normalize(data) : data
    n, p = size(data)
    # Construct grid
    grid, aux = construct_grid(data, n_grid)
    # Define the initial density function
    fs = Vector{Function}([(v) -> sum(exp.(
        -dist(data, reshape(collect(v), (1, p)), arg).^2 / (2*σ^2)))])
    # Iterate
    evals = []
    for k in 1:n_it
        # Find the point with maximum density
        push!(evals, eval_grid(grid, fs[k]))
        ind_max = argmax(evals[k])
        pₖ = reshape(collect(grid[ind_max]), (1, p))
        if k == 1
            global M = evals[k][ind_max]
            global protos = pₖ
        else
            # Stop criterion or accept cluster center
            Mk = evals[k][ind_max]
            if abs(Mk/M) < γ
                break
            else
                protos = vcat(protos, pₖ)
            end
        end
        # Update density function
        push!(fs, (v) -> fs[k](v) - fs[k](protos[k, :])*exp(
            - dist(reshape(protos[k, :], (1, p)), reshape(collect(v), (1, p)),
                arg)[1]^2 / (2*β^2)))
    end
    # Find the nearest points to the found clusters
    U, _ = find_membership(data, dist, protos, arg)
    return data, protos, U, grid, aux, evals[1:end-1]
end
