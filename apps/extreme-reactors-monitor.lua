local serialization = require("serialization")
local wApi = require("window-api")
wApi.clearAll()

local comp = require("component")
local thread = require("thread")
local fs = require("filesystem")
local event = require("event")

if not comp.isAvailable("br_reactor") then
  print("No Extreme Reactors reactor found!")
  os.exit()
end

local reactor = comp.br_reactor
local gpu = comp.gpu

local configFile = "/fractal/apps/settings/reactor-monitor.cfg"
local config = {}

local running = true

-- Buttons
local btnSubMinID = "btn-sub-min"
local btnAddMinID = "btn-add-min"
local btnSubMaxID = "btn-sub-max"
local btnAddMaxID = "btn-add-max"
local btnReactorControlID = "btn-reactor-control"

-- Text boxes
local txtMinID = "txt-min"
local txtMaxID = "txt-max"


--[[
     If this is on 'automatic', the code does the on/off thing for you
     If this is on 'off', the reactor is off and won't change unless user inputs an on signal
     If this is on 'on', the reactor is on and won't change unless user inputs an off signal
  ]]
local reactorState = "automatic" -- automatic, on, off
local reactorStatus = "OFF"

if not reactor.getMultiblockAssembled() then
  print("The reactor must be assembled correctly!")
  return 1
end

local w, h = gpu.getResolution()

reactor["stats"] = {}
local running = true
local maxRF = 10000000
local currentRF = 0
local currenFuel = 0
local maxFuel = 0

local minPowerRod = 0
local maxPowerRod = 100

function reactorOff()
  reactor.setActive(false)
end

function reactorOn()
  reactor.setActive(true)
end

function getMaxEnergy()
  return 10000000
end

function getMinPercent()
  return config.percentages.minPercent
end
function getMaxPercent()
  return config.percentages.maxPercent
end
function setMinPercent(x)
  config.percentages.minPercent = x
  wApi.setTextBoxText(txtMinID, tostring(getMinPercent()).."%")
end
function setMaxPercent(x)
  config.percentages.maxPercent = x
  wApi.setTextBoxText(txtMaxID, tostring(getMaxPercent()).."%")
end

function drawBox(x, y, width, height)
  gpu.fill(x, y, width, 1, " ")
  gpu.fill(x, y, 1, height, " ")
  gpu.fill(x + width, y, 1, height, " ")
  gpu.fill(x, y + height, width + 1, 1, " ")
end

local saveConfig = function()
  local file = io.open(configFile,"w")
  file:write(serialization.serialize(config, false))
  file:close()
end

--#read_config

local readConfig = function()
  config.percentages = {}

  if not fs.exists(configFile) then
    return false
  end
  local file = io.open(configFile,"r")
  local c = serialization.unserialize(file:read(fs.size(configFile)))
  file:close()
  for k,v in pairs(c) do
    config[k] = v
  end
  return true
end

local createConfig = function()
  config.percentages = {}
  config.percentages.minPercent = 5
  config.percentages.maxPercent = 95

  fs.makeDirectory("/fractal/apps/settings")
  saveConfig()
end

function handleInterrupt()
  running = false
end

function clamp(var, min, max)
  if var < min then
    var = min
  end
  if var > max then
    var = max
  end
  return var
end

function mouseDown(x, y)
  local btnId = wApi.withinButtons(x, y)
  if btnId ~= -1 then
    if btnId == btnSubMinID then
      setMinPercent(getMinPercent() - 1)
      setMinPercent(clamp(getMinPercent(), 0, getMaxPercent() - 1))
    elseif btnId == btnAddMinID then
      setMinPercent(getMinPercent() + 1)
      setMinPercent(clamp(getMinPercent(), 0, getMaxPercent() - 1))
    elseif btnId == btnSubMaxID then
      setMaxPercent(getMaxPercent() - 1)
      setMaxPercent(clamp(getMaxPercent(), getMinPercent() + 1, 100))
    elseif btnId == btnAddMaxID then
      setMaxPercent(getMaxPercent() + 1)
      setMaxPercent(clamp(getMaxPercent(), getMinPercent() + 1, 100))
    elseif btnId == btnReactorControlID then
      if reactorState == "automatic" then
        reactorState = "on"
      elseif reactorState == "on" then
        reactorState = "off"
      else
        reactorState = "automatic"
      end
    end
  end
end

