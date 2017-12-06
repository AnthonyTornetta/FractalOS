local comp = require("component")
local gpu = comp.gpu

local api = {}
local buttons = {}

function api.clearButtons()
  buttons = {}
  api.clear()
end

function api.setButton(id, x, y, width, height, bgcolor, fgcolor, text)
  buttons[id] = {}
  buttons[id]["x"] = x
  buttons[id]["y"] = y
  buttons[id]["text"] = text
  buttons[id]["bgcol"] = bgcolor
  buttons[id]["fgcol"] = bgcolor
  print(buttons[id]["bgcol"], buttons[id]["fgcol"])
  buttons[id]["width"]  = width
  buttons[id]["height"] = height
  buttons[id]["text-align"] = "left"
end

function api.getButtonPosition(id)
  return buttons[id]["x"], buttons[id]["y"]
end

function api.getButtonDimentions(id)
  return buttons[id]["width"], buttons[id]["height"]
end

function api.setTextAlignment(id, alignment)
  buttons[id]["text-align"] = centered
end

function api.getTextAlignment(id)
  return buttons[id]["text-align"]
end

function api.getBackgroundColor(id)
  return buttons[id]["bgcol"]
end

function api.getForegroundColor(id)
  return buttons[id]["fgcol"]
end

function api.getColors(id)
  return api.getBackgroundColor(id), api.getForegroundColor(id)
end

function api.draw(id)
  local b = buttons[id]["bgcol"]
  local f = buttons[id]["fgcol"]
  local bgCol, fgCol = api.getColors()

  gpu.setBackground(bgCol)
  gpu.setForeground(fgCol)

  local x, y = api.getButtonPosition(id)
  local width, height = api.getButtonDimentions(id)
  gpu.fill(x, y, width, height, " ")

  local alignment = api.getTextAlignment(id)
  local drawX, drawY

  if alignment == "left" then
    drawX = x
    drawY = y + height / 2 - 1
  elseif alignment == "right" then
    drawX = (x + width) - (#buttons[id]["text"])
    drawY = y + height / 2 - 1
  else
    drawX = x + (width / 2) - (#buttons[id]["text"] / 2)
    drawY = y + height / 2 - 1
  end

  gpu.set(drawX, drawY, b["text"])
end

function api.within(x, y)
  for id, _ in pairs(buttons) do
    local btnX, btnY = api.getButtonPosition(id)
    local width, height = api.getButtonDimentions(id)
    if x >= btnX and x <= btnX + width then
      if y >= btnY and y <= btnY + height then
        return id
      end
    end
  end
  return -1
end

return api
