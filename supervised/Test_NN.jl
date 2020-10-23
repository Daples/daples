include("BackPropagation.jl")
include("PlotTools.jl")

X = [0 0; 0 1; 1 0; 1 1];

# XOR
# Y = [0; 1; 1; 0];
# OR
Y = [0; 1; 1; 1];

L = [3, 4, 2];
ϕ_sigm(x) = 1.0 ./ (1.0 .+ exp.(-x));
∂ϕ_sigm(x) = ϕ_sigm(x).*(1 .- ϕ_sigm(x));

ϕ = [ϕ_sigm for i in 1:size(L, 1)+2]
∂ϕ = [∂ϕ_sigm for i in 1:size(L, 1)+2]

# NN
s = 100
η = 0.1
∇s, Ws, Ξ = nn(X, Y, L, ϕ, ∂ϕ, s=s, η=η)
