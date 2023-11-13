local display = require("display")
local entity = require("gameplay.entity")

local PLAYER_COLOR_FILL_R = 0xFF/255.0
local PLAYER_COLOR_FILL_G = 0xEC/255.0
local PLAYER_COLOR_FILL_B = 0x40/255.0

MOVE_KIND_NONE = 0
MOVE_KIND_SIMPLE = 1
MOVE_KIND_CUT = 2
MOVE_KIND_PLAYER_AND_ENEMY_CONTACT = 3
MOVE_KIND_TAIL = 4

function Player()
    local self = Entity()

	function self.createEntity(initial_position_x, intial_position_y, initialIndexI, initialIndexJ, size, background, eventsTimeInterval)
		self.createEntityBase(initialIndexI, initialIndexJ, size, background, eventsTimeInterval)
        self.drawable = display.newCircle(initial_position_x, intial_position_y, size/2.0)
        self.drawable:setFillColor(PLAYER_COLOR_FILL_R, PLAYER_COLOR_FILL_G, PLAYER_COLOR_FILL_B, 1.0)
	end

	function self.onSwipeBase(firstDir, secondDir)
		if self.isCutting and self.moveDirection == firstDir then
			return
		end
		if self.moveDirection == secondDir then
			return
		end
		self.moveDirection = secondDir
		if self.locked then
			self.background.tryToUnlockPlayer(self.indexI, self.indexJ, self.moveDirection, self)
		end
	end

	function self.onSwipeLeft( )
		self.onSwipeBase(MOVE_DIRECTION_RIGHT, MOVE_DIRECTION_LEFT)
	end

	function self.onSwipeRight( )
		self.onSwipeBase(MOVE_DIRECTION_LEFT, MOVE_DIRECTION_RIGHT)
	end

	function self.onSwipeTop( )
		self.onSwipeBase(MOVE_DIRECTION_DOWN, MOVE_DIRECTION_UP)
	end

	function self.onSwipeBottom( )
		self.onSwipeBase(MOVE_DIRECTION_UP, MOVE_DIRECTION_DOWN)
	end

	function self.onMove ( )
		if self.needToStop then
			self.moveDirection = MOVE_DIRECTION_NONE
			self.needToStop = false
		end
        self.background.onEntityNeedsToChangePositionOnBoard(self.indexI, self.indexJ, self.moveDirection, self)
        if not (self.locked) then
            if (self.moveDirection == MOVE_DIRECTION_LEFT) then
            	self.drawable.x = self.drawable.x - self.size
            elseif (self.moveDirection == MOVE_DIRECTION_RIGHT) then
                self.drawable.x = self.drawable.x + self.size
            elseif (self.moveDirection == MOVE_DIRECTION_UP) then
                self.drawable.y = self.drawable.y - self.size
            elseif (self.moveDirection == MOVE_DIRECTION_DOWN) then
                self.drawable.y = self.drawable.y + self.size
            end
        end
	end

	function self.cellType ( )
        return CELL_STATE_PLAYER
    end

    function self.destroyObject ()
        
    end

    function self.canCut()
    	return true
    end

    function self.canSwim()
        return false
    end

    function self.canFightWithPlayer()
        return true
    end

	return self
end
