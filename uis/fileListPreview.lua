FileListPreview = Object:extend()

function FileListPreview:init(node, data)
	if node == nil or data == nil then return end
	self.node = node

	self.path = data.path or love.filesystem.getSaveDirectory()
	self.padding = data.padding or 0
	self.color = data.color or { r = 0, g = 0, b = 0, a = 1 }

	local savePath = love.filesystem.getSaveDirectory()
	local maps = helper:scanDir(savePath)

	self.maps = {}

	for k, map in pairs(maps) do
		if love.filesystem.getInfo(map).type == "directory" then
			self.maps[#self.maps+1] = map
		end
	end
end

function FileListPreview:loadLayersData(path)
	local layers = {}

	local layerFiles = helper:scanDir(path)

	for k, layer in pairs(layerFiles) do
		local tiles = {}
		if layer.tiles ~= nil then
			for k2, tile in pairs(layer.tiles) do tiles[#tiles+1] = tile end
		end
		layers[#layers+1] = {floaty = false, tiles = tiles}
	end

	return layers
end

function FileListPreview:update(dt)
end

function FileListPreview:draw()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)

	for k, map in pairs(self.maps) do
		love.graphics.print(map, self.node.transform.x + self.padding, self.node.transform.y + self.padding + ( ( k - 1 ) * 40 ) )
	end

	love.graphics.setColor(1,1,1,1)
end

function FileListPreview:mousepressed(x, y, button, istouch)
	if not helper:contains(input.nodes_hovered, self.node) then return end

	for k, map in pairs(self.maps) do
		local fileX = self.node.transform.x + self.padding
		local fileY = self.node.transform.y + self.padding + ( ( k - 1 ) * 40 )
		if x > fileX and y > fileY and y < ( fileY + 40 ) then
			local savePath = love.filesystem.getSaveDirectory()
			local layers = self:loadLayersData(savePath.."/"..map.."/")
			globals.data.map = {}
			globals.data.map["map"] = map
			globals.data.map["layers"] = layers
			globals.data.map["currentLayer"] = 1
			nodes:unloadNodeGroup("main")
			nodes:loadNodeGroup("editor")
			return "abort"
		end
	end
end

function FileListPreview:mousereleased(x, y, button, istouch)
end

function FileListPreview:wheelmoved(x, y)
end