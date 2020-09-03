using Plots
using LinearAlgebra
using LaTeXStrings
using Combinatorics

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
            guidefont = (fontsize, font),
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
            guidefont = (fontsize, font),
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
        if isnothing(z)
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
                guidefont = (fontsize, font),
                legendfontsize = fontsize,
                markersize = markersize,
                markershape = markershape,
                markerstrokewidth = markerstrokewidth,
                markersizewidth = markersizewidth
            )
        else
            global fig = scatter(x, y, z,
                label = label,
                color = color,
                lw = lw,
                legend = legend,
                xlabel = xlabel,
                ylabel = ylabel,
                zlabel = zlabel,
                titlefont = (fontsize, font),
                xtickfont = (fontsize, font),
                ytickfont = (fontsize, font),
                ztickfont = (fontsize, font),
                guidefont = (fontsize, font),
                legendfontsize = fontsize,
                markersize = markersize,
                markershape = markershape,
                markerstrokewidth = markerstrokewidth,
                markersizewidth = markersizewidth
            )
        end
    else
        if isnothing(z)
            scatter!(add, x, y, z,
                label = label,
                color = color,
                lw = lw,
                legend = legend,
                xlabel = xlabel,
                ylabel = ylabel,
                titlefont = (fontsize, font),
                xtickfont = (fontsize, font),
                ytickfont = (fontsize, font),
                guidefont = (fontsize, font),
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
                zlabel = zlabel,
                titlefont = (fontsize, font),
                xtickfont = (fontsize, font),
                ytickfont = (fontsize, font),
                ztickfont = (fontsize, font),
                guidefont = (fontsize, font),
                legendfontsize = fontsize,
                markersize = markersize,
                markershape = markershape,
                markerstrokewidth = markerstrokewidth,
                markersizewidth = markersizewidth
            )
        end
    end
    if isnothing(add)
        return fig
    else
        return add
    end
end

function plot_k_clusters(protos, U, data, out_file)
    k = size(protos, 1)
    for j in 1:k
        aux = argmax(U, dims=1)[[x[1] for x in argmax(U, dims=1)] .== j]
        data_cluster = data[[x[2] for x in aux], :]
        if j == 1
            global fig = scatterPL(data_cluster[:, 1], data_cluster[:, 2])
        else
            scatterPL(data_cluster[:, 1], data_cluster[:, 2], fig)
        end
    end
    scatterPL(protos[:, 1], protos[:, 2], fig, color=:black, markersize=4)
    save(fig, out_file)
    return fig
end

function plot_3DClusters(protos, U, sample_data, out_file, labels)
    k = size(protos, 1)
    for j in 1:k
        aux = argmax(U, dims=1)[[x[1] for x in argmax(U, dims=1)] .== j]
        data_cluster = data[[x[2] for x in aux], :]
        if j == 1
            global fig = scatterPL(data_cluster[:, 1], data_cluster[:, 2],
                z=data_cluster[:, 3]
            )
        else
            scatterPL(data_cluster[:, 1], data_cluster[:, 2], fig,
                z=data_cluster[:, 3]
            )
        end
    end
    scatterPL(protos[:, 1], protos[:, 2], fig,
        z=protos[:, 3], color=:black, markersize=5,
        xlabel=labels[1],
        ylabel=labels[2],
        zlabel=labels[3]
    )
    save(fig, out_file)
    return fig
end

function plot_nDimData(protos, U, sample_data, out_file)
    n, p = size(data)
    for j in 1:binomial(p, 3)
        k1 = j % p + 1
        k2 = (j+1) % p + 1
        k3 = (j+2) % p + 1
        plot_3DClusters(protos_cmeans[:, k1:sign(k3-k1):k3], U_cmeans,
            data[:, k1:sign(k3-k1):k3], out_file*"$j.pdf", ("x$k1", "x$k2", "x$k3")
        )
    end
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
function find_membership(data, dist, protos, arg)
    n = size(data, 1)
    k, p = size(protos)
    U = zeros(k, n)
    dists = zeros(k, n)
    for j in 1:k
        dists[j, :] = dist(data, reshape(protos[j, :], (1, p)), arg)
    end
    indexes_min = argmin(dists, dims=1)
    U[indexes_min] .= 1
    return U, dists
end

function rand_params_MvN(a, b, p)
    u = Uniform(a, b)
    μ = rand(u, p)
    Σ = rand(p, p)
    Σ = 0.5 * (Σ + Σ') + p*I
    return μ, Σ
end

function normalize(data)
    return data ./ maximum(abs.(data), dims=1)
end

function read_iris(iris_file)
    iris_file = open(iris_file, "r") do io
        read(io, String)
    end
    lines = split(iris_file, "\n")[1:end-1]
    lines = replace.(lines, "\r" => "")
    data = split.(lines, ",")
    tags = map(x -> x[end], data)
    data = map(x -> x[1:end-1], data)
    n = size(data)[1]
    p = size(data[1])[1]
    data = [parse.(Float64, point) for point in data]
    aux = reshape(data[1], (1, p))
    for j in 2:n
        aux = vcat(aux, reshape(data[j], (1, p)))
    end
    return aux, tags
end
