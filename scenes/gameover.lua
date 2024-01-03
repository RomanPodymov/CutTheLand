local composer = require("composer")
local widget = require("widget")
local json = require("json")
local GBCLanguageCabinet = require("plugin.GBCLanguageCabinet")
local utility = require("utility")

local scene = composer.newScene()
local newHighScore = false

local function handleButtonEvent(event)
    if (event.phase == "ended") then
        utility.goToScene("scenes.menu")
    end
    return true
end

function scene:create(event)
    local sceneGroup = self.view

    sceneGroup:insert(utility.createBackground())

    local gameOverText = display.newText(GBCLanguageCabinet.getText("GAME_OVER", utility.getCurrentLanguage()), 0, 0, native.systemFontBold, 32)
    gameOverText:setFillColor(0)
    gameOverText.x = display.contentCenterX
    gameOverText.y = 50
    sceneGroup:insert(gameOverText)

    local doneButton = utility.createButton("button1", "BACK", handleButtonEvent)
    doneButton.x = display.contentCenterX
    doneButton.y = display.contentHeight - utility.BUTTON_HEIGHT * 0.7
    sceneGroup:insert(doneButton)
end

scene:addEventListener("create", scene)
return scene
