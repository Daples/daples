include("Fuzzy-C-Means.jl");
include("K-Means.jl");
include("Mountain.jl");
include("Subtractive.jl");

include("Tools.jl");
include("PlotTools.jl");

# Read data
data, countries, header = read_countries("data/country-data.csv");

# Dimension reduction
# new_data = tsne(normalize(data), verbose=true, 3);

# Mountain example
# data, protos, U, _, _, _ = @time mountain_cluster(data, euclidean, 3, 0.1, 0.15, full=false)
# fig = scatterPL(new_data[:, 1], new_data[:, 2], color=:red)

# Explore space - Mountain
function explore_mountain(data, dist, n_grid, σs, βs, γ=0.4;
    dataset="country", newfile=true
)
    s = joinpath(pwd(), "results")
    if ~isdir(s)
        mkdir(s)
    end
    nβ = size(βs, 1)
    nσ = size(σs, 1)
    mode = newfile ? "w" : "a"
    outfile = open(joinpath(s, dataset*"_mountain.res"), mode)
    write(outfile, "gamma = "*string(γ)*"\n")
    ks = zeros(nσ, nβ)
    for i in 1:nσ
        σ = σs[i]
        for j in 1:nβ
            β = βs[j]
            protos = mountain_cluster(data, dist, n_grid, σ, β, γ=γ)[2]
            k = size(protos, 1)
            ks[i, j] = k
            if j == nβ
                write(outfile, string(k))
            else
                write(outfile, string(k)*",")
            end
        end
        write(outfile, "\r\n")
    end
    close(outfile)
    return ks
end

σs = [0.1, 0.25, 0.5];
βs = [0.15, 0.375, 0.75];
γs = [0.1, 0.3, 0.5];
nf = true;
for γ in γs
    explore_mountain(data, euclidean, 3, σs, βs, γ, newfile=nf)
    global nf = false
end

# Explore space - Subtractive
function explore_subtractive(data, dist, rₐs; dataset="country")
    nrₐ = size(rₐs, 1)
    outfile = open(dataset*"_subtractive.res", "a")
    write(outfile, "gamma = "*string(γ))
    ks = zeros(nrₐ)
    for i in nrₐ
        rₐ = rₐs[i]
        protos = subtractive_cluster(data, dist, rₐ)[2]
        k = size(protos, 1)
        ks[i] = k
        if j == nrₐ
            outfile.write(string(k))
        else
            outfile.write(string(k)*",")
        end
    end
end
