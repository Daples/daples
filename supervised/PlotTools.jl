# using Pkg
# Pkg.add("LaTeXStrings")
# Pkg.add("Plots")

using LaTeXStrings
using Plots

# Standardize file saving
function save(fig, out_file; dir="")
    if ~isdir(joinpath(pwd(), "figs"))
        mkdir("figs");
    end
    if ~isdir(joinpath(pwd(), "figs", dir))
        mkdir(joinpath(pwd(), "figs", dir))
    end
    plot_wd = joinpath(pwd(), "figs", dir);
    savefig(fig, joinpath(plot_wd, out_file))
end

# Standardize plots and surfaces
function plotPL(x, y,
    add = nothing;
    z = nothing,
    label = "",
    color = :black,
    lw = 2,
    legend = :right,
    fontsize = 12,
    font = "times",
    xlabel = "",
    ylabel = "",
    zlabel = "",
    st = :surface,
    cam = (-30, 30)
)
    if isnothing(add)
        if isnothing(z)
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
                # guidefont = (fontsize, font),
                legendfontsize = fontsize
            )
        else
            global fig = plot(x, y, z,
                label = label,
                lw = lw,
                legend = legend,
                xlabel = xlabel,
                ylabel = ylabel,
                zlabel = zlabel,
                titlefont = (fontsize, font),
                xtickfont = (fontsize, font),
                ytickfont = (fontsize, font),
                ztickfont = (fontsize, font),
                # guidefont = (fontsize, font),
                legendfontsize = fontsize,
                st = st
            )
        end
    else
        if isnothing(z)
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
                # guidefont = (fontsize, font),
                legendfontsize = fontsize
            )
        else
            plot!(add, x, y, z,
                label = label,
                lw = lw,
                legend = legend,
                xlabel = xlabel,
                ylabel = ylabel,
                zlabel = zlabel,
                titlefont = (fontsize, font),
                xtickfont = (fontsize, font),
                ytickfont = (fontsize, font),
                ztickfont = (fontsize, font),
                # guidefont = (fontsize, font),
                legendfontsize = fontsize,
                st = st
            )
        end
    end
    if isnothing(add)
        return fig
    else
        return add
    end
end
