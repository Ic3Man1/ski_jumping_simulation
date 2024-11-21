import Pkg

include("functions.jl")

using DifferentialEquations
using GLMakie

# Tworzenie figury i wykresów
fig = Figure(resolution = (1920, 1080))
ax1 = fig[1, 1] = Axis(fig,
    aspect = 2,
    title = "Ski Jumper's Trajectory",
    titlegap = 10, titlesize = 30,
    xlabel = "Distance", xgridwidth = 2, xticks = LinearTicks(20),
    ylabel = "Height", ygridwidth = 2, yticks = LinearTicks(20)
)

params_grid = SliderGrid(
    fig[1, 2], 
    (label = "mass", range=50:1:120, format="{:.2f}", startvalue=70.), 
    tellheight = false,
    tellwidth = false
)

# Parametry lotu
m = Observable(70.0)  # Masa skoczka
rho = 1.225
g = 9.81
phi = 7.0
alpha = 30.0 * (pi / 180)
vw = 0.0  # Prędkość wiatru
u0 = [25.0 * cosd(phi), 25.0 * sind(phi), 0.0, 0.0]

# Parametry skoczni
hill_params = (90.0, 35.5, 5.9, 71.26, -38.25)

# Obserwowalne parametry i trajektoria
jumper_params = Observable((m[], rho, g, phi, alpha, vw))
trajectory = Observable(calculate_trajectory(jumper_params[], hill_params, u0))

# Aktualizacja trajektorii w odpowiedzi na zmianę masy
on(params_grid.sliders[1].value) do new_mass
    jumper_params[] = (new_mass, rho, g, phi, alpha, vw)
    trajectory[] = calculate_trajectory(jumper_params[], hill_params, u0)
    println("Updated mass: ", m[])
    println("Updated trajectory: ", trajectory[])
end

# Rysowanie trajektorii
plot_trajectory = lift(trajectory) do traj
    vx_sim, vy_sim, x_sim, y_sim, plot_time = traj
    empty!(ax1)
    lines!(ax1, x_sim, y_sim, color=:red)
    lines!(ax1, 0:0.1:150, jump_hill(0:0.1:150, hill_params), color=:black)
end

fig
