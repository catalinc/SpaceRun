-- Enemy ship.

local physics = require("physics")
local sounds = require("libs.sounds")
local eachframe = require("libs.eachframe")
local sprites = require("engine.sprites")
local healthbar = require("engine.healthbar")
local laser = require("engine.laser")

local abs = math.abs
local HEIGHT = display.contentHeight

-- -----------------------------------------------------------------------------------
-- Public API
-- -----------------------------------------------------------------------------------

local M = {}

function M.new(group, x, y, options)
    options = options or {}

    local newEnemy = display.newImageRect(group, sprites, 4, 98, 79)
    newEnemy.yScale = -1
    newEnemy.x = x
    newEnemy.y = y
    newEnemy.points = options.points or 200
    newEnemy.maxHealth = options.maxHealth or 100
    newEnemy.health = newEnemy.maxHealth
    newEnemy.fireInterval = options.fireInterval or 500 -- Millis
    newEnemy.lastFireTime = 0
    newEnemy.target = options.target
    newEnemy.myName = "enemy" -- Used for collision detection

    physics.addBody(newEnemy, {radius = 30, isSensor = true})

    local showHealthBar = options.showHealthBar or false
    if showHealthBar then
        newEnemy.healthBar = healthbar.new(group, newEnemy.contentWidth - 10, 5)
    end

    local velocity = options.velocity or {x = 0, y = 0}
    newEnemy:setLinearVelocity(velocity.x, velocity.y)

    function newEnemy:eachFrame()
        if self.healthBar then
            self.healthBar.x = self.x - (self.contentWidth / 2) + 5
            self.healthBar.y = self.y - (self.contentHeight / 2) - 5
        end

        if not self.target then
            return
        end

        if not self.target.isBodyActive then
            return
        end

        if self.y < 50 then -- No need to fire laser because we are outside screen
            return
        end

        local now = eachframe.lastFrameTime
        local dx = abs(self.x - self.target.x)

        if now - self.lastFireTime > self.fireInterval and dx < 10 then
            self.lastFireTime = now
            sounds.play("fire")
            laser.fire(group, self.x, self.y,
                       {y = HEIGHT + 40, name="enemyLaser", duration = 2000, damage = 20})
        end
    end

    eachframe.add(newEnemy)

    function newEnemy:takeDamage(amount)
        self.health = self.health - amount

        if self.health < 0 then
            self.health = 0
        end

        if self.healthBar then
            self.healthBar:setHealth(self.health, self.maxHealth)
        end
    end

    function newEnemy:isDead()
        return self.health == 0
    end

    function newEnemy:finalize(event)
        if self.healthBar then
            display.remove(self.healthBar)
        end
        eachframe.remove(self)
    end

    newEnemy:addEventListener("finalize")

    return newEnemy
end

return M