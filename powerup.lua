local Constants = require("constants")

local Powerup = {}
Powerup.__index = Powerup

function Powerup:new()
    local powerup = setmetatable({}, self)
    powerup.x = math.random(50, love.graphics.getWidth() - 50)
    powerup.y = -50
    powerup.speed = 100
    powerup.radius = 20
    powerup.type = Constants.POWERUP_TYPES[math.random(#Constants.POWERUP_TYPES)]
    return powerup
end

function Powerup:update(dt)
    self.y = self.y + self.speed * dt
end

function Powerup:draw()
    love.graphics.setColor(0, 255, 0) -- Green color for power-ups
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(255, 255, 255) -- Reset color
end

return Powerup
