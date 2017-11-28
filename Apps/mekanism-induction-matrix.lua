-- TODO: Make work w/ Fractal OS

local computer = require("computer");
local comp = require("component")
local gpu = comp.gpu

if not comp.isAvailable("induction_matrix") then
  print("No Mekanism Induction Matrix Found!")
  os.exit()
end

local matrix = comp.induction_matrix

oW, oH = gpu.getResolution() -- To set it back to the original settings after running
gpu.setResolution(100, 40)
w, h = gpu.getResolution()

gpu.setBackground(0x000000)
gpu.setForeground(0x000000)
gpu.fill(1, 1, w, h, " ")

repeat
  local maxPower = matrix.getMaxEnergy()
  local storedPower = matrix.getEnergy()
  local powerHeight = h / 2
  local percentFilled = math.ceil((storedPower / maxPower) * 100)
  local powerWidth = percentFilled * (w / 100) -- 100 because 100% is max

  local input = matrix.getInput()
  local output = matrix.getOutput()
  local dif = input - output

  -- Main power bar
  gpu.setForeground(0x333333)
  gpu.setBackground(0x333333)
  gpu.fill(w - (w - (percentFilled + 1)), 0, w + 1, h / 3 + 1, " ")

  gpu.setBackground(0x00FF00)
  gpu.setForeground(0x00FF00)

  if percentFilled < 10 then
    gpu.setBackground(0xFF0000)
    gpu.setForeground(0xFF0000)
  elseif percentFilled < 20 then
    gpu.setBackground(0xCC3300)
    gpu.setForeground(0xCC3300)
  elseif percentFilled < 30 then
    gpu.setBackground(0xAA4400)
    gpu.setForeground(0xAA4400)
  elseif percentFilled < 40 then
    gpu.setBackground(0x995500)
    gpu.setBackground(0x995500)
  elseif percentFilled < 50 then
    gpu.setBackground(0x886600)
    gpu.setForeground(0x886600)
  elseif percentFilled < 60 then
    gpu.setBackground(0x777700)
    gpu.setForeground(0x777700)
  elseif percentFilled < 70 then
    gpu.setBackground(0x668800)
    gpu.setForeground(0x668800)
  elseif percentFilled < 80 then
    gpu.setBackground(0x44AA00)
    gpu.setForeground(0x44AA00)
  elseif percentFilled < 90 then
    gpu.setBackground(0x33CC00)
    gpu.setForeground(0x33CC00)
  else
    gpu.setBackground(0x00FF00)
    gpu.setForeground(0x00FF00)
  end

  gpu.fill(1, 1, powerWidth, h / 3, " ")

  gpu.setForeground(0x00FF00)
  gpu.setBackground(0x000000)
  gpu.set(1, h / 3 + 2, "0%")
  gpu.set(w - 3, h / 3 + 2, "100%")

  local str = percentFilled.."%"

  if percentFilled < 100 then
    str = " "..str
  end
  if percentFilled == 0 then
    str = " "..str
  end

  if percentFilled <= 10 and dif <= 0 then
    computer.beep(500)
  end

  gpu.set(w / 2 - 2, h / 3 + 2, str)

  if output > input and percentFilled ~= 100 then
    gpu.setForeground(0xFF0000)
  elseif input == output then
    gpu.setForeground(0x3333FF)
  else
    gpu.setForeground(0x00FF00)
  end


  gpu.set(1, h/3 + 3, "                                                    ")
  gpu.set(1, h/3 + 3, "Input: "..math.ceil(input).." | ".."Output: "..math.ceil(output))

until false

os.sleep(3)

gpu.setResolution(oW, oH)
