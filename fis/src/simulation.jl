using Plots

include("tools.jl")

## Parameters
k = 10^-5;
k1 = 1;
k2 = 0.05;
α = 0.75;
k3 = 0.05;
k4 = 0.01;
β = 0.1;
k5 = 0.1;

## System
x0 = [0.6];
T = 1000;
h = 0.01;

u(t) = t < 500 ? 1 : 0;
v(t) = 0;

f(t, x) = k .+ (1 .+ k1*v(t))*k2*(x.^α) .- k3*x .- k4*log(1 .+ u(t))*(x.^β) .- k5*log(1 .+ v(t))*x;

# Simulation
ts, xs = euler(f, x0, h, T);
ts, xsk = rk4(f, x0, h, T);

# Plot
plot(ts, transpose(real.(xs)), label = "Real(x(t))", color = :black);
plot(ts, transpose(real.(xsk)), label = "Real(x(t))", color = :red);
# plot!(ts, transpose(imag.(xs)), label = "Imag(x(t))", color = :red);
plot!(xlabel = "t", ylabel = "x(t)")
savefig("simulation.pdf")
