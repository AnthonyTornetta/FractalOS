local comp = require("component")
local fs = require("filesystem")
local event = require("event")
local term = require("term")

local internet = comp.internet
local gpu = comp.gpu

local line = 1

oW, oH = gpu.getResolution()
print(oW..", "..oH)

gpu.setForeground(0x004488)
gpu.setBackground(0xffffff)
gpu.fill(1, 1, oW, oH, " ")

gpu.setResolution(40, 20)
w, h = gpu.getResolution()

local printCentered = function(txt, height)
  gpu.set(w / 2 - math.floor(string.len(txt) / 2), height, txt)
  line = height + 1
  if line > h then
    line = 1
  end
end

local clearCentered = function(height)
  printCentered("                                          ", height)
end

printCentered("Welcome to Fractal OS!", 2)
printCentered("An open source OS for Open Computers!", 3)

os.sleep(2)

printCentered("Install? y/n", 5)

local ch = ''

repeat -- Wait until they type a valid key...
  _, _, _, ch = event.pull('key_down')
until ch == 21 or ch == 49 -- y = 21; n = 49

if ch == 49 then
  printCentered("Cancelling installation", line)
  os.sleep(2)
  gpu.setForeground(0xffffff)
  gpu.setBackground(0x000000)
  gpu.setResolution(oW, oH)

  gpu.fill(1, 1, oW, oH, " ")

  term.clear()
  os.exit()
end

local function internetRequest(url)
  local success, response = pcall(internet.request, url)
  if success then
    local responseData = ""
    while true do
      local data, responseChunk = response.read()
      if data then
        responseData = responseData..data
      else
        if responseChunk then
          return false, responseChunk
        else
          return true, responseData
        end
      end
    end
  else
    return false, reason
  end
end

local function err(ex) -- TODO: Make better
  os.execute("cls")
  print(ex)
  os.exit()
end

local function getFileFromURL(url, path)
  printCentered("Downloading...", 12)

  local printOut = url
  for i = string.len(url), 1, -1 do
    if string.sub(url, i, i) == "/" then
      printOut = string.sub(url, i + 1, string.len(url))
      break
    end
  end
  
  printCentered(printOut, 13)

  local success, response = internetRequest(url)
  if success then
    fs.makeDirectory(fs.path(path) or "/")
    local file = io.open(path, "w")
    file:write(response)
    file:close()

    clearCentered(12)
    clearCentered(13)
  else
    err("Could not connect to the url \""..url.."\"")

    clearCentered(12)
    clearCentered(13)
  end
end

term.clear()

local githubRoot = "https://raw.githubusercontent.com/Cornchipss/FractalOS/master/"
printCentered("Installing Core Components...", 5)

-- [ Downloads core libraries needed for the installer to work ] --

local _, tempStr = internetRequest(githubRoot.."core/fractalcore.lua")
local fractalcore = load(tempStr)()

_, tempStr = internetRequest(githubRoot.."libs/json-api.lua")
local json = load(tempStr)()

_, tempStr = internetRequest(githubRoot.."packages.json")
local temp = json.decode(tempStr)

local function getDir(str)
  local dir = ""

  local parenOpenAt = -1

  for i = 1, string.len(str) do
    local c = string.sub(str, i, i)

    if c == "(" and parenOpenAt == -1 then
      parenOpenAt = i
    elseif c == ")" then
      dir = string.sub(str, parenOpenAt + 1, i - 1)
      break
    end
  end

  if dir ~= "" then
    dir = fractalcore.getDir(dir)
  else
    dir = "/" 
  end

  return dir
end

function resolvePathAfterParen(saveto)
  local index = string.find(saveto, ")")
  
  if index == nil then
    return saveto
  else
    return string.sub(saveto, index + 1)
end

-- [ Installs core libraries for the OS to work ] --

for k, v in pairs(temp["files"]["core"]) do
  getFileFromURL(githubRoot..v["file"], getDir(v["saveto"]) .. "/" .. resolvePathAfterParen(v["saveto"]))
end

printCentered("Installing additional packages", 3)

-- [ Installs non-manditory packages ] (todo) --
for k, v in pairs(temp["files"]) do
  if k ~= "core" then
    clearCentered(5)
    printCentered("Install ".. k .."? y/n", 5)

    local ch = ''

    repeat -- Wait until they type a valid key...
      _, _, _, ch = event.pull('key_down')
    until ch == 21 or ch == 49 -- y = 21; n = 49

    if ch == 21 then
      for _, f in ipairs(temp["files"][k]) do
        getFileFromURL(githubRoot..f["file"], getDir(f["saveto"]) .. "/" .. resolvePathAfterParen(f["saveto"]))
      end
    end
  end
end

clearCentered(9)
term.clear()
printCentered("Fractal OS Installation Complete!" , 3)
os.sleep(2)
gpu.setResolution(oW, oH)
gpu.setForeground(0xFFFFFF)
gpu.setBackground(0x000000)
term.clear()
