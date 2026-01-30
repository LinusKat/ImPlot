--!strict
--[[
	31-12-2025

	Made for a graphing widget for Iris.
	Class to make "infinite" Linear Path2Ds,
	tangents and positions along curve not taken into consideration.
]]
local table_insert = table.insert
local table_clear = table.clear
local table_clone = table.clone
local table_move = table.move

local MAX_SIZE = 98

local Path = {}
Path.__index = Path

function Path.new()
	local self = setmetatable({}:: self, Path)
	self._paths = {}
	self._control_points = {}
	self._properties = {}
	
	return self
end

function Path._clear_paths(self: self)
	for _, v in ipairs(self._paths) do
		v:Destroy()
	end
end

function Path._set_path_properties(self: self, Path: Path2D)
	for key, value in pairs(self._properties) do
		Path[key] = value
	end
end

function Path._generate_paths(self: self)
	self:_clear_paths()

	for i = 1, #self._control_points, MAX_SIZE do
		local Path2D = Instance.new("Path2D")
		local split = {}

		table_move(self._control_points, i, i + MAX_SIZE - 1, 1, split)
		table_insert(self._paths, Path2D)

		Path2D:SetControlPoints(split)
		self:_set_path_properties(Path2D)
	end	
end

function Path.SetControlPoints(self: self, ControlPoints: ControlPoints)
	table.clear(self._control_points)
	self._control_points = table_clone(ControlPoints)
	self:_generate_paths()
end

function Path.PushProperty(self: self, Property: Property | string, Value: any)
	self._properties[Property] = Value
end

function Path.Destroy(self: self)
	self:_clear_paths()
	table_clear(self)
end

export type ControlPoints = {Path2DControlPoint}
export type Property = "Name" | "Parent" | "Closed" | "Visible" | "Color3" | "Thickness" | "ZIndex"
export type Path = {
	_paths: {Path2D},
	_control_points: ControlPoints,
	_properties: {[string]: any},
} & typeof(Path)

type self = Path

return Path