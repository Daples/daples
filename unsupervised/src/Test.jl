using Distributions
using Plots

include("K-means.jl")
include("Tools.jl")
include("Mountain.jl")

# Create mixture
p = 2;
k = 2;
n = 1000;
b = 10;
data = rand(MvNormal(rand_params_MvN(0, b, p)...), n)';
for j in 1:k-1
    global data = vcat(data, rand(MvNormal(rand_params_MvN(0, b, p)...), n)')
end

# Test K-Means with mixture
# protos, U, improvs = k_means(data, k, euclidean)
# plot_k_means(protos, U, data, "test_k_means.pdf")

# Test Mountain Clusters with mixture
# protos, _, aux, evals = mountain_clusters(data, euclidean, 20, 1, 1, n_iter=k)
# plot_mountains(protos, data, "test_mountain.pdf")
