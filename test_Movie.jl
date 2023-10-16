using Plots
using Plots.PlotMeasures
using .SymRegMethods

bronze_data = load_data("data/bronze.txt")

x_values = [x for (x, y) in bronze_data]
y_values = [y for (x, y) in bronze_data]

evaluation = 10
depth = 3

function random_search_for_movie(x_values, y_values, evaluation, depth)
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
            plot(x_values, y_values, label="Actual Data",lw=3)
            plot!(x_values, y_values_pred, label="Predicted Data (Random Search)",lw=3)
            plot!(title = "Evaluation $i, MAE: $best_mae")
            print("here")
            savefig("movie/random_search_$i.png")
        end
        println(best_expr)
        push!(mae_history, best_mae)
    end
    return best_expr, best_mae, mae_history
end

function genetic_programming_for_movie(population_size, x_values, y_values, evaluation, depth)
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

best_expr_rs, best_mae_rs, mae_history_rs = genetic_programming_for_movie(20, x_values, y_values, evaluation, depth)