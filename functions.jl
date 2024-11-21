function skiers_flight(du, u, p, t)  # Model of skier's flight
    vx, vy, x, y = u
    m, rho, A, cd, cl, g, phi = p
    v = sqrt(vx^2 + vy^2)

    Fd = 0.5 * rho * v^2 * A * cd
    Fl = 0.5 * rho * v^2 * A * cl

    du[1] = (-Fd * cosd(phi) - Fl * sind(phi)) / m
    du[2] = (-Fd * sind(phi) + Fl * cosd(phi)) / m - g
    du[3] = vx
    du[4] = vy
end

function skiers_flight1(du1, u1, p1, t)  # Model of skier's flight with angle of attack
    vx, vy, x, y = u1
    m, rho, A, cd, cl, g, phi, alpha, vw = p1
    v = sqrt(vx^2 + vy^2)

    L1 = -0.43903 + 0.60743 * alpha - 7.192 * 10 ^ (-4) * alpha ^ 2
    D1 = -0.032061 + 0.1232 * alpha + 2.283 * 10 ^ (-4) * alpha ^ 2
    
    Fd = 0.5 * rho * v^2 * L1  # Drag force
    Fl = 0.5 * rho * v^2 * D1  # Lift force

    du1[1] = ((-Fd * cosd(phi) - Fl * sind(phi)) / m) * (v / (v-vw))
    du1[2] = ((-Fd * sind(phi) + Fl * cosd(phi)) / m - g) * (v / (v-vw))
    du1[3] = vx
    du1[4] = vy
end

function skiers_flight2(du2, u2, p2, t)  # Model of skier's flight with angle of attack
    vx, vy, x, y = u2
    m, rho, A, cd, cl, g, phi, alpha, beta = p2
    v = sqrt(vx^2 + vy^2)

    L1 = -0.43903 + 0.60743 * alpha - 7.192 * 10 ^ (-4) * alpha ^ 2
    D1 = -0.032061 + 0.1232 * alpha + 2.283 * 10 ^ (-4) * alpha ^ 2

    L2 =  0.75037 + 8.86746 * 10 ^ (-3) * beta - 2.99665 * 10 ^ (-4) * beta ^ 2
    D2 = 0.578995 + 0.01201 * beta + 2.91724 * 10 ^ (-5) * beta ^ 2

    L2_2 = -0.645718 + 0.0126185 * beta - 3.348 * 10 ^ (-4) * beta ^ 2
    D2_2 = 0.408434 + 0.01364 *  beta + 3.9308 * 10 ^ (-5) * beta ^ 2

    L = L1 * ((L2 + L2_2) / 2) 
    D = D1 * ((D2 + D2_2) / 2)
    
    Fd = 0.5 * rho * v^2 * L  # Drag force
    Fl = 0.5 * rho * v^2 * D  # Lift force

    du2[1] = (-Fd * cosd(phi) - Fl * sind(phi)) / m
    du2[2] = (-Fd * sind(phi) + Fl * cosd(phi)) / m - g
    du2[3] = vx
    du2[4] = vy
end

function skiers_flight3(du3, u3, p3, t)  # Model of skier's flight with angle of attack
    vx, vy, x, y = u3
    m, rho, A, cd, cl, g, phi, alpha, beta, gamma = p3
    v = sqrt(vx^2 + vy^2)

    L1 = -0.43903 + 0.60743 * alpha - 7.192 * 10 ^ (-4) * alpha ^ 2
    D1 = -0.032061 + 0.1232 * alpha + 2.283 * 10 ^ (-4) * alpha ^ 2

    L2 =  0.75037 + 8.86746 * 10 ^ (-3) * beta - 2.99665 * 10 ^ (-4) * beta ^ 2
    D2 = 0.578995 + 0.01201 * beta + 2.91724 * 10 ^ (-5) * beta ^ 2

    L2_2 = -0.645718 + 0.0126185 * beta - 3.348 * 10 ^ (-4) * beta ^ 2
    D2_2 = 0.408434 + 0.01364 *  beta + 3.9308 * 10 ^ (-5) * beta ^ 2

    L3 = -2.442 + 0.04035 * gamma - 1.25 * 10 ^ (-4) * gamma ^ 2
    D3 = 1.722 - 0.01365 * gamma + 4.5 * 10 ^ (-5)

    L = L1 * ((L2 + L2_2) / 2) * L3
    D = D1 * ((D2 + D2_2) / 2) * D3
    
    Fd = 0.5 * rho * v^2 * L * 10  # Drag force
    Fl = 0.5 * rho * v^2 * D * 10  # Lift force

    du3[1] = (-Fd * cosd(phi) - Fl * sind(phi)) / m
    du3[2] = (-Fd * sind(phi) + Fl * cosd(phi)) / m - g
    du3[3] = vx
    du3[4] = vy
end

function jump_hill(x, params) # Model of ski jump hill
    x_h = x
    w, beta_p, beta_o, P_x, P_y = params
    u = -P_y - w/40 - P_x * tand(beta_o)
    v = P_x * (tand(beta_p) - tand(beta_o))
    return y_h = -w/40 .- x_h .* tand(beta_o) .- (3*u - v) .* ((x_h ./ P_x).^2) .+ (2*u - v) .* ((x_h ./ P_x).^3)
end

function filter_data(time, sol, x_sim, y_sim, params)
    for t in time  # Loop for showing simulated trajectory to the moment of jumper's landing
        x_jumper = sol(t)[3]
        y_jumper = sol(t)[4]
        y_hill = jump_hill(x_jumper, params)

        if(y_jumper + 1 > y_hill)
            push!(x_sim, sol(t)[3])
            push!(y_sim, sol(t)[4])
        else
            break
        end
    end
end