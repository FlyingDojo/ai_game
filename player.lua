local Bullet = require("Bullet")
local Constants = require("Constants")

local Player = {}

function Player:new()
    local obj = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() - 50,
        radius = 20,
        speed = 300,
        shotSpeed = 500,
        lives = 3,
        shootTimer = 0
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Player:update(dt)
    -- Move player
    local dx = 0
    local dy = 0
    if love.keyboard.isDown("left") then
        dx = -self.speed * dt
    elseif love.keyboard.isDown("right") then
        dx = self.speed * dt
    end
    if love.keyboard.isDown("up") then
        dy = -self.speed * dt
    elseif love.keyboard.isDown("down") then
        dy = self.speed * dt
    end
    self.x = self.x + dx
    self.y = self.y + dy

    -- Keep player within screen bounds
    self.x = math.max(self.radius, math.min(love.graphics.getWidth() - self.radius, self.x))
    self.y = math.max(self.radius, math.min(love.graphics.getHeight() - self.radius, self.y))

    -- Update shoot timer
    self.shootTimer = self.shootTimer - dt
end

function Player:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Player:shoot(game)
    if self.shootTimer <= 0 then
        local bullet = Bullet:new(self.x, self.y - self.radius)
        table.insert(game.bullets, bullet)
        self.shootTimer = 1 / self.shotSpeed
    end
end

function Player:loseLife(game)
    self.lives = self.lives - 1
    if self.lives <= 0 then
        game.state = Constants.GAME_STATES.GAME_OVER
    end
end

function Player:gainLife()
    self.lives = self.lives + 1
end

function Player:increaseSpeed(multiplier)
    self.speed = self.speed * multiplier
end

function Player:increaseShotSpeed(multiplier)
    self.shotSpeed = self.shotSpeed * multiplier
end

return Player
