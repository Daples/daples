using StatsBase
include("Tools.jl")

function cost_fun(U, dists)
    return sum(U .* dists)
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
        U, dists = find_membership(data, dist, protos, arg)
        protos = (U * data) ./ sum(U, dims=2)
        # Evaluate improvement
        prev_cost = cost
        cost = cost_fun(U, dists)
        improv = abs(prev_cost - cost)
        push!(improvs, improv)
    end
    U, _ = find_membership(data, dist, protos, arg)
    return data, protos, U, improvs
end
