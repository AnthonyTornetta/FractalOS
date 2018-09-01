local fractalCore = require("fractalcore")
local winApi = require("window-api");
winApi.clearAll();

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

-- All the button ids and such
local taskBarBox = "task-bar-box"
local btnGo = "go-btn"

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
  local btnId = winApi.withinButtons(x, y)

  if btnId ~= nil then
    if btnId == btnGo then
      msgBox("makeme")
    elseif(btnId == "msg-box-ok") then
      winApi.clearBox('msg-box')
      winApi.clearButton("msg-box-ok")
      winApi.clearTextBox("msg-box-message")
      winApi.drawAll()
      print("OK")
    else
      if(type(btnId) == "number" and fractalCore.tableLength(files) <= btnId) then
        os.execute(fractalCore.getDir("desktop")..files[btnId])
      end
    end
  end
end

local mouseUp = function(x, y, mouseBtn, player)
  touchX, touchY = -1, -1
end

function handleInterrupt()
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

    local status, err = pcall(
      function()
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
      end)

    if not status then
      print(err)
    end
  until false
end)

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

  winApi.setBox("background", 1, 1, w, h, 0xFFFFFF)
  setupButtons()
  setupTaskbar()

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

function msgBox(msg, ...)
  local arg = {...}

  local len = #arg;

  w, h = gpu.getResolution()

  local boxW = 20
  local boxH = 6
  local boxX = w / 2 - boxW / 2
  local boxY = h / 2 - boxH

  local btnW = 8
  local btnH = 3

  winApi.setBox("msg-box", boxX, boxY, boxW, boxH, 0xDDDDDD, 0xCCCCCC)
  if(len == 0 or len == 1) then
    local drawX = boxX + boxW / 2 - btnW / 2

    winApi.setTextBox("msg-box-message", drawX, boxY + 1, btnW, 1, 0xDDDDDD, 0x000000, msg)
    winApi.setButton("msg-box-ok", drawX, boxY + boxH - btnH - 1, btnW, btnH, 0xDDDDDD, 0x000000, "OK")
  end

  winApi.drawAll()
end

init()
