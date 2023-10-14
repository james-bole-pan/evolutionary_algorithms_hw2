using Plots
using Plots.PlotMeasures
using .SymRegMethods
using Statistics

bronze_data = load_data("data/bronze.txt")

x_values = [x for (x, y) in bronze_data]
y_values = [y for (x, y) in bronze_data]

num_runs = 3

all_mae_histories_hc = []
all_mae_histories_rs = []
all_best_expr_hc = []
all_best_expr_rs = []

evaluation = 5
depth = 2

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

for _ in 1:num_runs
    best_expr_hc, best_mae_hc, mae_history_hc = hill_climber(x_values, y_values, evaluation, depth)
    best_expr_rs, best_mae_rs, mae_history_rs = random_search(x_values, y_values, evaluation, depth)

    push!(all_mae_histories_hc, mae_history_hc)
    push!(all_mae_histories_rs, mae_history_rs)
    push!(all_best_expr_hc, best_expr_hc)
    push!(all_best_expr_rs, best_expr_rs)
end

best_expr_hc, best_mae_hc = best_expr_of_list(all_best_expr_hc, x_values, y_values)
best_expr_rs, best_mae_rs = best_expr_of_list(all_best_expr_rs, x_values, y_values)

y_values_pred_hc = evaluate_expr(best_expr_hc, x_values)
y_values_pred_rs = evaluate_expr(best_expr_rs, x_values)

best_mae_hc = round(best_mae_hc, digits=2)
best_mae_rs = round(best_mae_rs, digits=2)

# plot the data
p1 = plot(x_values, y_values, label="Actual Data (Bronze)",lw=3)
plot!(x_values, y_values_pred_rs, label="Predicted Data (Random Search)",lw=3)
plot!(x_values, y_values_pred_hc, label="Predicted Data (Hill Climber)",lw=3)
xlabel!("X")
ylabel!("Y")
annotate!(0.5, 15, text("RS Expression: $best_expr_rs", 9, :left))
annotate!(0.5, 12, text("HC Expression: $best_expr_hc", 9, :left))
plot!(left_margin = 20px, topmargin = 15px, ylim=(-18, 25))
title!("\nMean Absolute Error: \n$best_mae_rs (RS)\n$best_mae_hc (HC)", titlefontsize=12)

# plot the MAE history
all_mae_histories_rs = (hcat(all_mae_histories_rs...))'
all_mae_histories_hc = (hcat(all_mae_histories_hc...))'

println(size(all_mae_histories_rs))
println(size(all_mae_histories_hc))

avg_mae_history_rs = reshape(mean(all_mae_histories_rs, dims=1), (evaluation,))
avg_mae_history_hc =  reshape(mean(all_mae_histories_hc, dims=1), (evaluation,))
se_mae_history_rs = reshape(std(all_mae_histories_rs, dims=1) ./ sqrt(num_runs), (evaluation,))
se_mae_history_hc = reshape(std(all_mae_histories_hc, dims=1) ./ sqrt(num_runs), (evaluation,))

p2 = plot(avg_mae_history_rs, ribbon=se_mae_history_rs, label="Random Search",lw=3)
plot!(avg_mae_history_hc, ribbon=se_mae_history_hc, label="Hill Climber",lw=3)
plot!(left_margin = 20px)
xlabel!("Evaluation")
ylabel!("MAE")

p = plot(p1, p2, layout=(2, 1))
plot!(size=(800, 1000))
display(p)
