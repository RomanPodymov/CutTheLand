local display = require("display")
local entity = require("gameplay.entity")

local ENEMY_COLOR_FILL_R = 0xFF/255.0
local ENEMY_COLOR_FILL_G = 0x7C/255.0
local ENEMY_COLOR_FILL_B = 0x00/255.0

function Enemy()
    local self = Entity()

	function self.createEntity(initial_position_x, intial_position_y, initialIndexI, initialIndexJ, size, background, eventsTimeInterval)
		self.createEntityBase(initialIndexI, initialIndexJ, size, background, eventsTimeInterval)
        self.drawable = display.newCircle(initial_position_x, intial_position_y, size/2.0)
        self.drawable:setFillColor(ENEMY_COLOR_FILL_R, ENEMY_COLOR_FILL_G, ENEMY_COLOR_FILL_B, 1.0)
        self.moveDirection = MOVE_DIRECTION_DOWN
        self.directions = {
            MOVE_DIRECTION_LEFT,
            MOVE_DIRECTION_UP,
            MOVE_DIRECTION_RIGHT,
            MOVE_DIRECTION_DOWN
        }
	end

	function self.onMove()
        self.onMoveBase()
        self.makeDecision()
	end

    function self.findDistance (fromI, fromJ, toI, toJ, currentDistance, currentDirection, copyField, watchedCellsArray)
        if (self.watchedVertexCount % 500 == 0) then
            coroutine.yield()
        end
        self.watchedVertexCount = self.watchedVertexCount + 1
        if (copyField[fromI] == nil) then
            return -currentDistance, currentDirection
        end
        if (copyField[fromI][fromJ] == nil) then
            return -currentDistance, currentDirection
        end
        if (copyField[fromI][fromJ] == CELL_STATE_FILLED) then
            return -currentDistance, currentDirection
        end
        if (fromI == toI and fromJ == toJ) then
            return currentDistance, currentDirection
        end
        local distanceToGoLeft = -1
        local distanceToGoRight = -1
        local distanceToGoDown = -1
        local distanceToGoUp = -1
        local resultDirection = MOVE_DIRECTION_NONE

        local newWatchedCellsArray = self.deepCopyWatchedList(watchedCellsArray)
        table.insert(newWatchedCellsArray, {fromI, fromJ})

        local isLeftStepWasAlready = false
        table.foreach(watchedCellsArray,
                      function(k,v)
                          if (v[1] == fromI and v[2] == fromJ - 1) then
                              isLeftStepWasAlready = true 
                          end
                      end)
        if isLeftStepWasAlready == false then
        	distanceToGoLeft, resultDirection = self.findDistance (fromI, fromJ - 1, toI, toJ, currentDistance + 1, MOVE_DIRECTION_LEFT, copyField, newWatchedCellsArray)
        end

		local isRightStepWasAlready = false
        table.foreach(watchedCellsArray,
                      function(k,v)
                          if (v[1] == fromI and v[2] == fromJ + 1) then
                              isRightStepWasAlready = true
                          end
                      end)
        if isRightStepWasAlready == false then
        	distanceToGoRight, resultDirection = self.findDistance (fromI, fromJ + 1, toI, toJ, currentDistance + 1, MOVE_DIRECTION_RIGHT, copyField, newWatchedCellsArray)
        end      
        
		local isDownStepWasAlready = false
        table.foreach(watchedCellsArray,
                      function(k,v)
                          if (v[1] == fromI + 1 and v[2] == fromJ) then
                              isDownStepWasAlready = true
                          end
                      end)
        if isDownStepWasAlready == false then
        	distanceToGoDown, resultDirection = self.findDistance (fromI + 1, fromJ, toI, toJ, currentDistance + 1, MOVE_DIRECTION_DOWN, copyField, newWatchedCellsArray)
        end  

		local isUpStepWasAlready = false
        table.foreach(watchedCellsArray,
                      function(k,v)
                          if (v[1] == fromI - 1 and v[2] == fromJ) then
                              isUpStepWasAlready = true
                          end
                      end)
        if isUpStepWasAlready == false then
        	distanceToGoUp, resultDirection = self.findDistance (fromI - 1, fromJ, toI, toJ, currentDistance + 1, MOVE_DIRECTION_UP, copyField, newWatchedCellsArray)
        end          

        local minimalDistance = 100000
        local distances = {{distanceToGoLeft, MOVE_DIRECTION_LEFT}, {distanceToGoRight, MOVE_DIRECTION_RIGHT}, {distanceToGoDown, MOVE_DIRECTION_DOWN}, {distanceToGoUp, MOVE_DIRECTION_UP}}
        for i = 1, #distances do
            if (distances[i][1] < minimalDistance and distances[i][1]>0) then
                minimalDistance = distances[i][1]
                resultDirection = distances[i][2]
            end
        end
        if (minimalDistance == 100000) then
        	minimalDistance = -1
        end
        return minimalDistance, resultDirection
    end

    function self.makeDecisionRoutine ()
        self.watchedVertexCount = 0
        local fieldCopy = self.background.deepcopyField()
        local playerI = -1
        local playerJ = -1
        playerI, playerJ = self.background.findPlayerOnField()
        if not (playerI == -1 and playerJ == -1) then
            local distance = -1
            local direction = MOVE_DIRECTION_NONE
            distance, direction = self.findDistance(self.indexI, self.indexJ, playerI, playerJ, 1, MOVE_DIRECTION_NONE, fieldCopy, {})
            if (distance > 0 and not (direction == MOVE_DIRECTION_NONE)) then
                self.moveDirection = direction
            end
        end
    end

    function self.makeDecision()
        if (self.co == nil or coroutine.status(self.co) == "dead") then
            self.co = coroutine.create(self.makeDecisionRoutine)
        end
        coroutine.resume(self.co)
    end

    function self.cellType ( )
        return CELL_STATE_ENEMY
    end

    function self.destroyObject ()

    end

    function self.canCut()
        return false
    end

    function self.canSwim()
        return false
    end

    function self.canFightWithPlayer()
        return true
    end

	return self
end
