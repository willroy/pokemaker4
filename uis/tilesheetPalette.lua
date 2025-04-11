TilesheetPalette = Object:extend()

function TilesheetPalette:init(node, data)
	if node == nil or data == nil then return end

	self.node = node
	self.columns = nil
	self.padding = nil
	local transform = self.node.transform
 	self.stencil = function() love.graphics.rectangle("fill", transform.x, transform.y, transform.w, transform.h) end

	globals.data.tilesheetIndex = { current = 1, min = 0, max = 0 }
	self.scroll = 0
	self.fullHeight = 0

	self.selectorStyle = {r = 0.2, g = 1, b = 0.2, a = 1, lineWeight = 1, mode = "line", animationCount = 0, animationReverseDir = false}
	self.selectorErrorStyle = {r = 1, g = 0.2, b = 0.2, a = 0.7, lineWeight = 3, mode = "fill", animationCount = 0}
 	self.selector = {x = nil, y = nil, w = 32, h = 32, error = false}
 	self.makingSelection = { status = false, startingPos = {x = 0, y = 0} }
 	self.selectionData = {}

 	self.controlsPadding = 80
end

function TilesheetPalette:update(dt)
	self.columns = math.floor( ( globals.trackers.windowSize.w - self.controlsPadding ) / 256 )
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

		-- handle right
		if currentX > startX then
			selectionFinalCornerX = currentX - startX + 1
		end

		-- handle down
		if currentY > startY then
			selectionFinalCornerY = currentY - startY + 1
		end

		-- handle left
		if currentX < startX then
			selectionFinalCornerX = -( startX - currentX ) - 1
			selectionStartCornerX = self.makingSelection.startingPos.x + 1
		end

		-- handle up
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
	if self.images == nil then
		self.images = {}
		for k, v in pairs(globals.data.tilesheetImagePaths) do
			self.images[k] = globals.data.tilesheetImages[v]
			globals.data.tilesheetIndex.min = 1
			globals.data.tilesheetIndex.max = #globals.data.tilesheetImagePaths - ( self.columns - 1 )
		end
	end
	if self.imagePaths == nil then self.imagePaths = globals.data.tilesheetImagePaths end

	love.graphics.setColor(1,1,1,1)
	love.graphics.setLineWidth(1)
	love.graphics.stencil(self.stencil, "replace", 1)
	love.graphics.setStencilTest("greater", 0)

	self:drawBorder()
	self:drawTilesheets()
	self:drawSelector()
	self:drawMouseIndicator()

	love.graphics.setColor(1,1,1,1)
	love.graphics.setLineWidth(1)
	love.graphics.setStencilTest()
end

function TilesheetPalette:drawBorder()
	love.graphics.setColor(1,1,1,1)
	love.graphics.rectangle("fill", self.node.transform.x, self.node.transform.y, self.node.transform.w, self.node.transform.h)
	love.graphics.setColor(0.6,0.6,0.6,1)
	love.graphics.rectangle("fill", self.node.transform.x, self.node.transform.y, self.padding, self.node.transform.h)
	love.graphics.rectangle("fill", self.node.transform.x+self.padding+(self.columns*256), self.node.transform.y, self.padding, self.node.transform.h)
	love.graphics.setColor(1,1,1,1)
end

function TilesheetPalette:drawTilesheets()
	local drawIndex = 1
	for i = globals.data.tilesheetIndex.current, globals.data.tilesheetIndex.current+(self.columns-1) do
		local image = self.images[i]
		local x = self.node.transform.x+(image:getWidth() * (drawIndex-1))+self.padding
		local y = self.node.transform.y+self.scroll
		love.graphics.draw(image, x, y)
		if self.fullHeight < image:getHeight() then self.fullHeight = image:getHeight() end
		drawIndex = drawIndex + 1
	end
end

function TilesheetPalette:drawSelector()
	if self.selector.x == nil or self.selector.y == nil then return end

	if self.selector.error and (( self.selectorErrorStyle.animationCount > 10 and self.selectorErrorStyle.animationCount < 20 ) or self.selectorErrorStyle.animationCount > 30 ) then
		love.graphics.setColor(self.selectorErrorStyle.r, self.selectorErrorStyle.g, self.selectorErrorStyle.b, 0.5)
		love.graphics.rectangle("fill", self.selector.x+self.node.transform.x+self.padding, self.selector.y+self.node.transform.y+self.scroll, self.selector.w, self.selector.h)
		love.graphics.setColor(self.selectorErrorStyle.r, self.selectorErrorStyle.g, self.selectorErrorStyle.b, self.selectorErrorStyle.a)
		love.graphics.setLineWidth(self.selectorErrorStyle.lineWeight)
		love.graphics.rectangle("line", self.selector.x+self.node.transform.x+self.padding, self.selector.y+self.node.transform.y+self.scroll, self.selector.w, self.selector.h)
	end

	if self.selector.error then
		self.selectorErrorStyle.animationCount = self.selectorErrorStyle.animationCount + 1
	else
		love.graphics.setColor(self.selectorStyle.r, self.selectorStyle.g, self.selectorStyle.b, self.selectorStyle.a)
		love.graphics.setLineWidth(self.selectorStyle.lineWeight+self.selectorStyle.animationCount)
		love.graphics.rectangle(self.selectorStyle.mode, self.selector.x+self.node.transform.x+self.padding, self.selector.y+self.node.transform.y+self.scroll, self.selector.w, self.selector.h)
		if not self.selectorStyle.animationReverseDir then self.selectorStyle.animationCount = self.selectorStyle.animationCount + 0.05 end
		if self.selectorStyle.animationReverseDir then self.selectorStyle.animationCount = self.selectorStyle.animationCount - 0.05 end
		if self.selectorStyle.animationCount <= 0 then
			self.selectorStyle.animationReverseDir = false
		end
		if self.selectorStyle.animationCount > 3 then
			self.selectorStyle.animationReverseDir = true
		end
	end
