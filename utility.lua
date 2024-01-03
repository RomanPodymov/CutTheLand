local composer = require("composer")
local widget = require("widget")
local GBCLanguageCabinet = require("plugin.GBCLanguageCabinet")
local GBCDataCabinet = require("plugin.GBCDataCabinet")

M = {}
M.BUTTON_WIDTH = display.contentWidth/2.8
M.BUTTON_HEIGHT = M.BUTTON_WIDTH/3.1

local BACKGROUND_COLOR_FILL_R = 0.8
local BACKGROUND_COLOR_FILL_G = 0.8
local BACKGROUND_COLOR_FILL_B = 0.8

function M.getCurrentLanguage()
    local allLangs = GBCLanguageCabinet.getLanguages()
    local currentLang = GBCLanguageCabinet.getDeviceLanguage()
    for i = 1, #allLangs do
        if (currentLang == allLangs[i]["key"]) then
            return currentLang
        end
    end
    return "en"
end

function M.createBackground()
    local background = display.newRect(0, 0, display.contentWidth, display.contentHeight)
    background:setFillColor(BACKGROUND_COLOR_FILL_R, BACKGROUND_COLOR_FILL_G, BACKGROUND_COLOR_FILL_B)
    return background
end

function M.createButton(buttonId, buttonTextKey, handleButtonEvent)
	local buttonText = GBCLanguageCabinet.getText(buttonTextKey, M.getCurrentLanguage())
    return widget.newButton({
        id = buttonId,
        label = buttonText,
        onEvent = handleButtonEvent,
        emboss = false,
        shape = "roundedRect",
        width = M.BUTTON_WIDTH,
        height = M.BUTTON_HEIGHT,
        font = native.systemFont,
        labelColor = {default = {1, 1, 1}, over = {0, 0, 0, 0.0}},
        fontSize = M.BUTTON_HEIGHT/2.5,
        cornerRadius = 12,
        fillColor = {default = M.buttonFillColorDefault(), over = M.buttonFillColorOver()},
        strokeColor = {default = M.buttonStrokeColorDefault(), over = M.buttonStrokeColorOver()},
        strokeWidth = 3
    }
)
end

function M.buttonFillColorDefault()
	return {0xFF/255.0, 0x89/255.0, 0x00/255.0, 1}
end

function M.buttonFillColorOver()
	return {0xA6/255.0, 0x59/255.0, 0x00/255.0, 0.7}
end

function M.buttonStrokeColorDefault()
	return {0xA6/255.0, 0x59/255.0, 0x00/255.0, 1}
end

function M.buttonStrokeColorOver()
	return {0xFF/255.0, 0xBE/255.0, 0x73/255.0, 0.7}
end

function M.transitionParams()
    return {effect = "crossFade", time = 500}
end

function M.databaseName()
	return "DatabaseCutTheLand"
end

function M.databaseFieldLevelName()
	return "availableLevel"
end

function M.getUserLevel()
	local availableLevelsForUser = GBCDataCabinet.get(M.databaseName(), M.databaseFieldLevelName())
    if (not availableLevelsForUser) then
    	availableLevelsForUser = 1
    	GBCDataCabinet.set(M.databaseName(), M.databaseFieldLevelName(), availableLevelsForUser)
    	GBCDataCabinet.save(M.databaseName())
    end
    return availableLevelsForUser
end

function M.removeAllScenes()
    -- composer.removeScene("menu")
    -- composer.removeScene("levelselect")
    -- composer.removeScene("help")
    -- composer.removeScene("game")
    -- composer.removeScene("gameover")
    -- composer.removeScene("nextlevel")
end

function M.goToScene(sceneName, additionalParams)
    M.removeAllScenes()
    local transitionParams = M.transitionParams()
    transitionParams.params = transitionParams.params or {}
    for k,v in pairs(additionalParams or {}) do transitionParams.params[k] = v end
    composer.gotoScene(sceneName, transitionParams)
end

return M