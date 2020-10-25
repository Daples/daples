include("BackPropagation.jl")
include("PlotTools.jl")

X = [0 0; 0 1; 1 0; 1 1];

# XOR
Y = reshape([0; 1; 1; 0], (4, 1));
# OR
# Y = reshape([0; 1; 1; 1], (4, 1));
# AND
# Y = reshape([0; 0; 0; 1], (4, 1));

L = [3, 2];
ϕ_sigm(x) = 1.0 ./ (1.0 .+ exp.(-x));
∂ϕ_sigm(x) = ϕ_sigm(x).*(1 .- ϕ_sigm(x));
ϕ_tanh(x) = tanh.(x)
∂ϕ_tanh(x) = 1 .- (ϕ_tanh(x)).^2

ϕ = [ϕ_sigm for i in 1:size(L, 1)+2]
∂ϕ = [∂ϕ_sigm for i in 1:size(L, 1)+2]

# NN
s = 50
η = 0.75
α = 0
Vs, Φs, Ws, ∇s, Ξ = nn(X, Y, L, ϕ, ∂ϕ, s=s, η=η, α=α)

# Plot Average Error
plot_ξav(Ξ)

# Plot Gradient
plot_∇s(∇s)

# Plot gradient's evolution in layer l for different seeds
S = rand(1:1000, 10)
l = 1
plot_seed∇(l, S, X, Y, L, ϕ, ∂ϕ, s=s, η=η, α=α)

# NN output
# for i in 1:size(X, 1)
#     print(propagate(X[i, :], Ws, ϕ, size(L, 1))[2][end])
# end
