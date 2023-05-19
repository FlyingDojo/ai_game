local constants = require("constants")
local pause = {}
local PAUSE_MENU_ITEMS = {
    {text = "Resume", action = function() gameState = constants.GAME_STATES.PLAY end},
    {text = "Quit", action = function() love.event.quit() end}
}
local FONT_SIZE = 24

local pauseSelectedItem = 1
local font = love.graphics.newFont(FONT_SIZE)

local function drawMenuItems(items, selectedItem, y)
    love.graphics.setFont(font)
    for i, item in ipairs(items) do
        if i == selectedItem then
            love.graphics.setColor(255, 255, 0)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.print(item.text, love.graphics.getWidth() / 2 - font:getWidth(item.text) / 2, y + (i - 1) * font:getHeight())
    end
end

function pause.update()
    if love.keyboard.isDown("up") then
        pauseSelectedItem = pauseSelectedItem - 1
        if pauseSelectedItem < 1 then
            pauseSelectedItem = #PAUSE_MENU_ITEMS
        end
    elseif love.keyboard.isDown("down") then
        pauseSelectedItem = pauseSelectedItem + 1
        if pauseSelectedItem > #PAUSE_MENU_ITEMS then
            pauseSelectedItem = 1
        end
    end

    if love.keyboard.isDown("return") then
        PAUSE_MENU_ITEMS[pauseSelectedItem].action()
    end
end

function pause.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    drawMenuItems(PAUSE_MENU_ITEMS, pauseSelectedItem, love.graphics.getHeight() / 2 - (#PAUSE_MENU_ITEMS * font:getHeight()) / 2)
end

function pause.keypressed(key)
    -- do nothing
end

return pause
