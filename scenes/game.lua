
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require("physics")
local eachframe = require("libs.eachframe")
local sounds = require("libs.sounds")
local sprites = require("engine.sprites")
local player = require("engine.player")
local asteroids = require("engine.asteroids")
local background = require("engine.background")

local score = 0

local gameLoopTimer
local livesText
local scoreText
local ship

local backGroup
local mainGroup
local uiGroup

physics.start()
physics.setGravity( 0, 0 )

local function updateText()
	livesText.text = "Lives: " .. ship.lives
	scoreText.text = "Score: " .. score
end

local function gameLoop()
	asteroids.newAsteroid(mainGroup)
	asteroids.removeOffScreen()
end

local function endGame()
	asteroids.removeAll()

	composer.setVariable( "finalScore", score )
	composer.removeScene( "scenes.highscores" )
	composer.gotoScene( "scenes.highscores", { time=800, effect="crossFade" } )
end

local function onCollision( event )

	if ( event.phase == "began" ) then

		local obj1 = event.object1
		local obj2 = event.object2

		if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
			 ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
		then
			-- Remove the laser
			if obj1.myName == "laser" then display.remove( obj1 ) end
			if obj2.myName == "laser" then display.remove( obj2 ) end

			if obj1.myName == "asteroid" then asteroids.remove( obj1 ) end
			if obj2.myName == "asteroid" then asteroids.remove( obj2 ) end

			-- Increase score
			score = score + 100
			scoreText.text = "Score: " .. score

		elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
				 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
		then
			if ( ship:isAlive() ) then
				ship:die()

				livesText.text = "Lives: " .. ship.lives

				if ( ship:isDead() ) then
					display.remove( ship )
					timer.performWithDelay( 2000, endGame )
				else
					timer.performWithDelay( 1000, function () ship:restore() end )
				end
			end
		end
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )
  -- Code here runs when the scene is first created but has not yet appeared on screen

	local sceneGroup = self.view

	physics.pause()

	-- Set up display groups

	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert(backGroup)

	mainGroup = display.newGroup()  -- Display group for the ship, asteroids, lasers, etc.
	sceneGroup:insert(mainGroup)

	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert(uiGroup)

  background.init(backGroup)
  ship = player.newShip(mainGroup)

	livesText = display.newText( uiGroup, "Lives: " .. ship.lives, 200, 80, native.systemFont, 36 )
	scoreText = display.newText( uiGroup, "Score: " .. score, 400, 80, native.systemFont, 36 )
end

-- show()
function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
		Runtime:addEventListener( "collision", onCollision )
		gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )
    background.start()
		sounds.playStream( "gameMusic" )
	end
end

-- hide()
function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )
	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
    background.stop()
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		-- Stop the music!
		sounds.stop()
	end
end

-- destroy()
function scene:destroy( event )
  -- Code here runs prior to the removal of scene's view
	local sceneGroup = self.view

	sounds.dispose( "explosion" )
	sounds.dispose( "fire" )
	sounds.dispose( "gameMusic" )
end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
