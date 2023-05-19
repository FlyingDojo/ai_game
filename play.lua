local constants = require("constants")
local play = {}
local player = {
    x = love.graphics.getWidth() / 2,
    y = love.graphics.getHeight() / 2,
    radius = 25,
    speed = 200,
    color = {0, 255, 0}
}

local bullets = {}
local enemies = {}

math.randomseed(os.time())

function updatePlayer(dt)
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end

    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed * dt
    elseif love.keyboard.isDown("down") then
        player.y = player.y + player.speed * dt
    end

    -- keep the player within the screen bounds
    if player.x < player.radius then
        player.x = player.radius
    elseif player.x > love.graphics.getWidth() - player.radius then
        player.x = love.graphics.getWidth() - player.radius
    end

    if player.y < player.radius then
        player.y = player.radius
    elseif player.y > love.graphics.getHeight() - player.radius then
        player.y = love.graphics.getHeight() - player.radius
    end
end

function updateBullets(dt)
    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        bullet.y = bullet.y - constants.BULLET_SPEED * dt
        if bullet.y < 0 then
            table.remove(bullets, i)
        else
            for j = #enemies, 1, -1 do
                local enemy = enemies[j]
                if checkCollision(enemy, bullet) then
                    enemy.flashTime = constants.ENEMY_FLASH_TIME
                    table.remove(bullets, i)
                    break
                end
            end
        end
    end
end

function updateEnemies(dt)
    for i = #enemies, 1, -1 do
        local enemy = enemies[i]
        enemy.y = enemy.y + enemy.speed * dt
        if enemy.y > love.graphics.getHeight() then
            table.remove(enemies, i)
        else
            if checkCollision(enemy, player) then
                gameState = constants.GAME_STATES.PAUSE
            end
            if enemy.flashTime > 0 then
                enemy.flashTime = enemy.flashTime - dt
            end
        end
    end

    -- spawn a new enemy randomly
    if math.random(1 / dt) < 1 then
        local enemy = {}
        enemy.x = math.random(love.graphics.getWidth() - constants.ENEMY_WIDTH)
        enemy.y = -constants.ENEMY_HEIGHT
        enemy.speed = math.random(50, 150)
        enemy.radius = constants.ENEMY_WIDTH / 2
        enemy.color = constants.ENEMY_COLOR
        enemy.flashColor = constants.ENEMY_FLASH_COLOR
        enemy.flashTime = 0
        table.insert(enemies, enemy)
    end
end

function checkCollision(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local distance

    if a.radius ~= nil then
        -- a is a circle
        distance = math.sqrt(dx * dx + dy * dy)
        return distance < a.radius + b.radius
    else
        -- a is a rectangle
        local width = a.width or 0
        local height = a.height or 0
        return dx < width / 2 and dx > -width / 2 and dy < height / 2 and dy > -height / 2
    end
end

function play.update(dt)
    updatePlayer(dt)
    updateBullets(dt)
    updateEnemies(dt)

    if love.keyboard.isDown("space") then
        local bullet = {}
        bullet.x = player.x
        bullet.y = player.y - player.radius - constants.BULLET_HEIGHT / 2
        bullet.width = constants.BULLET_WIDTH
        bullet.height = constants.BULLET_HEIGHT
        bullet.color = constants.BULLET_COLOR
        table.insert(bullets, bullet)
    end
end

function play.draw()
    -- draw player
    love.graphics.setColor(player.color)
    love.graphics.circle("fill", player.x, player.y, player.radius)

    -- draw bullets
    love.graphics.setColor(constants.BULLET_COLOR)
    for i, bullet in ipairs(bullets) do
        love.graphics.rectangle("fill", bullet.x - bullet.width / 2, bullet.y, bullet.width, bullet.height)
    end

    -- draw enemies
    for i, enemy in ipairs(enemies) do
        if enemy.flashTime > 0 then
            love.graphics.setColor(enemy.flashColor)
        else
            love.graphics.setColor(enemy.color)
        end
        love.graphics.rectangle("fill", enemy.x - enemy.radius, enemy.y - enemy.radius, constants.ENEMY_WIDTH, constants.ENEMY_HEIGHT)
    end
end

function play.keypressed(key)
    -- do nothing
end

return play
