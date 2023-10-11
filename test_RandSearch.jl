using Plots
using Plots.PlotMeasures
using .SymRegMethods

bronze_data = load_data("data/bronze.txt")

x_values = [x for (x, y) in bronze_data]
y_values = [y for (x, y) in bronze_data]

evaluation = 10
depth = 3

best_expr_rs, best_mae_rs, mae_history_rs = random_search(x_values, y_values, evaluation, depth)

y_values_pred_rs = evaluate_expr(best_expr_rs, x_values)
best_mae_rs = round(best_mae_rs, digits=2)

# plot the data
p1 = plot(x_values, y_values, label="Actual Data (Bronze)",lw=3)
plot!(x_values, y_values_pred_rs, label="Predicted Data (Random Search)",lw=3)
xlabel!("X")
ylabel!("Y")
annotate!(0.5, 15, text("Expression: $best_expr_rs", 9, :left))
plot!(left_margin = 20px, topmargin = 15px, ylim=(-18, 25))
title!("\nMean Absolute Error: $best_mae_rs", titlefontsize=12)

# plot the MAE history
mae_history_rs = log10.(mae_history_rs)
p2 = plot(mae_history_rs, label="Random Search",lw=3)
plot!(left_margin = 20px)
xlabel!("Evaluation")
ylabel!("log(MAE)")

p = plot(p1, p2, layout=(2, 1))
plot!(size=(800, 1000))
display(p)