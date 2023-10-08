module SymRegMethods

using Random
using SymPy

const FUNCTIONS = [:+, :-, :*, :/, :sin, :cos]
const TERMINALS = [:x]

export load_data, random_expression, evaluate_expr, mean_squared_error, random_search

function random_constant()
    return 20 * rand() - 10
end

function load_data(filepath)
    data = [] 
    open(filepath) do file
        for line in eachline(file)
            x, y = split(line, ',')
            push!(data, (parse(Float64, x), parse(Float64, y))) 
        end
    end
    return data
end

function random_expression(depth)
    # 30% of the time, return a terminal
    if depth == 0 || rand() < 0.3 
        # Choose between a variable (e.g., x) or a constant
        # 50% of the time, return a constant
        if rand() < 0.5 
            return round(random_constant(),digits=3)
        else
            return :x
        end
    end

    func = rand(FUNCTIONS)
    if func in [:sin, :cos]
        return Expr(:call, func, random_expression(depth-1))
    else
        return Expr(:call, func, random_expression(depth-1), random_expression(depth-1))
    end
end

function evaluate_expr(expr, x_values)
    y_values = []  # Initialize an empty array of the same number type as x_values
    for val in x_values
        try
            push!(y_values, eval(:(let x = $val; $expr end)))
        catch
            push!(y_values, NaN)
        end
    end
    return y_values
end

function mean_squared_error(y_values, y_values_pred)
    if length(y_values) != length(y_values_pred)
        throw(ArgumentError("Input vectors must have the same length"))
    end
    return sum((y_values .- y_values_pred).^2) / length(y_values)
end

function random_search(x_values, y_values, evaluation)
    mse_history = []
    expr = random_expression()
    best_expr = random_expression()
    best_mse = 10^9
    for i in 1:evaluation
        expr = random_expression()
        y_values_pred = evaluate_expr(expr, x_values)
        mse = mean_squared_error(y_values, y_values_pred)
        if mse < best_mse
            best_mse = mse
            best_expr = expr
        end
        push!(mse_history, best_mse)
    end
    return best_expr, best_mse, mse_history
end

end

