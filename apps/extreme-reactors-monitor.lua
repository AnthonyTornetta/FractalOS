local comp = require("component")
local thread = require("thread")
local fs = require("filesystem")
local bApi = require("button-api")
local event = require("event")
local serialization = require("serialization")

local gpu = comp.gpu
local reactor = comp.br_reactor

local configFile = "/fractal/apps/settings/reactor-monitor.cfg"
local config = {}

local running = true

local btnSubMinID = "btn-sub-min"
local btnAddMinID = "btn-add-min"
local btnSubMaxID = "btn-sub-max"
local btnAddMaxID = "btn-add-max"


--[[
     If this is on 'monitor', the code does the on/off thing for you
     If this is on 'off', the reactor is off and won't change unless user inputs an on signal
     If this is on 'on', the reactor is on and won't change unless user inputs an off signal
  ]]
local reactorState = "monitor" -- monitor, on, off



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

function setMinPercent(x)
  config.percentages.minPercent = x
end
function setMaxPercent(x)
  config.percentages.maxPercent = x
end
function getMinPercent()
  return config.percentages.minPercent
end
function getMaxPercent()
  return config.percentages.maxPercent
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
  setMinPercent(5)
  setMaxPercent(95)

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
  local btnId = bApi.within(x, y)
  if btnId ~= -1 then
    if btnId == btnSubMinID then
      setMinPercent(getMinPercent() - 1)
    elseif btnId == btnAddMinID then
      setMinPercent(getMinPercent() + 1)
    elseif btnId == btnSubMaxID then
      setMaxPercent(getMaxPercent() - 1)
    elseif btnId == btnAddMaxID then
      setMaxPercent(getMaxPercent() + 1)
    end

    setMinPercent(clamp(getMinPercent(), 0, getMaxPercent() - 1))
    setMaxPercent(clamp(getMaxPercent(), getMinPercent() + 1, 100))
  end
end

function run()
  if not readConfig() then
    createConfig()
  end

  currentRf = reactor.getEnergyStored()
  maxFuel = reactor.getFuelAmountMax()

  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  gpu.fill(1, 1, w, h, " ")

  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x333333)
  drawBox(1, 1, w - 1, h - 1)

  local width = 100
  local height = 15

  local btnPaddingX = 6
  local btnPaddingY = 1
  local btnDrawX = width + btnPaddingX
  local btnDrawY = 2
  local btnWidth = 9
  local btnHeight = 3
  bApi.setButton(btnSubMinID, btnDrawX                         , btnDrawY + btnPaddingY, btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "-")
  bApi.setButton(btnAddMinID, btnDrawX + btnWidth + btnPaddingX, btnDrawY + btnPaddingY, btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "+")

  bApi.setButton(btnSubMaxID, btnDrawX                         , btnDrawY + btnPaddingY * 2 + btnHeight, btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "-")
  bApi.setButton(btnAddMaxID, btnDrawX + btnWidth + btnPaddingX, btnDrawY + btnPaddingY * 2 + btnHeight, btnWidth, btnHeight, 0x4863A0, 0xFFFFFF, "+")

  drawBox(1, 1, width + 1, height + 1)

  drawBox(1, height + 2, width + 1, height + 1)

  -- Event listener thread
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

    bApi.drawAll()
    gpu.setForeground(0xFFFFFF)

    drawX = btnDrawX + btnWidth + btnPaddingX + btnWidth + btnPaddingX
    drawY = btnDrawY + btnPaddingY + math.floor(btnHeight / 2)

    gpu.setBackground(0x000000)
    gpu.set(drawX, drawY, "              ")
    gpu.setBackground(0x4863A0)
    gpu.set(drawX, drawY, getMinPercent().."%".." Min")

    drawY = drawY + math.floor(btnHeight / 2) + btnHeight
    gpu.setBackground(0x000000)
    gpu.set(drawX, drawY, "              ")
    gpu.setBackground(0x4863A0)
    gpu.set(drawX, drawY, getMaxPercent().."%".." Max")

    if percentFilled >= getMaxPercent() then
      reactorOff()
    end

    if percentFilled <= getMinPercent() then
      reactorOn()
    end
    os.sleep(0.1)
  end

  saveConfig()
  eventListenerT:kill()
  gpu.setForeground(0xFFFFFF)
  gpu.setBackground(0x000000)
  os.execute("cls")
end

run()
