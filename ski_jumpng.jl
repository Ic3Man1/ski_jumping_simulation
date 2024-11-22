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
    xlabel = "Distance", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Height", ygridwidth = 2, yticks = LinearTicks(20)
)
ax2 = fig[1, 2] = Axis(fig,
    aspect = 2, limits = (0, 4.25, 24, 50),
    title = "Ski Jumper's Side Trajectory",
    titlegap = 10, titlesize = 30,
    xlabel = "Side movements", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Height", ygridwidth = 2, yticks = LinearTicks(20)
)
ax3 = fig[2, 1] = Axis(fig,
    aspect = 2, limits = (0, 4.25, 20, 32),
    title = "Ski Jumper's x-axis velocity",
    titlegap = 10, titlesize = 30,
    xlabel = "Time", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Speed in x-axis", ygridwidth = 2, yticks = LinearTicks(20)
)
ax4 = fig[2, 2] = Axis(fig,
    aspect = 2, limits = (0, 4.25, -40, 5),
    title = "Ski Jumper's y-axis velocity",
    titlegap = 10, titlesize = 30,
    xlabel = "Time", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Speed in y-axis", ygridwidth = 2, yticks = LinearTicks(20)
)

params_grid = SliderGrid(
    fig[1:2,3], 
    (label = "mass (kg)", range=50:1:120, startvalue=70.), 
    (label = "air density (kg/m^3)", range=0.5:0.01:1.3, format="{:.2f}", startvalue=1.),
    (label = "angle of the jump (degrees)", range=5:1:15, format="{:.2f}", startvalue=10.), 
    (label = "angle of attack (degrees)", range=25:0.1:40, format="{:.2f}", startvalue=35.), 
    (label = "wind speed (m/s)", range=-3:0.1:3, format="{:.2f}", startvalue=0.), 
    (label = "jumper's speed (m/s)", range=20:0.1:30, format="{:.2f}", startvalue=25.), 
    tellheight = false,
    tellwidth = false
)

# Flight parameters
m = 70.0                      # Skier's mass (kg)
rho = 1.225                   # Air denity (kg/m^3)
g = 9.81                      # Acceleration of gravity (m/s^2)
phi = 7.0                     # Angle of the jump (degrees)
alpha = 30.0 * (pi / 180)     # Angle of attack (radians)
v = 25.0                 # Jumper's speed (m/s)
vw = 0.0               # Wind speed (m/s) do 3 m/s


# Initial conditions
#v = params_grid.sliders[6].value                 # Jumper's speed (m/s)
#vw = params_grid.sliders[5].value               # Wind speed (m/s) do 3 m/s
function calc_params(v, vw, phi)
    #v0 = v + vw                  # Take off speed (m/s)
    vx0 = v * cosd(phi)          # Take off speed in x-axis (m/s)
    vy0 = v * sind(phi)          # Take off speed in y-axis (m/s)
    x0 = 0.0                     # Take off x-coordinate
    y0 = 0.0                     # Take off y-coordiante
    return [vx0, vy0, x0, y0]
end

# Ski jump hill parameters (Courchevel hill in Savoie)
w = 90.0        # Distance between the edge of the take off and the K point (meters)
beta_p = 35.5   # Angle of the hill at the P point (degrees)
beta_o = 5.9    # Angle at the base of the take off (degrees)
P_x = 71.26     # P point x coordiante
P_y = -38.25    # P point y coordiante

x_h = 0:0.1:150
hill_params = (w, beta_p, beta_o, P_x, P_y)
#u0 = calc_params(params_grid.sliders[6].value[], params_grid.sliders[5].value[], phi)

jumper_params = Observable((m, rho, g, phi, alpha, vw, v))
trajectory = Observable(calculate_trajectory(jumper_params[], hill_params))

for i in 1:5
    on(params_grid.sliders[i].value) do new_val
        if(i == 1)
            jumper_params[] = (new_val, rho, g, phi, alpha, vw, v)
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        elseif (i == 2)
            jumper_params[] = (m, new_val, g, phi, alpha, vw. v)
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        elseif (i == 3)
            jumper_params[] = (m, rho, g, new_val, alpha, vw, v)
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        elseif (i == 4)
            jumper_params[] = (m, rho, g, phi, new_val * (pi / 180) , vw, v)
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        elseif (i == 5)
            jumper_params[] = (m, rho, g, phi, alpha, new_val, v)
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        elseif (i == 6)
            jumper_params[] = (m, rho, g, phi, alpha, vw, new_val)
            trajectory[] = calculate_trajectory(jumper_params[], hill_params)
        end
    end
end


plot_trajectory = lift(trajectory) do (vx_sim, vy_sim, x_sim, y_sim, plot_time)
    v_sim = sqrt.(vx_sim .^ 2 .+ vy_sim .^ 2)
    empty!(ax1)
    empty!(ax2)
    empty!(ax3)
    empty!(ax4)
    lines!(ax1, x_sim, y_sim, color=:red)
    lines!(ax1, x_h, jump_hill(x_h, hill_params), color=:black)
    lines!(ax2, plot_time, v_sim, color=:purple)
    lines!(ax3, plot_time, vx_sim, color=:green)
    lines!(ax4, plot_time, vy_sim, color=:blue)
end

fig