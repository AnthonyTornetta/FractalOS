local comp = require("component")
local gpu = comp.gpu

local api = {}
local buttons = {}
local textBoxes = {}
local pBars = {}
local boxes = {}

function api.clearButtons()
  buttons = {}
end

function api.clearTextBoxes()
  textBoxes = {}
end

function api.clearProgressBars()
  pBars = {}
end

function api.clearBoxes()
  boxes = {}
end

function api.clearButton(id)
  buttons[id] = nil
end

function api.clearTextBox(id)
  textBoxes[id] = nil
end

function api.clearProgressBar(id)
  pBars[id] = nil
end

function api.clearBox(id)
  boxes[id] = nil
end

function api.clearAll()
  api.clearBoxes()
  api.clearButtons()
  api.clearTextBoxes()
  api.clearProgressBars()
end

function api.setButton(id, x, y, width, height, bgcolor, fgcolor, text)
  checkArg(2, x, "number")
  checkArg(2, y, "number")
  checkArg(2, width, "number")
  checkArg(2, height, "number")
  checkArg(2, bgcolor, "number")
  checkArg(2, fgcolor, "number")
  checkArg(2, text, "string")

  buttons[id] = {}
  buttons[id]["x"] = x
  buttons[id]["y"] = y
  buttons[id]["text"] = text
  buttons[id]["bgcol"] = bgcolor
  buttons[id]["fgcol"] = fgcolor
  buttons[id]["width"]  = width
  buttons[id]["height"] = height
  buttons[id]["text-align"] = "center"
  buttons[id]["text-align-veticle"] = "center"
end

function api.getButtonPosition(id)
  return buttons[id]["x"], buttons[id]["y"]
end

function api.getButtonDimentions(id)
  return buttons[id]["width"], buttons[id]["height"]
end

function api.setButtonAlignment(id, alignment)
  checkArg(2, alignment, "string")
  buttons[id]["text-align"] = alignment
end

function api.getButtonTextAlignment(id)
  return buttons[id]["text-align"]
end

function api.setButtonAlignmentVertical(id, alignment)
  checkArg(2, alignment, "string")
  buttons[id]["text-align-vertical"] = alignment
end

function api.getButtonTextAlignmentVertical(id)
  return buttons[id]["text-align-vertical"]
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

function api.setButtonBackground(id, c)
  checkArg(2, c, "number")
  buttons[id]["bgcol"] = c
end

function api.setButtonForeground(id, c)
  checkArg(2, c, "number")
  buttons[id]["fgcol"] = c
end

