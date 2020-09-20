include("Fuzzy-C-Means.jl");
include("K-Means.jl");
include("Mountain.jl");
include("Subtractive.jl");

include("Tools.jl");
include("PlotTools.jl");

# Read data
data, countries, header = read_countries("data/country-data.csv");

# Normalize data
norm_data = normalize(data);

## Statistical Analysis (over original data)
dig = 2
dir = "Data-Analysis"
h = "#############################################################\n"
# Mean Vector
μ = mean(data, dims = 1);
println(h, "Mean Vector:\n", round.(μ; digits=dig));

# Covariance Matrix
Σ = cov(data)
println("Covariance Matrix:");
print_2Dmatrix(round.(Σ, digits=dig));

# Screes (PCA) - Covariance
js, screes_cov = screes(data)
fig = plotPL(js, screes_cov, xlabel=L"j", ylabel=L"$\lambda_j$")
save(fig, "screes_cov.pdf", dir=dir)

# Screes (PCA) - Correlation
js, screes_cor = screes(data, corr=true)
fig = plotPL(js, screes_cor, xlabel=L"j", ylabel=L"$\lambda_j$")
save(fig, "screes_cor.pdf", dir=dir)

# Homogeneity test
function homogeneity(data, part, filename)
    # Depth scores
    S₁ = data[1:part, :]
    S₂ = data[part+1:end, :]
    Z₁, Z₂ = depths(S₁, S₂)
    fig = ddplot(Z₁, Z₂, "ddplot_"*filename*".pdf", dir=dir)
    return Z₁, Z₂, fig
end

res = homogeneity(data, 84, "og")

# Multicollinearity
cΣ = cond(Σ);
println(h, "Condition number of Covariance Matrix: ", cΣ);

new_data, rms, R, og_R = remove_collinear(data)
new_Σ = cov(new_data)
new_cΣ = cond(new_Σ)

res = homogeneity(new_data, 84, "new_dims")

## Unsupervised Learning
function explore_space(data, dataset, dir)
    # Explore space by Mountain clustering
    σs = [0.1, 0.25, 0.5]
    βs = [0.15, 0.375, 0.75]
    γs = [0.1, 0.3, 0.5]
    nf = true
    for γ in γs
        explore_mountain(data, euclidean, 3, σs, βs, γ,
            newfile = nf, dataset=dataset
        )
        global nf = false
    end

    # Explore space by Subtractive Clustering
    rₐs = collect(0.1:0.01:0.9)
    ks = explore_subtractive(data, euclidean, rₐs)
    fig = plotPL(rₐs, ks, xlabel=L"r_a", ylabel=L"k")
    save(fig, "K_subtractive.pdf", dir=dir)
end

function clusterize(data, k, dataset, dir)
    _, protos_KM, U_KM, _, _ = k_means(data, k, euclidean, norm=true)
    _, protos_FCM, U_FCM, _, _ = fuzzy_c_means(data, k, dist, 2, norm=true)

    emb_data = tsne(data, 3)
    plot_3DClusters(protos_KM, U_KM, data, "KM_"*dataset*".pdf",
        ("", "", ""), dir=dir, plot_protos = false
    )
    plot_3DClusters(protos_FCM, U_FCM, data, "FCM_"*dataset*".pdf",
        ("", "", ""), dir=dir, plot_protos = false
    )
end
