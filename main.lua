require("lovelsm2d/main")

lovelsm2d = Lovelsm2d

function love.load()
	lovelsm2d:init()

	nodes:loadNodeGroup("menus/main/main")
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
	lovelsm2d:quit()
	return false
end