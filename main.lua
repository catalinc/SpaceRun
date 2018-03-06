local composer = require("composer")
local Settings = require("libs.Settings")

math.randomseed(os.time())

display.setStatusBar(display.HiddenStatusBar)

local platform = system.getInfo('platformName')

-- Hide navigation bar and add support for back button on Android
if platform == 'Android' then
  native.setProperty('androidSystemUiVisibility', 'immersiveSticky')

  Runtime:addEventListener('key',
    function(event)
      if event.phase == 'down' and event.keyName == 'back' then
        local scene = composer.getScene(composer.getSceneName('current'))
        if scene then
          if type(scene.gotoPreviousScene) == 'function' then
            scene:gotoPreviousScene()
            return true
          elseif type(scene.gotoPreviousScene) == 'string' then
            composer.gotoScene(scene.gotoPreviousScene, {time = 500, effect = 'slideRight'})
            return true
          end
        end
      end
    end
  )
end

-- Set default background color
display.setDefault("background", 0.0353, 0.0902, 0.1608)

-- Set default settings
Settings(
  {
    isSoundOn = false,  -- TODO: all isXXXOn are temporarly disabled for development
    isMusicOn = false,
    isVibrateOn = true,
    currentLevel = 1,
    maxLevel = 2
  }
)

-- Automatically remove scenes from memory
composer.recycleOnSceneChange = true

-- Go to the menu screen
composer.gotoScene("scenes.Menu")
