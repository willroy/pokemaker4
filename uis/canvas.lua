Canvas = Object:extend()

function Canvas:init(node, data)
	if node == nil or data == nil then return end

	self.node = node
end

function Canvas:update(dt)
	if not helper:contains(input.nodes_hovered, self.node) or #input.nodes_hovered ~= 1 then return end

	if globals.data.selectionData ~= nil and input.mouseDown then
		local mousePos = globals.trackers.mousePos
		local mouseAdjuX = self.node.transform.x + ( math.floor((mousePos.x) / 32) * 32 )
		local mouseAdjuY = self.node.transform.y + ( math.floor((mousePos.y) / 32) * 32 )
		local currentX = math.floor(mouseAdjuX / 32)
		local currentY = math.floor(mouseAdjuY / 32) - 1

		for k, data in pairs(globals.data.selectionData) do
			data.quad = love.graphics.newQuad(data.tilesheetTransform.x*32-32, data.tilesheetTransform.y*32-32, 32, 32, data.image)
			self:addTile({x = currentX+data.transform.x-1, y = currentY+data.transform.y-1, data = data})
		end
	end
end

function Canvas:draw()
	if self.layerNum ~= globals.data.map.currentLayer then self.layerNum = globals.data.map.currentLayer end

	for k1, layer in pairs(globals.data.map.layers) do
		for k, tile in pairs(layer.tiles) do
			local tileX = self.node.transform.x + ( tile.x * 32 )
			local tileY = self.node.transform.y + ( tile.y * 32 )

			if tile.data.quad == nil then tile.data.quad = love.graphics.newQuad(tile.data.tilesheetTransform.x*32-32, tile.data.tilesheetTransform.y*32-32, 32, 32, globals.data.tilesheetImages[tile.data.imagePath]) end
			love.graphics.draw(globals.data.tilesheetImages[tile.data.imagePath], tile.data.quad, tileX, tileY)
		end
	end

	if not helper:contains(input.nodes_hovered, self.node) or #input.nodes_hovered ~= 1 then return end

	local mousePos = globals.trackers.mousePos
	local mouseAdjuX = self.node.transform.x + ( math.floor((mousePos.x) / 32) * 32 )
	local mouseAdjuY = self.node.transform.y + ( math.floor((mousePos.y) / 32) * 32 ) - 32

	love.graphics.rectangle("line", mouseAdjuX, mouseAdjuY, 32, 32)
end

function Canvas:addTile(data)
	local layer = globals.data.map.layers[globals.data.map.currentLayer]

	for k, tile in pairs(layer.tiles) do
		if tile.x == data.x and tile.y == data.y then
			layer.tiles[k] = data
			return
		end
	end

	layer.tiles[#layer.tiles+1] = data

	globals.data.map.layers[globals.data.map.currentLayer].tiles = layer.tiles
end

function Canvas:mousepressed(x, y, button, istouch)
end

function Canvas:mousereleased(x, y, button, istouch)
end

function Canvas:wheelmoved(x, y)
end