Canvas = Object:extend()

function Canvas:init(node, data)
	if node == nil or data == nil then return end

	self.node = node

	self.tiles = {}
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
			self.tiles[#self.tiles+1] = {x = currentX+data.transform.x-1, y = currentY+data.transform.y, data = data}
		end		
	end
end

function Canvas:draw()
	for k, tile in pairs(self.tiles) do
		love.graphics.draw(tile.data.image, tile.data.quad, tile.x*32, tile.y*32)
	end
end

function Canvas:mousepressed(x, y, button, istouch)
end

function Canvas:mousereleased(x, y, button, istouch)
end

function Canvas:wheelmoved(x, y)
end