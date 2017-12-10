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

function api.getButtonPosition(id)
  return buttons[id]["x"], buttons[id]["y"]
end

function api.getButtonDimentions(id)
  return buttons[id]["width"], buttons[id]["height"]
end

function api.setButtonAlignment(id, alignment)
  buttons[id]["text-align"] = centered
end

function api.getButtonTextAlignment(id)
  return buttons[id]["text-align"]
end

function api.getButtonBackgroundColor(id)
  return buttons[id]["bgcol"]
end

function api.getButtonForegroundColor(id)
  return buttons[id]["fgcol"]
end

function api.getButtonColors(id)
  return buttons[id]["bgcol"], buttons[id]["fgcol"]
end

function api.drawButton(id)
  local bgCol, fgCol = api.getButtonColors(id)

  gpu.setBackground(bgCol)
  gpu.setForeground(fgCol)

  local x, y = api.getButtonPosition(id)
  local width, height = api.getButtonDimentions(id)
  gpu.fill(x, y, width, height, " ")

  local alignment = api.getButtonTextAlignment(id)
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

function api.drawAllButtons()
  for k, v in pairs(buttons) do
    api.drawButton(k)
  end
end

function api.withinButtons(x, y)
  for id, _ in pairs(buttons) do
    local btnX, btnY = api.getButtonPosition(id)
    local width, height = api.getButtonDimentions(id)
    if x >= btnX and x < btnX + width then
      if y >= btnY and y < btnY + height then
        return id
      end
    end
  end
  return -1
end

function api.setTextBox(id, x, y, width, height, bgcolor, fgcolor, text)
  textBoxes[id] = {}
  textBoxes[id]["x"] = x
  textBoxes[id]["y"] = y
  textBoxes[id]["width"] = width
  textBoxes[id]["height"] = height
  textBoxes[id]["text"] = text
  textBoxes[id]["bgcol"] = bgcolor
  textBoxes[id]["fgcol"] = fgcolor
  textBoxes[id]["alignment"] = "center"
end

function api.getTextBoxText(id)
  return textBoxes[id]["text"]
end

function api.setTextBoxText(id, text)
  textBoxes[id]["text"] = text
end

function api.getTextBoxDimensions(id)
  return textBoxes[id]["width"], textBoxes[id]["height"]
end

function api.setTextBoxDimensions(id, w, h)
  if w ~= nil then
    textBoxes[id]["width"] = w
  end
  if h ~= nil then
    textBoxes[id]["height"] = h
  end
end

function api.getTextBoxPrevLength(id)
  return textBoxes[id]["prevLen"]
end

function api.getTextBoxColors(id)
  return textBoxes[id]["bgcol"], textBoxes[id]["fgcol"]
end

function api.setTextBoxAlignment(id, alignment)
  textBoxes[id]["alignment"] = alignment
end

function api.getTextBoxAlignment(id)
  return textBoxes[id]["alignment"]
end

function api.drawTextBox(id)
  local bgCol, fgCol = api.getTextBoxColors(id)

  local prevBG = gpu.setBackground(bgCol)
  local prevFG = gpu.setForeground(fgCol)

  local x, y = api.getTextBoxPosition(id)
  local w, h = api.getTextBoxDimensions(id)
  local txt = api.getTextBoxText(id)

  gpu.fill(x, y, w, h, " ")

  local drawX = x
  local drawY = y
  if api.getTextBoxAlignment(id) == "center" then
    drawX = drawX + math.floor(w / 2) - (#txt / 2)
    drawY = drawY + math.floor(h / 2)
  end
  gpu.set(drawX, drawY, txt)

  gpu.setBackground(prevBG)
  gpu.setForeground(prevFG)
end

function api.drawAllTextBoxes()
  for k, v in pairs(textBoxes) do
    api.drawTextBox(k)
  end
end

function api.getTextBoxPosition(id)
  return textBoxes[id]["x"], textBoxes[id]["y"]
end

function api.getTextBoxDimentions(id)
  return textBoxes[id]["width"], textBoxes[id]["height"]
end

function api.drawAll()
  api.drawAllButtons()
  api.drawAllTextBoxes()
end


return api
