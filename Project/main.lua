--
--  main.lua
--  Cut The Land
--
--  Created by Roman Podymov on 07/07/2024.
--  Copyright © 2024 Cut The Land. All rights reserved.
--

local composer = require("composer")
local utility = require("utility")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

local function setupLocalDatabase()

end

local function setupTranslations()

end 

local function systemEvents(event)
    if event.type == "applicationStart" then
        utility.goToScene("scenes.menu")
    end
    return true
end

setupLocalDatabase()
setupTranslations()
Runtime:addEventListener("system", systemEvents)
