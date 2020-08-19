using Plots
using Fuzzy

include("tools.jl");

cwd = "C:\\Users\\Daples\\git\\daples\\fis\\src\\figs\\";

## Membership functions
# Controllers
contMF_low = SigmoidMF(-20, 0.25, 0);
contMF_med = BellMF(0.25, 4, 0.5);
contMF_high = SigmoidMF(10, 0.6, 1);
in_controllers = [contMF_low, contMF_med, contMF_high];
plotMFs(in_controllers, [0 1], ["Low", "Medium", "High"], cwd*"contMFs.pdf")

# x(t)
xMF_null = TrapezoidalMF(0, 0, 0.1, 0.2);
xMF_controlled = BellMF(0.15, 5, 0.3);
xMF_high = TrapezoidalMF(0.4, 0.5, 1, 1);
in_xs = [xMF_null, xMF_controlled, xMF_high];
plotMFs(in_xs, [0 1],
    ["Null", "Controlled", "High"], cwd*"stateMFs.pdf"
)

# Output controllers
# Δs
ω = 0.05;
a = 150;
ΔMF_dec = SigmoidMF(-a, -ω/3, -ω);
ΔMF_con = GaussianMF(0, 0.01);
ΔMF_inc = SigmoidMF(a, ω/3, ω);
out_controllers = [ΔMF_dec, ΔMF_con, ΔMF_inc];
plotMFs(out_controllers, [-ω ω],
    ["Decrease", "Constant", "Increase"], cwd*"outMFs.pdf"
)

## Inputs
in_u = Dict();
in_u["low"] = contMF_low;
in_u["medium"] = contMF_med;
in_u["high"] = contMF_high;

in_v = Dict();
in_v["low"] = contMF_low;
in_v["medium"] = contMF_med;
in_v["high"] = contMF_high;

in_x = Dict();
in_x["null"] = xMF_null;
in_x["controlled"] = xMF_controlled;
in_x["high"] = xMF_high;

inputs = [in_u, in_v, in_x];

## Outputs
out_Δu = Dict();
out_Δu["decrease"] = ΔMF_dec;
out_Δu["constant"] = ΔMF_con;
out_Δu["increase"] = ΔMF_inc;

out_Δv = Dict();
out_Δv["decrease"] = ΔMF_dec;
out_Δv["constant"] = ΔMF_con;
out_Δv["increase"] = ΔMF_inc;

## Rules
rules_file = open("rules", "r") do io
    read(io, String)
end;
lines = split(rules_file, "\n")[1:end-1];
rules_u = [];
rules_v = [];
norm = "MIN";
for line in lines
    ant = split(line, " then ")[1]
    con = split(line, " then ")[2]
    push!(rules_u, Rule(split(ant, " and "), split(con, " and ")[1], norm))
    push!(rules_v, Rule(split(ant, " and "), split(con, " and ")[2], norm))
end

fis_u = FISMamdani(inputs, out_Δu, rules_u);
fis_v = FISMamdani(inputs, out_Δv, rules_v);

## Control System
x0 = 1;
u0 = 0;
v0 = 0;
T = 100;
ts, xs, us, vs = simulate_FISCS(x0, u0, v0, T,
    fis_u = fis_u,
    fis_v = fis_v,
    defuzz = "WTAV"
);

# Plots
fig = plotPL(ts, real.(xs), label = L"$x(t)$")
plotPL(ts, us, fig, label = L"$u(t)$", color = :red)
plotPL(ts, vs, fig, label = L"$v(t)$", color = :orange,
    legend = :topright, xlabel = L"$t$")
savefig(cwd*"FISCS-$x0-$u0-$v0.pdf")
