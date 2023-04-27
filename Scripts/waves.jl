using Plots
using Waveforms

n_periods = 10
wave_period = [-10, -5, 0, 5, 10, 5, 0, -5]
P = 3

x = -pi/2:0.05:2*pi * n_periods - pi/2
plot(x, @.trianglewave(x))
plot!(legend=false, xaxis=false)
savefig("triangle.pdf")

scatter(collect(1:8*P), repeat(wave_period, P), linetype=:steppre, legend=false, xticks=false, xaxis=false)  
savefig("triangle_step.pdf")

println("Ready")