local constants = require("constants")
local play = require("play")
local pause = require("pause")

function love.load()
    gameState = constants.GAME_STATES.PLAY
    love.window.setTitle("Space Invaders")
    love.window.setMode(constants.SCREEN_WIDTH, constants.SCREEN_HEIGHT, {
        resizable = false
    })
    love.graphics.setBackgroundColor(constants.BACKGROUND_COLOR)
end

function love.update(dt)
    if gameState == constants.GAME_STATES.PLAY then
        play.update(dt)
    elseif gameState == constants.GAME_STATES.PAUSE then
        pause.update(dt)
    end
end

function love.draw()
    if gameState == constants.GAME_STATES.PLAY then
        play.draw()
    elseif gameState == constants.GAME_STATES.PAUSE then
        pause.draw()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "p" and gameState == constants.GAME_STATES.PLAY then
        gameState = constants.GAME_STATES.PAUSE
    elseif key == "r" and gameState == constants.GAME_STATES.PAUSE then
        gameState = constants.GAME_STATES.PLAY
    end

    if gameState == constants.GAME_STATES.PLAY then
        play.keypressed(key)
    elseif gameState == constants.GAME_STATES.PAUSE then
        pause.keypressed(key)
    end
end
