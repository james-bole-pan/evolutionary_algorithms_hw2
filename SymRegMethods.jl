module SymRegMethods

using Random
using SymPy

const FUNCTIONS = [:+, :-, :*, :/, :sin, :cos]
const TERMINALS = [:x]

export load_data, random_constant, random_expression, evaluate_expr, mean_absolute_error, random_search, mutate, hill_climber
export FUNCTIONS, TERMINALS

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

function mean_absolute_error(y_values, y_values_pred)
    if length(y_values) != length(y_values_pred)
        throw(ArgumentError("Input vectors must have the same length"))
    end
    return sum(abs.(y_values .- y_values_pred)) / length(y_values)
end

function random_search(x_values, y_values, evaluation, depth)
    mae_history = []
    expr = random_expression(depth)
    best_expr = random_expression(depth)
    best_mae = 10^9
    for i in 1:evaluation
        expr = random_expression(depth)
        y_values_pred = evaluate_expr(expr, x_values)
        mae = mean_absolute_error(y_values, y_values_pred)
        if mae < best_mae
            best_mae = mae
            best_expr = expr
        end
        push!(mae_history, best_mae)
    end
    return best_expr, best_mae, mae_history
end

const PROBABILITY_MUTATION = 0.9
const PROBABILITY_IN_PLACE_MUTATION = 0.9 # in-place mutation vs. new subtree
const PROBABILITY_SYMBOL_MUTATION = 0.5 # symbol vs. constant

function mutate(expr)
    if rand() < (1 - PROBABILITY_MUTATION) # probability of not mutating
        return expr
    else
        if rand() < PROBABILITY_IN_PLACE_MUTATION # assign higher probability to "new number/terminal"
            if isa(expr, Expr)
                op = rand(FUNCTIONS)
                if op in [:sin, :cos]
                    return Expr(:call, op, mutate(expr.args[2]))
                else
                    if length(expr.args) == 2
                        return Expr(:call, op, mutate(expr.args[2]), random_expression(1))
                    else
                        return Expr(:call, op, mutate(expr.args[2]), mutate(expr.args[3]))
                    end
                end
            else  
                if rand() < PROBABILITY_SYMBOL_MUTATION
                    return rand(TERMINALS)
                else
                    return random_constant()
                end
            end
        else # new subtree
            return random_expression(2)
        end
    end
end

function hill_climber(x_values, y_values, evaluation, depth)
    mae_history = []
    expr = random_expression(depth)
    best_expr = random_expression(depth)
    best_mae = 10^9
    for i in 1:evaluation
        println(i)
        expr = mutate(expr)
        y_values_pred = evaluate_expr(expr, x_values)
        mae = mean_absolute_error(y_values, y_values_pred)
        if mae < best_mae
            best_mae = mae
            best_expr = expr
        end
        println(best_expr)
        push!(mae_history, best_mae)
    end
    return best_expr, best_mae, mae_history
end

end