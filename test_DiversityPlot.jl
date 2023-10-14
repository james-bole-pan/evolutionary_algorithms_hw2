using Plots
using Plots.PlotMeasures
using .SymRegMethods
using Statistics

all_generations = []
all_generations_std = []

GENERATION = 100
POPULATION = 50

function new_population(size,depth)
    population = []
    for i in 1:size
        push!(population, random_expression(depth))
    end
    return population
end

# loop through all possible pairs in the population
function get_population_diversity(population, x_values, y_values)
    difference_list = []
    for i in 1:length(population)
        for j in 1:length(population)
            if i != j
                expr1 = population[i]
                expr2 = population[j]
                y_values_pred1 = evaluate_expr(expr1, x_values)
                y_values_pred2 = evaluate_expr(expr2, x_values)
                difference = mean_absolute_error(y_values_pred1, y_values_pred2)
                println("expr1: $expr1")
                println("expr2: $expr2")
                println("difference: $difference")
                if isinf(difference)
                    difference = 100
                else if isnan(difference)
                    difference = 0
                end
                push!(difference_list, difference)
            end
        end
    end
    return mean(difference_list), std(difference_list)
end

bronze_data = load_data("data/bronze.txt")

x_values = [x for (x, y) in bronze_data]
y_values = [y for (x, y) in bronze_data]

for i in 1:GENERATION
    population = new_population(POPULATION, 5)
    diversity, std = get_population_diversity(population, x_values, y_values)
    println(i)
    println(diversity)
    push!(all_generations, diversity)
    push!(all_generations_std, std)
end

p = plot(all_generations, xlabel="Generation", ylabel="Diversity", title="\nDiversity Plot of Random Search", lw=3)
plot!(p, size=(800, 600))
plot!(p, left_margin=20px, top_margin=15px)

end