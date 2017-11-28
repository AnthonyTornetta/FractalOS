local fractalCore = require("fractalcore")

local computer = require("computer")
local comp = require("component")
local fs = require("filesystem")
local thread = require("thread")
local key = require("keyboard")
local event = require("event")
local term = require("term")

local gpu = comp.gpu;

-- DESKTOP --
w, h = gpu.getResolution()
local desktopButtons = { {} }

-- DESKTOP ICONS --
local iconWidth, iconHeight = 14, 7
local sidePadding = 4
local topPadding  = 6

-- TASKBAR --
local taskbarHeight = 2
local startWidth, startHeight = 4, 2

-- For easy storage of the files/directories in the desktop directory
local files = {}
local directories = {}

-- Desktop Stuff --
local drawWholeDesktop = function() -- Draws the desktop to the screen for the first time - DNL
  gpu.setForeground(0x000000)
  gpu.setBackground(0xFFFFFF)

  gpu.fill(1, 1, w, h, " ")
end

-- Draws helpful info to the screen --
local drawInfo = function()
  gpu.setBackground(0x333333)
  gpu.setForeground(0x888888)
  local curRam = math.floor((computer.freeMemory() / computer.totalMemory()) * 100).."% RAM free"
  gpu.fill(w - #curRam + 1, 1, #curRam, 1, " ")
  gpu.set(w - #curRam + 1, 1, curRam)
end

-- Draws the desktop icons in super-hd
local drawDesktopIcons = function()
  gpu.setBackground(0x333333)
  gpu.setForeground(0xAAAAAA)

  for k, b in pairs(desktopButtons) do

    local drawX = b["x"]
    local drawY = b["y"]
    gpu.fill(drawX, drawY, b["width"], b["height"], " ")
    gpu.set(b["textX"], b["textY"], b["text"])
  end

  drawInfo()
end

-- Refreshes all the buttons based off the file & directory list & redraws it
local refreshDesktop = function()
  desktopButtons = { {} }
  local y = 0
  local dtopFiles = 0

  -- Make the file buttons
  for k, v in pairs(files) do
    desktopButtons[k] = {}
    -- TODO: Take into account seperate rows!!
    local drawX = (k - 1) * iconWidth + sidePadding * k
    local drawY = y * iconHeight + topPadding
    desktopButtons[k]["text"]   = " "..v.." "
    desktopButtons[k]["x"]      = drawX
    desktopButtons[k]["y"]      = drawY
    desktopButtons[k]["textX"]  = drawX + math.floor((iconWidth - #desktopButtons[k]["text"]) / 2)
    desktopButtons[k]["textY"]  = drawY + iconHeight - 1
    desktopButtons[k]["width"]  = iconWidth
    desktopButtons[k]["height"] = iconHeight
    desktopButtons[k]["icon"]   = nil

    dtopFiles = dtopFiles + 1

    local width = drawX + #desktopButtons[k]["text"]
    if width > w - sidePadding then
      y = y + 1
      if y > h then
        -- TODO: Do something here :p
      end
    end
  end

  -- Make the directory buttons
  for k, v in pairs(directories) do
    -- TODO: Take into account seperate rows!!
    local kk = k + dtopFiles
    desktopButtons[kk] = {}
    local drawX = (kk - 1) * iconWidth + sidePadding * kk
    local drawY = y * iconHeight + topPadding
    desktopButtons[kk]["text"]   = " "..v.." "
    desktopButtons[kk]["x"]      = drawX
    desktopButtons[kk]["y"]      = drawY
    desktopButtons[kk]["textX"]  = drawX + math.floor((iconWidth - #desktopButtons[kk]["text"]) / 2)
    desktopButtons[kk]["textY"]  = drawY + iconHeight - 1
    desktopButtons[kk]["width"]  = iconWidth
    desktopButtons[kk]["height"] = iconHeight
    desktopButtons[kk]["icon"]   = nil

    local width = drawX + #desktopButtons[kk]["text"]
    if width > w - sidePadding then
      y = y + 1
      if y > h then
        -- TODO: Do something here :p
      end
    end
  end

  drawWholeDesktop()
  drawDesktopIcons()
end



local setupTaskbar = function()

end

-- Draws the task bar in all its high-res glory
local drawTaskBar = function()
  gpu.setBackground(0x333333)
  gpu.setForeground(0x888888)
  gpu.fill(1, h - (taskbarHeight - 1), w, taskbarHeight, " ")

  gpu.setBackground(0x555555)
  gpu.fill(1, h - (startHeight - 1), startWidth, startHeight, " ")
end

local err = function(msg)
  error(msg)
end

local refreshFileList = function()
  local temp, reason = fs.list(fractalCore.desktopDir)
  if not temp then
    err(reason)
  end

  for f in temp do
    local indexOf = string.find(f, "/")
    if indexOf ~= nil then
      table.insert(directories, f) -- Remove the pesky '/' at the beginning
    else
      table.insert(files, f)
    end
  end
end

local printCentered = function(txt, height)
  gpu.set(w / 2 - math.floor(string.len(txt) / 2), height, txt)
  line = height + 1
  if line > h then
    line = 1
  end
end

local keydown = function(_, _, _, ch)

end

local mousedown = function(address, x, y, mouseBtn, playerName)

end

local mouseup = function(address, x, y, mouseBtn, playerName)

end

local keyListenerT = thread.create(function()
  repeat
    _, _, _, ch = event.pull("key_down")
  until false
end)

local init = function()
  w, h = gpu.getResolution()
  if not fs.isDirectory(fractalCore.desktopDir) then
    if fs.makeDirectory(fractalCore.desktopDir) == nil then
      err("Error creating desktop directory!")
      os.exit()
    end
    -- Give them a nice welcoming gift
    local welcomeFile = fs.open(fractalCore.desktopDir.."/welcome.txt", "w")
    welcomeFile:write("Hello, and welcome to Fractal OS")
    welcomeFile:close()
  end

  refreshFileList()
  refreshDesktop()
  drawDesktopIcons()
  drawTaskBar()

  ch = nil
  while ch ~= fractalCore.keycode("BACKSPACE") do
    drawInfo()
    if ch ~= nil then
      print(ch)
      if ch == fractalCore.keycode("F5") then -- F5
        os.execute("cls")
        w, h = gpu.getResolution()
        refreshDesktop()
        drawTaskBar()
      end

      ch = nil
    end
    --event.pull("touch", mousedown)
    --event.pull("drop", mouseup)

    os.sleep(0.1)
  end

  -- Kill all the running threads
  keyListenerT:kill()
end

init()
