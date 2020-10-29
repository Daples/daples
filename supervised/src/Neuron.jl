function gradient_descent(f, ∇f, x₀; λ=0.01, tol=1e-5)
    x = x₀
    fₚ = 0
    first = false
    while (!first || abs(fₚ - f(x)) >= tol)
        fₚ = f(x)
        x -= λ * ∇f(x)
        if (!first)
            first = true
        end
    end
    return x
end

function create_neuron(operator, ϕ, ∂ϕ)
    dataset_x = [0 0; 0 1; 1 0; 1 1]
    function J(w)
        acum = 0
        for i in 1:size(dataset_x)[1]
            xs = dataset_x[i, :]
            acum += (operator(xs...) - ϕ(sum(w .* xs))) ^ 2
        end
        return acum / 2
    end

    function ∇J(w)
        acum = [0, 0]
        for i in 1:size(dataset_x)[1]
            xs = dataset_x[i,:]
            ws = sum(w .* xs)
            acum = acum .- (operator(xs...) - ϕ(ws)) * ∂ϕ(ws) * xs
        end
        return acum
    end

    return gradient_descent(J, ∇J, zeros(2))
end

and(x1, x2) = x1 & x2
or(x1, x2) = x1 | x2

ϕ_linear(x) = x
∂ϕ_linear(x) = 1
ϕ_sigmoid(x) = 1.0 / (1.0 + exp(-x))
∂ϕ_sigmoid(x) = exp(-x) / (1.0 + exp(-x))^2
∂ϕ_tanh(x) = sech(x)^2

println(create_neuron(and, ϕ_linear, ∂ϕ_linear))
println(create_neuron(and, ϕ_sigmoid, ∂ϕ_sigmoid))
println(create_neuron(and, tanh, ∂ϕ_tanh))
println()
println(create_neuron(or, ϕ_linear, ∂ϕ_linear))
println(create_neuron(or, ϕ_sigmoid, ∂ϕ_sigmoid))
println(create_neuron(or, tanh, ∂ϕ_tanh))
println()
println(create_neuron(xor, ϕ_linear, ∂ϕ_linear))
println(create_neuron(xor, ϕ_sigmoid, ∂ϕ_sigmoid))
println(create_neuron(xor, tanh, ∂ϕ_tanh))
