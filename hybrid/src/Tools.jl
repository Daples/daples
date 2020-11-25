using MLDatasets
using Plots

function plot_number(mat)
    return heatmap(mat, color = :greys)
end
