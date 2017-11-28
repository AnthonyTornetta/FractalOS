local fractalCore = require("fractalCore")
local fs = require("filesystem")

fractalCore.rootDir = "/fractal/"
fractalCore.coreDir = fractalCore.rootDir.."core/"
fractalCore.userDir = fractalCore.rootDir.."user/"
fractalCore.appsDir = fractalCore.rootDir.."apps/"       -- All users can use
fractalCore.localAppsDir = fractalCore.userDir.."apps/"  -- Other users on the computer cannot use apps in another user's folder
fractalCore.desktopDir = fractalCore.userDir.."desktop/"

print("Booting Fractal OS...")

local boot = function()
  if not fs.isDirectory(fractalCore.rootDir) then
    print("CRITICAL ERROR: The root directory of Fractal OS is missing!")
    print("Solution: re-install the OS; the pastebin is "..fractalCore.installPastebin)
    os.exit()
  end
  if not fs.isDirectory(fractalCore.coreDir) then
    print("CRITICAL ERROR: The core directory of Fractal OS is missing!")
    print("Solution: re-install the OS; the pastebin is "..fractalCore.installPastebin)
    os.exit()
  end
  if not fs.isDirectory(fractalCore.appsDir) then
    print("Warning: There is no directory for global apps")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.appsDir) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.appsDir)
        os.exit()
      end
    end
  end
  if not fs.isDirectory(fractalCore.userDir) then
    print("Warning: There is no directory for the current user")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.userDir) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.userDir)
        os.exit()
      end
      if fs.makeDirectory(fractalCore.localAppsDir) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.localAppsDir)
        os.exit()
      end
      if fs.makeDirectory(fractalCore.desktopDir) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.desktopDir)
        os.exit()
      end
    end
  end
  if not fs.isDirectory(fractalCore.desktopDir) then
    print("Warning: Missing desktop directory")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.desktopDir) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.desktopDir)
        os.exit()
      end
    end
  end
  if not fs.isDirectory(fractalCore.localAppsDir) then
    print("Warning: Missing local apps directory")
    print("Make the directory? (y/n) ")
    if string.lower(io.read()) == "y" then
      if fs.makeDirectory(fractalCore.localAppsDir) == nil then
        print("CRITICAL ERROR: Could not create directory: "..fractalCore.localAppsDir)
        os.exit()
      end
    end
  end
  print("All directories found...")
  os.execute(fractalCore.coreDir.."desktop.lua")
end



boot()
