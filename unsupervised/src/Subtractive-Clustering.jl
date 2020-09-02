include("Tools.jl")

function subtractive_cluster(data, dist, rₐ;
    γ=0.4, n_it=10, arg=nothing, norm=true
)
    data = norm ? normalize(data) : data
    n, p = size(data)
    rᵦ = 1.5 * rₐ
    # Initial Densities
    D = zeros(n, 1)
    for j = 1:n
        D[j, 1] = sum(exp.(-dist(data,
            reshape(data[j, :], (1, p)), arg).^2 ./ (rₐ/2)^2))
    end
    # Iterate
    protos = zeros(1, p)
    evals = []
    for k in 1:n_it
        ind_max = argmax(D)[1]
        if k == 1
            global M = D[ind_max]
            push!(evals, M)
        else
            Mk = D[ind_max]
            push!(evals, Mk)
            if Mk/M < γ
                break
            end
        end
        D -= D[ind_max] * exp.(-dist(data,
            reshape(data[ind_max, :], (1, p)), arg).^2 ./ (rᵦ/2)^2)
        protos = vcat(protos, reshape(data[ind_max, :], (1, p)))
    end
    return data, protos[2:end, :], evals
end
