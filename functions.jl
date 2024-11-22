function skiers_flight1(du1, u1, p1, t)  # Model of skier's flight with angle of attack
    vx, vy, x, y = u1
    m, rho, g, phi, alpha, vw = p1
    v = sqrt(vx^2 + vy^2)

    L1 = -0.43903 + 0.60743 * alpha - 7.192 * 10 ^ (-4) * alpha ^ 2
    D1 = -0.032061 + 0.1232 * alpha + 2.283 * 10 ^ (-4) * alpha ^ 2
    
    Fd = 0.5 * rho * v^2 * L1  # Drag force
    Fl = 0.5 * rho * v^2 * D1  # Lift force

    du1[1] = ((-Fd * cosd(phi) - Fl * sind(phi)) / m) * (v / (v-vw))
    du1[2] = ((-Fd * sind(phi) - Fl * cosd(phi)) / m - g) * (v / (v-vw))
    du1[3] = vx
    du1[4] = vy
end

function jump_hill(x, params) # Model of ski jump hill
    x_h = x
    w, beta_p, beta_o, P_x, P_y = params
    u = -P_y - w/40 - P_x * tand(beta_o)
    v = P_x * (tand(beta_p) - tand(beta_o))
    return y_h = -w/40 .- x_h .* tand(beta_o) .- (3*u - v) .* ((x_h ./ P_x).^2) .+ (2*u - v) .* ((x_h ./ P_x).^3)
end

function filter_data(sim_time, sol, hill_params) # Function for showing simulated trajectory to the moment of jumper's landing
    vx_sim, vy_sim, x_sim, y_sim, plot_time = [], [], [], [], []
    for t in sim_time  
        x_jumper = sol(t)[3]
        y_jumper = sol(t)[4]
        y_hill = jump_hill(x_jumper, hill_params)

        if(y_jumper + 1 > y_hill)
            push!(vx_sim, sol(t)[1])
            push!(vy_sim, sol(t)[2])
            push!(x_sim, sol(t)[3])
            push!(y_sim, sol(t)[4])
            push!(plot_time, t)
        else
            return vx_sim, vy_sim, x_sim, y_sim, plot_time
            break
        end
    end
    return vx_sim, vy_sim, x_sim, y_sim, plot_time
end

function calc_params(v, vw, phi)
    v0 = v + vw                  # Take off speed (m/s)
    vx0 = v0 * cosd(phi)          # Take off speed in x-axis (m/s)
    vy0 = v0 * sind(phi)          # Take off speed in y-axis (m/s)
    x0 = 0.0                     # Take off x-coordinate
    y0 = 0.0                     # Take off y-coordiante
    return [vx0, vy0, x0, y0]
end

function calculate_trajectory(jumper_params, hill_params)  # Calculates jumper's trajectory based on non-linear differential equations
    m, rho, g, phi, alpha, vw, v = jumper_params
    t_sim = (0.0, 10.0)
    sim_time = 0:0.1:10
    u0 = calc_params(v, vw, phi)
    prob = ODEProblem(skiers_flight1, u0, t_sim, jumper_params)
    sol = solve(prob, Tsit5())

    return filter_data(sim_time, sol, hill_params)
end