--!strict
local Maid = require("../Dependancies/Maid")
local Util = require("../Util")

local table_clear = table.clear
local table_sort = table.sort

local floor = math.floor
local rad = math.rad
local cos = math.cos
local sin = math.sin

local MIDDLE = Vector2.one * .5
local START_ANGLE = 90

local PieChart = {}
PieChart.__index = PieChart

function PieChart.new(PlotData: PieData)
	local self = setmetatable({}:: self, PieChart)
	self._maid = Maid.new()
	self.Instance = Instance.new("Frame")
	self.Instance.Transparency = 1
	
	self._color_index = table.create(100, Color3.new(1, 1, 1))
	for index in ipairs(self._color_index) do
		self._color_index[index] = Util.RandomColor()
	end
	
	self._plot_data = PlotData
	
	self._maid:GiveTask(self.Instance)
	
	self.Normalize = true
	
	return self
end

function PieChart._update(self: self)
	self.Instance:ClearAllChildren()
	
	local sum = 0
	for _, chunk: Chunk in self._plot_data do
		sum += chunk.Value
	end
	
	table_sort(self._plot_data, function(C1, C2)
		return C1.Value < C2.Value
	end)
	
	local previous_angle = START_ANGLE
	for index, chunk: Chunk in self._plot_data do
		local color = chunk.Color:: Color3
		chunk.Color = color
		
		local value = chunk.Value
		local alpha = self.Normalize and value / sum or value
		
		local angle = previous_angle + alpha * 360
		local r1 = angle + 180
		local r2 = previous_angle + 180
		
		local circle_1 = Util.CreateSemiCircle()
		circle_1.Parent = self.Instance
		
		local delta_angle = (angle - previous_angle)
		if delta_angle < 180 then
			circle_1.Rotation = r2 + 180
			
			local cut_angle = (r1 + 90 - circle_1.Rotation) % 360
			Util.CutCircle(circle_1, cut_angle)
		else
			local circle_2 = circle_1:Clone()
			circle_2.Rotation = r2 + 180
			circle_1.Rotation = r1
			
			circle_2.Parent = self.Instance
			circle_2.ZIndex = chunk.Value
			
			circle_2.ImageColor3 = color
		end
		circle_1.ImageColor3 = color
		circle_1.ZIndex = chunk.Value
		
		-- // Linus here, i am personally not a fan of using AI however i did use ChatGPT to make this label part because i couldn't be asked.
		local mid_angle = previous_angle + delta_angle * 0.5
		local radius_scale = .5 / 2
		local rad = rad(mid_angle)
		
		local dir = Vector2.new(cos(rad), sin(rad)) * radius_scale
		
		local label = Instance.new("TextLabel")
		
		label.AnchorPoint = Vector2.new(0.5, 0.5)
		label.Size = UDim2.new(0, 60, 0, 20)
		label.Position = UDim2.new(MIDDLE.X - dir.X, 0, MIDDLE.Y - dir.Y, 0)
		
		label.BackgroundTransparency = 1
		
		label.Text = string.format("%s", tostring(floor(value * 100) / 100))
		
		label.TextColor3 = Util.TextContrastBasedOnBackground(color)
		label.ZIndex = chunk.Value + 1
		label.Parent = self.Instance
		
		previous_angle += delta_angle
	end
end

function PieChart.SetPieData(self: self, Data: PieData)
	table.clear(self._plot_data)
	
	self._plot_data = Util.DeepCopy(Data):: PieData
	
	for index, chunk: Chunk in ipairs(self._plot_data) do
		if chunk.Color then continue end
		chunk.Color = self._color_index[index] or Util.RandomColor()
	end
	
	self:_update()
end

function PieChart.Destroy(self: self)
	self._maid:DoCleaning()
	table_clear(self)
end

export type Chunk = {
	Color: Color3?,
	Value: number,
}
export type PieData = {Chunk}
export type PieChart = {
	_maid: Maid,
	_plot_data: PieData,
	
	_color_index: {Color3},
	
	Instance: Frame,
	Normalize: boolean,
} & typeof(PieChart)

type self = PieChart
type Maid = Maid.Maid

return PieChart