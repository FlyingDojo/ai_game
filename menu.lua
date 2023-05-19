local Constants = require("constants")

local Menu = {}
Menu.__index = Menu

function Menu:new()
    local menu = setmetatable({}, self)
    menu.options = {"Start", "Instructions", "Quit"}
    menu.selection = 1
    return menu
end

function Menu:update(dt)
    -- Update menu logic here
end

function Menu:draw()
    love.graphics.setFont(Constants.FONT_MEDIUM)
    local menuY = Constants.WINDOW_HEIGHT / 2 - (#self.options * Constants.FONT_MEDIUM:getHeight()) / 2
    for i, option in ipairs(self.options) do
        if i == self.selection then
            love.graphics.setColor(1, 0, 0) -- Highlight the selected option
        else
            love.graphics.setColor(1, 1, 1) -- Set color to white for other options
        end
        love.graphics.printf(option, 0, menuY + (i - 1) * Constants.FONT_MEDIUM:getHeight(), Constants.WINDOW_WIDTH, "center")
    end
end

return Menu
