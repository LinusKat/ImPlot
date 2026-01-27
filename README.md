# <span align="left">ImPlot</span> <a href="https://github.com/LinusKat/ImPlot/releases/download/V1/ImPlotExampleWindow.rbxm"><img align="right" src="/public/download.svg" /></a>

This is a widget addon, using the open source project [Iris](https://github.com/SirMallard/Iris).

<div align="center">
    <table>
        <tr>
            <td><img src="public/example1.png" alt="Example 1" width="400"/></td>
            <td><img src="public/example2.png" alt="Example 2" width="400"/></td>
        </tr>
        <tr>
            <td><img src="public/example3.png" alt="Example 3" width="400"/></td>
            <td><img src="public/example4.png" alt="Example 4" width="400"/></td>
        </tr>
    </table>
</div>

> Iris is an Immediate-Mode GUI Library for Roblox for creating debug and visualisation UI and tools and based on Dear ImGui.

## Installation

### Pre-installed

Download the Iris RBXM/ZIP from [releases](https://github.com/LinusKat/ImPlot/releases).

### Manual

Since Iris does not have the capability to simply add widgets you will need to modify Iris internal files to use the ImPlot addon.

If you are using an external code editor through a tool such as Rojo, I recommend downloading the packaged Iris zip file in [releases](https://github.com/LinusKat/ImPlot/releases).

## Usage

### Graphs

```lua
local RunService = game:GetService("RunService")
local Memory = require("@self/Memory")
local Iris = require("@self/Iris")

local PIDMemory = Memory.new(2400)

local function PIDUpdate()
    local pid_plots = Iris.State({})
    local show_context = Iris.State(true)

	-- PID Updates

    pid_plots:set{{
        Data = PIDMemory.Memory,
        Name = "PID Force",
        GraphStyle = {
            Color = Color3.new(1, 0, 0),
            Thickness = 1,
        },
    }}

    Iris.Window({"Live PID Graph"}); do
        Iris.ImPlotGraph({
            "PID Force",
            { X = "t", Y = "Force", XScale = 1, YScale = .4 }},
            {plots = pid_plots, showDataInformation = show_context}
        )
    end; Iris.End()
end

RunService.Heartbeat:Connect(PIDUpdate)
```

### Pie Charts

```lua
local Iris = require("@self/Iris")

local EuropeanPizzaPreference = {
	{Value = 97, Color = Color3.fromRGB(255, 99, 71), Name = "Neapolitan Pizza"},
	{Value = 19, Color = Color3.fromRGB(30, 144, 255), Name = "Sicilian Pizza"},
	{Value = 7, Color = Color3.fromRGB(50, 205, 50), Name = "Roman Pizza"},
	{Value = 13, Color = Color3.fromRGB(218, 112, 214), Name = "French Pizza"},
	{Value = 45, Color = Color3.fromRGB(255, 165, 0), Name = "Spanish Pizza"},
	{Value = 21, Color = Color3.fromRGB(139, 69, 19), Name = "Calzone"},
	{Value = 64, Color = Color3.fromRGB(0, 191, 255), Name = "New York Pizza"},
}

Iris.Window({"Pie Chart"}); do
    local show_pie_chart_data = Iris.State(true) -- this will show whether the data of the pie chart is shown.
    Iris.Checkbox({"Show Pie Chart Data"}, {isChecked = show_pie_chart_data})

	Iris.ImPlotPieChart({EuropeanPizzaPreference}, {showPieData = show_pie_chart_data})
end; Iris.End()
```

### Scatter Charts

```lua
local Iris = require("@self/Iris")

local ScatterPlot = {
	Data = {},
	Name = "math.random()",
	MarkerStyle = {
		Shape = "Circle",
		Color = Color3.new(1, 0, 0),
		Size = 10,
		Transparency = .4
	},
}

local RNG = Random.new(os.clock())
for i = 1, 50 do
    table.insert(ScatterPlot.Data,
		Vector2.new(RNG:NextInteger(-100, 100), RNG:NextInteger(0, 50))
	)
end

local scatter_plot_state = Iris.State({})

scatter_plot_state:set({ScatterPlot})

Iris.Window({"Scatter Chart"}); do
	Iris.ImPlotGraph({
		"Scatter Plot",
		{X = "X", Y = "Y", XScale = .9, YScale = .9}},
		{plots = scatter_plot_state}
	)
end; Iris.End()
```

## API

### `ImPlotGraph` - Graph Widget

```lua
function ImPlotGraph(
	WidgetArguments: {
		GraphName: string?,
		Axes: {
			XScale: number,
			X: string,
			YScale: number,
			Y: string,
		},
	},

	WidgetStates: {
		showDataInformation: State<boolean>,
		size: State<Vector2>,
		plots: State<{
			{
				Data: {Vector2},
				Name: string?,
				MarkerStyle: { -- Include when scatter plot | Customization for scatter plot
					Shape: Shape,
					Color: Color3,
					Size: number,
					Transparency: number,
				}?,
				GraphStyle: { -- Include when graph plot | Customization for graph lines
					Color: Color3,
					Thickness: number,
				}?,
			}
		}>,
	}
)
```

### `ImPlotPieChart` - Pie Chart Widget

```lua
function ImPlotPieChart(
	ChunkDataContainer: Frame,
	PieChart: any,

	WidgetArguments: {
		pieData: {
			Color: Color3?,
			Value: number,
		},
	},

	WidgetStates: {
		showPieData: State<boolean>,
		normalize: State<boolean>,
	}
)
```

## Credits

- ImPlot Documentation - [@vijarsan](https://github.com/vijarsan)
- [Iris](https://github.com/SirMallard/Iris) - Maintained by [@SirMallad](https://github.com/SirMallard)
- [Maid](https://github.com/Quenty/NevermoreEngine/blob/main/src/maid/src/Shared/Maid.lua) - Maid by [Quenty](https://github.com/Quenty)
