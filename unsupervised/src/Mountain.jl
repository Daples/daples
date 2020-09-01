# data -> (n, p)
function construct_grid(data, h)
    n, p = size(data)
    uppers = data[argmax(data, dims=1)]
    lowers = data[argmin(data, dims=1)]
    aux = []
    for i in 1:p
        push!(aux, lowers[i]:h:uppers[i])
    end
    grid = collect(Iterators.product(aux...))
    return grid, aux
end

function eval_grid(grid, f)
    return f.(grid)
end

function mountain_clusters(data, dist, h, σ, β; arg=nothing, n_iter=10)
    n, p = size(data)
    grid, aux = construct_grid(data, h)
    # Iterate
    protos = zeros(1, p)
    fs = Vector{Function}([(v) -> sum(exp.(-dist(data, reshape(collect(v), (1, p)), arg).^2 / (2*σ^2)))])
    for k in 1:n_iter
        evals = eval_grid(grid, fs[k])
        protos = vcat(protos, reshape(collect(grid[argmax(evals)]), (1, p)))
        push!(fs, (v) -> fs[k](v) - fs[k](protos[k, :])*exp(-dist(protos[k, :], reshape(collect(v), (1, p)), arg)^2 / (2*β^2)))
    end
    return protos[1:end, :], grid, aux, evals
end
