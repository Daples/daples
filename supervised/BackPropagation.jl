include("Tools.jl");

function propagate(x, Ws, ϕ, hidden_layers)
    Vs = []
    Φs = []
    push!(Vs, x)
    push!(Φs, vcat(ϕ[1](x), [1]))
    aux = Φs[end]
    for i in 1:(hidden_layers + 1)
        v = Ws[i] * aux
        push!(Vs, v)
        aux = i == hidden_layers + 1 ? ϕ[i+1](v) : vcat(ϕ[i+1](v), [1])
        push!(Φs, aux)
    end
    return Vs, Φs
end

function nn(X, Y, L, ϕ, ∂ϕ; η=0.05, α=0.1, s=10, seed=nothing)
    # Dimensions
    m = size(X, 2) + 1
    N, n = size(Y)
    hidden_layers = size(L, 1)
    layers = size(L, 1) + 2

    # Auxiliary Structures
    augL = [m - 1, L..., n]
    Y_nn = zeros(size(Y))
    Ξ = zeros(N, s) # error energies per epoch
    ∇ = zeros(N, hidden_layers + 1) # sum of gradients per layer for each pattern
    ∇s = []
    Ws = []
    ΔWs = []

    # Fill weights
    for l in 1:(layers - 1)
        push!(Ws, init_weights(augL[l+1], augL[l] + 1, seed=seed))
        push!(ΔWs, zeros(augL[l+1], augL[l] + 1))
    end

    # Optimization
    Vs = nothing
    E = nothing
    ΔW = nothing
    δs = nothing
    Φs = nothing
    for h in 1:s
        E = zeros(size(Y)) # errors in one epoch
        for p in 1:N
            δs = []
            x = reshape(X[p, :], (m - 1, 1))
            y = reshape(Y[p, :], (n, 1))

            # Propagate
            Vs, Φs = propagate(x, Ws, ϕ, hidden_layers)
            y_nn = Φs[end]
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
                    δ = ∂ϕ[i](Vs[i]) .* (Ws[i][:, 1:end-1]' * δs[1])
                end
                pushfirst!(δs, δ)
                ∇[p, i-1] = sum(δ)
                ΔW = -η * δ * Φs[i-1]' + α * ΔWs[i-1]
                Ws[i-1] += ΔW
                ΔWs[i-1] = ΔW
            end
            print(Ws[end], "\n")
        end
        Ξ[:, h] = sum(0.5 * E.^2, dims=2)
        push!(∇s, ∇)
    end
    return Vs, Φs, Ws, ∇s, Ξ
end
