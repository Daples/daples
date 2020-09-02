using StatsBase
include("Tools.jl")

# data -> (n, p)
# protos -> (k, p)
# U, dists -> (k, n)
function find_membership(data, k, dist, protos, arg)
    n = size(data, 1)
    U = zeros(k, n)
    p = size(protos, 2)
    dists = zeros(k, n)
    for j in 1:k
        dists[j, :] = dist(data, reshape(protos[j, :], (1, p)), arg)
    end
    indexes_min = argmin(dists, dims=1)
    U[indexes_min] .= 1
    return U, dists
end

function cost_fun(U, dists)
    return sum(dists*transpose(U))
end

function k_means(data, k, dist; γ=0.001, arg=nothing, norm=true)
    data = norm ? normalize(data) : data
    # Initialize prototypes
    n = size(data, 1)
    indexes = collect(1:n)
    selection = sample(indexes, k, replace=false)
    protos = data[selection, :]

    # Iterate k-means
    improv = Inf
    cost = 0
    improvs = []
    while improv >= γ
        # New groups and prototypes
        U, dists = find_membership(data, k, dist, protos, arg)
        protos = (U * data) ./ sum(U, dims=2)
        # Evaluate improvement
        prev_cost = cost
        cost = cost_fun(U, dists)
        improv = abs(prev_cost - cost)
        push!(improvs, improv)
    end
    U, _ = find_membership(data, k, dist, protos, arg)
    return data, protos, U, improvs
end
