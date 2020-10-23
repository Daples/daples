include("Tools.jl");

function propagate(Ws, Vs, ϕ, hidden_layers)
    aux = Vs[end]
    for i in 1:(hidden_layers + 1)
        push!(Vs, Ws[i] * aux)
        aux = ϕ[i+1](Vs[end])
    end
    return ϕ[end](Vs[end])
end

function nn(X, Y, L, ϕ, ∂ϕ; η = 0.05, s = 10, seed = nothing)
    # Dimensions
    N, m = size(X)
    n = size(Y, 2)
    hidden_layers = size(L, 1)
    layers = size(L, 1) + 2

    # Auxiliary Structures
    augL = [m, L..., n]
    Y_nn = zeros(size(Y))
    Ξ = zeros(N, s) # error energies per epoch
    ∇ = zeros(N, hidden_layers + 1) # sum of gradients per layer for each pattern
    ∇s = []

    # Fill weights
    Ws = []
    for l in 1:(layers - 1)
        push!(Ws, init_weights(augL[l+1], augL[l], seed=seed))
    end

    # BackPropagation
    Vs = nothing
    E = nothing
    ΔW = nothing
    δs = nothing
    for h in 1:s
        E = zeros(size(Y)) # errors in one epoch
        for p in 1:N
            Vs = []
            δs = []
            x = reshape(X[p, :], (m, 1))
            push!(Vs, ϕ[1](x))
            y = reshape(Y[p, :], (n, 1))

            # Propagate
            y_nn = propagate(Ws, Vs, ϕ, hidden_layers)
            Y_nn[p, :] = y_nn
            E[p, :] = y - y_nn

            # Backpropagate
            aux = true
            for i in layers:-1:2
                e = reshape(E[p, :], (n, 1))
                if aux
                    δ = e .* ∂ϕ[i](Vs[i])
                    aux = false
                else
                    δ = ∂ϕ[i](Vs[i]) .* (Ws[i]' * δs[1])
                end
                pushfirst!(δs, δ)
                ∇[p, i-1] = sum(δ)
                ΔW = -η * δ * Vs[i-1]'
                Ws[i-1] += ΔW
            end
        end
        Ξ[:, h] = sum(0.5 * E.^2, dims=2)
        push!(∇s, ∇)
    end
    return ∇s, Ws, Vs, Ξ
end
