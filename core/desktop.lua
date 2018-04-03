local fractalCore = require("fractalcore")
local winApi = require("window-api");

local computer = require("computer")
local comp = require("component")
local fs = require("filesystem")
local thread = require("thread")
local key = require("keyboard")
local event = require("event")

local gpu = comp.gpu
local running = true

-- Desktop width & height to work with --
w, h = gpu.getResolution()

-- Files to put on desktop
local files = {}
local directories = {}

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

-- Event Handlers
local mouseDown = function(x, y, mouseBtn, player)
  local btnId = wApi.withinButtons(x, y)
  print(btnId)
  if btnId ~= nil then
    if btnId == btnGo then
      print("makeme")
    else
      if(fractalCore.tableLength(files) <= btnId) then
        handleInterrupt()
        local appThread = thread.create(
        function()
          os.execute(files[btnId])
        end)
      end
    end
  end
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

local drawBackground = function()
  gpu.setForeground(0x000000)
  gpu.setBackground(0xFFFFFF)

  gpu.fill(1, 1, w, h, " ")
end

local setupButtons = function()
  local lastFileIndex = 0

  local iconWidth = 12
  local iconPaddingX = 2
  local iconTotalWidth = iconPaddingX + iconWidth

  local iconHeight = 6
  local iconPaddingY = 2

  local currentX = iconPaddingX
  local currentY = iconPaddingY

  local id = 0

  for k, v in ipairs(files) do
    id = id + 1

    gpu.setForeground(0xFFFFFF)
    print(k)
    print(files[k])
    os.sleep(4)

    if currentX + iconTotalWidth > w then
      currentX = iconPaddingX
      currentY = currentY + iconHeight + iconPaddingY
    end

    winApi.setButton(id, currentX, currentY, iconWidth, iconHeight, 0x555555, 0x999999, v)
    winApi.setButtonAlignmentVertical(id, "bottom")

    currentX = currentX + iconWidth + iconPaddingX
  end
  for k, v in ipairs(directories) do
    id = id + 1

    if currentX + iconTotalWidth > w then
      currentX = iconPaddingX
      currentY = currentY + iconHeight + iconPaddingY
    end

    winApi.setButton(id, currentX, currentY, iconWidth, iconHeight, 0x555555, 0x999999, v)
    winApi.setButtonAlignmentVertical(id, "bottom")

    currentX = currentX + iconWidth + iconPaddingX
  end
end

local taskBarBox = "task-bar-box"
local btnGo = "go-btn"

local setupTaskbar = function()
  winApi.setBox(taskBarBox, 1, h - 4, w, 5, 0x999999)

  winApi.setButton(btnGo, 1, h - 4, 11, 5, 0x4444FF, 0xFFFFFF, "Go!")
end

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

  setupButtons()
  setupTaskbar()

  drawBackground()
  winApi.drawAll()

  while running do
    os.sleep(0.1)
  end

  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)

  winApi.clearAll()
  os.execute("cls")
  os.exit()
end

-- Util functions
local err = function(msg)
  error(msg)
end

init()
