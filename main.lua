-- Constants.lua
Constants = {
    SPAWN_DELAY = 2,
    POWERUP_DELAY = 5,
    POWERUP_TYPES = {"health", "score", "speed"},
    GAME_STATES = {
        MENU = "menu",
        PLAY = "play",
        PAUSE = "pause",
        GAME_OVER = "game_over"
    }
}

-- Player.lua
Player = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() - 50,
    radius = 20,
    speed = 200,
    lives = 3,
    score = 0,
    rotation = 0
}

function Player:new()
    local player = {}
    setmetatable(player, self)
    self.__index = self
    return player
end

function Player:update(dt, game)
    local dx = 0
    local dy = 0

    if love.keyboard.isDown("left") then
        dx = -self.speed
    elseif love.keyboard.isDown("right") then
        dx = self.speed
    end

    if love.keyboard.isDown("up") then
        dy = -self.speed
    elseif love.keyboard.isDown("down") then
        dy = self.speed
    end

    self.x = self.x + dx * dt
    self.y = self.y + dy * dt

    if self.x < 0 then
        self.x = 0
    elseif self.x > love.graphics.getWidth() then
        self.x = love.graphics.getWidth()
    end

    if self.y < 0 then
        self.y = 0
    elseif self.y > love.graphics.getHeight() then
        self.y = love.graphics.getHeight()
    end

    if love.keyboard.isDown("space") then
        local bullet = Bullet:new(self.x, self.y, self.rotation)
        table.insert(game.bullets, bullet)
    end
end

function Player:keypressed(key)
    if key == "r" then
        self:rotate()
    end
end

function Player:rotate()
    self.rotation = self.rotation + math.pi / 4
    if self.rotation >= 2 * math.pi then
        self.rotation = self.rotation - 2 * math.pi
    end
end

function Player:draw()
    love.graphics.setColor(255, 255, 255)
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.rotation)
    love.graphics.circle("fill", 0, 0, self.radius)
    love.graphics.pop()
end

-- Enemy.lua
Enemy = {
    radius = 10,
    speed = 100
}

function Enemy:new()
    local enemy = {
        x = love.graphics.getWidth() + self.radius,
        y = math.random(love.graphics.getHeight()),
        radius = self.radius,
        speed = self.speed
    }
    setmetatable(enemy, self)
    self.__index = self
    return enemy
end

function Enemy:update(dt)
    self.x = self.x - self.speed * dt
end

