function laplacian_matrix(data, dist; m=5, arg=nothing)
    n, p = size(data)
    dists = zeros(n, n)
    adj_matrix = zeros(n, n)
    neighbors = zeros(n, m)
    for j in 1:n
        dists[j, :] = dist(data, reshape(protos[j, :], (1, p)), arg)
    end
    for i in 1:n
        for j in 1:m
            ind_min = argmin(dists[i, :])
            adj_matrix[i, ind_min] = 1
            dists[i, ind_min] = Inf
        end
    end

    degree_matrix = diagm(sum(adj_matrix, 1))
    L = degree_matrix - adj_matrix
    return L
end

function spectral_cluster(data, m)

end
