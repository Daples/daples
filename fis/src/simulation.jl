using Plots

# 4th-Order Runge-Kutta for ODEs
function rk4(f, x0, h, T)
    nvars = size(x0, 1)
    arr_size = Int(T/h)
    xs = zeros(ComplexF64, nvars, arr_size)
    xs[:,1] = x0
    t = 0
    ts = zeros(1)
    for i in 2:arr_size
        push!(ts, t)
        x_aux = xs[:, i-1]
        k1 = f(t, x_aux)
        t += h/2
        k2 = f(t, x_aux + k1*h/2)
        k3 = f(t, x_aux + k2*h/2)
        t += h/2
        k4 = f(t, x_aux + k3*h)
        xs[:, i] = x_aux + h*(k1 + 2*k2 + 2*k3 + k4)/6
    end
    return ts, xs
end

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
T = 2500;
h = 0.1;

u(t) = 1;
v(t) = 0;

f(t, x) = k .+ (1 .+ k1*v(t))*k2*(x.^α) .- k3*x .- k4*log(1 .+ u(t))*(x.^β) .- k5*log(1 .+ v(t))*x;

# Simulation
ts, xs = rk4(f, x0, h, T);

# Plot
plot(ts, transpose(real.(xs)), label = "Real(x(t))", color = :black);
plot!(ts, transpose(imag.(xs)), label = "Imag(x(t))", color = :red);
plot!(xlabel = "t", ylabel = "x(t)")
savefig("simulation.pdf")
