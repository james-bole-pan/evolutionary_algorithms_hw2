using Plots
using Plots.PlotMeasures
using .SymRegMethods

all_generations = []
GENERATION = 10
POPULATION = 5

function new_population(size,depth)
    population = []
    for i in 1:size
        push!(population, random_expression(depth))
    end
    return population
end

function get_population_mae_list(population, x_values, y_values)
    mae_list = []
    for expr in population
        y_values_pred = evaluate_expr(expr, x_values)
        mae = mean_absolute_error(y_values, y_values_pred)
        push!(mae_list, mae)
    end
    return mae_list
end

bronze_data = load_data("data/bronze.txt")

x_values = [x for (x, y) in bronze_data]
y_values = [y for (x, y) in bronze_data]

for i in 1:GENERATION
    population = new_population(POPULATION, 5)
    mae_list = get_population_mae_list(population, x_values, y_values)
    push!(all_generations, mae_list)
end

# Use comprehension to format data for plotting
x_vals = [i for i=1:GENERATION for _=1:POPULATION]
y_vals = [y for x in all_generations for y in x]

scatter(x_vals, y_vals,color=:purple)
plot!(legend=false, xlabel="Generation", ylabel="MAE", title="\nDot Plot of Random Search")
plot!(ylim = (0,30), size=(800, 600), left_margin=20px, topmargin=15px)
