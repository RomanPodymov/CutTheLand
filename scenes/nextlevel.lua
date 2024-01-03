local composer = require("composer")
local widget = require("widget")
local GBCDataCabinet = require("plugin.GBCDataCabinet")
local GBCLanguageCabinet = require ("plugin.GBCLanguageCabinet")
local utility = require("utility")
local stages = require("gameplay.stages")

local scene = composer.newScene() 
local nextLevelText
local nextLevel

local function handleButtonEvent(event)
    if (event.phase == "ended") then
        utility.goToScene("scenes.game", {selectedLevel = nextLevel})
    end
end

function scene:create(event)
    local sceneGroup = self.view

    selectedLevel = event.params.selectedLevelKey
        
    local background = display.newRect(0, 0, 570, 360)
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    local wooHooOptions = {text = GBCLanguageCabinet.getText("CONGRATULATIONS", utility.getCurrentLanguage()), fontSize = 42, font = native.systemFontBold, align = "center"}

    local wooHooText = display.newText(wooHooOptions)
    wooHooText.x = display.contentCenterX 
    wooHooText.y = 40
    wooHooText:setFillColor(0)
    sceneGroup:insert(wooHooText)

    nextLevel = selectedLevel + 1
    if (nextLevel > stages.getStagesCount()) then
        nextLevel = stages.getStagesCount()
    else
        GBCDataCabinet.set(M.databaseName(), M.databaseFieldLevelName(), nextLevel)
        GBCDataCabinet.save(M.databaseName())
    end
    nextLevelText = display.newText(GBCLanguageCabinet.getText("NEXT_LEVEL_TEXT", utility.getCurrentLanguage()) .. nextLevel, display.contentCenterX, display.contentCenterY, native.systemFontBold, 48)
    nextLevelText:setFillColor(0)
    sceneGroup:insert(nextLevelText)

    local doneButton = utility.createButton("button1", "NEXT_LEVEL", handleButtonEvent)
    doneButton.x = display.contentCenterX 
    doneButton.y = display.contentHeight - utility.BUTTON_HEIGHT * 0.7
    sceneGroup:insert(doneButton)
end

scene:addEventListener("create", scene)
return scene
