using GLMakie

fig = Figure(resolution = (1920, 1080))
ax1 = fig[1, 1] = Axis(fig,
    # borders
    aspect = 1, limits = (-10, 10, -10, 10),
    # title
    title = "Sliders Tutorial",
    titlegap = 48, titlesize = 30,
    # x-axis
    xautolimitmargin = (0, 0), xgridwidth = 2, xticklabelsize = 15,
    xticks = LinearTicks(20), xticksize = 18,
    # y-axis
    yautolimitmargin = (0, 0), ygridwidth = 2, yticklabelpad = 14,
    yticklabelsize = 15, yticks = LinearTicks(20), yticksize = 18
)

vlines!(ax1, [0], linewidth = 2)
hlines!(ax1, [0], linewidth = 2)

lsgrid = SliderGrid(
    fig[1,2], 
    (label = "slope", range=-10:0.01:10, format="{:.2f}", startvalue=0), 
    (label = "y-intercept", range=-10:0.01:10, format="{:.2f}", startvalue=0),
    tellheight = false,
    tellwidth = false
)

sl_sublayout = GridLayout(height = 800)
fig[1, 2] = sl_sublayout
fig[1, 2] = lsgrid.layout

slope = lsgrid.sliders[1].value
intercept = lsgrid.sliders[2].value

x = -10:0.01:10
y = @lift($slope .* x .+ $intercept)

line1 = lines!(ax1, y, x, color = :blue, linewidth = 5)

xlims!(ax1, -10, 10)
ylims!(ax1, -10, 10)




fig