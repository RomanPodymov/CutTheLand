local composer = require("composer")
local widget = require("widget")
local stages = require("gameplay.stages")
local GBCLanguageCabinet = require ("plugin.GBCLanguageCabinet")
local GBCDataCabinet = require("plugin.GBCDataCabinet")
local utility = require("utility")

local scene = composer.newScene()
local levelsPerLine = 6
local levelButtonWidth = 42
local levelButtonHeight = 32
local levelButtonHorizSpace = 10
local levelButtonVerticSpace = 10

local function handleButtonEvent(event)
    if (event.phase == "ended") then
        utility.goToScene("scenes.menu")
    end
end

local function handleLevelSelect(event)
    if (event.phase == "ended") then
    	local buttonId = event.target.id
        utility.goToScene("scenes.game", {selectedLevel = buttonId})
    end
end

function scene:create(event)
    local sceneGroup = self.view
 
    sceneGroup:insert(utility.createBackground())

    local selectLevelText = display.newText(GBCLanguageCabinet.getText("SELECT_LEVEL", utility.getCurrentLanguage()), 125, 32, native.systemFontBold, 32)
    selectLevelText:setFillColor(0)
    selectLevelText.x = display.contentCenterX
    selectLevelText.y = 40
    sceneGroup:insert(selectLevelText)

    local avaliableLevelsForUser = utility.getUserLevel()

    local x = 0
    local y = 0
    local buttons = {}
    local buttonBackgrounds = {}
    local buttonGroups = {}
    local levelSelectGroup = display.newGroup()
    local cnt = 1
    for i = 1, stages.getStagesCount() do
        buttonGroups[i] = display.newGroup()
        buttonBackgrounds[i] = display.newRoundedRect( x, y, levelButtonWidth, levelButtonHeight, 8 )
        buttonBackgrounds[i]:setFillColor(utility.buttonFillColorDefault()[1], 
        								  utility.buttonFillColorDefault()[2], 
        								  utility.buttonFillColorDefault()[3], 
        								  utility.buttonFillColorDefault()[4])
        buttonBackgrounds[i]:setStrokeColor(utility.buttonStrokeColorDefault()[1], 
        	                                utility.buttonStrokeColorDefault()[2], 
        	                                utility.buttonStrokeColorDefault()[3], 
        	                                utility.buttonStrokeColorDefault()[4])
        buttonBackgrounds[i].strokeWidth = 1
        buttonGroups[i]:insert(buttonBackgrounds[i])
        buttonGroups[i].id = i
        
        if i <= avaliableLevelsForUser then
            buttonGroups[i].alpha = 1.0
            buttonGroups[i]:addEventListener("touch", handleLevelSelect)
        else
            buttonGroups[i].alpha = 0.5
        end
        buttons[i] = display.newText(tostring(i), 0, 0, native.systemFontBold, 28)
        buttons[i].x = x
        buttons[i].y = y
        buttonGroups[i]:insert(buttons[i])

        x = x + levelButtonWidth + levelButtonHorizSpace
        cnt = cnt + 1
        if cnt > levelsPerLine then
            cnt = 1
            x = 0
            y = y + levelButtonHeight + levelButtonVerticSpace
        end
        levelSelectGroup:insert(buttonGroups[i])
    end
    sceneGroup:insert(levelSelectGroup)
    levelSelectGroup.x = display.contentCenterX - (levelsPerLine * levelButtonWidth)/2.0 - (levelsPerLine - 1 * levelButtonHorizSpace)/2.0
    levelSelectGroup.y = 110

    local doneButton = utility.createButton("button1", "BACK", handleButtonEvent)
    doneButton.x = display.contentCenterX
    doneButton.y = display.contentHeight - utility.BUTTON_HEIGHT * 0.7
    sceneGroup:insert(doneButton)
end

scene:addEventListener("create", scene)
return scene
