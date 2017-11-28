local fractalCore = {}

fractalCore.rootDir = "/fractal/"
fractalCore.coreDir = fractalCore.rootDir.."core/"
fractalCore.userDir = fractalCore.rootDir.."user/"
fractalCore.appsDir = fractalCore.rootDir.."apps/"       -- All users can use
fractalCore.localAppsDir = fractalCore.userDir.."apps/"  -- Other users on the computer cannot use apps in another user's folder
fractalCore.desktopDir = fractalCore.userDir.."desktop/"

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








return fractalCore
