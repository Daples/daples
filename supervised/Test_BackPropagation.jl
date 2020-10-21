include("Tools.jl")

function nn(X, Y, L, Φ, ∂Φ; η=0.05, s=10)
    # Dimensions
    N, m = size(X)
    n = size(Y, 2)
    hidden_layers = size(L)
    augL = [m, L..., n]

    # Auxiliary Matrices
    Ynn = zeros(N, n)
    E = zeros(N, s)

    # Fill weights
    Ws = []
    for l in 1:(size(augL) - 1)
        append!(Ws, init_weights(L[l], L[l+1])))
    end

    # for h in 1:s
    #     for p in 1:N
    #         x = Φ[1].(reshape(X[p, :], (m, 1)))
    #         y = reshape(Y[p, :], (n, 1))
    #         for i in 1:(hidden_layers + 1)
    #             continue
    #         end
    #     end
    # end
    return Ws
end

# Propagate pattern x (mx1) and associated output y (nx1)
function prop(x, y, ϕ, ∂ϕ; η=0.1, s=10)
    continue
end

nn()
