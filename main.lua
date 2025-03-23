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
	if nodes:isNodeGroupLoaded("editor") then
		local currentMap = globals.data.map.map
		local layers = helper:tableDeepCopy(globals.data.map.layers)

		local mapPath = love.filesystem.getSaveDirectory().."/"..currentMap.."/"

		for k, layer in pairs(layers) do
			for k2, tile in pairs(layer.tiles) do
				tile.data.image = nil
				tile.data.quad = nil
			end
			helper:writeFile(mapPath.."layer"..k..".json", layer)
		end
	end
end

function loadMap(map)
	local savePath = love.filesystem.getSaveDirectory()

	local layers = {}

	local layerFiles = helper:scanDir(savePath.."/"..map.."/")

	for k, layerFile in pairs(layerFiles) do
		local layer = helper:readSaveFile(map.."/"..layerFile)
		local tiles = {}
		if layer.tiles ~= nil then
			for k2, tile in pairs(layer.tiles) do tiles[#tiles+1] = tile end
		end
		layers[#layers+1] = {floaty = false, tiles = tiles}
	end

	globals.data.map = {}
	globals.data.map["map"] = map
	globals.data.map["layers"] = layers
	globals.data.map["currentLayer"] = 1

	globals.data.tilesheetImages = {}
	globals.data.tilesheetImagePaths = {}

	local path = globals.config.pathTilesheets
	local files = helper:getFilesInDir(globals.config.pathTilesheets)
	local images = {}
	local imagePaths = {}

	for k, file in pairs(files) do
		images[path.."/"..file] = love.graphics.newImage(path.."/"..file)
		imagePaths[#imagePaths+1] = path.."/"..file
	end

	globals.data.tilesheetImages = images
	globals.data.tilesheetImagePaths = imagePaths
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