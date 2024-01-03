local composer = require("composer")
local widget = require("widget")
local json = require("json")
local background = require("gameplay.background")
local GBCLanguageCabinet = require("plugin.GBCLanguageCabinet")
local utility = require("utility")

local scene = composer.newScene()
local backgroundScene
local currentPlayers
local currentPlayersDisplay
local currentPlayersDisplayLabel
local currentScore     
local currentScoreDisplay
local currentScoreDisplayLabel  
local levelText          
local updateEntitiesTimer    
local updateEntitiesTimerInterval = 1000
local completeProgress = 1
local selectedLevel

local function onBackBtnPressed(event)
    if event.phase == "ended" then
        utility.goToScene("levelSelect")
    end
    return true
end

local function handleWin()
    utility.goToScene("nextLevel", {selectedLevelKey = selectedLevel})
end

local function handleLoss()
    utility.goToScene("gameover")
end

local function updateEntities( )
    backgroundScene.onMove()
end

function scene:create(event)
    local sceneGroup = self.view
    selectedLevel = event.params.selectedLevel

    local backgroundView = utility.createBackground()
    backgroundView.x = display.contentCenterX
    backgroundView.y = display.contentCenterY
    backgroundView:addEventListener("touch", handleSwipe)
    sceneGroup:insert(backgroundView)

    levelText = display.newText(selectedLevel, 0, 0, native.systemFontBold, 60)
    levelText:setFillColor(1000)
    levelText.x = display.contentCenterX
    levelText.y = display.contentCenterY
    sceneGroup:insert(levelText)

    local backBtn = widget.newButton({
        label = GBCLanguageCabinet.getText("BACK", utility.getCurrentLanguage()),
        onEvent = onBackBtnPressed
    })
    sceneGroup:insert(backBtn)
    backBtn.x = 50
    backBtn.y = 20

    currentScoreDisplayLabel = display.newText(GBCLanguageCabinet.getText("PROGRESS", utility.getCurrentLanguage()), 120, 20, native.systemFont, 16)
    currentScoreDisplayLabel:setFillColor(0.0, 0.0, 0.0)
    sceneGroup:insert(currentScoreDisplayLabel)
    currentScoreDisplay = display.newText("0%", 120, 42, native.systemFont, 16)
    currentScoreDisplay:setFillColor(0.0, 0.0, 0.0)
    sceneGroup:insert(currentScoreDisplay)

    currentPlayersDisplayLabel = display.newText(GBCLanguageCabinet.getText("PLAYERS", utility.getCurrentLanguage()), 200, 20, native.systemFont, 16)
    currentPlayersDisplayLabel:setFillColor(0.0, 0.0, 0.0)
    sceneGroup:insert(currentPlayersDisplayLabel)
    currentPlayersDisplay = display.newText("0", 200, 42, native.systemFont, 16)
    currentPlayersDisplay:setFillColor(0.0, 0.0, 0.0)
    sceneGroup:insert(currentPlayersDisplay)

    backgroundScene = Background(display.contentCenterX, 
                                 display.contentCenterY, 
                                 display.contentWidth - 40, 
                                 display.contentHeight - 40)
    backgroundScene.create(sceneGroup, updateEntitiesTimerInterval, selectedLevel)

    updateEntitiesTimer = timer.performWithDelay( updateEntitiesTimerInterval, updateEntities, -1)
    currentScore = 0
    currentScoreDisplay.text = string.format("%00d%%", currentScore)
    currentPlayers = 3
    currentPlayersDisplay.text = string.format("%d", currentPlayers)
    Runtime:addEventListener("progressChanged", onProgressChanged)
    Runtime:addEventListener("playerWasContactedWithEnemy", onPlayerWasContactedWithEnemy)
end

function handleSwipe( event )
    if (event.phase == "moved") then
        local dX = event.x - event.xStart
        local dY = event.y - event.yStart
        if ( dX > 10 ) then
            backgroundScene.onSwipeRight()
        elseif ( dX < -10 ) then
            backgroundScene.onSwipeLeft()
        elseif ( dY < -10) then
            backgroundScene.onSwipeTop()
        elseif ( dY > 10) then
            backgroundScene.onSwipeBottom()
        end
    end
    return true
end

function scene:show( event )
    local sceneGroup = self.view
    if event.phase == "did" then
        transition.to(levelText, {time = 500, alpha = 0})
    else

    end
end

function onProgressChanged (event)
    currentScore = event.progress
    currentScoreDisplay.text = string.format("%00d%%", currentScore)
    if (currentScore > completeProgress) then
        handleWin()
    end
end 

function onPlayerWasContactedWithEnemy(event)
    currentPlayers = currentPlayers - 1
    currentPlayersDisplay.text = string.format("%d", currentPlayers )
    stopEvents()
    if (currentPlayers == 0) then
        handleLoss()
    else
        backgroundScene.restartLevel(selectedLevel)
        timer.cancel( updateEntitiesTimer )
        updateEntitiesTimer = timer.performWithDelay(updateEntitiesTimerInterval, updateEntities, -1)
    end
end

function stopEvents()
    timer.cancel(updateEntitiesTimer)
    backgroundScene.destroyObject()
end

function scene:destroy( event )
    Runtime:removeEventListener("progressChanged", onProgressChanged)
    Runtime:removeEventListener("playerWasContactedWithEnemy", onPlayerWasContactedWithEnemy)
    stopEvents()
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("destroy", scene)
return scene
