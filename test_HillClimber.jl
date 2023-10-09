using Plots
using Plots.PlotMeasures
using .SymRegMethods

bronze_data = load_data("data/bronze.txt")

x_values = [x for (x, y) in bronze_data]
y_values = [y for (x, y) in bronze_data]

evaluation = 100
depth = 10

best_expr_hc, best_mae_hr, mae_history_hc = hill_climber(x_values, y_values, evaluation, depth)

y_values_pred_hc = evaluate_expr(best_expr_hc, x_values)
best_mae_hr = round(best_mae_hr, digits=2)

# plot the data
p1 = plot(x_values, y_values, label="Actual Data (Bronze)",lw=3)
plot!(x_values, y_values_pred_hc, label="Predicted Data (Hill Climber)",lw=3)
xlabel!("X")
ylabel!("Y")
annotate!(0.5, 15, text("Expression: $best_expr_hc", 9, :left))
plot!(left_margin = 20px, topmargin = 15px, ylim=(-18, 25))
title!("\nMean Absolute Error: $best_mae_hr", titlefontsize=12)

# plot the MAE history
mae_history_hc = log10.(mae_history_hc)
p2 = plot(mae_history_hc, label="Hill Climber",lw=3)
plot!(left_margin = 20px)
xlabel!("Evaluation")
ylabel!("log(MAE)")

p = plot(p1, p2, layout=(2, 1))
plot!(size=(800, 1000))
display(p)