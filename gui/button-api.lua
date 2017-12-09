local comp = require("component")
local gpu = comp.gpu

local api = {}
buttons = {}
textBoxes = {}

function api.clearButtons()
  buttons = {}
end

function api.clearTextBoxes()
  textBoxes = {}
end

function api.setButton(id, x, y, width, height, bgcolor, fgcolor, text)
  buttons[id] = {}
  buttons[id]["x"] = x
  buttons[id]["y"] = y
  buttons[id]["text"] = text
  buttons[id]["bgcol"] = bgcolor
  buttons[id]["fgcol"] = fgcolor
  buttons[id]["width"]  = width
  buttons[id]["height"] = height
  buttons[id]["text-align"] = "center"
end

function api.setTextBox(id, x, y, width, height, bgcolor, fgcolor, text)
  textBoxes[id] = {}
  textBoxes[id]["x"] = x
  textBoxes[id]["y"] = y
  textBoxes[id]["text"] = text
  textBoxes[id]["bgcol"] = bgcolor
  textBoxes[id]["fgcol"] = fgcolor
  textBoxes[id]["width"]  = width
  textBoxes[id]["height"] = height
  textBoxes[id]["text-align"] = "center"
end

function api.getButtonPosition(id)
  return buttons[id]["x"], buttons[id]["y"]
end

function api.getButtonDimentions(id)
  return buttons[id]["width"], buttons[id]["height"]
end

function api.setAlignment(id, alignment)
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
  return buttons[id]["bgcol"], buttons[id]["fgcol"]
end

function api.draw(id)
  local bgCol, fgCol = api.getColors(id)

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
    drawY = y + math.floor(height / 2)
  end

  gpu.set(drawX, drawY, buttons[id]["text"])
end

function api.drawAll()
  for k, v in pairs(buttons) do
    api.draw(k)
  end
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
