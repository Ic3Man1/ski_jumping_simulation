#import Pkg

#Pkg.add("GLMakie")
#Pkg.add("DifferentialEquations")

include("functions.jl")
include("figures.jl")

using DifferentialEquations
using GLMakie

fig = make_fig(1920, 1080)
ax1, ax2, ax3, ax4 = make_ax()
params_grid = make_sliders()

# Flight parameters
m = 70.0                      # Skier's mass (kg)
rho = 1.23                   # Air denity (kg/m^3)
g = 9.81                      # Acceleration of gravity (m/s^2)
phi = 10.0                     # Angle of the jump (degrees)
alpha = 30.0 * (pi / 180)     # Angle of attack (radians)
v = 25.0                      # Jumper's speed (m/s)
vw = 0.0                      # Wind speed (m/s)
vsw = Observable(0.0)         # Side wind speed (m/s)
rot = Observable(0.0)          #Jumper's rotation (degrees)

# Ski jump hill parameters (Courchevel hill in Savoie)
w = 90.0        # Distance between the edge of the take off and the K point (meters)
beta_p = 35.5   # Angle of the hill at the P point (degrees)
beta_o = 5.9    # Angle at the base of the take off (degrees)
P_x = 71.26     # P point x coordiante
P_y = -38.25    # P point y coordiante

hill_params = (w, beta_p, beta_o, P_x, P_y)
jumper_params = Observable((m, rho, g, phi, alpha, vw, v))
trajectory = Observable(calculate_trajectory(jumper_params[], hill_params))

for i in 1:8
    if (i <= 6)
        on(params_grid.sliders[i].value) do new_val
            jumper_params[] = update_params(i, jumper_params[], new_val)
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        end
    elseif (i == 7)
        on(params_grid.sliders[7].value) do new_vsw
            vsw[] = new_vsw
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        end
    else
        on(params_grid.sliders[8].value) do new_rot
            rot[] = new_rot
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        end
    end
end

plot_trajectory = lift(trajectory) do (vx_sim, vy_sim, x_sim, y_sim, plot_time)
    x_h = 0:0.1:150
    v_sim = sqrt.(vx_sim .^ 2 .+ vy_sim .^ 2)
    z_sim = calculate_swind(vsw[], rot[], jumper_params[], plot_time, x_sim)
    x_sim = sqrt.(x_sim .^ 2 - z_sim .^ 2)
    println(last(x_sim))
    empty!(ax1)
    empty!(ax2)
    empty!(ax3)
    empty!(ax4)
    lines!(ax1, x_sim, y_sim, color=:red)
    lines!(ax1, x_h, jump_hill(x_h, hill_params), color=:black)
    lines!(ax2, +0.084 .* jump_hill(x_h, hill_params) .- 2.7, jump_hill(x_h, hill_params), color=:black)
    lines!(ax2, -0.084 .* jump_hill(x_h, hill_params) .+ 2.7, jump_hill(x_h, hill_params), color=:black)
    lines!(ax2, z_sim .* 100, y_sim, color=:red)
    lines!(ax3, plot_time, v_sim, color=:blue)
    lines!(ax4, plot_time, vx_sim, color=:green)
end

fig