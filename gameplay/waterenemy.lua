local display = require("display")
local entity = require("gameplay.entity")

local ENEMY_COLOR_FILL_R = 0x80/255.0
local ENEMY_COLOR_FILL_G = 0xEA/255.0
local ENEMY_COLOR_FILL_B = 0x69/255.0

function WaterEnemy()
    local self = Entity()

	function self.createEntity(initial_position_x, intial_position_y, initialIndexI, initialIndexJ, size, background, eventsTimeInterval)
		self.createEntityBase(initialIndexI, initialIndexJ, size, background, eventsTimeInterval)
        self.drawable = display.newCircle( initial_position_x, intial_position_y, size/2.0 )
        self.drawable:setFillColor(ENEMY_COLOR_FILL_R,ENEMY_COLOR_FILL_G,ENEMY_COLOR_FILL_B,1.0)
	    self.moveDirection = MOVE_DIRECTION_DOWN_LEFT
        self.directions = {
            MOVE_DIRECTION_DOWN_LEFT,
            MOVE_DIRECTION_UP_RIGHT,
            MOVE_DIRECTION_DOWN_RIGHT,
            MOVE_DIRECTION_UP_LEFT
        }
    end

	function self.onMove()
        self.onMoveBase()         
	end

    function self.cellType()
        return CELL_STATE_WATER_ENEMY
    end

    function self.destroyObject()

    end

    function self.canCut()
        return false
    end

    function self.canSwim()
        return true
    end

    function self.canFightWithPlayer()
        return true
    end

	return self
end
