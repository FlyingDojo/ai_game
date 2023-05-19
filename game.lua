local Player = require("player")
local Bullet = require("bullet")
local Enemy = require("enemy")
local Powerup = require("powerup")
local Constants = require("constants")

local Game = {}
Game.__index = Game

function Game:new()
    local game = setmetatable({}, self)
    game:reset()
    return game
end

function Game:update(dt)
    if self.state == Constants.GAME_STATES.PLAY then
        -- Update player
        self.player:update(dt)

        -- Update bullets
        for i, bullet in ipairs(self.bullets) do
            bullet:update(dt)
            if bullet.y < 0 then
                table.remove(self.bullets, i)
            end
        end

        -- Update enemies
        for i, enemy in ipairs(self.enemies) do
            enemy:update(dt)
            if enemy.y > love.graphics.getHeight() + enemy.radius then
                table.remove(self.enemies, i)
                self.player:loseLife()
                if self.player.lives <= 0 then
                    self:gameOver()
                end
            elseif self:checkCollision(self.player, enemy) then
                table.remove(self.enemies, i)
                self.player:loseLife()
                if self.player.lives <= 0 then
                    self:gameOver()
                end
            end
        end

        -- Update power-ups
        for i, powerup in ipairs(self.powerups) do
            powerup:update(dt)
            if powerup.y > love.graphics.getHeight() + powerup.radius then
                table.remove(self.powerups, i)
            elseif self:checkCollision(self.player, powerup) then
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
    end
end

function Game:draw()
    -- Draw player
    self.player:draw()

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

    -- Draw UI
    self:drawUI()

    -- Draw game over screen
    if self.state == Constants.GAME_STATES.GAME_OVER then
        self:drawGameOver()
    end

    -- Draw menu
    if self.state == Constants.GAME_STATES.MENU then
        self:drawMenu()
    end
end

function Game:keyPressed(key)
    if self.state == Constants.GAME_STATES.PLAY then
        -- Player controls
        if key == "left" or key == "a" then
            self.player:moveLeft()
        elseif key == "right" or key == "d" then
            self.player:moveRight()
        elseif key == "space" or key == "w" or key == "up" then
            self.player:shoot()
        end
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        -- Restart the game
        self:reset()
    elseif self.state == Constants.GAME_STATES.MENU then
        -- Menu controls
        if key == "up" then
            self:menuUp()
        elseif key == "down" then
            self:menuDown()
        elseif key == "return" or key == "space" then
            self:menuSelect()
        end
    end
end

function Game:mousePressed(x, y, button)
    if self.state == Constants.GAME_STATES.PLAY then
        -- Player controls
        if button == 1 then
            local mouseX = love.mouse.getX()
            if mouseX < self.player.x then
                self.player:moveLeft()
            elseif mouseX > self.player.x then
                self.player:moveRight()
            else
                self.player:shoot()
            end
        end
    elseif self.state == Constants.GAME_STATES.GAME_OVER then
        -- Restart the game
        self:reset()
    elseif self.state == Constants.GAME_STATES.MENU then
        -- Menu controls
        if button == 1 then
            local mouseY = love.mouse.getY()
            local menuOptionHeight = love.graphics.getHeight() / (#self.menuOptions + 1)
            local selection = math.floor(mouseY / menuOptionHeight) + 1
            self.menuSelection = selection
            self:menuSelect()
        end
    end
end

function Game:startGame()
    self:reset()
    self.state = Constants.GAME_STATES.PLAY
end

function Game:gameOver()
    self.state = Constants.GAME_STATES.GAME_OVER
end

function Game:reset()
    self.player = Player:new()
    self.bullets = {}
    self.enemies = {}
    self.powerups = {}
    self.spawnTimer = Constants.SPAWN_DELAY
    self.powerupTimer = Constants.POWERUP_DELAY
    self.state = Constants.GAME_STATES.MENU
    self.menuOptions = { "Start", "Instructions", "Quit" }
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

function Game:drawUI()
    -- Draw player lives
    love.graphics.print("Lives: " .. self.player.lives, 10, 10)

    -- Draw menu options
    if self.state == Constants.GAME_STATES.MENU then
        self:drawMenu()
    end
end

function Game:drawGameOver()
    -- Draw game over text
    love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")
    love.graphics.printf("Press any key to restart", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
end

function Game:drawMenu()
    -- Draw menu options
    love.graphics.printf("Main Menu", 0, love.graphics.getHeight() / 2 - 100, love.graphics.getWidth(), "center")
    for i, option in ipairs(self.menuOptions) do
        local yPos = love.graphics.getHeight() / 2 + (i - 1) * 30
        if i == self.menuSelection then
            love.graphics.print("> " .. option, love.graphics.getWidth() / 2 - 40, yPos)
        else
            love.graphics.print(option, love.graphics.getWidth() / 2 - 40, yPos)
        end
    end
end

function Game:menuUp()
    self.menuSelection = self.menuSelection - 1
    if self.menuSelection < 1 then
        self.menuSelection = #self.menuOptions
    end
end

function Game:menuDown()
    self.menuSelection = self.menuSelection + 1
    if self.menuSelection > #self.menuOptions then
        self.menuSelection = 1
    end
end

function Game:menuSelect()
    local option = self.menuOptions[self.menuSelection]
    if option == "Start" then
        self:startGame()
    elseif option == "Instructions" then
        -- Display instructions (optional)
    elseif option == "Quit" then
        love.event.quit()
    end
end

function Game:checkCollision(obj1, obj2)
    local dx = obj1.x - obj2.x
    local dy = obj1.y - obj2.y
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < obj1.radius + obj2.radius
end

return Game
