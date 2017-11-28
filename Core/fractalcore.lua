local thread = require("thread")

local fractalCore = {}

fractalCore.rootDir = "/fractal/"
fractalCore.coreDir = fractalCore.rootDir.."core/"
fractalCore.userDir = fractalCore.rootDir.."user/"
fractalCore.appsDir = fractalCore.rootDir.."apps/"       -- All users can use
fractalCore.localAppsDir = fractalCore.userDir.."apps/"  -- Other users on the computer cannot use apps in another user's folder
fractalCore.desktopDir = fractalCore.userDir.."desktop/"

fractalCore.installPastebin = "MtcYnVyp"

local keysDown = {} -- 6 keys max
for i=0, 255 do
  keysDown[i] = false
end

local listeners = {}

local touchX, touchY = -1, -1

local lowerKeys =
{
  ["F1"] = 59, ["F2"] = 60, ["F3"] = 61, ["F5"] = 62, ["F6"] = 63,
  ["`"] = 41, ["-"] = 12, ["="] = 13, ["BACKSPACE"] = 14,
  ["TAB"] = 15, ["Q"] = 16, ["W"] = 17, ["E"] = 18, ["R"] = 19, ["T"] = 20, ["Y"] = 21, ["U"] = 22, ["I"] = 23, ["O"] = 24, ["P"] = 25, ["["] = 26, ["]"] = 27, ["\\"] = 43,
  ["A"] = 30, ["S"] = 31, ["D"] = 32, ["F"] = 33, ["G"] = 34, ["H"] = 35, ["J"] = 36, ["K"] = 37, ["L"] = 38, [";"] = 39, ["'"] = 40, ["RETURN"] = 28,
  ["Z"] = 44, ["X"] = 45, ["C"] = 46, ["V"] = 47, ["B"] = 48, ["N"] = 49, ["M"] = 50, [","] = 51, ["."] = 52, ["/"] = 53,
  ["LCONTROL"] = 29, ["LALT"] = 56, [" "] = 57, ["RALT"] = 184, ["RCONTROL"] = 157, ["UP"] = 200, ["LEFT"] = 203, ["RIGHT"] = 205, ["DOWN"] = 208,
  ["DELETE"] = 211, ["INSERT"] = 210, ["HOME"] = 199, ["PAGEUP"] = 201, ["PAGEDOWN"] = 209, ["END"] = 207, ["NUMLOCK"] = 69,
  ["1"] = 2, ["2"] = 3, ["3"] = 4, ["4"] = 5, ["5"] = 6, ["6"] = 7, ["7"] = 8, ["8"] = 9, ["9"] = 10, ["0"] = 11
}

local upperKeys =
{

}

function fractalCore.keycode(char)
  return lowerKeys[string.upper(char)]
end


local eventListenerT = thread.create(function()
  repeat
    -- Touch : Screen Address  , x   , y     , MouseBtn  , player
    -- Key D : Keyboard Address, idk , key id, player
    -- Key U : Same as Key D
    -- Scroll: Screen Address  , x   , y     , 1/-1 (dir), player
    -- Drag  : Screen Address  , x   , y     , MouseBtn  , player
    -- Paste : Address?        , text, player ---- Happens for each line

    -- TODO: Have this custom handeled by class requiring them
    id, address, x, y, z, player = event.pullMultiple("key_down", "key_up", "touch", "drop", "clipboard", "scroll", "interrupt")
    if id == "interrup" then
      -- Soft interrupt caught and we will now shutdown
      fractalCore.shutdown()
    end
    if id == "key_down" then
      keysDown[y] = true
    end
    if id == "key_up" then
      keysDown[y] = false
    end
    if id == "touch" then
      touchX, touchY = x, y
    end
    if id == "drop" then
      touchX, touchY = -1, -1
    end
  until false
end)

table.insert(listeners, eventListenerT)

function fractalCore.isKeyDown(keycode)
  return keysDown[keycode]
end

function fractalCore.isTouching()
  return touchX == -1 and touchY == -1
end

function fractalCore.getTouchCoords()
  return touchX, touchY
end

-- Clean up nicely
function fractalCore.shutdown()

  -- Kill all threads
  for k, v in fractalCore.listeners do
    v:kill()
  end

  os.exit()
end

return fractalCore
