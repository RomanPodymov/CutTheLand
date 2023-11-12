local composer = require("composer")
local widget = require("widget")
local GBCLanguageCabinet = require("plugin.GBCLanguageCabinet")
local utility = require("utility")

local scene = composer.newScene() 

local function handleButtonEvent(event)
    if (event.phase == "ended") then
        utility.goToScene("menu")
    end
    return true
end

function scene:create( event )
    local sceneGroup = self.view
        
    local background = utility.createBackground()
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)

    local title = display.newText("Cut the Land", 125, 32, native.systemFontBold, 32)
    title.x = display.contentCenterX
    title.y = 40
    title:setFillColor(0)
    sceneGroup:insert(title)

    local doneButton = utility.createButton("button1", "DONE", handleButtonEvent)
    doneButton.x = display.contentCenterX
    doneButton.y = display.contentHeight - utility.BUTTON_HEIGHT * 0.7
    sceneGroup:insert(doneButton)

    local scrollViewText = widget.newScrollView({width = background.width - 100, 
                                                 height = background.height - 200,
                                                 friction = 1.0,
                                                 horizontalScrollDisabled = true,
                                                 verticalScrollDisabled = false,
                                                 isBounceEnabled = true,
                                                 x = display.contentCenterX, 
                                                 y = display.contentCenterY, 
                                                 leftPadding = 0,
                                                 topPadding = 10,
                                                 rightPadding = 0,
                                                 bottomPadding = 10,
                                                 backgroundColor = {1.0, 1.0, 1.0, 1.0}})
    local optionsHelpText = {
        text = GBCLanguageCabinet.getText("HELP_TEXT", M.getCurrentLanguage()),
        x = scrollViewText.width/2.0,
        width = scrollViewText.width - 20,
        font = native.systemFont,
        labelColor = {default={0, 1, 1}, over={0, 0, 0, 0.5}},
        fontSize = 18
    }
    local helpText = display.newText(optionsHelpText)
    helpText:setFillColor(0)
    helpText.y = helpText.height/2.0

    scrollViewText:insert(helpText)
    sceneGroup:insert(scrollViewText)
end

scene:addEventListener("create", scene)
return scene