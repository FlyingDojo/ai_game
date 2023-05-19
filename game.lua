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
    game.player = nil
    game.enemies = {}
    game.bullets = {}
    game.powerups = {}
    game.spawnTimer = Constants.SPAWN_DELAY
    game.powerupTimer = Constants.POWERUP_DELAY
    return game
end

function Game:update(dt)
    if self.state == Constants.GAME_STATES.PLAY then
        if self.player then
            -- Update player
            self.player:update(dt)
        end

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
                if self.player then
                    self.player:loseLife()
                end
            end

            -- Check collision with player
            if self.player and self:checkCollision(enemy, self.player) then
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
            if self.player and self:checkCollision(powerup, self.player) then
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
        if self.player and self.player.lives <= 0 then
            self.state = Constants.GAME_STATES.GAME_OVER
        end
    end
end

function Game:draw()
    if self.state == Constants.GAME_STATES.PLAY then
        -- Draw player
        if self.player then
            self.player:draw()
        end

        -- Draw bullets
        for _, bullet in ipairs(self.bullets) do
            bullet:draw()
        end

        -- Draw enemies
        for _, enemy in ipairs(self.enemies) do
            enemy:draw()
        end

        -- Draw power-ups
        for _, powerup in ipairs(self.powerups) do
            powerup:draw()
        end

        -- Draw score
        love.graphics.print("Score: " .. self.score, 10, 10)
        if self.player then
            love.graphics.print("Lives: " .. self.player.lives, 10, 30)
        end
    elseif self.state == Constants.GAME_STATES.MENU then
        -- Draw menu options
        for i, option in ipairs(self.menuOptions) do
            if i == self.menuSelection then
                love.graphics.setColor(0, 1, 0) -- Highlight the selected option
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.print(option, 10, 10 + (i - 1) * 20)
        end
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        -- Draw game over message
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("Game Over", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 - 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Press Enter to Restart", love.graphics.getWidth() / 2 - 85, love.graphics.getHeight() / 2 + 20)
    end
end

function Game:keyPressed(key)
    if self.state == Constants.GAME_STATES.PLAY then
        if self.player then
            self.player:keyPressed(key)
        end
    elseif self.state == Constants.GAME_STATES.MENU then
        if key == "up" then
            self.menuSelection = self.menuSelection - 1
            if self.menuSelection < 1 then
                self.menuSelection = #self.menuOptions
            end
        elseif key == "down" then
            self.menuSelection = self.menuSelection + 1
            if self.menuSelection > #self.menuOptions then
                self.menuSelection = 1
            end
        elseif key == "return" or key == "enter" then
            self:handleMenuSelection()
        end
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        if key == "return" or key == "enter" then
            self:resetGame()
        end
    end
end

function Game:mousePressed(x, y, button)
    if self.state == Constants.GAME_STATES.MENU then
        self:handleMenuSelection()
    elseif self.state == Constants.GAME_STATES.PLAY then
        if self.player then
            self.player:mousePressed(x, y, button)
        end
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        self:resetGame()
    end
end

function Game:handleMenuSelection()
    local selection = self.menuOptions[self.menuSelection]
    if selection == "Start" then
        self:startGame()
    elseif selection == "Instructions" then
        -- Handle instructions
    elseif selection == "Quit" then
        love.event.quit()
    end
end

function Game:startGame()
    self.state = Constants.GAME_STATES.PLAY
    self.player = Player:new()
    self.score = 0
end

function Game:resetGame()
    self.state = Constants.GAME_STATES.MENU
    self.player = nil
    self.enemies = {}
    self.bullets = {}
    self.powerups = {}
    self.spawnTimer = Constants.SPAWN_DELAY
    self.powerupTimer = Constants.POWERUP_DELAY
    self.menuSelection = 1
end

function Game:spawnEnemy()
    local enemy = Enemy:new()
    table.insert(self.enemies, enemy)
end

function Game:spawnPowerup()
    local powerup = Powerup:new()
    table.insert(self.powerups, powerup)
end

function Game:checkCollision(obj1, obj2)
    if not obj1 or not obj2 then
        return false
    end
    local dx = obj1.x - obj2.x
    local dy = obj1.y - obj2.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < obj1.radius + obj2.radius
end

return Game
