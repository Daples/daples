include("Tools.jl")

# data -> (n, p)
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

function eval_grid(grid, f)
    return f.(grid)
end

function mountain_clusters(data, dist, n_grid, σ, β; arg=nothing, n_iter=7)
    n, p = size(data)
    grid, aux = construct_grid(data, n_grid)
    # Iterate
    protos = zeros(1, p)
    fs = Vector{Function}([(v) -> sum(exp.(
        -dist(data, reshape(collect(v), (1, p)), arg).^2 / (2*σ^2)))])
    evals = []
    for k in 1:n_iter
        push!(evals, eval_grid(grid, fs[k]))
        protos = vcat(protos, reshape(collect(grid[argmax(evals[k])]), (1, p)))
        push!(fs, (v) -> fs[k](v) - fs[k](protos[k+1, :])*exp(
            - dist(reshape(protos[k+1, :], (1, p)), reshape(collect(v), (1, p)),
                arg)[1]^2 / (2*β^2)))
    end
    return protos[2:end, :], grid, aux, evals
end
