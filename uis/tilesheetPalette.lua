TilesheetPalette = Object:extend()

function TilesheetPalette:init(node, data)
	if node == nil or data == nil then return end

	self.node = node
	self.files = helper:getFilesInDir(globals.config.pathTilesheets)
	self.images = self:generateImages(globals.config.pathTilesheets, self.files)
	self.index = 1
	self.columns = math.floor(globals.trackers.windowSize.w / 256)
	self.scroll = 0
	self.padding = ( globals.trackers.windowSize.w - ( 256 * self.columns ) ) / 2
	self.fullHeight = 0

	local transform = self.node.transform
 	self.stencil = function() love.graphics.rectangle("fill", transform.x, transform.y, transform.w, transform.h) end

	self.selectorColor = {r = 0.1, g = 0.6, b = 0.8, a = 1}
 	self.selector = {x = 0, y = 0, w = 32, h = 32}
 	self.makingSelection = { status = false, startingPos = {x = 0, y = 0} }
end

function TilesheetPalette:generateImages(path, files)
	local images = {}

	for k, file in pairs(files) do
		images[#images+1] = love.graphics.newImage(path.."/"..file)
	end

	return images
end

function TilesheetPalette:update(dt)
	self.columns = math.floor(globals.trackers.windowSize.w / 256)
	self.padding = ( globals.trackers.windowSize.w - ( 256 * self.columns ) ) / 2
	if self.makingSelection.status then
		local mousePos = globals.trackers.mousePos
		local adjustedX = mousePos.x - (self.node.transform.x + self.padding)
		local adjustedY = mousePos.y - self.node.transform.y
		
		local startX = self.makingSelection.startingPos.x
		local startY = self.makingSelection.startingPos.y
		local currentX = math.floor(adjustedX / 32)
		local currentY = math.floor(adjustedY / 32) - math.floor(self.scroll/32)

		local selectionStartCornerX = self.makingSelection.startingPos.x
		local selectionStartCornerY = self.makingSelection.startingPos.y
		local selectionFinalCornerX = currentX
		local selectionFinalCornerY = currentY

		-- handle down and right
		if currentX > startX then selectionFinalCornerX = currentX - startX + 1 end
		if currentY > startY then selectionFinalCornerY = currentY - startY + 1 end

		-- handle up and left
		if currentX < startX then
			selectionFinalCornerX = -( startX - currentX ) - 1
			selectionStartCornerX = self.makingSelection.startingPos.x + 1
		end
		if currentY < startY then
			selectionFinalCornerY = -( startY - currentY ) - 1
			selectionStartCornerY = self.makingSelection.startingPos.y + 1
		end

		--handle same row / column selections
		if currentX == startX then selectionFinalCornerX = 1 end
		if currentY == startY then selectionFinalCornerY = 1 end

		self.selector.x = selectionStartCornerX * 32
		self.selector.y = selectionStartCornerY * 32
		self.selector.w = selectionFinalCornerX * 32
		self.selector.h = selectionFinalCornerY * 32

	end
end

function TilesheetPalette:draw()
	local transform = self.node.transform
	love.graphics.stencil(self.stencil, "replace", 1)
	love.graphics.setStencilTest("greater", 0)
	for i = self.index, self.index+(self.columns-1) do
		local image = self.images[i]
		local x = self.node.transform.x+(image:getWidth() * (i-1))+self.padding
		local y = self.node.transform.y+self.scroll
		love.graphics.draw(image, x, y)
		if self.fullHeight < image:getHeight() then self.fullHeight = image:getHeight() end
	end
	love.graphics.setColor(self.selectorColor.r, self.selectorColor.g, self.selectorColor.b, self.selectorColor.a)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle("line", self.selector.x+self.node.transform.x+self.padding, self.selector.y+self.node.transform.y+self.scroll, self.selector.w, self.selector.h)
	love.graphics.setLineWidth(1)
	love.graphics.setColor(1,1,1,1)
	love.graphics.setStencilTest()
end

function TilesheetPalette:mousepressed(x, y, button, istouch)
	if helper:contains(input.nodes_hovered, self.node) then
		if button == 1 then
			self.makingSelection.status = true
			local mousePos = globals.trackers.mousePos
			local adjustedX = mousePos.x - (self.node.transform.x + self.padding)
			local adjustedY = mousePos.y - self.node.transform.y
			local tileX = math.floor(adjustedX/32)
			local tileY = math.floor(adjustedY/32) - math.floor(self.scroll/32)
			self.selector.w = 32
			self.selector.h = 32
			self.makingSelection.startingPos.x = tileX
			self.makingSelection.startingPos.y = tileY
			self.selector.x = self.makingSelection.startingPos.x * 32
			self.selector.y = self.makingSelection.startingPos.y * 32
		end
	end
end

function TilesheetPalette:mousereleased(x, y, button, istouch)
	self.makingSelection.status = false
	self.makingSelection.startingPos = {x = 0, y = 0}
end

function TilesheetPalette:wheelmoved(x, y)
	if helper:contains(input.nodes_hovered, self.node) then
		if globals.config.naturalScroll then
			if y == -1 and self.scroll ~= 0 then
				self.scroll = self.scroll + globals.config.scrollSpeed
			elseif self.scroll > -self.fullHeight then
				self.scroll = self.scroll - globals.config.scrollSpeed
			end
		else
			if y == -1 and self.scroll > -self.fullHeight then
				self.scroll = self.scroll - globals.config.scrollSpeed
			elseif self.scroll ~= 0 then
				self.scroll = self.scroll + globals.config.scrollSpeed
			end
		end
	end
end