function run()
  if not readConfig() then
    createConfig()
  end

  if reactor.getActive() then
    reactorStatus = "ON"
  else
    reactorStatus = "OFF"
  end

  currentRf = reactor.getEnergyStored()
  maxFuel = reactor.getFuelAmountMax()

  -- Create all the GUI elements
  local width = 100
  local height = 15

  local btnPaddingX = 6
  local btnPaddingY = 1
  local btnWidth = 9
  local btnHeight = 3
  local btnDrawX = width + btnPaddingX
  local btnDrawXRight = btnDrawX + btnWidth + btnPaddingX
  local btnDrawTxtBox = btnDrawXRight + btnWidth + btnPaddingX
  local btnDrawY = 2 + btnPaddingY
  local txtWidth = 9
  local txtHeight = 1

  wApi.setButton (btnSubMinID, btnDrawX     , btnDrawY    , btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "-")
  wApi.setButton (btnAddMinID, btnDrawXRight, btnDrawY    , btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "+")
  wApi.setTextBox(txtMinID   , btnDrawTxtBox, btnDrawY + 1, txtWidth, txtHeight, 0x4863A0, 0xFFFFFF, tostring(getMinPercent()).."%")
  btnDrawY = btnDrawY + btnPaddingY * 2 + btnHeight

  wApi.setButton (btnSubMaxID, btnDrawX     , btnDrawY    , btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "-")
  wApi.setButton (btnAddMaxID, btnDrawXRight, btnDrawY    , btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "+")
  wApi.setTextBox(txtMaxID   , btnDrawTxtBox, btnDrawY + 1, txtWidth, txtHeight, 0x4863A0, 0xFFFFFF, tostring(getMaxPercent()).."%")

  btnDrawY = btnDrawY + btnPaddingY * 2 + btnHeight

  wApi.setButton (btnReactorControlID, btnDrawX    , btnDrawY, btnWidth * 2 + btnPaddingX, btnHeight, 0xAAAAAA, 0xFFFFFF, "Automatic Control: "..reactorStatus)

  -- Draw the initial window template
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, w, h, " ")

  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x333333)
  drawBox(1, 1, w - 1, h - 1)

  drawBox(1, 1, width + 1, height + 1)
  drawBox(1, height + 2, width + 1, height + 1)

  -- Event listener thread for clicks n stuff
  local eventListenerT = thread.create(function()
    repeat
      local id, _, x, y = event.pullMultiple("touch", "interrupted")
      if id == "interrupted" then
        handleInterrupt()
      elseif id == "touch" then
        mouseDown(x, y)
      end

    until false
  end)

  while running do
    local RFProduced = reactor.getEnergyStored() - currentRf
    currentRF = reactor.getEnergyStored()
    currentFuel = reactor.getFuelAmount()

    local percentFilled = math.ceil((currentRF / maxRF) * width)
    local percentFuelFilled = math.ceil((currentFuel / maxFuel) * width)

    gpu.setBackground(0x000000)
    gpu.fill(2, 2, width, height, " ")
    gpu.setBackground(0x33FF33)
    gpu.fill(2, 2, percentFilled, height, " ")
    gpu.setBackground(0x000000)
    gpu.fill(2, height + 3, width, height, " ")
    gpu.setBackground(0xFFFF33)
    gpu.fill(2, height + 3, percentFuelFilled, height, " ")

    if reactorState == "automatic" then
      if percentFilled >= getMaxPercent() then
        reactorOff()
      elseif percentFilled <= getMinPercent() then
        reactorOn()
      end
    elseif reactorState == "on" then
      reactorOn()
    else
      reactorOff()
    end

    if reactor.getActive() then
      reactorStatus = "ON"
    else
      reactorStatus = "OFF"
    end

    if reactorState == "automatic" then
      wApi.setButtonText(btnReactorControlID, "Automatic Control: "..reactorStatus)
      wApi.setButtonBackground(btnReactorControlID, 0xAAAAAA)
    elseif reactorState == "on" then
      wApi.setButtonText(btnReactorControlID, "ON")
      wApi.setButtonBackground(btnReactorControlID, 0x00FF00)
    elseif reactorState == "off" then
      wApi.setButtonText(btnReactorControlID, "OFF")
      wApi.setButtonBackground(btnReactorControlID, 0xFF0000)
    end

    wApi.drawAll()

    os.sleep(0.1)
  end

  saveConfig()
  eventListenerT:kill()
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  os.execute("cls")
end

run()
