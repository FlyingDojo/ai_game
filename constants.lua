local constants = {}

constants.SCREEN_WIDTH = 800
constants.SCREEN_HEIGHT = 600

constants.GAME_STATES = {
    MENU = 0,
    PLAY = 1,
    PAUSE = 2
}

constants.BACKGROUND_COLOR = {0, 0, 0}

constants.BULLET_WIDTH = 5
constants.BULLET_HEIGHT = 10
constants.BULLET_COLOR = {255, 255, 255}
constants.BULLET_SPEED = 500

constants.ENEMY_WIDTH = 30
constants.ENEMY_HEIGHT = 30
constants.ENEMY_COLOR = {255, 255, 255}
constants.ENEMY_FLASH_COLOR = {255, 0, 0}
constants.ENEMY_FLASH_TIME = 0.1
constants.ENEMY_SPAWN_RATE = 2 -- Adjust this value to change how frequently enemies spawn

return constants
