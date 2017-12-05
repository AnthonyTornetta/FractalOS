local thread = require("thread")
local computer = require("computer")

local fractalCore = {}

local dirs = {}

function fractalCore.getDir(dirName)
  return dirs[string.lower(dirName)]
end
function fractalCore.getInstallPastebin()
  return "MtcYnVyp"
end

local keysDown = {}
for i=0, 255 do
  keysDown[i] = false
end

function fractalCore.setKeyDown(keyCode, down)
  keysDown[keyCode] = down
end

function fractalCore.keyDown(keyCode)
  return keysDown[keyCode]
end

local lowerKeys =
{
  ["F1"] = 59, ["F2"] = 60, ["F3"] = 61, ["F4"] = 62, ["F5"] = 63, ["F6"] = 64,
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

-- Clean up nicely
function fractalCore.shutdown()
  computer.shutdown(false) -- Shutdown, not restart
end


local initVals = function()
  dirs["root"]      = "/fractal/"
  dirs["lib"]       = "/lib/"
  dirs["core"]      = fractalCore.getDir("root").."core/"
  dirs["user"]      = fractalCore.getDir("root").."user/"
  dirs["apps"]      = fractalCore.getDir("root").."apps/"
  dirs["localapps"] = fractalCore.getDir("user").."apps/"
  dirs["desktop"]   = fractalCore.getDir("user").."desktop/"
end

-- Util Functions
function fractalCore.tableLength(table)
  local count = 0
  for _ in pairs(table) do
    count = count + 1
  end
  return count
end

initVals()

return fractalCore
