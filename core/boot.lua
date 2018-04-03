local fractalCore = require("fractalcore")
local fs = require("filesystem")

print("Booting Fractal OS...")

local boot = function()
  if not fs.isDirectory(fractalCore.getDir("root")) then
    print("CRITICAL ERROR: The root directory of Fractal OS is missing!")
    print("Solution: re-install the OS; the pastebin is "..fractalCore.getInstallPastebin())
    os.exit()
  end
  if not fs.isDirectory(fractalCore.getDir("core")) then
    print("CRITICAL ERROR: The core directory of Fractal OS is missing!")
    print("Solution: re-install the OS; the pastebin is "..fractalCore.getInstallPastebin())
    os.exit()
  end
  if not fs.isDirectory(fractalCore.getDir("apps")) then
    print("Warning: There is no directory for global apps")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.getDir("apps")) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.getDir("apps"))
        os.exit()
      end
    end
  end
  if not fs.isDirectory(fractalCore.getDir("user")) then
    print("Warning: There is no directory for the current user")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.getDir("user")) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.getDir("user"))
        os.exit()
      end
      if fs.makeDirectory(fractalCore.getDir("localapps")) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.getDir("localapps"))
        os.exit()
      end
      if fs.makeDirectory(fractalCore.getDir("desktop")) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.getDir("desktop"))
        os.exit()
      end
    else
      print("Unable to boot: directory ("..fractalCore.getDir("user")..") not found :(")
      os.exit()
    end
  end
  if not fs.isDirectory(fractalCore.getDir("desktop")) then
    print("Warning: Missing desktop directory")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.getDir("desktop")) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.getDir("desktop"))
        os.exit()
      end
    else
      print("Unable to boot: directory ("..fractalCore.getDir("desktop")..") not found :(")
      os.exit()
    end
  end
  if not fs.isDirectory(fractalCore.getDir("localapps")) then
    print("Warning: Missing local apps directory")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.getDir("localapps")) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.getDir("localapps"))
        os.exit()
      end
    else
      print("Unable to boot: directory ("..fractalCore.getDir("localapps")..") not found :(")
    end
  end
  print("All directories found...")
  os.execute(fractalCore.getDir("core").."desktop.lua")
end

boot()
