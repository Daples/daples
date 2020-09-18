using Pkg
# Pkg.add("Distributions")
# Pkg.add("LinearAlgebra")
# Pkg.add("TSne")

using Distributions
using LinearAlgebra
using TSne

## Similarities
function pnorm(data, y, arg)
    return (sum(abs.(data .- y).^arg, dims=2)).^(1/arg)
end

function euclidean(data, y, arg)
    return pnorm(data, y, 2)
end

function manhattan(data, y, arg)
    return pnorm(data, y, 1)
end

function mahal(data, y, IV)
    diff = data .- y
    return sqrt.(sum(diff * IV .* diff, dims=2))
end

## Misc
# Find memebership matrix of data to given cluster centers
function find_membership(data, dist, protos, arg)
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

# Randomizes parameters for a Multivariate Normal Distributions for gen([a,b])
function rand_params_MvN(a, b, p)
    u = Uniform(a, b)
    μ = rand(u, p)
    Σ = rand(p, p)
    Σ = 0.5 * (Σ + Σ') + p*I
    return μ, Σ
end

# Generates data from a Multivariate Normal Distribution
function generate_MvN_Mixture(p, k, n; b = 25)
    data = rand(MvNormal(rand_params_MvN(0, b, p)...), n)';
    for j = 1:k-1
        data = vcat(data, rand(MvNormal(rand_params_MvN(0, b, p)...), n)')
    end
    return data
end

# Normalize data with max|x_i| -> [-1,1] hypercube.
function normalize(data)
    return data ./ maximum(abs.(data), dims=1)
end

# Read Iris dataset
function read_iris(iris_file)
    iris_file = open(iris_file, "r") do io
        read(io, String)
    end
    lines = split(iris_file, "\n")[1:end-1]
    lines = replace.(lines, "\r" => "")
    data = split.(lines, ",")
    tags = map(x -> x[end], data)
    data = map(x -> x[1:end-1], data)
    n = size(data)[1]
    p = size(data[1])[1]
    data = [parse.(Float64, point) for point in data]
    aux = reshape(data[1], (1, p))
    for j in 2:n
        aux = vcat(aux, reshape(data[j], (1, p)))
    end
    return aux, tags
end

# Read Counties dataset
function read_countries(country_file)
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
