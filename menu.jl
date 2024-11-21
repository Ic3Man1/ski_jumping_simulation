fig = Figure(resolution = (1920, 1080))
ax1 = fig[1, 1] = Axis(fig,
    # borders
    aspect = 1, limits = (-10, 10, -10, 10),
    # title
    title = "Multiverse Tutorial",
    titlegap = 48, titlesize = 30,
    # x-axis
    xautolimitmargin = (0, 0), xgridwidth = 2, xticklabelsize = 15,
    xticks = LinearTicks(20), xticksize = 18,
    # y-axis
    yautolimitmargin = (0, 0), ygridwidth = 2, yticklabelpad = 14,
    yticklabelsize = 15, yticks = LinearTicks(20), yticksize = 18,

    backgroundcolor = :black
)

vlines!(ax1, [0], linewidth = 2)
hlines!(ax1, [0], linewidth = 2)

colors = [:white, :red, :green, :blue, :cyan, :yellow, :magenta, :black]
markersizes = [6, 8, 10, 12, 14, 18, 24, 30, 36, 42, 60, 72, 84, 96]

datamenu = Menu(fig, options = [1, 2, 3, 4, 5], fontsize = 30)
colormenu = Menu(fig, options = colors, fontsize = 30)
msmenu = Menu(fig, options = markersizes, fontsize = 30)

fig[1,2] = vgrid!(
    Label(fig, "Universe:", fontsize = 30, width = 400), datamenu,
    Label(fig, "Color", fontsize = 30, width = 400), colormenu,
    Label(fig, "Markersize:", fontsize = 30, width = 400), msmenu;
    tellheight = false, width = 500
)

data = []

for i in 1:5
    d = rand(-10:0.1:10, length(x))
    push!(data, d)
end

x = -10:0.1:10
y = Observable(data[1])
c = Observable(colors[1])
ms = Observable(markersizes[1])

scat1 = scatter!(ax1, x, y, color = c, markersize = ms)

on(datamenu.selection) do select
    y[] = data[select]
end

on(colormenu.selection) do select
    c[] = select
end

on(msmenu.selection) do select
    ms[] = select
end

fig