MOVE_DIRECTION_NONE = 0
MOVE_DIRECTION_LEFT = 1
MOVE_DIRECTION_RIGHT = 2
MOVE_DIRECTION_UP = 3
MOVE_DIRECTION_DOWN = 4
MOVE_DIRECTION_UP_RIGHT = 5
MOVE_DIRECTION_DOWN_RIGHT = 6
MOVE_DIRECTION_DOWN_LEFT = 7
MOVE_DIRECTION_UP_LEFT = 8

function Entity()
	local self = {
		drawable = nil,
		moveDirection = nil,
		background = nil,
		indexI = 0,
        indexJ = 0,
		size = 0,
		locked = false,
        eventsTimeInterval = 1000,
        isCutting = false,
        needToStop = false,
        directions = {}
	}

	function self.createEntityBase(initialIndexI, initialIndexJ, size, background, eventsTimeInterval)
		self.drawable = nil
		self.moveDirection = MOVE_DIRECTION_NONE
		self.indexI = initialIndexI
        self.indexJ = initialIndexJ
		self.size = size
		self.background = background
		self.locked = false
        self.eventsTimeInterval = eventsTimeInterval
	end

	function self.moveCoords()
        if (self.moveDirection == MOVE_DIRECTION_LEFT) then
            self.drawable.x = self.drawable.x - self.size
        elseif (self.moveDirection == MOVE_DIRECTION_RIGHT) then
            self.drawable.x = self.drawable.x + self.size
        elseif (self.moveDirection == MOVE_DIRECTION_UP) then
            self.drawable.y = self.drawable.y - self.size
        elseif (self.moveDirection == MOVE_DIRECTION_DOWN) then
            self.drawable.y = self.drawable.y + self.size
        elseif (self.moveDirection == MOVE_DIRECTION_UP_RIGHT) then
            self.drawable.x = self.drawable.x + self.size
            self.drawable.y = self.drawable.y - self.size
        elseif (self.moveDirection == MOVE_DIRECTION_DOWN_RIGHT) then
            self.drawable.x = self.drawable.x + self.size
            self.drawable.y = self.drawable.y + self.size
        elseif (self.moveDirection == MOVE_DIRECTION_DOWN_LEFT) then
            self.drawable.x = self.drawable.x - self.size
            self.drawable.y = self.drawable.y + self.size
        elseif (self.moveDirection == MOVE_DIRECTION_UP_LEFT) then
            self.drawable.x = self.drawable.x - self.size
            self.drawable.y = self.drawable.y - self.size           
        end  
    end

   	function self.deepCopyWatchedList(watchedCellsArray)
		local result = {}
		for i = 1, #watchedCellsArray do
			table.insert(result, {watchedCellsArray[i][1], watchedCellsArray[i][2]})
		end
		return result
	end

    function self.nextDirection(direction)
        local directionToUse = direction or self.moveDirection
        if directionToUse == nil then
            return self.directions[1]
        end
        for i, v in ipairs(self.directions) do
            if v == directionToUse then
                local nextIndex = i + 1
                if nextIndex == table.getn(self.directions) + 2 then
                    nextIndex = 1
                end 
                return self.directions[nextIndex]
            end
        end
    end

	function self.onSwipeLeft()

	end

	function self.onSwipeRight()

	end

	function self.onSwipeTop()

	end

	function self.onSwipeBottom()

	end

	function self.onMove() 
		
	end

	function self.onEntityNeedsToChangePositionOnBoard(j, direction, ent)
        
    end

    function self.cellType()

    end

    function self.destroyObject()
        
    end

    function self.canCut()

    end

    function self.canSwim()

    end

    function self.canFightWithPlayer()

    end

    function self.onMoveBase(unlockFunction)
        self.background.onEntityNeedsToChangePositionOnBoard(self.indexI, self.indexJ, self.moveDirection, self)
        if not (self.locked) then
            self.moveCoords()
        else
            local initialDirection = self.moveDirection
            while (true) do
                local nextDirectionValue = self.nextDirection()
                if nextDirectionValue == initialDirection then
                    break
                end
                self.moveDirection = nextDirectionValue
                unlockFunction(self.indexI, self.indexJ, self.moveDirection, self)
                if not self.locked then
                    break
                end
            end
        end
    end

	return self
end