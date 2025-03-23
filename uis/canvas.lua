Canvas = Object:extend()

function Canvas:init(node, data)
	if node == nil or data == nil then return end

	self.node = node
end

function Canvas:update(dt)
	if not helper:contains(input.nodes_hovered, self.node) or #input.nodes_hovered ~= 1 then return end

	if globals.data.selectionData ~= nil and input.mouseDown then
		local mousePosX = globals.trackers.mousePos.x - self.node.transform.x
		local mousePosY = globals.trackers.mousePos.y - self.node.transform.y

		local currentX = math.floor(mousePosX / 32)
		local currentY = math.floor(mousePosY / 32)

		for k, data in pairs(globals.data.selectionData) do
			data.quad = love.graphics.newQuad(data.tilesheetTransform.x*32-32, data.tilesheetTransform.y*32-32, 32, 32, data.image)
			self:addTile({x = currentX+data.transform.x-1, y = currentY+data.transform.y, data = data})
		end
	end
end

function Canvas:draw()
  -- need to draw relative to self.node.transform

	if self.map == nil or self.layerNum ~= globals.data.map.currentLayer then
		self.map = globals.data.map
		self.layers = globals.data.map.layers
		self.layer = globals.data.map.layers[globals.data.map.currentLayer]
		self.layerNum = globals.data.map.currentLayer
	end

	local mousePos = globals.trackers.mousePos
	local mouseAdjuX = ( math.floor((mousePos.x) / 32) * 32 )
	local mouseAdjuY = ( math.floor((mousePos.y) / 32) * 32 )

	love.graphics.rectangle("line", mouseAdjuX, mouseAdjuY, 32, 32)

	for k1, layer in pairs(self.layers) do
		for k, tile in pairs(layer.tiles) do
			local tileX = ( tile.x * 32 )
			local tileY = ( tile.y * 32 )

			if tile.data.quad == nil then tile.data.quad = love.graphics.newQuad(tile.data.tilesheetTransform.x*32-32, tile.data.tilesheetTransform.y*32-32, 32, 32, globals.data.tilesheetImages[tile.data.imagePath]) end
			love.graphics.draw(globals.data.tilesheetImages[tile.data.imagePath], tile.data.quad, tileX, tileY)
		end
	end
end

function Canvas:addTile(data)
	for k, tile in pairs(self.layer.tiles) do
		if tile.x == data.x and tile.y == data.y then
			self.layer.tiles[k] = data
			return
		end
	end
	self.layer.tiles[#self.layer.tiles+1] = data
	globals.data.map.layers[globals.data.map.currentLayer].tiles = self.layer.tiles
end

function Canvas:mousepressed(x, y, button, istouch)
end

function Canvas:mousereleased(x, y, button, istouch)
end

function Canvas:wheelmoved(x, y)
end