local comp = require("component")
local fs = require("filesystem")

local gpu = comp.gpu
local reactor = comp.br_reactor

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

function drawBox(x, y, width, height)
  gpu.fill(x, y, width, 1, " ")
  gpu.fill(x, y, 1, height, " ")
  gpu.fill(x + width, y, 1, height, " ")
  gpu.fill(x, y + height, width + 1, 1, " ")
end

function run()
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

  drawBox(1, 1, width + 1, height + 1)

  drawBox(1, height + 2, width + 1, height + 1)

  while true do
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

    

    if percentFilled >= 95 then
      reactorOff()
    end

    if percentFilled <= 10 then
      reactorOn()
    end
    os.sleep(0.1)
  end
end

run()
