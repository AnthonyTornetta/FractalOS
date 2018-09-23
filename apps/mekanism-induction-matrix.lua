local computer = require("computer")
local comp = require("component")
local win = require("window-api")
local thread = require("thread")

local gpu = comp.gpu

if not comp.isAvailable("induction_matrix") then
  print("No Mekanism Induction Matrix Found!")
  os.exit()
end

win.clearAll()

local matrix = comp.induction_matrix

local running = true
local w, h = gpu.getResolution()

local eventListenerT = thread.create(function()
  repeat
    local id, _, x, y = event.pullMultiple("touch", "interrupted")
    if id == "interrupted" then
      handleInterrupt()
    end
  until not running
end)

function handleInterrupt()
  running = false
  os.exit()
end

function getBarColor(percentFilled)
  if percentFilled < 10 then
    return 0xFF0000
  elseif percentFilled < 20 then
    return 0xCC3300
  elseif percentFilled < 30 then
    return 0xAA4400
  elseif percentFilled < 40 then
    return 0x995500
  elseif percentFilled < 50 then
    return 0x886600
  elseif percentFilled < 60 then
    return 0x777700
  elseif percentFilled < 70 then
    return 0x668800
  elseif percentFilled < 80 then
    return 0x44AA00
  elseif percentFilled < 90 then
    return 0x33CC00
  else
    return 0x00FF00
  end
end

local barPower = "percent-power"
local txtPercentPower = "percent-power"
local txtIO = "io"
local txtStoredPower = "stored-power"

local barHeight = math.ceil(h / 1.2)

win.setProgressBar(barPower, 1, 1, w, barHeight, 0x333333, 0x000000)
win.setTextBox("0%", 1, barHeight + 2, 2, 1, 0x000000, 0x00FF00, "0%")
win.setTextBox("100%", w - 4, barHeight + 2, 4, 1, 0x000000, 0x00FF00, "100%")
win.setTextBox(txtPercentPower, w / 2 - 2, barHeight + 2, 4, 1, 0x000000, 0x00FF00, "----")
win.setTextBox(txtIO, 1, barHeight + 6, w, 1, 0x000000, 0x00FF00, "-")
win.setTextBox(txtStoredPower, 1, barHeight + 3, w, 3, 0x000000, 0x00FF00, "x GJ / y GJ")

while running do
  local maxPower = matrix.getMaxEnergy()
  local storedPower = matrix.getEnergy()
  local percentFilled = math.ceil((storedPower / maxPower) * 100)

  local input = matrix.getInput()
  local output = matrix.getOutput()

  win.setTextBoxText(txtPercentPower, percentFilled.."%")
  win.setProgressBarColors(barPower, nil, getBarColor(percentFilled))
  win.setProgressBarProgress(barPower, percentFilled)

  local col
  if output > input and percentFilled ~= 100 then
    col = 0xFF0000
  elseif input == output then
    col = 0x3333FF
  else
    col = 0x00FF00
  end

  win.setTextBoxColors(txtIO, nil, col)

  local decimals = 5
  local roundDif = math.pow(10, decimals) -- 10 ^ how many decimals to show
  local TO_GJ_CONVERSION = 1000000000 -- x units per GJ
  local TPS = 20 -- x ticks per second

  local roundedStored = math.ceil(storedPower * roundDif / TO_GJ_CONVERSION) / roundDif
  local roundedMax = math.ceil(maxPower * roundDif / TO_GJ_CONVERSION) / roundDif

  local roundedInput = math.ceil(input * roundDif / TO_GJ_CONVERSION) / roundDif * TPS
  local roundedOutput = math.ceil(output * roundDif / TO_GJ_CONVERSION) / roundDif * TPS

  win.setTextBoxText(txtStoredPower, string.format("%."..decimals.."f", roundedStored).." GJ / "..string.format("%."..decimals.."f", roundedMax).." GJ")
  win.setTextBoxText(txtIO, "Input: "..string.format("%."..decimals.."f", roundedInput).." GJ/s | ".."Output: "..string.format("%."..decimals.."f", roundedOutput).." GJ/s")

  if percentFilled <= 10 and input - output <= 0 then
    computer.beep(500)
  end

  win.drawAll()

  os.sleep(1)
end
