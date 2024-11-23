#import Pkg

#Pkg.add("GLMakie")
#Pkg.add("DifferentialEquations")

include("functions.jl")

using DifferentialEquations
using GLMakie

fig = Figure(resolution = (1920, 1080))
ax1 = fig[1, 1] = Axis(fig,
    aspect = 2,
    title = "Ski Jumper's Trajectory",
    titlegap = 10, titlesize = 30,
    xlabel = "Distance [m]", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Height [m]", ygridwidth = 2, yticks = LinearTicks(20)
)
ax2 = fig[1, 2] = Axis(fig,
    aspect = 2, limits = (-9, 9, -75, 2),
    title = "Ski Jumper's Side Trajectory",
    titlegap = 10, titlesize = 30,
    xlabel = "Side movements [m]", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Height [m]", ygridwidth = 2, yticks = LinearTicks(20)
)
ax3 = fig[2, 1] = Axis(fig,
    aspect = 2, limits = (0, 4.5, 16, 50),
    title = "Ski Jumper's resultant velocity",
    titlegap = 10, titlesize = 30,
    xlabel = "Time [s]", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Speed [ms/s]", ygridwidth = 2, yticks = LinearTicks(20)
)
ax4 = fig[2, 2] = Axis(fig,
    aspect = 2, limits = (0, 4.5, 16, 33),
    title = "Ski Jumper's x-axis velocity",
    titlegap = 10, titlesize = 30,
    xlabel = "Time [s]", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Speed [m/s]", ygridwidth = 2, yticks = LinearTicks(20)
)

params_grid = SliderGrid(
    fig[1:2,3], 
    (label = "mass (kg)", range=50:1:120, startvalue=70.), 
    (label = "air density (kg/m^3)", range=0.5:0.01:1.3, format="{:.2f}", startvalue=1.23),
    (label = "angle of the jump (degrees)", range=5:1:15, startvalue=10.), 
    (label = "angle of attack (degrees)", range=25:0.1:40, format="{:.1f}", startvalue=35.), 
    (label = "wind speed (m/s)", range=-3:0.1:3, format="{:.1f}", startvalue=0.), 
    (label = "take-off speed (m/s)", range=20:0.1:30, format="{:.1f}", startvalue=25.), 
    (label = "side wind speed (m/s)", range=-2.5:0.1:2.5, format="{:.1f}", startvalue=0.), 
    tellheight = false,
    tellwidth = false
)

# Flight parameters
m = 70.0                      # Skier's mass (kg)
rho = 0.5                   # Air denity (kg/m^3)
g = 9.81                      # Acceleration of gravity (m/s^2)
phi = 7.0                     # Angle of the jump (degrees)
alpha = 30.0 * (pi / 180)     # Angle of attack (radians)
v = 25.0                      # Jumper's speed (m/s)
vw = 0.0                      # Wind speed (m/s)
vsw = Observable(0.0)         # Side wind speed (m/s)

# Ski jump hill parameters (Courchevel hill in Savoie)
w = 90.0        # Distance between the edge of the take off and the K point (meters)
beta_p = 35.5   # Angle of the hill at the P point (degrees)
beta_o = 5.9    # Angle at the base of the take off (degrees)
P_x = 71.26     # P point x coordiante
P_y = -38.25    # P point y coordiante

x_h = 0:0.1:150
hill_params = (w, beta_p, beta_o, P_x, P_y)
z_sim = zeros(length(0:0.1:5))
jumper_params = Observable((m, rho, g, phi, alpha, vw, v))
trajectory = Observable(calculate_trajectory(jumper_params[], hill_params))

for i in 1:6
    on(params_grid.sliders[i].value) do new_val
        jumper_params[] = update_params(i, jumper_params[], new_val)
        trajectory[] = calculate_trajectory(jumper_params[], hill_params)
    end
end

on(params_grid.sliders[7].value) do new_vsw
    vsw[] = new_vsw
    trajectory[] = calculate_trajectory(jumper_params[], hill_params)
end

plot_trajectory = lift(trajectory) do (vx_sim, vy_sim, x_sim, y_sim, plot_time)
    v_sim = sqrt.(vx_sim .^ 2 .+ vy_sim .^ 2)
    z_sim = calculate_swind(vsw[], jumper_params[])
    x_sim = sqrt.(x_sim .^ 2 - z_sim[1:length(plot_time)] .^ 2)
    empty!(ax1)
    empty!(ax2)
    empty!(ax3)
    empty!(ax4)
    lines!(ax1, x_sim, y_sim, color=:red)
    lines!(ax1, x_h, jump_hill(x_h, hill_params), color=:black)
    lines!(ax2, +0.084 .* jump_hill(x_h, hill_params) .- 2.7, jump_hill(x_h, hill_params), color=:black)
    lines!(ax2, -0.084 .* jump_hill(x_h, hill_params) .+ 2.7, jump_hill(x_h, hill_params), color=:black)
    lines!(ax2, z_sim[1:length(plot_time)] .* 100, y_sim, color=:red)
    lines!(ax3, plot_time, v_sim, color=:blue)
    lines!(ax4, plot_time, vx_sim, color=:green)
end

fig