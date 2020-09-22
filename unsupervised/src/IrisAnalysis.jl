include("CountryAnalysis.jl")

data, tags = read_iris("data/iris.data")

## Statistical Analysis (over original data)
dig = 2
dir = "Data-Analysis-Iris"
h = "#############################################################\n"
# Mean Vector
μ = mean(data, dims = 1)
println(h, "Mean Vector:\n", round.(μ; digits=dig))

# Covariance Matrix
Σ = cov(data)
println("Covariance Matrix:")
print_2Dmatrix(round.(Σ, digits=dig))

# Screes (PCA) - Covariance
js, screes_cov = screes(data)
fig = plotPL(js, screes_cov, xlabel=L"j", ylabel=L"$\lambda_j$")
save(fig, "screes_cov_iris.pdf", dir=dir)

# Screes (PCA) - Correlation
js, screes_cor = screes(data, corr=true)
fig = plotPL(js, screes_cor, xlabel=L"j", ylabel=L"$\lambda_j$")
save(fig, "screes_cor_iris.pdf", dir=dir)

res = homogeneity(data, 75, "iris", legend=:topright)

# Multicollinearity
cΣ = cond(Σ);
println("Condition number of Covariance Matrix: ", cΣ);

new_data, rms, R, og_R = remove_collinear(data)
new_Σ = cov(new_data)
new_cΣ = cond(new_Σ)

res = homogeneity(new_data, 75, "new_dims_iris", legend=:topright)

## Unsupervised Learning
# Normalize data
norm_data = normalize(data)

# Dimension Reduction
red_data = normalize(tsne(data, 3))

# Set to 'true' to run the combinations
explore = false

# Explore space using normalized high-dimensions data
dataset_og = "og_iris"
dir_og = "OG-Iris-Analysis"
if explore
    explore_space(norm_data, dataset_og, dir_og)
end

# Explore space using normalized embedded-dimensions data
dataset_red = "red_iris"
dir_red = "Red-Iris-Analysis"
if explore
    explore_space(red_data, dataset_red, dir_red)
end

clusterize(norm_data, 3, dataset_og, dir_og)
clusterize(red_data, 3, dataset_red, dir_red)
