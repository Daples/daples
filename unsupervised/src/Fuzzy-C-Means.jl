
include("Tools.jl")

function initialize_membership(c, n)
    U = zeros(c, n)
    for j in 1:n
        r = rand(c, 1)
        U[:, j] = r / sum(r)
    end
    return U
end

function cost_fun(Uᵐ, dists)
    return sum(dists.^2 * transpose(Uᵐ))
end

# data (n, p)
# protos (c, p)
# U, dists (c, n)
function fuzzy_c_means(data, c, dist, m; γ=0.001, arg=nothing)
    n, p = size(data)
    # Initialize
    U = initialize_membership(c, n)
    Uᵐ = U.^m
    # Iterate
    improv = Inf
    dists = zeros(k, n)
    cost = 0
    improvs = []
    while improv >= γ
        # Find current clusters
        global protos = Uᵐ * data ./ sum(Uᵐ, dims=2)
        for j in 1:k
            dists[j, :] = dist(data, reshape(protos[j, :], (1, p)), arg)
        end
        # Evaluate improvement
        prev_cost = cost
        cost = cost_fun(Uᵐ, dists)
        improv = abs(prev_cost - cost)
        push!(improvs, improv)
        # New memberships
        U = 1 ./ (c * dists ./ sum(dists, dims=1)).^(2/(m - 1))
        Uᵐ = U.^m
    end
    return protos, U, improvs
end
