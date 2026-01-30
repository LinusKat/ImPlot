--!strict
local floor = math.floor
local huge = math.huge
local map = math.map

local RunService = game:GetService("RunService")

local WidgetTypes = require("../WidgetTypes")
local IrisTypes = require("../Types")

local MeterTape = require("@self/Plots/Graph/MeterTape")
local PieChart = require("@self/Plots/PieChart")
local Graph = require("@self/Plots/Graph")
local Util = require("@self/Util")

local GRID_FLOOR_TRANSPARENCY = 0.7
local GRID_LINES_TRANSPARENCY = 0.9

return function(Iris: IrisTypes.Internal, widgets: IrisTypes.WidgetUtility)
	local function NewText(Parent: Instance, MinTextSize: number, MaxTextSize: number)
		local Label = Instance.new("TextLabel")

		Label.Parent = Parent

		Label.BackgroundTransparency = 1

		Label.TextColor3 = Iris._config.TextColor
		Label.FontFace = Iris._config.TextFont

		Label.TextScaled = true

		local constraint = Instance.new("UITextSizeConstraint")

		constraint.Parent = Label
		constraint.MinTextSize = MinTextSize or 0
		constraint.MaxTextSize = MaxTextSize or huge

		return Label
	end
	
	Iris.WidgetConstructor("ImPlotPieChart", {
		hasState = true,
		hasChildren = false,
		Args = {
			["pieData"] = 1,
		},
		Events = {},
		Generate = function(thisWidget: WidgetTypes.ImPlotPieChart)
			local background = Instance.new("Frame")
			background.Name = "Iris_PieChart"

			background.Size = UDim2.fromOffset(250, 250)
			background.BackgroundColor3 = Iris._config.FrameBgColor
			background.Transparency = Iris._config.FrameBgTransparency
			background.AutomaticSize = Enum.AutomaticSize.None
			background.ClipsDescendants = true
			background.ZIndex = thisWidget.ZIndex
			background.LayoutOrder = thisWidget.ZIndex

			widgets.applyFrameStyle(background)
			
			local pie_viewport = Instance.new("CanvasGroup")
			pie_viewport.Name = "Viewport"
			pie_viewport.Size = UDim2.fromOffset(250 - 15, 250 - 15)
			pie_viewport.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			pie_viewport.AnchorPoint = Vector2.one * .5
			pie_viewport.Position = UDim2.fromScale(.5, .5)
			pie_viewport.Parent = background
			widgets.applyFrameStyle(pie_viewport)
			
			local chunk_data = Instance.new("Frame")
			chunk_data.Name = "ChunkData"
			chunk_data.AutomaticSize = Enum.AutomaticSize.XY
			chunk_data.Position = UDim2.fromOffset(10, 10)
			chunk_data.ClipsDescendants = true
			chunk_data.Transparency = 0
			chunk_data.Parent = pie_viewport
			chunk_data.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			chunk_data.BorderSizePixel = 0
			chunk_data.ZIndex = 2
			
			widgets.applyFrameStyle(chunk_data)
			widgets.UIStroke(chunk_data, Iris._config.PopupBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)
			widgets.UIPadding(chunk_data, Iris._config.WindowPadding)
			if Iris._config.PopupRounding > 0 then
				widgets.UICorner(chunk_data, Iris._config.PopupRounding)
			end
			
			local list_layout = Instance.new("UIListLayout")
			list_layout.Parent = chunk_data
			
			local pie_chart = PieChart.new{{Value = 1}}
			pie_chart.Instance.Size = UDim2.fromOffset(250 - 30, 250 - 30)
			pie_chart.Instance.Position = UDim2.fromScale(.5, .5)
			pie_chart.Instance.AnchorPoint = Vector2.one * .5
			pie_chart.Instance.Parent = pie_viewport
			widgets.applyFrameStyle(pie_chart.Instance)
						
			thisWidget.ChunkDataContainer = chunk_data
			thisWidget.PieChart = pie_chart
			thisWidget.Instance = background
			
			return background
		end,
		GenerateState = function(thisWidget: WidgetTypes.ImPlotPieChart)
			if not thisWidget.state.showPieData then
				thisWidget.state.showPieData = Iris._widgetState(thisWidget, "showPieData", true)
			end
			if not thisWidget.state.normalize then
				thisWidget.state.normalize = Iris._widgetState(thisWidget, "normalize", true)
			end
		end,
		
		UpdateState = function(thisWidget: WidgetTypes.ImPlotPieChart)
			thisWidget.ChunkDataContainer.Visible = thisWidget.state.showPieData:get()
			thisWidget.PieChart.Normalize = thisWidget.state.normalize:get()
			thisWidget.PieChart:_update()
		end,
		Update = function(thisWidget: WidgetTypes.ImPlotPieChart)
			thisWidget.PieChart:SetPieData(thisWidget.arguments.pieData)

			for _, v in ipairs(thisWidget.ChunkDataContainer:GetChildren()) do
				if not v:IsA("Frame") then continue end
				v:Destroy()
			end

			for _, chunk: PieChart.Chunk & {Name: string} in thisWidget.PieChart._plot_data do
				local index_frame = Instance.new("Frame")
				index_frame.AutomaticSize = Enum.AutomaticSize.XY
				index_frame.Parent = thisWidget.ChunkDataContainer
				index_frame.BackgroundTransparency = 1
				index_frame.Size = UDim2.fromScale(0, 0)

				local list_layout = Instance.new("UIListLayout")
				list_layout.Parent = index_frame
				list_layout.FillDirection = Enum.FillDirection.Horizontal
				list_layout.Padding = UDim.new(0, 5)
				list_layout.VerticalAlignment = Enum.VerticalAlignment.Center

				local label = Instance.new("TextLabel")
				label.Text = chunk.Name
				label.Parent = index_frame
				label.AutomaticSize = Enum.AutomaticSize.XY
				label.Size = UDim2.fromOffset(0, 0)
				label.BackgroundTransparency = 1
				label.LayoutOrder = 2

				local colour_frame = Instance.new("Frame")
				colour_frame.Size = UDim2.fromOffset(index_frame.AbsoluteSize.Y - 2, index_frame.AbsoluteSize.Y - 2)
				colour_frame.BackgroundColor3 = chunk.Color or Util.RandomColor()
				colour_frame.Parent = index_frame

				widgets.applyTextStyle(label)
			end
		end,

		Discard = function(thisWidget: WidgetTypes.ImPlotPieChart)
			thisWidget.PieChart:Destroy()
			thisWidget.Instance:Destroy()
		end,
	} :: IrisTypes.WidgetClass)
	
	Iris.WidgetConstructor("ImPlotGraph", {
		hasState = true,
		hasChildren = false,
		Args = {
			["GraphName"] = 1,
			["Axes"] = 2,
		},
		Events = {},
		Generate = function(thisWidget: WidgetTypes.ImPlotGraph)
			---------------------------
			--// Background
			---------------------------
			local background = Instance.new("Frame")
			background.Name = "Iris_Graph"

			background.Size = UDim2.fromOffset(400, 250)
			background.BackgroundColor3 = Iris._config.FrameBgColor
			background.Transparency = Iris._config.FrameBgTransparency
			background.AutomaticSize = Enum.AutomaticSize.None
			background.ClipsDescendants = true
			background.ZIndex = thisWidget.ZIndex
			background.LayoutOrder = thisWidget.ZIndex

			widgets.applyFrameStyle(background)

			---------------------------
			--// Graph Viewport
			---------------------------
			local graph_viewport = Instance.new("CanvasGroup")

			graph_viewport.Name = "Iris_Graph_GraphViewport"

			graph_viewport.AnchorPoint = Vector2.new(1, 0.5)
			graph_viewport.Position = UDim2.fromScale(1, 0.5)
			graph_viewport.Size = UDim2.fromScale(1, 1) - UDim2.fromOffset(30, 60)

			graph_viewport.BackgroundColor3 = Color3.fromRGB(0, 0, 0)-- = Color3.fromRGB(18, 20, 18) --Iris._config.FrameBgColor
			graph_viewport.Transparency = 0--Iris._config.FrameBgTransparency
			graph_viewport.AutomaticSize = Enum.AutomaticSize.None
			graph_viewport.ClipsDescendants = true

			graph_viewport.Parent = background

			local ui_stroke = Instance.new("UIStroke")
			ui_stroke.Parent = graph_viewport
			ui_stroke.Color = Iris._config.BorderColor
			ui_stroke.Thickness = 1.5

			widgets.applyFrameStyle(graph_viewport)
			
			---------------------------
			--// Grid
			---------------------------
			local floor_bar_horizontal = Instance.new("ImageLabel")
			floor_bar_horizontal.Image = "rbxassetid://79263528871042"
			floor_bar_horizontal.TileSize = UDim2.fromOffset(40, 5)
			floor_bar_horizontal.ResampleMode = Enum.ResamplerMode.Pixelated
			floor_bar_horizontal.ScaleType = Enum.ScaleType.Tile
			
			floor_bar_horizontal.ImageTransparency = GRID_FLOOR_TRANSPARENCY
			
			floor_bar_horizontal.Size = UDim2.new(1, 0, 0, 5)
			floor_bar_horizontal.BackgroundTransparency = 1
			
			floor_bar_horizontal.AnchorPoint = Vector2.new(0, 0)
			floor_bar_horizontal.Position = UDim2.new(0, 0, 1, 1)
			
			floor_bar_horizontal.Parent = graph_viewport
			
			local floor_bar_vertical = Instance.fromExisting(floor_bar_horizontal)
			floor_bar_vertical.Image = "rbxassetid://103310049375227"
			floor_bar_vertical.TileSize = UDim2.fromOffset(5, 40)
			
			floor_bar_vertical.Size = UDim2.new(0, 5, 1, 0)
			
			floor_bar_vertical.AnchorPoint = Vector2.new(1, 0)
			floor_bar_vertical.Position = UDim2.fromOffset(-2, 0)
			
			floor_bar_vertical.Parent = graph_viewport
			
			local grid = Instance.new("ImageLabel")
			grid.Image = "rbxassetid://137361458622651"
			grid.ImageTransparency = GRID_LINES_TRANSPARENCY

			grid.ResampleMode = Enum.ResamplerMode.Pixelated
			grid.ScaleType = Enum.ScaleType.Tile
			grid.TileSize = UDim2.fromOffset(40, 40)
			grid.Size = UDim2.new(1, 0, 1, 0)
			grid.BackgroundTransparency = 1

			grid.AnchorPoint = Vector2.new(.5, .5)
			grid.Position = UDim2.fromScale(.5, .5)
			
			grid.Parent = graph_viewport
			
			---------------------------
			--// Graph
			---------------------------
			local graph = Graph.new()
			local graph_container = graph.Canvas
			graph_container.Name = "Iris_Graph_GraphContainer"

			graph_container.AnchorPoint = Vector2.new(0.5, 0.5)
			graph_container.Size = UDim2.fromScale(1, 1)
			graph_container.Position = UDim2.fromScale(0.5, 0.5)

			graph_container.BackgroundColor3 = Iris._config.FrameBgColor
			graph_container.Transparency = 1--Iris._config.FrameBgTransparency
			graph_container.AutomaticSize = Enum.AutomaticSize.X
			graph_container.BorderSizePixel = 0
			graph_container.ClipsDescendants = true
			graph_container.ZIndex = 2

			graph_container.Parent = graph_viewport
			
			---------------------------
			--// X/Y Rulers
			---------------------------
			local x_meter_tape = MeterTape.new("X", false, 40, UDim2.fromOffset(22, 0), function()
				local label = NewText(nil:: any, 7, 12)
				label.AnchorPoint = Vector2.new(.5, 0)
				return label
			end)
			local x_bar = x_meter_tape.Instance
			x_bar.Size = UDim2.new(1, -40, 0, 50)
			x_bar.Position = UDim2.fromScale(0, 1) + UDim2.fromOffset(35, -45)
			x_bar.Parent = background

			x_bar.BackgroundColor3 = Iris._config.FrameBgColor
			x_bar.Transparency = 1
			x_bar.AutomaticSize = Enum.AutomaticSize.None
			x_bar.ClipsDescendants = true
			
			local y_meter_tape = MeterTape.new("Y", true, 40, UDim2.new(0, 15, 0, 40), function()
				local label = NewText(nil:: any, 7, 12)
				label.AnchorPoint = Vector2.new(.5, .5)
				return label
			end)
			local y_bar = y_meter_tape.Instance
			y_bar.Size = UDim2.new(0, 50, 1, -50)
			y_bar.Position = UDim2.fromScale(0, .5) + UDim2.fromOffset(50, -10)
			y_bar.AnchorPoint = Vector2.new(1, .5)
			y_bar.Parent = background

			y_bar.BackgroundColor3 = Iris._config.FrameBgColor
			y_bar.Transparency = 1
			y_bar.AutomaticSize = Enum.AutomaticSize.None
			y_bar.ClipsDescendants = true
			
			---------------------------
			--// Tooltip
			---------------------------
			local tooltip = Instance.new("TextLabel")
			tooltip.Name = "Iris_Tooltip"
			tooltip.AutomaticSize = Enum.AutomaticSize.XY
			tooltip.BackgroundColor3 = Iris._config.PopupBgColor
			tooltip.BackgroundTransparency = Iris._config.PopupBgTransparency
			tooltip.BorderSizePixel = 0
			tooltip.ZIndex = 4
			tooltip.Visible = false

			widgets.applyTextStyle(tooltip)
			widgets.UIStroke(tooltip, Iris._config.PopupBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)
			widgets.UIPadding(tooltip, Iris._config.WindowPadding)
			if Iris._config.PopupRounding > 0 then
				widgets.UICorner(tooltip, Iris._config.PopupRounding)
			end

			local popup = Iris._rootInstance and Iris._rootInstance:FindFirstChild("PopupScreenGui")
			tooltip.Parent = popup and popup:FindFirstChild("TooltipContainer")
			
			local runtime_connection = nil

			widgets.applyMouseEnter(graph_viewport, function()
				if runtime_connection then
					runtime_connection:Disconnect()
				end
				
				runtime_connection = RunService.Heartbeat:Connect(function()
					local mouse_pos = widgets.getMouseLocation()
					local relative_mouse_pos = (
						Vector2.new(mouse_pos.X, mouse_pos.Y) 
						+ widgets.GuiOffset 
						- graph_viewport.AbsolutePosition
					) / graph_viewport.AbsoluteSize

					local x_value = map(relative_mouse_pos.X * graph.XScale, 0, 1, graph.Range.MinX, graph.Range.MaxX)
					local y_value = map(1 - relative_mouse_pos.Y * graph.YScale, 0, 1, graph.Range.MinY, graph.Range.MaxY)

					tooltip.Text = string.format("X: %f, Y: %f", x_value, y_value)
				end)
				
				tooltip.Visible = true
			end)
			widgets.applyMouseLeave(graph_viewport, function()
				if runtime_connection then
					runtime_connection:Disconnect()
				end
				
				tooltip.Visible = false
			end)
			
			---------------------------
			--// Data Information
			---------------------------
			local data_information = Instance.new("Frame")
			data_information.Name = "ChunkData"
			data_information.AutomaticSize = Enum.AutomaticSize.XY
			data_information.Position = UDim2.fromOffset(10, 10)
			data_information.ClipsDescendants = true
			data_information.Transparency = 0
			data_information.Parent = graph_viewport
			data_information.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			data_information.BorderSizePixel = 0
			data_information.ZIndex = 3

			widgets.applyFrameStyle(data_information)
			widgets.UIStroke(data_information, Iris._config.PopupBorderSize, Iris._config.BorderActiveColor, Iris._config.BorderActiveTransparency)
			widgets.UIPadding(data_information, Iris._config.WindowPadding)
			if Iris._config.PopupRounding > 0 then
				widgets.UICorner(data_information, Iris._config.PopupRounding)
			end
			
			local list_layout = Instance.new("UIListLayout")
			list_layout.Parent = data_information
			
			thisWidget.DataInformation = data_information
			
			---------------------------
			--// Axes Display
			---------------------------
			local x_label = NewText(background, 0, 10)
			x_label.Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 30)
			x_label.Position = UDim2.fromScale(.5, 1) + UDim2.fromOffset(15, -20)
			x_label.AnchorPoint = Vector2.new(.5, 0)

			x_label.Name = "X"
			x_label.Text = "X"

			local y_label = NewText(background, 0, 10)
			y_label.Size = UDim2.fromScale(1, 0) + UDim2.fromOffset(0, 30)
			y_label.Position = UDim2.fromScale(0, .5) + UDim2.fromOffset(0, 0)
			y_label.AnchorPoint = Vector2.new(.5, .5)
			y_label.Rotation = -90

			y_label.Name = "Y"
			y_label.Text = "Y"
			
			---------------------------
			--// Chart Window Name
			---------------------------
			local name_label = NewText(background, 0, 12)
			name_label.Size = UDim2.new(1, 0, 0, 30)
			name_label.Position = UDim2.fromScale(.5, 0) + UDim2.fromOffset(15, 10)
			name_label.AnchorPoint = Vector2.new(.5, .5)

			name_label.Name = "NameLabel"
			name_label.Text = "Nil"
			
			thisWidget.Graph = graph
			thisWidget.XMeterTape = x_meter_tape
			thisWidget.YMeterTape = y_meter_tape
			
			thisWidget.NameLabel = name_label
			thisWidget.XLabel = x_label
			thisWidget.YLabel = y_label

			return background
		end,
		GenerateState = function(thisWidget: WidgetTypes.ImPlotGraph)
			if not thisWidget.state.plots then
				thisWidget.state.plots = Iris._widgetState(thisWidget, "plots", {})
			end
			if not thisWidget.state.size then
				thisWidget.state.size = Iris._widgetState(thisWidget, "size", Vector2.new(400, 250))
			end
			if not thisWidget.state.showDataInformation then
				thisWidget.state.showDataInformation = Iris._widgetState(thisWidget, "showDataInformation", {})
			end
		end,
		
		Update = function(thisWidget: WidgetTypes.ImPlotGraph)
			thisWidget.NameLabel.Text = thisWidget.arguments.GraphName or ""
			
			thisWidget.XLabel.Text = thisWidget.arguments.Axes.X or "X"
			thisWidget.YLabel.Text = thisWidget.arguments.Axes.Y or "Y"
			
			thisWidget.Graph.XScale = thisWidget.arguments.Axes.XScale or 1
			thisWidget.Graph.YScale = thisWidget.arguments.Axes.YScale or .9
		end,
		UpdateState = function(thisWidget: WidgetTypes.ImPlotGraph)
			local plots = thisWidget.state.plots.value
			
			thisWidget.Graph:SetChartData(plots)

			thisWidget.XMeterTape:Update()
			thisWidget.YMeterTape:Update()
			
			thisWidget.XMeterTape.Range = NumberRange.new(thisWidget.Graph.Range.MinX, thisWidget.Graph.Range.MaxX)
			thisWidget.YMeterTape.Range = NumberRange.new(thisWidget.Graph.Range.MinY, thisWidget.Graph.Range.MaxY)
			
			thisWidget.Instance.Size = UDim2.fromOffset(thisWidget.state.size.value.X, thisWidget.state.size.value.Y)
			
			thisWidget.DataInformation.Visible = thisWidget.state.showDataInformation.value
			if not thisWidget.DataInformation.Visible then return end
			
			for _, v in ipairs(thisWidget.DataInformation:GetChildren()) do
				if not v:IsA("Frame") then continue end
				v:Destroy()
			end
			
			for _, graph in ipairs(plots) do
				if not graph.Name then continue end
				
				local index_frame = Instance.new("Frame")
				index_frame.AutomaticSize = Enum.AutomaticSize.XY
				index_frame.Parent = thisWidget.DataInformation
				index_frame.BackgroundTransparency = 1
				index_frame.Size = UDim2.fromScale(0, 0)

				local list_layout = Instance.new("UIListLayout")
				list_layout.Parent = index_frame
				list_layout.FillDirection = Enum.FillDirection.Horizontal
				list_layout.Padding = UDim.new(0, 5)
				list_layout.VerticalAlignment = Enum.VerticalAlignment.Center

				local label = Instance.new("TextLabel")
				label.Text = graph.Name
				label.Parent = index_frame
				label.AutomaticSize = Enum.AutomaticSize.XY
				label.Size = UDim2.fromOffset(0, 0)
				label.BackgroundTransparency = 1
				label.LayoutOrder = 2

				local color_frame = Instance.new("Frame")
				color_frame.Size = UDim2.fromOffset(index_frame.AbsoluteSize.Y - 2, index_frame.AbsoluteSize.Y - 2)
				color_frame.BackgroundColor3 = (graph.GraphStyle and graph.GraphStyle.Color) or (graph.MarkerStyle and graph.MarkerStyle.Color) or Color3.new(1, 1, 1)
				color_frame.Parent = index_frame

				widgets.applyTextStyle(label)
			end
		end,

		Discard = function(thisWidget: WidgetTypes.ImPlotGraph)
			thisWidget.Graph:Destroy()
			thisWidget.XMeterTape:Destroy()
			thisWidget.YMeterTape:Destroy()
			thisWidget.Instance:Destroy()
		end,
	} :: IrisTypes.WidgetClass)
end
