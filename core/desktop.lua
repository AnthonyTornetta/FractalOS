local fractalCore = require("fractalcore")

local computer = require("computer")
local comp = require("component")
local fs = require("filesystem")
local thread = require("thread")
local key = require("keyboard")
local event = require("event")
local term = require("term")

local gpu = comp.gpu
local running = true

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
    if b["x"] ~= nil then
      local drawX = b["x"]
      local drawY = b["y"]
      gpu.fill(drawX, drawY, b["width"], b["height"], " ")
      gpu.set(b["textX"], b["textY"], b["text"])
    end
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
  local temp, reason = fs.list(fractalCore.getDir("desktop"))
  if not temp then
    err(reason)
  end

  for f in temp do
    local indexOf = string.find(f, "/")
    if indexOf ~= nil then
      table.insert(directories, f)
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

local mouseDown = function(x, y, mouseBtn, player)
  touchX, touchY = x, y
  
end

local mouseUp = function(x, y, mouseBtn, player)
  touchX, touchY = -1, -1

end

local handleInterrupt = function()
  running = false
end
-- Event listener thread
local eventListenerT = thread.create(function()
  repeat
    -- Touch : Screen Address  , x   , y     , MouseBtn  , player
    -- Key D : Keyboard Address, idk , idk   , key id, player
    -- Key U : Same as Key D
    -- Scroll: Screen Address  , x   , y     , 1/-1 (dir), player
    -- Drag  : Screen Address  , x   , y     , MouseBtn  , player
    -- Paste : Address?        , text, player ---- Happens for each line

    -- TODO: Have this custom handeled by class requiring them
    local id, address, x, y, z, player = event.pullMultiple("interrupt", "key_down", "key_up", "touch", "drop", "clipboard", "scroll")
    if     id == "interrupted" then
      handleInterrupt()
    elseif id == "key_down" then
      fractalCore.setKeyDown(y, true)
    elseif id == "key_up" then
      fractalCore.setKeyDown(y, false)
    elseif id == "touch" then
      mouseDown(x, y, z, player)
    elseif id == "drop" then
      mouseUp(x, y, z, player)
    end
  until false
end)

local init = function()
  w, h = gpu.getResolution()
  if not fs.isDirectory(fractalCore.getDir("desktop")) then
    if fs.makeDirectory(fractalCore.getDir("desktop")) == nil then
      err("Error creating desktop directory!")
      os.exit()
    end
    -- Give them a nice welcoming gift
    local welcomeFile = fs.open(fractalCore.getDir("desktop").."/welcome.txt", "w")
    welcomeFile:write("Hello, and welcome to Fractal OS")
    welcomeFile:close()
  end

  refreshFileList()
  refreshDesktop()
  drawDesktopIcons()
  drawTaskBar()

  while running do
    drawInfo()
    if fractalCore.keyDown(fractalCore.keycode("F5")) then
      os.execute("cls")
      w, h = gpu.getResolution()
      refreshDesktop()
      drawTaskBar()
    end
    os.sleep(0.1)
  end
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  os.execute("cls")
  os.exit()
end

init()
