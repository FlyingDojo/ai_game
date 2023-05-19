local Enemy = {}
Enemy.__index = Enemy

function Enemy:new()
    local enemy = setmetatable({}, self)
    enemy.x = math.random(50, love.graphics.getWidth() - 50)
    enemy.y = -50
    enemy.speed = 100
    enemy.radius = 30
    return enemy
end

function Enemy:update(dt)
    self.y = self.y + self.speed * dt
end

function Enemy:draw()
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

return Enemy
