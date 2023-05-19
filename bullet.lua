local Bullet = {}
Bullet.__index = Bullet

function Bullet:new(x, y)
    local bullet = setmetatable({}, self)
    bullet.x = x
    bullet.y = y
    bullet.speed = 500
    bullet.radius = 5
    return bullet
end

function Bullet:update(dt)
    self.y = self.y - self.speed * dt
end

function Bullet:draw()
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Bullet
