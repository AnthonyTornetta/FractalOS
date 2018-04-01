local wApi = require("window-api")

local comp = require("component")
local thread = require("thread")
local event = require("event")

local tape = comp.tape_drive
local gpu  = comp.gpu

local prevState = "STOPPED"
local lamps = {}

for address in comp.list('colorful_lamp') do
  local lamp = comp.proxy(address)
  table.insert(lamps, lamp)
end

local running = true

local btnPlayId = "btn-play"
local btnStopId = "btn-stop"
local btnRewindId = "btn-rewind"
local btnQuitId = "btn-quit"

local txtStateId = "txt-state"
local txtNameId = "txt-name"

function mouseDown(x, y)
  local btnId = wApi.withinButtons(x, y)
  if btnId ~= nil then
    if btnId == btnPlayId and tape ~= nil and tape.isReady() then
      if tape.getState() ~= "PLAYING" then
        tape.play()
      end
    elseif btnId == btnStopId and tape ~= nil and tape.isReady()  then
      if tape.getState() ~= "STOPPED" then
        tape.stop()
      end
    elseif btnId == btnRewindId and tape ~= nil and tape.isReady()  then
      tape.seek(-tape.getSize())
    elseif btnId == btnQuitId then
      running = false
      os.exit()
    end
  end
end

function handleInterrupt()
  if tape.getState ~= "STOPPED" then
    running = false
    os.exit()
  end
end

gpu.setResolution(32, 16)

local w, h = gpu.getResolution()
gpu.setBackground(0x333333)
gpu.fill(1, 1, w, h, " ")

wApi.setButton(btnPlayId, 2, 2, 6, 3, 0x22FF22, 0xFFFFFF, "Play")
wApi.setButton(btnRewindId, 2, 6, 6, 3, 0x2222FF, 0xFFFFFF, "Rwnd")
wApi.setButton(btnStopId, w - 6, 2, 6, 3, 0xFF2222, 0xFFFFFF, "Stop")
wApi.setButton(btnQuitId, w - 6, 6, 6, 3, 0x2222FF, 0xFFFFFF, "Exit")

local state = "No Tape"
local label = "No Tape"
if tape ~= nil and tape.isReady() then
  state = tape.getState()
  label = tape.getLabel()
end
wApi.setTextBox(txtStateId, w / 2 - 5, h - 1, 10, 1, 0x000000, 0xFFFFFF, state)
wApi.setTextBox(txtNameId, w / 2 - 10, 1, 22, 1, 0xFFFFFF, 0x000000, label)

local eventListenerT = thread.create(function()
  repeat
    local id, _, x, y = event.pullMultiple("touch", "interrupted")
    if id == "interrupted" then
      handleInterrupt()
    elseif id == "touch" then
      mouseDown(x, y)
    end
  until not running
end)

while running do
  if tape ~= nil and tape.getState() ~= nil and tape.getLabel() ~= nil and tape.isReady() then
    if prevState ~= tape.getState() then
      prevState = tape.getState()
      for k, v in pairs(lamps) do
        if(tape.getState() == "PLAYING") then
          v.setLampColor(992) -- Green
        else
          v.setLampColor(32767) -- White
        end
      end
    end
    wApi.setTextBoxText(txtStateId, tape.getState())
    wApi.setTextBoxText(txtNameId, tape.getLabel())
  else
    if prevState ~= "No Tape" then
      prevState = "No Tape"
      for k, v in pairs(lamps) do
        v.setLampColor(32767) -- White
      end
    end
    wApi.setTextBoxText(txtStateId, "No Tape")
    wApi.setTextBoxText(txtNameId, "No Tape")
  end
  wApi.drawAll()
  os.sleep(0.1)
end

if not running then
  eventListenerT:kill()
end
