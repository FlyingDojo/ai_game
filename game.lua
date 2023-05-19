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
            self.player:update(dt, self)  -- Pass the game object
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
        end

        -- Update powerups
        for i = #self.powerups, 1, -1 do
            local powerup = self.powerups[i]
            powerup:update(dt)
            if powerup.y > love.graphics.getHeight() + powerup.radius then
                table.remove(self.powerups, i)
            end
        end

        -- Check for collisions
        self:checkCollisions()

        -- Spawn enemies
        self.spawnTimer = self.spawnTimer - dt
        if self.spawnTimer <= 0 then
            self:spawnEnemy()
            self.spawnTimer = Constants.SPAWN_DELAY
        end

        -- Spawn powerups
        self.powerupTimer = self.powerupTimer - dt
        if self.powerupTimer <= 0 then
            self:spawnPowerup()
            self.powerupTimer = Constants.POWERUP_DELAY
        end
    end
end

function Game:draw()
    if self.state == Constants.GAME_STATES.MENU then
        self:drawMenu()
    elseif self.state == Constants.GAME_STATES.PLAY then
        self:drawGame()
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        self:drawGameOver()
    end
end

function Game:keyPressed(key)
    if self.state == Constants.GAME_STATES.MENU then
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
        elseif key == "return" then
            if self.menuSelection == 1 then
                self:startGame()
            elseif self.menuSelection == 2 then
                -- Show instructions
            elseif self.menuSelection == 3 then
                love.event.quit()
            end
        end
    elseif self.state == Constants.GAME_STATES.PLAY then
        if key == "space" then
            self:playerShoot()
        end
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        if key == "return" then
            self:resetGame()
        end
    end
end

function Game:checkCollisions()
    -- Check collision between player and enemies
    if self.player then
        for i = #self.enemies, 1, -1 do
            local enemy = self.enemies[i]
            local distance = math.sqrt((enemy.x - self.player.x)^2 + (enemy.y - self.player.y)^2)
            if distance < enemy.radius + self.player.radius then
                table.remove(self.enemies, i)
                self.player:loseLife(self)
            end
        end
    end

    -- Check collision between bullets and enemies
    for i = #self.bullets, 1, -1 do
        local bullet = self.bullets[i]
        for j = #self.enemies, 1, -1 do
            local enemy = self.enemies[j]
            local distance = math.sqrt((enemy.x - bullet.x)^2 + (enemy.y - bullet.y)^2)
            if distance < enemy.radius + bullet.radius then
                table.remove(self.bullets, i)
                table.remove(self.enemies, j)
                self.score = self.score + 1
            end
        end
    end

    -- Check collision between player and powerups
    if self.player then
        for i = #self.powerups, 1, -1 do
            local powerup = self.powerups[i]
            local distance = math.sqrt((powerup.x - self.player.x)^2 + (powerup.y - self.player.y)^2)
            if distance < powerup.radius + self.player.radius then
                table.remove(self.powerups, i)
                if powerup.type == Constants.POWERUP_TYPES.LIFE then
                    self.player:gainLife()
                elseif powerup.type == Constants.POWERUP_TYPES.SPEED then
                    self.player:increaseSpeed(Constants.POWERUP_SPEED_MULTIPLIER)
                elseif powerup.type == Constants.POWERUP_TYPES.SHOT_SPEED then
                    self.player:increaseShotSpeed(Constants.POWERUP_SHOT_SPEED_MULTIPLIER)
                end
            end
        end
    end
end

function Game:spawnEnemy()
    local enemy = Enemy:new()
    table.insert(self.enemies, enemy)
end

function Game:spawnPowerup()
    local powerup = Powerup:new()
    table.insert(self.powerups, powerup)
end

function Game:playerShoot()
    if self.player then
        self.player:shoot(self)
    end
end

function Game:startGame()
    self.state = Constants.GAME_STATES.PLAY
    self.score = 0
    self.player = Player:new()
end

function Game:resetGame()
    self.state = Constants.GAME_STATES.MENU
    self.menuSelection = 1
    self.score = 0
    self.player = nil
    self.enemies = {}
    self.bullets = {}
    self.powerups = {}
    self.spawnTimer = Constants.SPAWN_DELAY
    self.powerupTimer = Constants.POWERUP_DELAY
end

function Game:drawMenu()
    -- Draw menu options
    love.graphics.setFont(Constants.FONT_MEDIUM)
    for i, option in ipairs(self.menuOptions) do
        if i == self.menuSelection then
            love.graphics.setColor(255, 255, 0)
        else
            love.graphics.setColor(255, 255, 255)
        end
        love.graphics.printf(option, 0, love.graphics.getHeight() / 2 + (i - 1) * 30, love.graphics.getWidth(), "center")
    end
end

function Game:drawGame()
    -- Draw score
    love.graphics.setFont(Constants.FONT_SMALL)
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Score: " .. self.score, 10, 10)

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

    -- Draw powerups
    for _, powerup in ipairs(self.powerups) do
        powerup:draw()
    end
end

function Game:drawGameOver()
    love.graphics.setFont(Constants.FONT_LARGE)
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")

    love.graphics.setFont(Constants.FONT_MEDIUM)
    love.graphics.printf("Score: " .. self.score, 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
    love.graphics.printf("Press Enter to Restart", 0, love.graphics.getHeight() / 2 + 100, love.graphics.getWidth(), "center")
end

return Game
