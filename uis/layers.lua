Layers = Object:extend()

function Layers:init(node, data)
	if node == nil or data == nil then return end

	self.node = node

	self.layerIndicatorStyle = {r = 0.2, g = 0.2, b = 0.2, a = 1}
end

function Layers:update(dt)
end

function Layers:draw()
	if self.layer ~= globals.data.map.currentLayer then self.layer = globals.data.map.currentLayer end

	love.graphics.setColor(self.layerIndicatorStyle.r, self.layerIndicatorStyle.g, self.layerIndicatorStyle.b, self.layerIndicatorStyle.a) 

	for k, l in pairs(globals.data.map.layers) do
		local distanceFromCurrent = -(k - self.layer)

		local layerDotX = self.node.transform.x + ( self.node.transform.w / 2 )
		local layerDotY = self.node.transform.y + ( self.node.transform.h / 2 ) + ( distanceFromCurrent * 40 )
		local layerDotW = 20
		local layerDotH = 20

		local mode = "line"
		if self.layer == k then mode = "fill" end

		love.graphics.print(k, layerDotX-25, layerDotY-2)
		if l.floaty then love.graphics.print("^", layerDotX-50, layerDotY+2) end
		love.graphics.rectangle(mode, layerDotX, layerDotY, layerDotW, layerDotH) 
	end

	love.graphics.setColor(1,1,1,1)
end

function Layers:mousepressed(x, y, button, istouch)
	if self.clickLock == true then return end
	for k, l in pairs(globals.data.map.layers) do
		local distanceFromCurrent = -(k - self.layer)

		local paddingTL = -10
		local paddingBR = 20

		local layerDotX = self.node.transform.x + ( self.node.transform.w / 2 ) + paddingTL
		local layerDotY = self.node.transform.y + ( self.node.transform.h / 2 ) + ( distanceFromCurrent * 40 ) + paddingTL
		local layerDotW = 20 + paddingBR
		local layerDotH = 20 + paddingBR

		if x > layerDotX and x < ( layerDotX + layerDotW ) then
			if y > layerDotY and y < ( layerDotY + layerDotH ) then
				self.layer = k
				self.clickLock = true
				globals.data.map["currentLayer"] = self.layer
				break
			end
		end
	end
end

function Layers:mousereleased(x, y, button, istouch)
	self.clickLock = false
end

function Layers:wheelmoved(x, y)
end