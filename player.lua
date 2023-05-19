local Constants = require "constants"

local Player = {}

function Player:new()
    local player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() - 50,
        width = 20,
        height = 20,
        speed = 300,
        bullets = {},
        fireRate = 0.2,
        fireTimer = 0,
        radius = 10
    }
    setmetatable(player, self)
    self.__index = self
    return player
end

function Player:update(dt)
    self:move(dt)
    self:fire(dt)
    self:updateBullets(dt)
end

function Player:move(dt)
    local dx = 0
    local dy = 0

    if love.keyboard.isDown("left") then
        dx = -1
    elseif love.keyboard.isDown("right") then
        dx = 1
    end

    if love.keyboard.isDown("up") then
        dy = -1
    elseif love.keyboard.isDown("down") then
        dy = 1
    end

    local magnitude = math.sqrt(dx * dx + dy * dy)
    if magnitude ~= 0 then
        dx = dx / magnitude
        dy = dy / magnitude
    end

    self.x = self.x + dx * self.speed * dt
    self.y = self.y + dy * self.speed * dt

    -- Keep the player within the game window
    self.x = math.max(0, math.min(self.x, love.graphics.getWidth()))
    self.y = math.max(0, math.min(self.y, love.graphics.getHeight()))
end

function Player:fire(dt)
    self.fireTimer = self.fireTimer + dt

    if self.fireTimer >= self.fireRate and love.keyboard.isDown("space") then
        self.fireTimer = 0
        local bullet = {
            x = self.x,
            y = self.y - self.radius,
            width = 2,
            height = 10,
            speed = 500
        }
        table.insert(self.bullets, bullet)
    end
end

function Player:updateBullets(dt)
    for i, bullet in ipairs(self.bullets) do
        bullet.y = bullet.y - bullet.speed * dt
        if bullet.y < 0 then
            table.remove(self.bullets, i)
        end
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)

    love.graphics.setColor(1, 0, 0)
    for _, bullet in ipairs(self.bullets) do
        love.graphics.rectangle("fill", bullet.x - bullet.width / 2, bullet.y - bullet.height / 2, bullet.width, bullet.height)
    end
end

return Player
