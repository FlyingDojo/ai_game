local constants = require("constants")

local MENU_ITEMS = {
    {text = "Play", action = function() gameState = constants.GAME_STATES.PLAY end},
    {text = "Quit", action = function() love.event.quit() end}
}
local FONT_SIZE = 24
local menu = {}
local selectedItem = 1
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

function menu.update()
    if love.keyboard.isDown("up") then
        selectedItem = selectedItem - 1
        if selectedItem < 1 then
            selectedItem = #MENU_ITEMS
        end
    elseif love.keyboard.isDown("down") then
        selectedItem = selectedItem + 1
        if selectedItem > #MENU_ITEMS then
            selectedItem = 1
        end
    end

    if love.keyboard.isDown("return") then
        MENU_ITEMS[selectedItem].action()
    end
end

function menu.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    drawMenuItems(MENU_ITEMS, selectedItem, love.graphics.getHeight() / 2 - (#MENU_ITEMS * font:getHeight()) / 2)
end

function menu.keypressed(key)
    -- do nothing
end

return menu
