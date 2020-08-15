using Fuzzy
using Plots

include("tools.jl");
cwd = "D:\\Dropbox\\DAVID-SAMUEL\\_David_\\0_EAFIT\\2020-2\\
    artificial-intelligence\\entregas\\fis\\src\\figs\\";

## Membership functions
# Input Controllers
contMF_low = SigmoidMF(-20, 0.25, 0);
contMF_med = BellMF(0.25, 4, 0.5);
contMF_high = SigmoidMF(10, 0.6, 1);
in_controllers = [contMF_low, contMF_med, contMF_high];

# Plot & export
plotMFs(in_controllers, [0 1], ["Low", "Medium", "High"], cwd*"contMFs.pdf")

# Input Δx(t) = x(t) - x(t-h)
ω = 0.05;
t = collect(-ω:0.001:ω);
a = 150;
ΔxMF_dec = SigmoidMF(-a, -ω/3, -ω);
ΔxMF_con = GaussianMF(0, 0.01);
ΔxMF_inc = SigmoidMF(a, ω/3, ω);

in_Δxs = [ΔxMF_dec, ΔxMF_con, ΔxMF_inc]
plotMFs(in_Δxs, [-ω ω],
    ["Decreasing", "Constant", "Increasing"], cwd*"stateMFs.pdf"
)

# Output controllers
# Low
outMF_low = TrapezoidalMF(0, 0, 0.25, 0.5)
outMF_med = TrapezoidalMF(0.25, 0.5, 0.5, 0.75)
outMF_high =

## Inputs
in_u = Dict()
in_u["low"] = contMF_low
in_u["medium"] = contMF_med
in_u["high"] = contMF_high

in_v = Dict()
in_v["low"] = contMF_low
in_v["medium"] = contMF_med
in_v["high"] = contMF_high

in_dx = Dict()
in_dx["decreasing"] = ΔxMF_dec
in_dx["constant"] = ΔxMF_con
in_dx["increasing"] = ΔxMF_inc

in_x = Dict()
in_x["controlled"] = xMF_cont
in_x["normal"] = xMF_norm
in_x["high"] = xMF_high

inputs = [in_u, in_v, in_dx]

## Outputs
