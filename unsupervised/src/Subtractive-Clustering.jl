include("Tools.jl")

function subtractive_cluster(data, dist, rₐ;
    ϵ_up = 0.5, ϵ_down = 0.15, n_it=10, arg=nothing, norm=true
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
    evals = []
    update = true
    for k in 1:n_it
        ind_max = argmax(D)[1]
        pₖ = reshape(data[ind_max, :], (1, p))
        if k == 1
            global M = D[ind_max]
            global protos = pₖ
            push!(evals, M)
        else
            Mₖ = D[ind_max]
            if Mₖ > ϵ_up * M
                protos = vcat(protos, pₖ)
                push!(evals, Mₖ)
            elseif Mₖ < ϵ_down * M
                break
            else
                dmin = minimum(dist(protos, pₖ, arg))
                if (dmin/rₐ + Mₖ/M) >= 1
                    protos = vcat(protos, pₖ)
                    push!(evals, Mₖ)
                    update = true
                else
                    D[ind_max] = 0
                    update = false
                end
            end
        end
        if update
            D -= D[ind_max] * exp.(-dist(data,
                reshape(data[ind_max, :], (1, p)), arg).^2 ./ (rᵦ/2)^2)
        end
    end
    U, _ = find_membership(data, dist, protos, arg)
    return data, protos, U, evals
end
