local Constants = require("constants")
local Bullet = require("bullet")

local Player = {}

function Player:new()
    local player = {
        x = love.graphics.getWidth() / 2,
        y = love.graphics.getHeight() - 50,
        width = Constants.PLAYER_WIDTH,
        height = Constants.PLAYER_HEIGHT,
        speed = Constants.PLAYER_SPEED,
        shootTimer = 0,
        lives = Constants.PLAYER_LIVES
    }
    setmetatable(player, self)
    self.__index = self
    return player
end

function Player:update(dt)
    -- Move left
    if love.keyboard.isDown("left") then
        self.x = self.x - self.speed * dt
        if self.x < 0 then
            self.x = 0
        end
    end

    -- Move right
    if love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        if self.x + self.width > love.graphics.getWidth() then
            self.x = love.graphics.getWidth() - self.width
        end
    end

    -- Shoot bullets
    self.shootTimer = self.shootTimer - dt
    if love.keyboard.isDown("space") and self.shootTimer <= 0 then
        self:shoot()
        self.shootTimer = Constants.PLAYER_SHOOT_DELAY
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1) -- Set color to white
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Player:shoot()
    local bullet = Bullet:new(self.x + self.width / 2, self.y)
    table.insert(Game.bullets, bullet)
end

function Player:loseLife()
    self.lives = self.lives - 1
end

function Player:applyPowerup(powerup)
    if powerup.type == Constants.POWERUP_TYPES.LIFE then
        self.lives = self.lives + 1
    elseif powerup.type == Constants.POWERUP_TYPES.SPEED then
        self.speed = self.speed + Constants.POWERUP_SPEED_INCREASE
    end
end

return Player
