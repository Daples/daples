using Plots

include("K-Means.jl")
include("Tools.jl")
include("Mountain.jl")
include("Fuzzy-C-Means.jl")
include("Subtractive-Clustering.jl")

## Read Iris Dataset
data, tags = read_iris("iris.data")
dist = euclidean

## Mountain
n_grid = 25
σ = 0.1
β = 0.3
data, protos_mount, grid, aux, evals_mount = mountain_cluster(
    data, dist, n_grid, σ, β; n_it = 10, γ=0.4, arg=nothing, norm=true
)
k = size(protos_mount, 1)


## Subtractive
rₐ = 0.1
_, protos_sub, evals_sub = subtractive_cluster(
    data, dist, rₐ; γ=0.4, n_it=10, arg=nothing, norm=true
)

## K-Means
_, protos_kmeans, U_kmeans, improvs_kmeans = k_means(
    data, k, dist; γ=0.001, arg=nothing, norm=true
)

## Fuzzy C-Means
m = 2
_, protos_cmeans, U_cmeans, improvs_cmeans = fuzzy_c_means(
    data, k, dist, m; γ=0.001, arg=nothing, norm=true
)

## Output Plots
p = size(data, 2)
for j in 0:(p-1)
    k1 = j % p + 1
    k2 = (j+1) % p + 1
    k3 = (j+2) % p + 1
    plot_3DClusters(protos_cmeans[:, k1:sign(k3-k1):k3], U_cmeans,
        data[:, k1:sign(k3-k1):k3], "test$j.pdf", ("x$k1", "x$k2", "x$k3")
    )
end