function Enemy:draw()
    love.graphics.setColor(255, 0, 0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- Bullet.lua
Bullet = {
    radius = 5,
    speed = 500
}

function Bullet:new(x, y, rotation)
    local bullet = {
        x = x,
        y = y,
        radius = self.radius,
        speed = self.speed,
        rotation = rotation
    }
    setmetatable(bullet, self)
    self.__index = self
    return bullet
end

function Bullet:update(dt)
    local dx = math.cos(self.rotation) * self.speed
    local dy = math.sin(self.rotation) * self.speed

    self.x = self.x + dx * dt
    self.y = self.y + dy * dt
end

function Bullet:draw()
    love.graphics.setColor(0, 255, 0)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- Powerup.lua
Powerup = {
    radius = 10,
    speed = 100
}

function Powerup:new(type)
    local powerup = {
        x = love.graphics.getWidth() + self.radius,
        y = math.random(love.graphics.getHeight()),
        radius = self.radius,
        speed = self.speed,
        type = type
    }
    setmetatable(powerup, self)
    self.__index = self
    return powerup
end

function Powerup:update(dt)
    self.x = self.x - self.speed * dt
end

function Powerup:draw()
    local color = {health = {255, 0, 0}, score = {0, 0, 255}, speed = {0, 255, 0}}
    love.graphics.setColor(unpack(color[self.type]))
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- Game.lua
Game = {
    gameState = Constants.GAME_STATES.MENU,
    spawnTimer = 0,
    powerupTimer = 0,
    player = nil,
    enemies = {},
    bullets = {},
    powerups = {},
    highscores = {}
}

function Game:new()
    local game = {}
    setmetatable(game, self)
    self.__index = self
    game.player = Player:new() -- Initialize player object

    return game
end

function Game:start()
    self.gameState = Constants.GAME_STATES.PLAY
    self.player = Player:new()
    self.enemies = {}
    self.bullets = {}
    self.powerups = {}
    self.spawnTimer = 0
    self.powerupTimer = 0
end

function Game:pause()
    if self.gameState == Constants.GAME_STATES.PLAY then
        self.gameState = Constants.GAME_STATES.PAUSE
    elseif self.gameState == Constants.GAME_STATES.PAUSE then
        self.gameState = Constants.GAME_STATES.PLAY
    end
end

function Game:update(dt)
    if self.gameState == Constants.GAME_STATES.PLAY then
        -- Update player
        self.player:update(dt, self)

        -- Update enemies
        for i, enemy in ipairs(self.enemies) do
            enemy:update(dt)

            -- Check collision with player
            local dx = enemy.x - self.player.x
            local dy = enemy.y - self.player.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < enemy.radius + self.player.radius then
                self.player.lives = self.player.lives - 1
                table.remove(self.enemies, i)
                if self.player.lives <= 0 then
                    self:gameOver()
                end
            end

            -- Check collision with bullets
            for j, bullet in ipairs(self.bullets) do
                local dx = enemy.x - bullet.x
                local dy = enemy.y - bullet.y
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance < enemy.radius + bullet.radius then
                    self.player.score = self.player.score + 10
                    table.remove(self.enemies, i)
                    table.remove(self.bullets, j)
                    break
                end
            end
        end

        -- Update bullets
        for i, bullet in ipairs(self.bullets) do
            bullet:update(dt)

            -- Remove bullets that are off-screen
            if bullet.x < 0 or bullet.x > love.graphics.getWidth() or bullet.y < 0 or bullet.y > love.graphics.getHeight() then
                table.remove(self.bullets, i)
            end
        end

        -- Update powerups
        for i, powerup in ipairs(self.powerups) do
            powerup:update(dt)

            -- Check collision with player
            local dx = powerup.x - self.player.x
            local dy = powerup.y - self.player.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < powerup.radius + self.player.radius then
                self:applyPowerup(powerup.type)
                table.remove(self.powerups, i)
            end
        end

        -- Spawn enemies
        self.spawnTimer = self.spawnTimer + dt
        if self.spawnTimer >= Constants.SPAWN_DELAY then
            self:spawnEnemy()
            self.spawnTimer = 0
        end

        -- Spawn powerups
        self.powerupTimer = self.powerupTimer + dt
        if self.powerupTimer >= Constants.POWERUP_DELAY then
            self:spawnPowerup()
            self.powerupTimer = 0
        end
    end
end

function Game:draw()
    -- Draw player
    self.player:draw()

    -- Draw enemies
    for _, enemy in ipairs(self.enemies) do
        enemy:draw()
    end

    -- Draw bullets
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end

    -- Draw powerups
    for _, powerup in ipairs(self.powerups) do
        powerup:draw()
    end

    -- Draw UI
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("Lives: " .. self.player.lives, 10, 10)
    love.graphics.print("Score: " .. self.player.score, 10, 30)

    -- Draw game over screen
    if self.gameState == Constants.GAME_STATES.GAME_OVER then
        love.graphics.setColor(255, 0, 0)
        love.graphics.print("GAME OVER", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 - 10)
        love.graphics.print("Press Enter to play again", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 10)

        -- Draw high scores
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("High Scores:", love.graphics.getWidth() / 2 - 40, love.graphics.getHeight() / 2 + 50)
        local yPos = love.graphics.getHeight() / 2 + 70
        for i, score in ipairs(self.highscores) do
            love.graphics.print(i .. ". " .. score, love.graphics.getWidth() / 2 - 20, yPos)
            yPos = yPos + 20
        end
    end

    -- Draw pause screen
    if self.gameState == Constants.GAME_STATES.PAUSE then
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("PAUSED", love.graphics.getWidth() / 2 - 30, love.graphics.getHeight() / 2 - 10)
    end
end

function Game:spawnEnemy()
    local enemy = Enemy:new()
    table.insert(self.enemies, enemy)
end

function Game:spawnPowerup()
    local type = Constants.POWERUP_TYPES[math.random(#Constants.POWERUP_TYPES)]
    local powerup = Powerup:new(type)
    table.insert(self.powerups, powerup)
end

function Game:applyPowerup(type)
    if type == "health" then
        self.player.lives = self.player.lives + 1
    elseif type == "score" then
        self.player.score = self.player.score + 100
    elseif type == "speed" then
        self.player.speed = self.player.speed + 50
    end
end

function Game:keypressed(key)
    if key == "space" and self.gameState == Constants.GAME_STATES.MENU then
        self:start()
    elseif key == "escape" then
        self:pause()
    elseif key == "return" and self.gameState == Constants.GAME_STATES.GAME_OVER then
        self:start()
    end

    if self.gameState == Constants.GAME_STATES.PLAY then
        self.player:keypressed(key)
    end
end

function Game:gameOver()
    self.gameState = Constants.GAME_STATES.GAME_OVER
    table.insert(self.highscores, self.player.score)
    table.sort(self.highscores, function(a, b) return a > b end)
    if #self.highscores > 5 then
        table.remove(self.highscores, 6)
    end
end

-- main.lua
function love.load()
    game = Game:new()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keypressed(key)
end
