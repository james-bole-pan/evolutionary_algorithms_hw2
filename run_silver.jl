using .SymRegMethods
using Plots
using Plots.PlotMeasures
using Statistics
# generate a simple case for testing
data = load_data("data/Silver.txt")

x_values = [x for (x, y) in data]
y_values = [y for (x, y) in data]

num_runs = 2

data_name = "silver"

all_mae_histories_hc = []
all_mae_histories_rs = []
all_mae_histories_gp = []
all_mae_histories_gp_var = []
all_best_expr_hc = []
all_best_expr_rs = []
all_best_expr_gp = []
all_best_expr_gp_var = []

evaluation = 50
depth = 5
population_size = 10

for i in 1:num_runs
    println("Run $i")
    best_expr_hc, best_mae_hc, mae_history_hc = hill_climber(x_values, y_values, evaluation, depth)
    best_expr_rs, best_mae_rs, mae_history_rs = random_search(x_values, y_values, evaluation, depth)
    best_expr_gp, best_mae_gp, mae_history_gp = genetic_programming(population_size, x_values, y_values, evaluation, depth)
    best_expr_gp_var, best_mae_gp_var, mae_history_gp_var = genetic_programming_stricter_selection(population_size, x_values, y_values, evaluation, depth)

    push!(all_mae_histories_hc, mae_history_hc)
    push!(all_mae_histories_rs, mae_history_rs)
    push!(all_mae_histories_gp, mae_history_gp)
    push!(all_mae_histories_gp_var, mae_history_gp_var)
    push!(all_best_expr_hc, best_expr_hc)
    push!(all_best_expr_rs, best_expr_rs)
    push!(all_best_expr_gp, best_expr_gp)
    push!(all_best_expr_gp_var, best_expr_gp_var)
end

best_expr_hc, best_mae_hc = best_expr_of_list(all_best_expr_hc, x_values, y_values)
best_expr_rs, best_mae_rs = best_expr_of_list(all_best_expr_rs, x_values, y_values)
best_expr_gp, best_mae_gp = best_expr_of_list(all_best_expr_gp, x_values, y_values)
best_expr_gp_var, best_mae_gp_var = best_expr_of_list(all_best_expr_gp_var, x_values, y_values)

y_values_pred_hc = evaluate_expr(best_expr_hc, x_values)
y_values_pred_rs = evaluate_expr(best_expr_rs, x_values)
y_values_pred_gp = evaluate_expr(best_expr_gp, x_values)
y_values_pred_gp_var = evaluate_expr(best_expr_gp_var, x_values)

best_mae_hc = round(best_mae_hc, digits=2)
best_mae_rs = round(best_mae_rs, digits=2)
best_mae_gp = round(best_mae_gp, digits=2)
best_mae_gp_var = round(best_mae_gp_var, digits=2)

# plot the data
p1 = plot(x_values, y_values, label="Actual Data $data_name",lw=3)
plot!(x_values, y_values_pred_rs, label="Predicted Data (Random Search)",lw=3)
plot!(x_values, y_values_pred_hc, label="Predicted Data (Hill Climber)",lw=3)
plot!(x_values, y_values_pred_gp, label="Predicted Data (Genetic Programming)",lw=3)
plot!(x_values, y_values_pred_gp_var, label="Predicted Data (Genetic Programming with Stricter Selection)",lw=3)
xlabel!("X")
ylabel!("Y")
annotate!(0.5, 12, text("RS Expression: $best_expr_rs", 9, :left))
annotate!(0.5, 9, text("HC Expression: $best_expr_hc", 9, :left))
annotate!(0.5, 6, text("GP Expression: $best_expr_gp", 9, :left))
annotate!(0.5, 3, text("GP Expression (Stricter): $best_expr_gp_var", 9, :left))
plot!(left_margin = 20px, topmargin = 15px, ylim=(-18, 25))
title!("\nMean Absolute Error: \n$best_mae_rs (RS)\n$best_mae_hc (HC)\n$best_mae_gp (GP)\n$best_mae_gp_var (GP_var)", titlefontsize=12)
println("Best expressions")
println("RS: $best_expr_rs")
println("HC: $best_expr_hc")
println("GP: $best_expr_gp")
println("GP (Stricter): $best_expr_gp_var")

# plot the MAE history
all_mae_histories_rs = (hcat(all_mae_histories_rs...))'
all_mae_histories_hc = (hcat(all_mae_histories_hc...))'
all_mae_histories_gp = (hcat(all_mae_histories_gp...))'
all_mae_histories_gp_var = (hcat(all_mae_histories_gp_var...))'

println(size(all_mae_histories_rs))
println(size(all_mae_histories_hc))
println(size(all_mae_histories_gp))
println(size(all_mae_histories_gp_var))

avg_mae_history_rs = reshape(mean(all_mae_histories_rs, dims=1), (evaluation,))
avg_mae_history_hc = reshape(mean(all_mae_histories_hc, dims=1), (evaluation,))
avg_mae_history_gp = reshape(mean(all_mae_histories_gp, dims=1), (evaluation,))
avg_mae_history_gp_var = reshape(mean(all_mae_histories_gp_var, dims=1), (evaluation,))
se_mae_history_rs = reshape(std(all_mae_histories_rs, dims=1) ./ sqrt(num_runs), (evaluation,))
se_mae_history_hc = reshape(std(all_mae_histories_hc, dims=1) ./ sqrt(num_runs), (evaluation,))
se_mae_history_gp = reshape(std(all_mae_histories_gp, dims=1) ./ sqrt(num_runs), (evaluation,))
se_mae_history_gp_var = reshape(std(all_mae_histories_gp_var, dims=1) ./ sqrt(num_runs), (evaluation,))

p2 = plot(avg_mae_history_rs, ribbon=se_mae_history_rs, label="Random Search",lw=3)
plot!(avg_mae_history_hc, ribbon=se_mae_history_hc, label="Hill Climber",lw=3)
plot!(avg_mae_history_gp, ribbon=se_mae_history_gp, label="Genetic Programming",lw=3)
plot!(avg_mae_history_gp_var, ribbon=se_mae_history_gp_var, label="Genetic Programming (Stricter)",lw=3)
plot!(left_margin = 20px)
xlabel!("Evaluation")
ylabel!("MAE")

p = plot(p1, p2, layout=(2, 1))
plot!(size=(800, 1000))
filename = "$data_name _ $evaluation.png"
savefig(filename)
display(p)
