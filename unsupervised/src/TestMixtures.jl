using Distributions
using Plots

include("K-Means.jl")
include("Tools.jl")
include("Mountain.jl")
include("Fuzzy-C-Means.jl")
include("Subtractive-Clustering.jl")

# Create mixture
p = 3;
k = 2;
n = 250;
b = 22;
data = rand(MvNormal(rand_params_MvN(0, b, p)...), n)';
for j in 1:k-1
    global data = vcat(data, rand(MvNormal(rand_params_MvN(0, b, p)...), n)')
end

# Test K-Means with mixture
# data, protos, U, improvs = k_means(data, k, euclidean)
# plot_k_clusters(protos, U, data, "mixture_k_means.pdf")

# Test Mountain Clusters with mixture
# data, protos, _, aux, evals = mountain_cluster(data, euclidean, 100, 0.1, 0.2)
# plot_density_clusters(protos, data, "mixture_mountain.pdf")

# Test Fuzzy C Means
# data, protos, U, improvs = fuzzy_c_means(data, k, euclidean, 2)
# plot_k_clusters(protos, U, data, "mixture_fuzzy_c_means.pdf")

# Test Subtractive
# data, protos, evals = subtractive_cluster(data, euclidean, 0.2)
# plot_density_clusters(protos, data, "mixture_subtractive.pdf")

# Test 3D Cluster
