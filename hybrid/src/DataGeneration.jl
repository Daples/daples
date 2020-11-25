using Clustering
using Clustering
using CSV
using Plots
using Random
using Distributions

# Fixed seed
Random.seed!(1234)

# Read Counties dataset
function read_countries(country_file :: String)
    country_file = open(country_file, "r") do io
        read(io, String)
    end
    lines = split(country_file, "\n")
    lines = lines[1:end-1]
    data = split.(lines, ",")
    header = split(data[1], ",")[1]
    data = data[2:end]
    countries = map(x -> x[1], data)
    data = map(x -> x[2:end], data)
    n = size(data)[1]
    p = size(data[1])[1]
    data = [parse.(Float64, point) for point in data]
    aux = reshape(data[1], (1, p))
    for j in 2:n
        aux = vcat(aux, reshape(data[j], (1, p)))
    end
    return aux, countries, header
end

# Find memebership matrix of data to given cluster centers
function find_membership(data :: Matrix{Float64}, dist :: Function,
    protos :: Matrix{Float64}, arg)
    n = size(data, 1)
    k, p = size(protos)
    U = zeros(k, n)
    dists = zeros(k, n)
    for j in 1:k
        dists[j, :] = dist(data, reshape(protos[j, :], (1, p)), arg)
    end
    indexes_min = argmin(dists, dims=1)
    U[indexes_min] .= 1
    return U, dists
end

# Read data
data, _, _ = read_countries("data/country-data.csv")

# Clustering
protos = transpose(Clustering.fuzzy_cmeans(transpose(data), 2, 2).centers)
u, _ = find_membership(data, euclidean, protos, nothing)
