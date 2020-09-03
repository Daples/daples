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
data, protos_mount, U_mount, grid, aux, evals_mount = mountain_cluster(
    data, dist, n_grid, σ, β; n_it = 10, γ=0.4, arg=nothing, norm=true
)
k = size(protos_mount, 1)


## Subtractive
rₐ = 0.5
_, protos_sub, U_sub, evals_sub = subtractive_cluster(
    data, dist, rₐ; ϵ_up = 0.5, ϵ_down = 0.15, n_it=10, arg=nothing, norm=true
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
# Mountain
plot_nDimData(protos_mount, U_mount, data, "mountain-Iris")
plot_nDimData(protos_sub, U_sub, data, "subtractive-Iris")
plot_nDimData(protos_kmeans, U_kmeans, data, "k-Means-Iris")
plot_nDimData(protos_cmeans, U_cmeans, data, "fuzzy-C-Means-Iris")
