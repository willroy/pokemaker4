require("lovelsm2d/main")
require("uis/tilesheetPalette")
require("uis/canvas")
require("uis/layers")
require("uis/fileListPreview")

lovelsm2d = Lovelsm2d

function love.load()
	-- init engine
	lovelsm2d:init()

	-- load custom uis
	nodes.uis["tilesheetPalette"] = TilesheetPalette()
	nodes.uis["canvas"] = Canvas()
	nodes.uis["layers"] = Layers()
	nodes.uis["fileListPreview"] = FileListPreview()

	globals.data.version = "build-"..string.sub(helper:readFile("version.txt", false), 1, 4)

	-- load nodes from files
	lovelsm2d:loadNodes()

	-- load main menu
	nodes:loadNodeGroup("main")
end

function newMap()
	
end

function saveMap()
	print("saving...")


	if nodes:isNodeGroupLoaded("editor") then
		local currentMap = globals.data.map.map
		local layers = helper:tableDeepCopy(globals.data.map.layers)

		local mapPath = love.filesystem.getSaveDirectory().."/"..currentMap.."/"

		-- for k, tile in pairs(layers[1].tiles) do
		-- 	print(k.." "..tile.data.image)
		-- end

		for k, layer in pairs(layers) do
			for k2, tile in pairs(layer.tiles) do
				tile.data.image = nil
				tile.data.quad = nil
			end
			helper:writeFile(mapPath.."layer"..k..".json", layer)
		end
	end
end

function love.update(dt)
	lovelsm2d:update(dt)
end

function love.draw()
	lovelsm2d:draw()
end

function love.mousepressed(x, y, button, istouch)
	lovelsm2d:mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
	lovelsm2d:mousereleased(x, y, button, istouch)
end

function love.keypressed(key, code)
	lovelsm2d:keypressed(key, code)
end

function love.keyreleased(key)
	lovelsm2d:keyreleased(key)
end

function love.wheelmoved(x, y)
	lovelsm2d:wheelmoved(x, y)
end

function love.resize(w, h)
  lovelsm2d:resize(w, h)
end

function love.quit()
	if nodes:isNodeGroupLoaded("editor") then saveMap() end
	lovelsm2d:quit()
	return false
end