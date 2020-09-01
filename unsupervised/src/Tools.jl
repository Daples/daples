using Plots
using LinearAlgebra
using LaTeXStrings

## Plots
function save(fig, out_file)
    if ~isdir(joinpath(pwd(), "figs"))
        mkdir("figs");
    end
    plot_wd = joinpath(pwd(), "figs");
    savefig(fig, joinpath(plot_wd, out_file))
end

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

function scatterPL(x, y,
    add = nothing;
    z = nothing,
    label = "",
    color = :auto,
    lw = 2,
    legend = :right,
    fontsize = 12,
    font = "times",
    xlabel = "",
    ylabel = "",
    zlabel = "",
    st = :surface,
    cam = (-30, 30),
    markersize = 3,
    markershape = :circle,
    markerstrokewidth = 0,
    markersizewidth = 0
)
    if isnothing(add)
        global fig = scatter(x, y,
            label = label,
            color = color,
            lw = lw,
            legend = legend,
            xlabel = xlabel,
            ylabel = ylabel,
            titlefont = (fontsize, font),
            xtickfont = (fontsize, font),
            ytickfont = (fontsize, font),
            legendfontsize = fontsize,
            markersize = markersize,
            markershape = markershape,
            markerstrokewidth = markerstrokewidth,
            markersizewidth = markersizewidth
        )
    else
        scatter!(add, x, y,
            label = label,
            color = color,
            lw = lw,
            legend = legend,
            xlabel = xlabel,
            ylabel = ylabel,
            titlefont = (fontsize, font),
            xtickfont = (fontsize, font),
            ytickfont = (fontsize, font),
            legendfontsize = fontsize,
            markersize = markersize,
            markershape = markershape,
            markerstrokewidth = markerstrokewidth,
            markersizewidth = markersizewidth
        )
    end
    if isnothing(add)
        return fig
    else
        return add
    end
end

function plot_k_means(protos, U, data, out_file)
    k = size(protos, 1)
    for j in 1:k
        data_cluster = data[U[j, :] .== 1, :]
        if j == 1
            global fig = scatterPL(data_cluster[:, 1], data_cluster[:, 2])
        else
            scatterPL(data_cluster[:, 1], data_cluster[:, 2], fig)
        end
    end
    scatterPL(protos[:, 1], protos[:, 2], fig, color=:black)
    save(fig, out_file)
    return fig
end

function plot_mountains(protos, data, out_file)
    fig = scatterPL(data[:, 1], data[:, 2])
    scatterPL(protos[:, 1], protos[:, 2], fig, color=:black, markersize=5)
    save(fig, out_file)
    return fig
end
## Similarities
# Assuming the vectors are columns (n, 1)
function minkowski(data, y, arg)
    return (sum(abs.(data .- y).^arg, dims=2)).^(1/arg)
end

function euclidean(data, y, arg)
    return minkowski(data, y, 2)
end

function manhattan(data, y, arg)
    return minkowski(data, y, 1)
end

## Misc
function rand_params_MvN(a, b, p)
    u = Uniform(a, b)
    μ = rand(u, p)
    Σ = rand(p, p)
    Σ = 0.5 * (Σ + Σ') + p*I
    return μ, Σ
end
