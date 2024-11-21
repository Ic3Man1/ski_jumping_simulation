import Pkg

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
    aspect = 2,
    title = "Ski Jumper's Side Trajectory",
    titlegap = 10, titlesize = 30,
    xlabel = "Side movements", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Height", ygridwidth = 2, yticks = LinearTicks(20)
)
ax3 = fig[2, 1] = Axis(fig,
    aspect = 2,
    title = "Ski Jumper's x-axis velocity",
    titlegap = 10, titlesize = 30,
    xlabel = "Time", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Speed in x-axis", ygridwidth = 2, yticks = LinearTicks(20)
)
ax4 = fig[2, 2] = Axis(fig,
    aspect = 2,
    title = "Ski Jumper's y-axis velocity",
    titlegap = 10, titlesize = 30,
    xlabel = "Time", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Speed in y-axis", ygridwidth = 2, yticks = LinearTicks(20)
)

params_grid = SliderGrid(
    fig[1,3], 
    (label = "mass", range=50:1:120, format="{:.2f}", startvalue=70.), 
    tellheight = false,
    tellwidth = false
)

# Flight parameters
m = Observable(70.0)                     # Skier's mass (kg)
rho = 1.225                   # Air denity (kg/m^3)
g = 9.81                      # Acceleration of gravity (m/s^2)
phi = 7.0                     # Angle of the jump (degrees)
alpha = 30.0 * (pi / 180)     # Angle of attack (radians)
beta = 9.5 * (pi/180)         # Body to ski angle (radians)
gamma = 150.0 * (pi/180)       # Hip angle (radians)


# Initial conditions
v = 25.0                     # Jumper's speed (m/s)
vw = 0                     # Wind speed (m/s) do 3 m/s
v0 = v + vw                  # Take off speed (m/s)
vx0 = v0*cosd(phi)          # Take off speed in x-axis (m/s)
vy0 = v0*sind(phi)          # Take off speed in y-axis (m/s)
x0 = 0.0                     # Take off x-coordinate
y0 = 0.0                     # Take off y-coordiante

t_sim = (0.0, 10.0)     # Length of simulation

# Ski jump hill parameters (Courchevel hill in Savoie)
w = 90.0        # Distance between the edge of the take off and the K point (meters)
beta_p = 35.5   # Angle of the hill at the P point (degrees)
beta_o = 5.9    # Angle at the base of the take off (degrees)
P_x = 71.26     # P point x coordiante
P_y = -38.25    # P point y coordiante

x_h = 0:0.1:150
jumper_params = Observable((m, rho, g, phi, alpha, vw))
hill_params = (w, beta_p, beta_o, P_x, P_y)
u0 = [vx0, vy0, x0, y0]
sim_time = 0:0.1:10

trajectory = Observable(calculate_trajectory((m[], rho, g, phi, alpha, vw), hill_params, u0))

#prob = ODEProblem(skiers_flight1, u0, t_sim, p1)
#sol = solve(prob1, Tsit5())

#vx_sim, vy_sim, x_sim, y_sim, plot_time = filter_data(sim_time, sol, hill_params)
#v_sim = sqrt.(vx_sim .^ 2 .+ vy_sim .^ 2)
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

on(params_grid.sliders[1].value) do new_mass
    m[] = new_mass
    trajectory[] = calculate_trajectory((m[], rho, g, phi, alpha, vw), hill_params, u0)
end

fig