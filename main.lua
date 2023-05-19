local Constants = require("constants")
local Game = require("game")

local game

function love.load()
    love.graphics.setFont(Constants.FONT_MEDIUM) -- Set the default font
    game = Game:new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keyPressed(key)
end

function love.mousepressed(x, y, button)
    game:mousePressed(x, y, button)
end
