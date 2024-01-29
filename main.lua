local composer = require("composer")
local GBCLanguageCabinet = require("plugin.GBCLanguageCabinet")
local GBCDataCabinet = require("plugin.GBCDataCabinet")
local utility = require("utility")

display.setStatusBar(display.HiddenStatusBar)

math.randomseed(os.time())

local function setupLocalDatabase()
    local isDatabaseExists = GBCDataCabinet.load(utility.databaseName())
    if (not isDatabaseExists) then
        GBCDataCabinet.createCabinet(utility.databaseName())
        GBCDataCabinet.save(utility.databaseName())
    else

    end
end

local function setupTranslations()
    GBCLanguageCabinet.addLanguage("English", "en")
    GBCLanguageCabinet.addLanguage("Russian", "ru")
    GBCLanguageCabinet.addText("NEW_GAME", {
        {"en", "New game"},
        {"ru", "Новая игра"}
    })
    GBCLanguageCabinet.addText("HELP", {
        {"en", "Help"},
        {"ru", "Помощь"}
    })
    GBCLanguageCabinet.addText("DONE", {
        {"en", "Done"},
        {"ru", "Назад"}
    })
    GBCLanguageCabinet.addText("SELECT_LEVEL", {
        {"en", "Select a level"},
        {"ru", "Выберите уровень"}
    }) 
    GBCLanguageCabinet.addText("BACK", {
        {"en", "Back"},
        {"ru", "Назад"}
    })   
    GBCLanguageCabinet.addText("HELP_TEXT", {
        {"en", "You need to cut as much rectangles as you can. " ..
               "There are 2 kinds of rectangles - ground (black) and water (blue). " ..
               "Your player is a yellow rectangle, ground enemies are orange and water enemies are green." ..
               "Swipe screen to move your player. " ..
               "Avoid enemies, you have only 3 attempts."},
        {"ru", "Суть игры заключается в том, чтобы отсечь как можно больше территории, представленной чёрными (суша) и синими (вода) элементами. " ..
               "Вы играете за жёлтого персонажи, а ваши враги - оранжевые (на суше) и зелёные (в воде) прямоугольникии. " ..
               "Для того чтобы передвинуть Вашего игрока проведите пальцем по экрану. " ..
               "Избегайте соприкосновений с Вашими врагами! " .. 
               "Всего у Вас будет 3 попытки на каждом уровне."}
    }) 
    GBCLanguageCabinet.addText("PROGRESS", {
        {"en", "Progress"},
        {"ru", "Прогресс"}
    }) 
    GBCLanguageCabinet.addText("PLAYERS", {
        {"en", "Players"},
        {"ru", "Игроки"}
    }) 
    GBCLanguageCabinet.addText("GAME_OVER", {
        {"en", "Game Over"},
        {"ru", "Игра окончена"}
    }) 
    GBCLanguageCabinet.addText("NEXT_LEVEL", {
        {"en", "Next"},
        {"ru", "Далее"}
    }) 
    GBCLanguageCabinet.addText("CONGRATULATIONS", {
        {"en", "Congratulations!!!"},
        {"ru", "Поздравляем!!!"}
    }) 
    GBCLanguageCabinet.addText("NEXT_LEVEL_TEXT", {
        {"en", "Next level "},
        {"ru", "Следующий уровень "}
    }) 
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
