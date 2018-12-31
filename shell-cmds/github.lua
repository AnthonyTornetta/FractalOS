local component = require("component")
local web = require("web-api")
local shell = require("shell")

local args, options = shell.parse(...)

local raw = "https://raw.githubusercontent.com/"

if #args < 2 then
    print("Usages:")
    print("NOTICE: Make sure to not include \"/blob/\" in the path to the file on GitHub.")
    print("github run <github path> (<args...>)")
    print("github get <github path> <file>")
    os.exit()
end

if args[1] == "run" then
    local success, resp = web.runFromUrl(raw..args[2], {table.unpack(args, 3, #args)})
    if not s and resp ~= nil then
        print("Error downloading/executing item. Did you include \"/blob/\" in the GitHub file's path?")
    end
elseif args[1] == "get" then
    if #args < 3 then
        print("Usage: github get <url> <file>")
        os.exit()
    else
        if web.download(raw..args[2], args[3]) then
            print("Success!")
        else
            print("Error downloading item. Did you include \"/blob/\" in the GitHub file's path?")
        end
    end
end
