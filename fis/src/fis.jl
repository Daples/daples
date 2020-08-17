using Fuzzy
using Plots

include("tools.jl");
cwd = "C:\\Users\\Daples\\git\\daples\\fis\\src\\figs\\";

## Membership functions
# Controllers
contMF_low = SigmoidMF(-20, 0.25, 0);
contMF_med = BellMF(0.25, 4, 0.5);
contMF_high = SigmoidMF(10, 0.6, 1);
in_controllers = [contMF_low, contMF_med, contMF_high];
plotMFs(in_controllers, [0 1], ["Low", "Medium", "High"], cwd*"contMFs.pdf")

# Δx(t) = x(t) - x(t-h)
ω = 0.05;
t = collect(-ω:0.001:ω);
a = 150;
ΔxMF_dec = SigmoidMF(-a, -ω/3, -ω);
ΔxMF_con = GaussianMF(0, 0.01);
ΔxMF_inc = SigmoidMF(a, ω/3, ω);
in_Δxs = [ΔxMF_dec, ΔxMF_con, ΔxMF_inc];
plotMFs(in_Δxs, [-ω ω],
    ["Decreasing", "Constant", "Increasing"], cwd*"deltaStateMFs.pdf"
)

# x(t)
xMF_controlled = TrapezoidalMF(0, 0, 0.1, 0.3)
xMF_normal = BellMF(0.2, 4, 0.4)
xMF_high = TrapezoidalMF(0.5, 0.7, 1, 1)
in_xs = [xMF_controlled, xMF_normal, xMF_high]
plotMFs(in_xs, [0 1],
    ["Controlled", "Normal", "High"], cwd*"stateMFs.pdf"
)

# Output controllers
# Δu(t)
ΔuMF_dec = SigmoidMF(-a, -ω/3, -ω);
ΔuMF_con = GaussianMF(0, 0.01);
ΔuMF_inc = SigmoidMF(a, ω/3, ω);
out_controllers = [ΔuMF_dec, ΔuMF_con, ΔuMF_inc];
plotMFs(out_controllers, [-ω ω],
    ["Decrease", "Constant", "Increase"], cwd*"outMFs.pdf"
)

## Inputs
in_u = Dict()
in_u["low"] = contMF_low
in_u["medium"] = contMF_med
in_u["high"] = contMF_high

in_v = Dict()
in_v["low"] = contMF_low
in_v["medium"] = contMF_med
in_v["high"] = contMF_high

in_Δx = Dict()
in_Δx["decreasing"] = ΔxMF_dec
in_Δx["constant"] = ΔxMF_con
in_Δx["increasing"] = ΔxMF_inc

in_x = Dict()
in_x["controlled"] = xMF_controlled
in_x["normal"] = xMF_normal
in_x["high"] = xMF_high

inputs = [in_u, in_v, in_Δx, in_x]

## Outputs
out_Δu = Dict()
out_Δu["decrease"] = ΔuMF_dec
out_Δu["constant"] = ΔuMF_con
out_Δu["increase"] = ΔuMF_inc

out_Δv = Dict()
out_Δv["decrease"] = ΔuMF_dec
out_Δv["constant"] = ΔuMF_con
out_Δv["increase"] = ΔuMF_incx

outputs = [out_Δu, out_Δv]
