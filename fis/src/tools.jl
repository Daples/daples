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

# Better plots
function plotPL(x, y,
    add = nothing;
    label = "",
    color = :black,
    lw = 2,
    legend = :right,
    fontsize = 12,
    font = "times"
)
    if isnothing(add)
        global fig = plot(x, y,
            label = label,
            color = color,
            lw = lw,
            legend = legend,
            xlabel = "",
            ylabel = "",
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
            xlabel = "",
            ylabel = "",
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

function plotMFs(MFs, dom, labels, outfile)
    colors = [:blue, :black, :orange, :red, :green]
    t = collect(dom[1]:(dom[2] - dom[1])/1000:dom[2])
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
