local wApi = require "window-api"
local comp = require "component"
local thread = require "thread"
local event = require "event"

wApi.clearAll()

if not comp.isAvailable("nc_fusion_reactor") then
  print("No nuclearcraft fusion reactor found!")

  return -1
end

local reactor = comp.nc_fusion_reactor
local gpu = comp.gpu

local MAX_FUEL_PER_CELL = 32000;

local ids =
{
  ["txtTitle"] = 1,
  ["txtPower"] = 2,
  ["txtHeat"]  = 3,
  ["txtEfficiency"] = 4,

  ["pgbEfficiency"] = 10,
  ["pgbPower"] = 11,
  ["pgbHeat"] = 12,
}

local running = true

local oldW, oldH = gpu.getResolution()

gpu.setResolution(100, 32)

local w, h = gpu.getResolution()

gpu.foregroundColor = 0x000000;
gpu.fill(1, 1, w, h, " ");

wApi.setBox(-1000, 1, 1, w, h, 0x333333, 0x333333)
wApi.setTextBox(ids["txtTitle"], 1, 1, w, 3, 0xFFFFFF, 0x000000, "Toroid Size ".. math.floor(reactor.getToroidSize()) .." Fusion Reactor")

wApi.setTextBox(ids["txtEfficiency"], 3, 5, w - 2, 1, 0x333333, 0xFF0000, "Efficiency: 0%")
wApi.setTextBoxAlignment(ids["txtEfficiency"], "left")
wApi.setProgressBar(ids["pgbEfficiency"], 2, 7, w - 2, 4, 0x111111, 0xFF0000)

wApi.setTextBox(ids["txtHeat"], 3, 12, w - 2, 1, 0x333333, 0xFF0000, "Heat: 0 K")
wApi.setTextBoxAlignment(ids["txtHeat"], "left")
wApi.setProgressBar(ids["pgbHeat"], 2, 14, w - 2, 4, 0x111111, 0xFF0000)

wApi.setTextBox(ids["txtPower"], 3, 19, w - 2, 1, 0x333333, 0xFF0000, "RF: 0 RF")
wApi.setTextBoxAlignment(ids["txtPower"], "left")
wApi.setProgressBar(ids["pgbPower"], 2, 21, w - 2, 4, 0x111111, 0xFF0000)

function handleInterrupt()
  running = false
  gpu.setResolution(oldW, oldH)
  os.exit()
end

local eventListenerT = thread.create(function()
  repeat
    local id, _, x, y = event.pullMultiple("touch", "interrupted")
    if id == "interrupted" then
      handleInterrupt()
    end
  until not running
end)

function goodColor(percentGood)
  return (math.floor(255 * (1 - percentGood)) << 16) + (math.floor(255 * percentGood) << 8)
end

while running do

  local effPercent = math.floor(reactor.getEfficiency() + 0.5) / 100
  wApi.setTextBoxText(ids["txtEfficiency"], "Efficiency: ".. math.floor(reactor.getEfficiency() + 0.5) .."%")
  wApi.setProgressBarProgress(ids["pgbEfficiency"], effPercent)

  local col = goodColor(effPercent)
  wApi.setTextBoxColors(ids["txtEfficiency"], 0x333333, col)
  wApi.setProgressBarColors(ids["pgbEfficiency"], 0x111111, col)

  if(effPercent >= .99) then
    reactor.deactivate()
  elseif(effPercent <= .97) then
    reactor.activate()

  end

  local heatPercent = reactor.getTemperature() / reactor.getMaxTemperature()

  col = goodColor(1 - heatPercent)

  wApi.setTextBoxText(ids["txtHeat"], "Heat: ".. math.ceil(reactor.getTemperature()) .." K")
  wApi.setTextBoxColors(ids["txtHeat"], 0x333333, col)
  wApi.setProgressBarProgress(ids["pgbHeat"], heatPercent)
  wApi.setProgressBarColors(ids["pgbHeat"], 0x111111, col)

  local powerPercent = reactor.getEnergyStored() / reactor.getMaxEnergyStored()
  col = goodColor(powerPercent)

  wApi.setTextBoxText(ids["txtPower"], "Power: ".. math.ceil(reactor.getEnergyStored()) .." RF + ".. math.ceil(reactor.getReactorProcessPower()) .." RF/t")
  wApi.setTextBoxColors(ids["txtPower"], 0x333333, col)
  wApi.setProgressBarProgress(ids["pgbPower"], powerPercent)
  wApi.setProgressBarColors(ids["pgbPower"], 0x111111, col)

  wApi.drawAll()
  os.sleep(1)
end
