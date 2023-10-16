module SymRegMethods

using Random
using SymPy
using Plots

const FUNCTIONS = [:+, :-, :*, :/, :sin, :cos]
const TERMINALS = [:x]

export load_data, random_constant, random_expression, evaluate_expr, mean_absolute_error, random_search, mutate, hill_climber, best_expr_of_list
export crossover, tournament_selection, genetic_programming, genetic_programming_stricter_selection

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
    for i in 1:length(y_values_pred)
        if isnan(y_values_pred[i])
            y_values_pred[i] = 0
        end
    end
    return sum(abs.(y_values .- y_values_pred)) / length(y_values)
end

function best_expr_of_list(expr_list, x_values, y_values)
    best_expr = expr_list[1]
    best_mae = mean_absolute_error(y_values, evaluate_expr(best_expr, x_values))
    for expr in expr_list
        mae = mean_absolute_error(y_values, evaluate_expr(best_expr, x_values))
        if mae < best_mae
            best_expr = expr
            best_mae = mae
        end
    end
    return best_expr, best_mae
end

function random_search(x_values, y_values, evaluation, depth)
    mae_history = []
    expr = random_expression(depth)
    best_expr = random_expression(depth)
    best_mae = mean_absolute_error(y_values, evaluate_expr(best_expr, x_values))
    for i in 1:evaluation
        println(i)
        expr = random_expression(depth)
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

const PROBABILITY_MUTATION = 0.9
const PROBABILITY_IN_PLACE_MUTATION = 0.9 # in-place mutation vs. new subtree
const PROBABILITY_SYMBOL_MUTATION = 0.5 # symbol vs. constant

function mutate(expr)
    expr = deepcopy(expr)
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
    best_mae = mean_absolute_error(y_values, evaluate_expr(best_expr, x_values))
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

# methods for genetic programming
function random_subexpr(expr, depth=0)
    if !isa(expr, Expr)
        return expr, depth
    end

    # Decide if we return this node or delve deeper
    if rand() < 0.2  # This probability can be adjusted
        return expr, depth
    end

    chosen_child = rand(expr.args[2:end])
    return random_subexpr(chosen_child, depth+1)
end

function replace_subexpr!(main_expr, old_subexpr, new_subexpr)
    if main_expr == old_subexpr
        return new_subexpr
    end

    for i in 1:length(main_expr.args)
        if main_expr.args[i] == old_subexpr
            main_expr.args[i] = new_subexpr
        elseif isa(main_expr.args[i], Expr)
            replace_subexpr!(main_expr.args[i], old_subexpr, new_subexpr)
        end
    end
    
    return main_expr
end

function crossover(parent1, parent2)
    subexpr1, _ = random_subexpr(deepcopy(parent1))
    subexpr2, _ = random_subexpr(deepcopy(parent2))

    child1 = replace_subexpr!(deepcopy(parent1), subexpr1, subexpr2)
    child2 = replace_subexpr!(deepcopy(parent2), subexpr2, subexpr1)

    return child1, child2
end

function tournament_selection(population, x_values, y_values)
    # randomly select 2 individuals from the population
    # return the individual with the lowest MAE
    # if there is a tie, return the first individual
    # (this is arbitrary)
    individual1 = population[rand(1:length(population))]
    individual2 = population[rand(1:length(population))]
    mae1 = mean_absolute_error(y_values, evaluate_expr(individual1, x_values))
    mae2 = mean_absolute_error(y_values, evaluate_expr(individual2, x_values))
    if mae1 < mae2
        return individual1
    else
        return individual2
    end
end

function tournament_selection_stricter(population, x_values, y_values)
    # randomly select 2 individuals from the population
    # return the individual with the lowest MAE
    # if there is a tie, return the first individual
    # (this is arbitrary)
    individual1 = population[rand(1:length(population))]
    individual2 = population[rand(1:length(population))]
    individual3 = population[rand(1:length(population))]
    mae1 = mean_absolute_error(y_values, evaluate_expr(individual1, x_values))
    mae2 = mean_absolute_error(y_values, evaluate_expr(individual2, x_values))
    mae3 = mean_absolute_error(y_values, evaluate_expr(individual3, x_values))
    if mae1 < mae2 && mae1 < mae3
        return individual1
    elseif mae2 < mae1 && mae2 < mae3
        return individual2
    else
        return individual3
    end
end

function genetic_programming(population_size, x_values, y_values, evaluation, depth)
    mae_history = []
    population = [random_expression(depth) for i in 1:population_size]
    best_expr = population[1]
    best_mae = mean_absolute_error(y_values, evaluate_expr(best_expr, x_values))
    for i in 1:evaluation
        println(i)
        new_population = []
        while length(new_population) < population_size
            parent1 = tournament_selection(population, x_values, y_values)
            parent2 = tournament_selection(population, x_values, y_values)
            child1, child2 = crossover(parent1, parent2)
            child1 = mutate(child1)
            child2 = mutate(child2)
            push!(new_population, child1)
            push!(new_population, child2)
        end
        population = new_population
        pop_best_expr, pop_best_mae = best_expr_of_list(population, x_values, y_values)
        if pop_best_mae < best_mae
            best_mae = pop_best_mae
            best_expr = pop_best_expr
            y_values_pred = evaluate_expr(best_expr, x_values)
            plot(x_values, y_values, label="Actual Data",lw=3)
            plot!(x_values, y_values_pred, label="Predicted Data",lw=3)
            plot!(title = "Evaluation $i, MAE: $best_mae")
            print("here")
            savefig("movie/gp_$i.png")
        end
        println(best_expr)
        push!(mae_history, best_mae)
    end
    return best_expr, best_mae, mae_history
end

function genetic_programming_stricter_selection(population_size, x_values, y_values, evaluation, depth)
    mae_history = []
    population = [random_expression(depth) for i in 1:population_size]
    best_expr = population[1]
    best_mae = mean_absolute_error(y_values, evaluate_expr(best_expr, x_values))
    for i in 1:evaluation
        println(i)
        new_population = []
        while length(new_population) < population_size
            parent1 = tournament_selection_stricter(population, x_values, y_values)
            parent2 = tournament_selection_stricter(population, x_values, y_values)
            child1, child2 = crossover(parent1, parent2)
            child1 = mutate(child1)
            child2 = mutate(child2)
            push!(new_population, child1)
            push!(new_population, child2)
        end
        population = new_population
        pop_best_expr, pop_best_mae = best_expr_of_list(population, x_values, y_values)
        if pop_best_mae < best_mae
            best_mae = pop_best_mae
            best_expr = pop_best_expr
        end
        println(best_expr)
        push!(mae_history, best_mae)
    end
    return best_expr, best_mae, mae_history
end

end