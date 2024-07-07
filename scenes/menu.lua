local composer = require("composer")
local widget = require("widget")
local GBCLanguageCabinet = require("plugin.GBCLanguageCabinet")
local utility = require("utility")

local scene = composer.newScene()
 
local function handlePlayButtonEvent(event)
    if (event.phase == "ended") then
        utility.goToScene("scenes.levelselect")
    end
end

local function handleHelpButtonEvent(event)
    if (event.phase == "ended") then
        utility.goToScene("scenes.help")
    end
end

function scene:create(event)
    local sceneGroup = self.view

    sceneGroup:insert(utility.createBackground())

    local title = display.newText("Cut the Land", 100, 32, native.systemFontBold, 32)
    title.x = display.contentCenterX
    title.y = 40
    title:setFillColor(0)
    sceneGroup:insert(title)
    
    local playButton = utility.createButton("button1", "NEW_GAME", handlePlayButtonEvent)
    playButton.x = display.contentCenterX
    playButton.y = display.contentCenterY - utility.BUTTON_HEIGHT * 0.6
    sceneGroup:insert(playButton)

    local helpButton = utility.createButton("button2", "HELP", handleHelpButtonEvent)
    helpButton.x = display.contentCenterX
    helpButton.y = display.contentCenterY + utility.BUTTON_HEIGHT * 0.6
    sceneGroup:insert(helpButton)
end

scene:addEventListener("create", scene)
return scene