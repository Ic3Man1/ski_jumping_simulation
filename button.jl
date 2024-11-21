fig = Figure(resolution = (1920, 1080))
ax1 = fig[1, 1] = Axis(fig,
    # borders
    aspect = 1, limits = (-10, 10, -10, 10),
    # title
    title = "Buttons Tutorial",
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

fig[2, 1] = buttongrid = GridLayout(tellwidth = false)
labels = ["Red-8", "Magenta-12", "Green-18", "Cyan-24", "Blue-30"]

buttons = buttongrid[1, 1:5] = [
    Button(fig,
        label = l, height = 60, width = 250, fontsize = 30
    )
    for l in labels
]

bt_sublayout = GridLayout(height = 150)
fig[2, 1] = bt_sublayout

x = -10:0.1:10

data = []

for i in 1:5
    d = rand(-10:0.1:10, length(x))
    push!(data, d)
end

y = Observable(data[1])

colors = [:red, :magenta, :green, :cyan, :blue]

c = Observable(colors[1])

markersizes = [8, 13, 18, 24, 30]

ms = Observable(markersizes[1])

scat1 = scatter!(ax1, x, y, color = c, markersize = ms)

for i in 1:5
    on(buttons[i].clicks) do click
        y[] = data[i]
        c[] = colors[i]
        ms[] = markersizes[i]
    end
end

fig