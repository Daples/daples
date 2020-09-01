using Distributions
using Plots
include("K-means.jl")
include("Tools.jl")
include("Mountain.jl")

# Create mixture
p = 2;
k = 2;
n = 100;
b = 1;
data = rand(MvNormal(rand_params_MvN(0, b, p)...), n)'
for j in 1:k-1
    global data = vcat(data, rand(MvNormal(rand_params_MvN(0, b, p)...), n)')
end

# Test K-Means with mixture
# protos, U, improvs = k_means(data, k, euclidean)
# plot_clusters(protos, U, data, "test_k_means.pdf")

# Test Mountain Clusters with mixture
protos, grid1, aux, evals = mountain_clusters(data, euclidean, 0.1, 100, 1)
