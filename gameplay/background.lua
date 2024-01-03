local display = require("display")
local player = require("gameplay.player")
local enemy = require("gameplay.enemy")
local waterenemy = require("gameplay.waterenemy")
local stages = require("gameplay.stages")

local BACKGROUND_COLOR_FILL_R = 0x3C/255.0
local BACKGROUND_COLOR_FILL_G = 0xA0/255.0
local BACKGROUND_COLOR_FILL_B = 0xD0/255.0

local BACKGROUND_COLOR_CURRENTLY_ACTIVE_R = 0.9
local BACKGROUND_COLOR_CURRENTLY_ACTIVE_G = 0.1
local BACKGROUND_COLOR_CURRENTLY_ACTIVE_B = 0.1

local BACKGROUND_COLOR_EMPTY_R = 0.0
local BACKGROUND_COLOR_EMPTY_G = 0.0
local BACKGROUND_COLOR_EMPTY_B = 0.0

function Background(_centerX, _centerY, _width, _height)
	local self = {
	}

	local centerX = _centerX
    local centerY = _centerY
    local width = _width
    local height = _height
    local field = {}
    local part_size = 0
    local enteties = {}
    local rects = {}
    local group = nil
    local timeInterval = 0
    local handleEnts = true

    function self.create(sceneGroup, eventsTimeInterval, stageNumber)
    	self.createScene(sceneGroup, eventsTimeInterval, true, stageNumber)
	end

    function self.createEntity(startY, startX, sceneGroup, eventsTimeInterval, stageNumber, entityClass)
        local currentStage = stages.getStage(stageNumber)
        local p = entityClass()
        p.createEntity(centerX - width/2.0 + startX * part_size - part_size/2.0,
                       centerY + height/2.0 + startY * part_size - part_size/2.0 - (part_size * #currentStage),
                       startY,
                       startX,
                       part_size,
                       self,
                       eventsTimeInterval)
        table.insert(enteties, p)
        return p
    end

    function self.createPlayer(startY, startX, sceneGroup, eventsTimeInterval, stageNumber)
        return self.createEntity(startY, startX, sceneGroup, eventsTimeInterval, stageNumber, Player)
    end

    function self.createEnemy(startY, startX, sceneGroup, eventsTimeInterval, stageNumber)
        return self.createEntity(startY, startX, sceneGroup, eventsTimeInterval, stageNumber, Enemy)
    end
    
    function self.createWaterEnemy(startY, startX, sceneGroup, eventsTimeInterval, stageNumber)
        return self.createEntity(startY, startX, sceneGroup, eventsTimeInterval, stageNumber, WaterEnemy)
    end

    function self.printBackground()
        local result = ""
        table.foreach(field,
                      function(k,v)
                          table.foreach(v,
                                        function(kInner, vInner)
                                            result = result .. vInner .. " "
                                        end)
                          result = result .. "\n"
                      end)
        print(result)
    end

    function self.printField(fieldToPrint)
        local result = ""
        table.foreach(fieldToPrint,
                      function(k,v)
                          table.foreach(v,
                                        function(kInner, vInner)
                                            result = result .. vInner .. " "
                                        end)
                          result = result .. "\n"
                      end)
        print(result)
    end

    function self.onSwipeLeft()
        for i = 1, #enteties do
            enteties[i].onSwipeLeft()
        end
    end

    function self.onSwipeRight()
        for i = 1, #enteties do
            enteties[i].onSwipeRight()
        end
    end

    function self.onSwipeTop()
		for i = 1, #enteties do
            enteties[i].onSwipeTop()
        end
    end

    function self.onSwipeBottom()
		for i = 1, #enteties do
            enteties[i].onSwipeBottom()
        end
    end

	function self.onMove() 
        for i = 1, #enteties do
            enteties[i].onMove()
        end
	end

    function self.canMoveBase(indexI, indexJ, incI, incJ)
        if (field[indexI + incI] == nil) then
            return MOVE_KIND_NONE
        end
        if (field[indexI + incI][indexJ + incJ] == nil) then
            return MOVE_KIND_NONE
        end
        if (field[indexI + incI][indexJ + incJ] == CELL_STATE_EMPTY) then
            return MOVE_KIND_SIMPLE
        elseif (field[indexI + incI][indexJ + incJ] == CELL_STATE_FILLED) then
            return MOVE_KIND_CUT
        elseif (field[indexI + incI][indexJ + incJ] == CELL_STATE_PLAYER) then
            return MOVE_KIND_PLAYER_AND_ENEMY_CONTACT
        elseif (field[indexI + incI][indexJ + incJ] == CELL_STATE_CURRENTLY_ACTIVE) then
            return MOVE_KIND_TAIL
        else
            return MOVE_KIND_NONE
        end
    end

    function self.canMoveLeft(indexI, indexJ)
    	return self.canMoveBase(indexI, indexJ, 0, -1)
    end

    function self.canMoveRight(indexI, indexJ)
		return self.canMoveBase(indexI, indexJ, 0, 1)
    end

    function self.canMoveDown(indexI, indexJ)
        return self.canMoveBase(indexI, indexJ, 1, 0)
    end

    function self.canMoveUp(indexI, indexJ)
        return self.canMoveBase(indexI, indexJ, -1, 0)
    end

    function self.canMoveUpRight(indexI, indexJ)
    	return self.canMoveBase(indexI, indexJ, -1, 1)
    end

    function self.canMoveDownRight(indexI, indexJ)
		return self.canMoveBase(indexI, indexJ, 1, 1)
    end

    function self.canMoveDownLeft(indexI, indexJ)
        return self.canMoveBase(indexI, indexJ, 1, -1)
    end

    function self.canMoveUpLeft(indexI, indexJ)
        return self.canMoveBase(indexI, indexJ, -1, -1)
    end

    function self.paintCell(i, j, color_a, color_b, color_c) 
    	rects[i][j]:setFillColor( color_a, color_b, color_c )
    end

    function self.replaceCellsAfterCutting()
        table.foreach(field,
                      function(k,v)
                          table.foreach(v,
                                        function(kInner, vInner)
                                            if (vInner == CELL_STATE_CURRENTLY_ACTIVE) then
                                            	v[kInner] = CELL_STATE_EMPTY
                                            	rects[k][kInner]:setFillColor(BACKGROUND_COLOR_EMPTY_R, BACKGROUND_COLOR_EMPTY_G, BACKGROUND_COLOR_EMPTY_B)
                                            end
                                        end)
                      end)
        local event = {
            name = "progressChanged",
            progress = self.getProgress()
        }
        Runtime:dispatchEvent(event)
    end

    function self.getProgress()
        local result = 0
        table.foreach(field,
                      function(k,v)
                          table.foreach(v,
                                        function(kInner, vInner)
                                            if (vInner == CELL_STATE_EMPTY and not (k == 1) and not (k == #field) and not (kInner == 1) and not (kInner == #(field[1]))) then
                                                result = result + 1
                                            end
                                        end)
                      end)
        return (result/(#field * #(field[1]) - (#field * 2) - (#(field[1]) * 2) + 2)) * 100
    end

    function self.onMoveBase(indexI, indexJ, direction, ent, indexIchange, indexJchange, canMoveFunction)
        if (not handleEnts) then
            return
        end
        local moveKind = canMoveFunction(indexI, indexJ)
        if (moveKind == MOVE_KIND_SIMPLE and not ent.canSwim()) then
            if (not ent.isCutting) then
                field[indexI + indexIchange][indexJ + indexJchange] = ent.cellType()
                field[indexI][indexJ] = CELL_STATE_EMPTY
                ent.indexI = indexI + indexIchange
                ent.indexJ = indexJ + indexJchange
            else
                field[indexI + indexIchange][indexJ + indexJchange] = ent.cellType()
                field[indexI][indexJ] = CELL_STATE_CURRENTLY_ACTIVE
                ent.indexI = indexI + indexIchange
                ent.indexJ = indexJ + indexJchange
                self.replaceCellsAfterCutting()
                ent.isCutting = false
                ent.needToStop = true
            end
        elseif (moveKind == MOVE_KIND_CUT and ent.canCut()) then
            field[indexI + indexIchange][indexJ + indexJchange] = CELL_STATE_CURRENTLY_ACTIVE
            if (ent.isCutting) then
                field[indexI][indexJ] = CELL_STATE_CURRENTLY_ACTIVE
            else
                field[indexI][indexJ] = CELL_STATE_EMPTY
            end
            ent.indexI = indexI + indexIchange
            ent.indexJ = indexJ + indexJchange
            ent.isCutting = true
            self.paintCell(indexI + indexIchange, indexJ + indexJchange, BACKGROUND_COLOR_CURRENTLY_ACTIVE_R, BACKGROUND_COLOR_CURRENTLY_ACTIVE_G, BACKGROUND_COLOR_CURRENTLY_ACTIVE_B)
        elseif (moveKind == MOVE_KIND_CUT and ent.canSwim()) then
            field[indexI + indexIchange][indexJ + indexJchange] = ent.cellType()
            field[indexI][indexJ] = CELL_STATE_FILLED
            ent.indexI = indexI + indexIchange
            ent.indexJ = indexJ + indexJchange
        elseif (moveKind == MOVE_KIND_PLAYER_AND_ENEMY_CONTACT and ent.canFightWithPlayer() or 
               (moveKind == MOVE_KIND_TAIL and ent.canFightWithPlayer() and ent.canSwim())) or 
               (moveKind == MOVE_KIND_TAIL and ent.canCut()) then
            self.printBackground()
            print("Move Kind " .. moveKind)
            print("Direction " .. direction)
            print("IndexI " .. indexI)
            print("IndexJ " .. indexJ)
            print("indexIchange " .. indexIchange)
            print("indexJchange " .. indexJchange)
            handleEnts = false
            local event = {
                name = "playerWasContactedWithEnemy"
            }
            Runtime:dispatchEvent(event)
        else
            ent.locked = true
        end
    end

    function self.onMoveLeft(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, 0, -1, self.canMoveLeft)
    end

    function self.onMoveRight(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, 0, 1, self.canMoveRight)
    end

    function self.onMoveUp(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, -1, 0, self.canMoveUp)
    end

    function self.onMoveDown(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, 1, 0, self.canMoveDown)
    end

    function self.onMoveUpRight(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, -1, 1, self.canMoveUpRight)
    end

    function self.onMoveDownRight(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, 1, 1, self.canMoveDownRight)
    end

    function self.onMoveDownLeft(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, 1, -1, self.canMoveDownLeft)
    end       

    function self.onMoveUpLeft(indexI, indexJ, direction, ent)
        self.onMoveBase(indexI, indexJ, direction, ent, -1, -1, self.canMoveUpLeft)
    end

    function self.onEntityNeedsToChangePositionOnBoard(indexI, indexJ, direction, ent)
        local handlers = {
            [MOVE_DIRECTION_LEFT] = self.onMoveLeft,
            [MOVE_DIRECTION_RIGHT] = self.onMoveRight,
            [MOVE_DIRECTION_DOWN] = self.onMoveDown,
            [MOVE_DIRECTION_UP] = self.onMoveUp,
            [MOVE_DIRECTION_UP_RIGHT] = self.onMoveUpRight,
            [MOVE_DIRECTION_DOWN_RIGHT] = self.onMoveDownRight,
            [MOVE_DIRECTION_DOWN_LEFT] = self.onMoveDownLeft,
            [MOVE_DIRECTION_UP_LEFT] = self.onMoveUpLeft
        }
        local directionFunction = handlers[direction]
        if (directionFunction) then
            directionFunction(indexI, indexJ, direction, ent)
        end
    end

    function self.tryToUnlockPlayer(indexI, indexJ, direction, ent)
        self.tryToUnlock(indexI, indexJ, direction, ent, {
            {direction = MOVE_DIRECTION_LEFT, handler = self.canMoveLeft},
            {direction = MOVE_DIRECTION_RIGHT, handler = self.canMoveRight},
            {direction = MOVE_DIRECTION_DOWN, handler = self.canMoveDown},
            {direction = MOVE_DIRECTION_UP, handler = self.canMoveUp}
        }, MOVE_KIND_NONE, MOVE_KIND_NONE)
    end

    function self.tryToUnlockEnemy(indexI, indexJ, direction, ent)
        self.tryToUnlock(indexI, indexJ, direction, ent, {
            {direction = MOVE_DIRECTION_LEFT, handler = self.canMoveLeft},
            {direction = MOVE_DIRECTION_RIGHT, handler = self.canMoveRight},
            {direction = MOVE_DIRECTION_DOWN, handler = self.canMoveDown},
            {direction = MOVE_DIRECTION_UP, handler = self.canMoveUp}
        }, MOVE_KIND_NONE, MOVE_KIND_CUT)
    end

    function self.tryToUnlockWaterEnemy(indexI, indexJ, direction, ent)
        self.tryToUnlock(indexI, indexJ, direction, ent, {
            {direction = MOVE_DIRECTION_UP_RIGHT, handler = self.canMoveUpRight},
            {direction = MOVE_DIRECTION_DOWN_RIGHT, handler = self.canMoveDownRight},
            {direction = MOVE_DIRECTION_DOWN_LEFT, handler = self.canMoveDownLeft},
            {direction = MOVE_DIRECTION_UP_LEFT, handler = self.canMoveUpLeft}
        }, MOVE_KIND_NONE, MOVE_KIND_NONE)
    end

    function self.tryToUnlock(indexI, indexJ, direction, ent, items, handlerResult1, handlerResult2)
        for key, item in pairs(items) do
            if direction == item.direction then
                local canMoveVar = item.handler(indexI, indexJ)
                if not(canMoveVar == handlerResult1 or canMoveVar == handlerResult2) then
                    ent.locked = false
                else
                    ent.locked = true
                end
                break
            end
        end
    end

    function self.destroyObject()
        for i = 1, #enteties do
            enteties[i].destroyObject()
        end  
    end

    function self.deepcopyField()
        local result = {}
        for i = 1, #field do
        	local newLine = {}
            for j = 1, #(field[i]) do
            	newLine[j] = field[i][j]
            end
            result[i] = newLine
        end      
        return result
    end

    function self.findPlayerOnField()
        local resultI = -1
        local resultJ = -1
        table.foreach(field,
                      function(k,v)
                          table.foreach(v,
                                        function(kInner, vInner)
                                            if (vInner == CELL_STATE_PLAYER) then
                                                resultI = k
                                                resultJ = kInner
                                            end
                                        end)
                      end)
        return resultI, resultJ
    end

    function self.removeAllEnt()
    	enteties = {}
        rects = {}
    	table.foreach(field,
                      function(k,v)
                          table.foreach(v,
                                        function(kInner, vInner)
                                            if (vInner == CELL_STATE_ENEMY or vInner == CELL_STATE_PLAYER) then
                                            	field[k][kInner] = CELL_STATE_EMPTY
                                            end
                                        end)
                      end)
    	while group.numChildren > 7 do
            group:remove(group.numChildren)
    	end
    end

    function self.removeUnfinishedWay()
        table.foreach(field,
                      function(k,v)
                          table.foreach(v,
                                        function(kInner, vInner)
                                            if (vInner == CELL_STATE_CURRENTLY_ACTIVE) then
                                                field[k][kInner] = CELL_STATE_FILLED
                                            end
                                        end)
                      end)
    end

    function drawEmpty(rect, newLine, kInner, isDeepCreation)
        rect:setFillColor(BACKGROUND_COLOR_EMPTY_R, BACKGROUND_COLOR_EMPTY_G, BACKGROUND_COLOR_EMPTY_B)
        if (isDeepCreation == true) then
            newLine[kInner] = CELL_STATE_EMPTY
        end
    end

    function drawPlayer(rect, newLine, k, kInner, isDeepCreation, sceneGroup, eventsTimeInterval, stageNumber, itemsToInsertAfter)
        rect:setFillColor(BACKGROUND_COLOR_EMPTY_R, BACKGROUND_COLOR_EMPTY_G, BACKGROUND_COLOR_EMPTY_B)
        local p = self.createPlayer(k, kInner, sceneGroup, eventsTimeInterval, stageNumber)
        table.insert(itemsToInsertAfter, p.drawable)
        if (isDeepCreation == true) then
            newLine[kInner] = CELL_STATE_PLAYER
        else
            field[k][kInner] = CELL_STATE_PLAYER
        end
    end

    function self.createScene(sceneGroup, eventsTimeInterval, isDeepCreation, stageNumber)
        handleEnts = true
        local itemsToInsertAfter = {}
        local currentStage = stages.getStage(stageNumber)
        if (#currentStage > #(currentStage[1])) then
        	part_size = height / #currentStage
        else
            part_size = width / #(currentStage[1])
        end
        local startX = centerX - width/2.0
        local startY = centerY + height/2.0 - (part_size * #currentStage)
        group = sceneGroup
        timeInterval = eventsTimeInterval
        table.foreach(currentStage,
                      function(k,v)
                          local newLine = {}
                          local newLineRects = {}
                          table.foreach(v,
                                        function(kInner, vInner)
                                        	local rect = display.newRect(startX + part_size/2.0, startY + part_size/2.0, part_size , part_size)
                                            if (vInner == CELL_STATE_EMPTY) then
                                                drawEmpty(rect, newLine, kInner, isDeepCreation)
                                            elseif (vInner == CELL_STATE_FILLED) then
                                                rect:setFillColor( BACKGROUND_COLOR_FILL_R, BACKGROUND_COLOR_FILL_G, BACKGROUND_COLOR_FILL_B )
                                                if (isDeepCreation == true) then
                                                    newLine[kInner] = CELL_STATE_FILLED
                                            	end
                                            elseif (vInner == CELL_STATE_PLAYER) then
                                                drawPlayer(rect, newLine, k, kInner, isDeepCreation, sceneGroup, eventsTimeInterval, stageNumber, itemsToInsertAfter)
                                            elseif (vInner == CELL_STATE_ENEMY) then
                                                rect:setFillColor( BACKGROUND_COLOR_EMPTY_R, BACKGROUND_COLOR_EMPTY_G, BACKGROUND_COLOR_EMPTY_B )
                                                local e = self.createEnemy(k, kInner, sceneGroup, eventsTimeInterval, stageNumber)
                                                table.insert(itemsToInsertAfter, e.drawable)
                                                if (isDeepCreation == true) then
                                                	newLine[kInner] = CELL_STATE_ENEMY
                                                else
                                                	field[k][kInner] = CELL_STATE_ENEMY
                                            	end
                                            elseif (vInner == CELL_STATE_WATER_ENEMY) then
                                                rect:setFillColor( BACKGROUND_COLOR_FILL_R, BACKGROUND_COLOR_FILL_G, BACKGROUND_COLOR_FILL_B )
                                                local e = self.createWaterEnemy(k, kInner, sceneGroup, eventsTimeInterval, stageNumber)
                                                table.insert(itemsToInsertAfter, e.drawable)
                                                if (isDeepCreation == true) then
                                                	newLine[kInner] = CELL_STATE_WATER_ENEMY
                                                else
                                                	field[k][kInner] = CELL_STATE_WATER_ENEMY
                                            	end
                                            end
                                            if (not (field[k] == nil)) then
                                            	if (field[k][kInner] == CELL_STATE_EMPTY) then
                                            		rect:setFillColor( BACKGROUND_COLOR_EMPTY_R, BACKGROUND_COLOR_EMPTY_G, BACKGROUND_COLOR_EMPTY_B )
                                            	end
                                        	end
                                            startX = startX + part_size
                                            sceneGroup:insert(rect)
                                            newLineRects[kInner] = rect
                                        end)
                          if (isDeepCreation == true) then
                              field[k] = newLine
                      	  end
                          rects[k] = newLineRects
                          startY = startY + part_size
                          startX = centerX - width/2.0
                      end)
        table.foreach(itemsToInsertAfter,
                      function(k,v)
                          group:insert(v)
                      end)
    end

    function self.restartLevel(stageNumber)
    	self.removeAllEnt()
        self.removeUnfinishedWay()
    	self.createScene(group, timeInterval, false, stageNumber)
    end

    return self
end
