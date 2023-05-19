local Constants = {
    PLAYER_SPEED = 400,
    PLAYER_RADIUS = 20,
    PLAYER_LIVES = 3,
    PLAYER_SHOOT_DELAY = 0.5,

    SPAWN_DELAY = 1.5,

    POWERUP_DELAY = 5,
    POWERUP_TYPES = {
        LIFE = "life",
        SPEED = "speed",
        SHOT_SPEED = "shot_speed"
    },
    POWERUP_SPEED_MULTIPLIER = 1.5,
    POWERUP_SHOT_SPEED_MULTIPLIER = 0.5,

    GAME_STATES = {
        MENU = "menu",
        PLAY = "play",
        GAME_OVER = "game_over"
    }
}

-- Font settings
Constants.FONT_SMALL = love.graphics.newFont(12)
Constants.FONT_MEDIUM = love.graphics.newFont(24)
Constants.FONT_LARGE = love.graphics.newFont(36)

return Constants
