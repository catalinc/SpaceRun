-- The bad guys

local physics = require("physics")
local composer = require("composer")
local sounds = require("libs.sounds")
local eachframe = require("libs.eachframe")
local sprites = require("engine.sprites")

local M = {}

function M.new(sceneGroup, playerShip)
  local group = sceneGroup or display.currentStage

  local newEnemy = display.newImageRect(group, sprites, 4, 98, 79)
  newEnemy.yScale = -1
  newEnemy.myName = "enemy" -- Used for collision detection

  physics.addBody(newEnemy, { radius = 30, isSensor = true })

  local lane = math.random(display.contentWidth / newEnemy.contentWidth)
  newEnemy.y = -100
  newEnemy.x = lane * newEnemy.contentWidth

  newEnemy:setLinearVelocity(math.random(-40, 40), math.random(40, 120))

  newEnemy.lastFireTime = 0

  function newEnemy:eachFrame()
    if self.y < 50 then return end -- No need to fire laser because we are outside screen

    if playerShip.isExploding then return end

    local now = eachframe.lastFrameTime
    local dx = math.abs(self.x - playerShip.x)

    if now - self.lastFireTime > 500 and dx < 10 then
      self.lastFireTime = now
      self:fireLaser()
    end
  end

  function newEnemy:fireLaser()
    sounds.play("fire")

    local newLaser = display.newImageRect(group, sprites, 5, 14, 40)
    newLaser.isBullet = true
    newLaser.myName = "enemyLaser"
    newLaser.x = self.x
    newLaser.y = self.y

    newLaser:toBack()
    physics.addBody(newLaser, "dynamic", { isSensor = true })

    transition.to(newLaser, {y=display.contentHeight + 40, time=2000,
        onComplete = function() display.remove(newLaser) end
    })
  end

  eachframe.add(newEnemy)

  function newEnemy:finalize(event)
    eachframe.remove(self)
  end

  newEnemy:addEventListener("finalize")

  return newEnemy
end

return M