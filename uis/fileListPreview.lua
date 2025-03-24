FileListPreview = Object:extend()

function FileListPreview:init(node, data)
	if node == nil or data == nil then return end

	self.node = node
	self.path = data.path or love.filesystem.getSaveDirectory()
	self.maps = {}

	local maps = helper:scanDir(self.path)

	for k, map in pairs(maps) do
		if love.filesystem.getInfo(map).type == "directory" then
			self.maps[#self.maps+1] = map
		end
	end

	self.padding = data.padding or {x = 0, y = 0}
	self.color = data.color or { r = 0, g = 0, b = 0, a = 1 }
end

function FileListPreview:update(dt)
end

function FileListPreview:draw()
	love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)

	for k, map in pairs(self.maps) do
		local mousePos = globals.trackers.mousePos
		local fileX = self.node.transform.x + self.padding.x
		local fileY = self.node.transform.y + self.padding.y + ( ( k - 1 ) * 40 )
		local selectorX = self.node.transform.x
		local selectorY = self.node.transform.y + ( ( k - 1 ) * 40 )
		local selectorH = selectorY + 40

		if mousePos.x > selectorX and mousePos.y > selectorY and mousePos.y < selectorH then
			love.graphics.rectangle("line", selectorX, selectorY, self.node.transform.w, 40)
		end

		love.graphics.print(map, fileX, fileY )
	end

	love.graphics.setColor(1,1,1,1)
end

function FileListPreview:mousepressed(x, y, button, istouch)
	if not helper:contains(input.nodes_hovered, self.node) then return end

	for k, map in pairs(self.maps) do
		local selectorX = self.node.transform.x
		local selectorY = self.node.transform.y + ( ( k - 1 ) * 40 )
		local selectorH = selectorY + 40

		if x > selectorX and y > selectorY and y < selectorH then
			loadMap(map)
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