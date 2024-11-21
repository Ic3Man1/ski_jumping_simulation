using DifferentialEquations
using GLMakie

# Funkcja opisująca układ równań różniczkowych
function ski_jump!(du, u, p, t)
    vx, vy, x, y = u  # Rozpakowanie stanu
    m, ρ, A, cd, cl, g, φ = p  # Rozpakowanie parametrów
    v = sqrt(vx^2 + vy^2)  # Całkowita prędkość

    # Siły aerodynamiczne
    Fd = 0.5 * ρ * v^2 * A * cd  # Siła oporu
    Fl = 0.5 * ρ * v^2 * A * cl  # Siła nośna

    # Równania różniczkowe
    du[1] = (-Fd * cos(φ) - Fl * sin(φ)) / m  # dvx/dt
    du[2] = (-Fd * sin(φ) + Fl * cos(φ)) / m - g  # dvy/dt
    du[3] = vx  # dx/dt
    du[4] = vy  # dy/dt
end

# Parametry
m = 70.0  # Masa skoczka (kg)
ρ = 1.225  # Gęstość powietrza (kg/m^3)
A = 0.8  # Powierzchnia czołowa (m^2)
cd = 0.5  # Współczynnik oporu
cl = 1.0  # Współczynnik nośności
g = 9.81  # Przyspieszenie grawitacyjne (m/s^2)
φ = 10.0 * (pi / 180)  # Kąt nachylenia (radiany)

p = (m, ρ, A, cd, cl, g, φ)  # Parametry przekazane do układu

# Warunki początkowe
v0 = 25
vx0 = v0*cos(φ)  # Początkowa prędkość pozioma (m/s)
vy0 = v0*sin(φ)   # Początkowa prędkość pionowa (m/s)
x0 = 0.0    # Początkowe położenie w osi x (m)
y0 = 0.0   # Początkowe położenie w osi y (m)

u0 = [vx0, vy0, x0, y0]  # Początkowe warunki

# Zakres czasu symulacji
tspan = (0.0, 10.0)  # Od 0 do 10 sekund

# Definicja problemu
prob = ODEProblem(ski_jump!, u0, tspan, p)

# Rozwiązanie problemu
sol = solve(prob, Tsit5())

# Wizualizacja wyników
fig = Figure(resolution = (1920, 1080))
ax1 = fig[1, 1] = Axis(fig,
    # borders
    aspect = 2,
    # title
    title = "Ski Jumper's Trajectory",
    titlegap = 10, titlesize = 30,
    # x-axis
    xlabel = "distance", xgridwidth = 2, xticks = LinearTicks(20),
    # y-axis
    ylabel = "height", ygridwidth = 2, yticks = LinearTicks(20)
)

w = 90
Bp = 35.5  # Kąt w stopniach
Bo = 5.9   # Kąt w stopniach
Px = 71.26
Pz = -38.25
params = (w, Bp, Bo, Px, Pz)


function skocznia(x, params)
    x_h = x
    w, Bp, Bo, Px, Pz = params
    u = -Pz - w/40 - Px * tand(Bo)
    v = Px * (tand(Bp) - tand(Bo))
    return z_h = -w/40 .- x_h .* tand(Bo) .- (3*u - v) .* ((x_h ./ Px).^2) .+ (2*u - v) .* ((x_h ./ Px).^3)
end

x_vals = []
y_vals = []

# Gęste próbki czasu dla gładkości
t_vals = 0:0.1:10  # Gęsta siatka czasu

for t in t_vals
    println(sol(t)[4], " ", skocznia(t, params))
    x_skoczek = sol(t)[3]  # Pozioma pozycja skoczka
    y_skoczek = sol(t)[4]  # Pionowa pozycja skoczka
    z_skocznia = skocznia(x_skoczek, params)  # Profil skoczni w pozycji x_skoczek
    if (y_skoczek +1  >= skocznia(x_skoczek, params))
        push!(x_vals, sol(t)[3])
        push!(y_vals, sol(t)[4])
    else
        break
    end
end

#x_vals = [sol(t)[3] for t in t_vals]  # Położenie x
#y_vals = [sol(t)[4] for t in t_vals]  # Położenie y

lines!(ax1, x_vals, y_vals, color=:blue, linewidth=2)
lines!(ax1, x_h, skocznia(x_h, params), color=:black)
fig