end

function TilesheetPalette:drawMouseIndicator()
	if globals.trackers.mousePos.x < self.padding or globals.trackers.mousePos.x > ( self.padding + ( self.columns * self.images[1]:getWidth() ) ) then return end

	love.graphics.setColor(0,0,0,0.5)
	love.graphics.setLineWidth(1)

	local mousePos = globals.trackers.mousePos
	local adjustedX = mousePos.x - (self.node.transform.x + self.padding)
	local adjustedY = mousePos.y - self.node.transform.y
	local mouseAdjuX = ( math.floor(adjustedX/32) * 32 ) + self.node.transform.x + self.padding
	local mouseAdjuY = ( ( math.floor(adjustedY/32) - math.floor(self.scroll/32) ) * 32 ) + self.node.transform.y

	love.graphics.rectangle("line", mouseAdjuX, mouseAdjuY, 32, 32)
end

function TilesheetPalette:mousepressed(x, y, button, istouch)
	if globals.trackers.mousePos.x < self.padding or globals.trackers.mousePos.x > ( self.padding + ( self.columns * self.images[1]:getWidth() ) ) then return end

	if helper:contains(input.nodes_hovered, self.node) then
		if button == 1 then
			local mousePos = globals.trackers.mousePos
			local adjustedX = mousePos.x - (self.node.transform.x + self.padding)
			local adjustedY = mousePos.y - self.node.transform.y
			local tileX = math.floor(adjustedX/32)
			local tileY = math.floor(adjustedY/32) - math.floor(self.scroll/32)

			self.makingSelection.status = true
			self.makingSelection.startingPos = { x = tileX, y = tileY }

			self.selector.w = 32
			self.selector.h = 32
			self.selector.x = self.makingSelection.startingPos.x * 32
			self.selector.y = self.makingSelection.startingPos.y * 32

			self.selector.error = false
			self.selectorErrorStyle.animationCount = 0
		end
		if button == 2 then
			self.selector = {x = nil, y = nil, w = 32, h = 32, error = false}
		 	self.makingSelection = { status = false, startingPos = {x = 0, y = 0} }
		end
	end
end

function TilesheetPalette:mousereleased(x, y, button, istouch)
	if globals.trackers.mousePos.x < self.padding or globals.trackers.mousePos.x > ( self.padding + ( self.columns * self.images[1]:getWidth() ) ) then
		self.makingSelection.status = false
		self.makingSelection.startingPos = {x = 0, y = 0}
	end

	self.makingSelection.status = false
	self.makingSelection.startingPos = {x = 0, y = 0}

	if self.selector.x == nil or self.selector.y == nil then return end

	self:checkForErrors()

	if not self.selector.error then
		self:createSelectionData()
	end
end

function TilesheetPalette:checkForErrors()
	if self.selector.x < 0 or self.selector.x > ( self.columns * 256 ) then self.selector.error = true end 
	if ( self.selector.x + self.selector.w ) < 0 or ( self.selector.x + self.selector.w ) > ( self.columns * 256 ) then self.selector.error = true end
	if self.selector.y < 0 or self.selector.y > self.fullHeight then self.selector.error = true end 
	if ( self.selector.y + self.selector.h ) < 0 or ( self.selector.y + self.selector.h ) > self.fullHeight then self.selector.error = true end

	for i = globals.data.tilesheetIndex.current, globals.data.tilesheetIndex.current+(self.columns-1) do
		local startInImage = self.selector.x > ( ( i - 1 ) * 256 ) and self.selector.x < ( i * 256 )
		local crossesImage = self.selector.x < ( ( i - 1 ) * 256 ) and ( self.selector.x + self.selector.w ) > ( i * 256 )
		local endInImage = ( self.selector.x + self.selector.w ) > ( ( i - 1 ) * 256 ) and ( self.selector.x + self.selector.w ) < ( i * 256 )
		local inImage = startInImage or crossesImage or endInImage
		if inImage and self.selector.y > self.images[i]:getHeight() then self.selector.error = true end
		if inImage and ( self.selector.y + self.selector.h ) > self.images[i]:getHeight() then self.selector.error = true end
	end
end

function TilesheetPalette:createSelectionData()
	self.selectionData = {}

	-- reverse start and end tiles for bottom right to top left selections
	if self.selector.w < 0 then
		self.selector.w = -self.selector.w
		self.selector.x = self.selector.x - self.selector.w
	end
	if self.selector.h < 0 then
		self.selector.h = -self.selector.h
		self.selector.y = self.selector.y - self.selector.h
	end

	-- update selection data
	for x = 1, ( self.selector.w / 32 ) do
		for y = 1, ( self.selector.h / 32 ) do
			local tileX = ( self.selector.x / 32 ) + x
			local tileY = ( self.selector.y / 32 ) + y
			local imageIndex = 0
			local drawIndex = 0
			for i = 1, self.columns do
				drawIndex = i
				local imageLeft = ( i - 1 ) * 8
				local imageRight = i * 8
				local inImage = tileX > imageLeft and tileX <= imageRight
				if inImage then
					imageIndex = ( i - 1 ) + globals.data.tilesheetIndex.current
					break
				end
			end

			local transform = {x = x, y = y}
			local tilesheetTransform = {x = ( tileX - ( ( drawIndex - 1 ) * 8 )), y = tileY}

			self.selectionData[#self.selectionData+1] = {imagePath = self.imagePaths[imageIndex], image = self.images[imageIndex], transform = transform, tilesheetTransform = tilesheetTransform}

			globals.data.selectionData = self.selectionData
		end
	end
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