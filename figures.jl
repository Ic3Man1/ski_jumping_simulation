function make_fig(y_res, x_res)
    return fig = Figure(resolution = (y_res, x_res))
end

function make_ax()
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
    return ax1, ax2, ax3, ax4
end

function make_sliders()
    params_grid = SliderGrid(
    fig[1:2,3], 
    (label = "mass (kg)", range=50:1:120, startvalue=70.), 
    (label = "air density (kg/m^3)", range=0.5:0.01:1.3, format="{:.2f}", startvalue=1.23),
    (label = "angle of the jump (degrees)", range=5:1:15, startvalue=10.), 
    (label = "angle of attack (degrees)", range=25:0.1:40, format="{:.1f}", startvalue=30.), 
    (label = "wind speed (m/s)", range=-3:0.1:3, format="{:.1f}", startvalue=0.), 
    (label = "take-off speed (m/s)", range=20:0.1:30, format="{:.1f}", startvalue=25.), 
    (label = "side wind speed (m/s)", range=-1.5:0.1:1.5, format="{:.1f}", startvalue=0.), 
    (label = "jumper's rotation (degrees)", range=-5:0.1:5, format="{:.1f}", startvalue=0.), 
    tellheight = false,
    tellwidth = false
    )
    return params_grid
end