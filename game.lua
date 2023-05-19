local Constants = require("constants")
local Player = require("player")
local Enemy = require("enemy")
local Powerup = require("powerup")

local Game = {}
Game.__index = Game

function Game:new()
    local game = setmetatable({}, self)
    game.state = Constants.GAME_STATES.MENU
    game.menuOptions = {"Start", "Instructions", "Quit"}
    game.menuSelection = 1
    game.score = 0
    game.player = nil -- Initialize player as nil
    game.enemies = {}
    game.bullets = {}
    game.powerups = {}
    game.spawnTimer = Constants.SPAWN_DELAY
    game.powerupTimer = Constants.POWERUP_DELAY
    return game
end

function Game:update(dt)
    if self.state == Constants.GAME_STATES.PLAY then
        -- Update player
        self.player:update(dt)

        -- Update bullets
        for i = #self.bullets, 1, -1 do
            local bullet = self.bullets[i]
            bullet:update(dt)
            if bullet.y < 0 then
                table.remove(self.bullets, i)
            end
        end

        -- Update enemies
        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            enemy:update(dt)
            if enemy.y > love.graphics.getHeight() + enemy.radius then
                table.remove(self.enemies, i)
                self.player:loseLife()
            end

            -- Check collision with player
            if self:checkCollision(enemy, self.player) then
                table.remove(self.enemies, i)
                self.player:loseLife()
            end
        end

        -- Update power-ups
        for i = #self.powerups, 1, -1 do
            local powerup = self.powerups[i]
            powerup:update(dt)
            if powerup.y > love.graphics.getHeight() + powerup.radius then
                table.remove(self.powerups, i)
            end

            -- Check collision with player
            if self:checkCollision(powerup, self.player) then
                table.remove(self.powerups, i)
                self.player:applyPowerup(powerup)
            end
        end

        -- Spawn enemies
        self.spawnTimer = self.spawnTimer - dt
        if self.spawnTimer <= 0 then
            self:spawnEnemy()
            self.spawnTimer = Constants.SPAWN_DELAY
        end

        -- Spawn power-ups
        self.powerupTimer = self.powerupTimer - dt
        if self.powerupTimer <= 0 then
            self:spawnPowerup()
            self.powerupTimer = Constants.POWERUP_DELAY
        end

        -- Game over condition
        if self.player.lives <= 0 then
            self.state = Constants.GAME_STATES.GAME_OVER
        end
    end
end

-- Rest of the code...

return Game
