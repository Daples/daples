using Plots
using LaTeXStrings

# 4th-Order Runge-Kutta
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

# Standard Euler's method
function euler(f, x0, h, T)
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
        xs[:, i] = x_aux + h*f(t, x_aux)
        t += h
    end
    return ts, xs
end

# Better plots
function plotPL(x, y,
    add = nothing;
    label = "",
    color = :black,
    lw = 2,
    legend = :right,
    fontsize = 12,
    font = "times",
    xlabel = "",
    ylabel = ""
)
    if isnothing(add)
        global fig = plot(x, y,
            label = label,
            color = color,
            lw = lw,
            legend = legend,
            xlabel = xlabel,
            ylabel = ylabel,
            titlefont = (fontsize, font),
            xtickfont = (fontsize, font),
            ytickfont = (fontsize, font),
            legendfontsize = fontsize
        )
    else
        plot!(add, x, y,
            label = label,
            color = color,
            lw = lw,
            legend = legend,
            xlabel = xlabel,
            ylabel = ylabel,
            titlefont = (fontsize, font),
            xtickfont = (fontsize, font),
            ytickfont = (fontsize, font),
            legendfontsize = fontsize
        )
    end
    if isnothing(add)
        return fig
    else
        return add
    end
end

# Plot array of MFs
function plotMFs(MFs, dom, labels, outfile; n=1000)
    colors = [:blue, :black, :orange, :red, :green]
    t = collect(dom[1]:(dom[2] - dom[1])/n:dom[2])
    i = 1
    for MF in MFs
        if i == 1
            global fig = plotPL(t, map(x -> MF.eval(x), t),
                label = labels[i],
                color = colors[i]
            )
        else
            fig = plotPL(t, map(x -> MF.eval(x), t),
                fig,
                label = labels[i],
                color = colors[i]
            )
        end
        i += 1
    end
    savefig(outfile)
    return fig
end

# Print combinations
function print_combinations(outfile)
    us = ["low" "medium" "high"];
    vs = ["low" "medium" "high"];
    xs = ["null" "controlled" "high"];

    open(outfile, "w") do io
        for u in us
            for v in vs
                for x in xs
                    write(io, "$u and $v and $x then \n")
                end
            end
        end
    end
end

# Iterate a single step of euler's method for a given u and v
function iter_euler(x_prev, t, u, v; h=0.01)
    k = 10^-5;
    k1 = 1;
    k2 = 0.05;
    α = 0.75;
    k3 = 0.05;
    k4 = 0.01;
    β = 0.1;
    k5 = 0.1;
    f(t, x) = k .+ (1 .+ k1*v)*k2*(x.^α) .- k3*x .- k4*log(1 .+ u)*(x.^β) .- k5*log(1 .+ v)*x
    x_new = x_prev + h*f(t, x_prev)
    t += h
    return t, x_new
end

function simulate_FISCS(x0, u0, v0, T;
    fis_u = nothing,
    fis_v = nothing,
    h = 0.01,
    defuzz = "WTAV"
)
    arr_size = Int64(T/h)
    xs = zeros(ComplexF64, arr_size)
    ts = zeros(Float64, arr_size)
    us = zeros(Float64, arr_size)
    vs = zeros(Float64, arr_size)
    xs[1] = x0
    us[1] = u0
    vs[1] = v0
    t = 0
    t, xs[2] = iter_euler(x0, t, u0, v0, h = h)
    for i in 2:arr_size-1
        ts[i] = t
        # Evaluate FIS for new controls
        in_vals = [us[i-1], vs[i-1], real(xs[i])]
        us[i] = us[i-1] + eval_fis(fis_u, in_vals, defuzz)
        vs[i] = vs[i-1] + eval_fis(fis_v, in_vals, defuzz)
        # Find next point
        t, xs[i+1] = iter_euler(xs[i], t, us[i], vs[i])
    end
    ts[end] = t
    return ts, xs, us, vs
end
