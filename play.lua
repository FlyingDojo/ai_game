local Constants = require("constants")
local Bullet = require("bullet")

local Player = {}
Player.__index = Player

function Player:new()
    local player = setmetatable({}, self)
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() - 50
    player.speed = Constants.PLAYER_SPEED
    player.radius = Constants.PLAYER_RADIUS
    player.lives = Constants.PLAYER_LIVES
    player.shootTimer = 0
    return player
end

function Player:update(dt)
    -- Movement
    self.x = self.x + self.speed * dt
    if self.x < self.radius then
        self.x = self.radius
    elseif self.x > love.graphics.getWidth() - self.radius then
        self.x = love.graphics.getWidth() - self.radius
    end

    -- Shooting
    self.shootTimer = self.shootTimer - dt
    if self.shootTimer <= 0 then
        self.shootTimer = Constants.PLAYER_SHOOT_DELAY
        self:shoot()
    end
end

function Player:draw()
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Player:moveLeft()
    self.speed = -Constants.PLAYER_SPEED
end

function Player:moveRight()
    self.speed = Constants.PLAYER_SPEED
end

function Player:shoot()
    local bullet = Bullet:new(self.x, self.y)
    table.insert(game.bullets, bullet)
end

function Player:loseLife()
    self.lives = self.lives - 1
end

function Player:applyPowerup(powerup)
    if powerup.type == Constants.POWERUP_TYPES.LIFE then
        self.lives = self.lives + 1
    elseif powerup.type == Constants.POWERUP_TYPES.SPEED then
        self.speed = self.speed * Constants.POWERUP_SPEED_MULTIPLIER
    elseif powerup.type == Constants.POWERUP_TYPES.SHOT_SPEED then
        Constants.PLAYER_SHOOT_DELAY = Constants.PLAYER_SHOOT_DELAY / Constants.POWERUP_SHOT_SPEED_MULTIPLIER
    end
end

return Player
