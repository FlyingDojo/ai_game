local Bullet = {}

function Bullet:new(x, y)
    local obj = {
        x = x,
        y = y,
        speed = 500,
        radius = 5
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Bullet:update(dt)
    self.y = self.y - self.speed * dt
end

function Bullet:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Bullet