function api.setButtonText(id, text)
  checkArg(2, text, "string")
  buttons[id]["text"] = text
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
  elseif alignment == "right" then
    drawX = (x + width) - (#buttons[id]["text"])
  else
    drawX = x + (width / 2) - (#buttons[id]["text"] / 2)
  end

  local vAlignment = api.getButtonTextAlignmentVertical(id)
  if vAlignment == "top" then
    drawY = y -- works
  elseif vAlignment == "bottom" then
    drawY = y + height - 1
  else
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
  checkArg(2, x, "number")
  checkArg(3, y, "number")

  for id, _ in pairs(buttons) do
    local btnX, btnY = api.getButtonPosition(id)
    local width, height = api.getButtonDimentions(id)
    if x >= btnX and x < btnX + width then
      if y >= btnY and y < btnY + height then
        return id
      end
    end
  end
  return nil
end

function api.setTextBox(id, x, y, width, height, bgcolor, fgcolor, text)
  assert(id ~= nil, "text box id is nil")
  checkArg(2, x, "number")
  checkArg(3, y, "number")
  checkArg(4, width, "number")
  checkArg(5, height, "number")
  checkArg(6, bgcolor, "number")
  checkArg(7, fgcolor, "number")
  checkArg(8, text, "string")

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
  checkArg(2, text, "string")
  textBoxes[id]["text"] = text
end

function api.getTextBoxDimensions(id)
  return textBoxes[id]["width"], textBoxes[id]["height"]
end

function api.textBoxExists(id)
  return textBoxes[id] ~= nil
end

function api.setTextBoxDimensions(id, w, h)
  checkArg(2, w, "number")
  checkArg(3, h, "number")
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
  checkArg(2, alignment, "string")
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
    drawX = x + math.floor(w / 2) - (#txt / 2)
    drawY = y + math.floor(h / 2)
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

function api.setProgressBar(id, x, y, width, height, bgcolor, fgcolor)
  checkArg(2, x, "number")
  checkArg(3, y, "number")
  checkArg(4, width, "number")
  checkArg(5, height, "number")
  checkArg(6, bgcolor, "number")
  checkArg(7, fgcolor, "number")

  pBars[id] = {}
  pBars[id]["x"] = x
  pBars[id]["y"] = y
  pBars[id]["bgcol"] = bgcolor
  pBars[id]["fgcol"] = fgcolor
  pBars[id]["width"]  = width
  pBars[id]["height"] = height
  pBars[id]["progress"] = 0.0
end

function api.getProgressBarColors(id)
  return pBars[id]["bgcol"], pBars[id]["fgcol"]
end

function api.getProgressBarProgress(id)
  return pBars[id]["progress"]
end

function api.getProgressBarPosition(id)
  return pBars[id]["x"], pBars[id]["y"]
end

function api.getProgressBarDimensions(id)
  return pBars[id]["width"], pBars[id]["height"]
end

function api.setProgressBarColors(id, bg, fg)
  checkArg(2, bg, "number")
  checkArg(2, fg, "number")
  pBars[id]["bgcol"] = bg
  pBars[id]["fgcol"] = fg
end

function api.setProgressBarProgress(id, progress)
  checkArg(2, progress, "number")
  pBars[id]["progress"] = progress
end

function api.setProgressBarPosition(id, x, y)
  checkArg(2, x, "number")
  checkArg(3, y, "number")
  pBars[id]["x"] = x
  pBars[id]["y"] = y
end

function api.setProgressBarDimensions(id, width, height)
  checkArg(2, width, "number")
  checkArg(3, height, "number")
  pBars[id]["width"] = width
  pBars[id]["height"] = height
end

function api.drawProgressBar(id)
  local bgCol, fgCol = api.getProgressBarColors(id)

  local prevBG = gpu.setBackground(bgCol)

  local progress = api.getProgressBarProgress(id)
  local x, y = api.getProgressBarPosition(id)
  local w, h = api.getProgressBarDimensions(id)

  gpu.fill(x + progress, y, w - progress, h, " ")
  gpu.setBackground(fgCol)
  gpu.fill(x, y, progress, h, " ")

  gpu.setBackground(prevBG)
end

function api.drawAllProgressBars()
  for k, v in pairs(pBars) do
    api.drawProgressBar(k)
  end
end

function api.setBox(id, x, y, width, height, bgcol, borderColor)
  checkArg(2, x, "number")
  checkArg(3, y, "number")
  checkArg(2, width, "number")
  checkArg(5, height, "number")
  checkArg(6, bgcol, "number")

  boxes[id] = {}
  boxes[id]["x"] = x
  boxes[id]["y"] = y
  boxes[id]["bgcol"] = bgcol
  if not borderColor then
    borderColor = bgcol
  end
  boxes[id]["bordercol"] = borderColor
  boxes[id]["width"]  = width
  boxes[id]["height"] = height
end

function api.getBoxPosition(id)
  return boxes[id]["x"], boxes[id]["y"]
end

function api.getBoxDimensions(id)
  return boxes[id]["width"], boxes[id]["height"]
end

function api.getBoxColor(id)
  return boxes[id]["bgcol"]
end

function api.getBoxBorderColor(id)
  return boxes[id]["bordercol"]
end

function api.setBoxPosition(id, x, y)
  checkArg(2, x, "number")
  checkArg(3, y, "number")
  boxes[id]["x"] = x
  boxes[id]["y"] = y
end

function api.setTextBoxDimensions(id, width, height)
  checkArg(2, width, "number")
  checkArg(3, height, "number")
  boxes[id]["width"]  = width
  boxes[id]["height"] = height
end

function api.setBoxColor(id, bgcol)
  checkArg(2, bgcolor, "number")
  boxes[id]["bgcol"] = bgcolor
end

function api.setBoxBorderColor(id, col)
  checkArg(2, col, "number")
  boxes[id]["bordercol"] = col
end

function api.drawBox(id)
  local x, y = api.getBoxPosition(id)
  local w, h = api.getBoxDimensions(id)

  local bgCol = api.getBoxColor(id)
  local borderCol = api.getBoxBorderColor(id)

  local prevBG = gpu.setBackground(borderCol)
  gpu.fill(x, y, w, h, " ")
  
  gpu.setBackground(bgCol)
  gpu.fill(x + 1, y + 1, w - 1, h - 1, " ")

  gpu.setBackground(prevBG)
end

function api.drawAllBoxes()
  for k, v in pairs(boxes) do
    api.drawBox(k)
  end
end

function api.drawAll()
  -- Stage 1
  api.drawAllBoxes()

  -- Stage 2
  api.drawAllProgressBars()

  -- Stage 3
  api.drawAllTextBoxes()

  -- Stage 4
  api.drawAllButtons()
end


return api
