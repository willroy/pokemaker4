Layers = Object:extend()

function Layers:init(node, data)
	if node == nil or data == nil then return end

	self.node = node

	self.layerIndicatorStyle = {r = 0.2, g = 0.2, b = 0.2, a = 1}
end

function Layers:update(dt)
	if self.map == nil then
		self.map = globals.data.map
		self.layers = globals.data.map.layers
		self.layer = globals.data.map.currentLayer
	end
end

function Layers:draw()
	love.graphics.setColor(self.layerIndicatorStyle.r, self.layerIndicatorStyle.g, self.layerIndicatorStyle.b, self.layerIndicatorStyle.a) 

	for k, l in pairs(self.layers) do
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
	for k, l in pairs(self.layers) do
		local distanceFromCurrent = -(k - self.layer)
		-- drawn hitbox
		local layerDotX = self.node.transform.x + ( self.node.transform.w / 2 )
		local layerDotY = self.node.transform.y + ( self.node.transform.h / 2 ) + ( distanceFromCurrent * 40 )
		local layerDotW = 20
		local layerDotH = 20
		-- better hitbox (more leeway)
		layerDotX = layerDotX - 10
		layerDotY = layerDotY - 10
		layerDotW = layerDotW + 20
		layerDotH = layerDotH + 20

		if x > layerDotX and x < ( layerDotX + layerDotW ) then
			if y > layerDotY and y < ( layerDotY + layerDotH ) then
				self.layer = k
				globals.data.map["currentLayer"] = self.layer
				self.clickLock = true
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