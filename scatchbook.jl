using Plots

x = 1:10; 
y = rand(10)

plot(x, y, label="line", lw=2)
savefig("graphs/line.png")