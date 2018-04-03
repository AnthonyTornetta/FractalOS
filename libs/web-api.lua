local comp = require("component")
local fs = require("filesystem")

local api = {}

function api.internetRequest(url)
  checkArg(1, url, "string")

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

function api.download(url, path)
  checkArg(1, url, "string")
  checkArg(2, path, "string")
  local success, response = api.internetRequest(url)

  if success then
    fs.makeDirectory(fs.path(path) or "/")
    local file = io.open(path, "w")
    file:write(response)
    file:close()
  end

  return success
end

function api.runFromUrl(url, ...)
  checkArg(1, url, "string")

  local success, response = api.internetRequest(url)
  if success then
    result, reason = load(result)
		if result then
			result = { pcall(result, ...) }
			if result[1] then
				return table.unpack(result, 2)
			else
				return false, "Failed to run script: "..tostring(result[2])
			end
		else
			return false, "Failed to run script: "..tostring(loadReason)
    end
  else
    return false, response
  end
end

return api
