-------------------
-- Configuration --

local defaultConfig = {
  pointer = "pointer-1.png",
  resolutionX = 800,
  resolutionY = 600,
  fullscreen = false
}

syst = syst or {}
syst.config = syst.config or {}
local configFile = 'config.lua'

print(love.filesystem.getSaveDirectory())

-- Recharge la configuration
function loadConfig()
  syst.config = syst.config or {}
  
  if love.filesystem.exists(configFile) then
    love.filesystem.load(configFile)()
  else
    for k, v in pairs(defaultConfig) do
      syst.config[k] = v
    end
    writeConfig()
  end
end

-- Enregistre la configuration
function writeConfig()
  local nl = "\r\n"
  local stringConfig = '-- Config' .. nl .. 'syst = syst or {}' .. nl .. 'syst.config = syst.config or {}' .. nl
  
  for k, v in pairs(syst.config) do
    if type(v) == 'string' then
      stringConfig = stringConfig .. 'syst.config.' .. k .. ' = "' .. v .. '"' .. nl
    elseif type(v) == 'boolean' then
      stringConfig = stringConfig .. 'syst.config.' .. k .. ' = ' .. (v and 'true' or 'false') .. nl
    else
      stringConfig = stringConfig .. 'syst.config.' .. k .. ' = ' .. v .. nl
    end
    
    syst.config[k] = v
  end
  
  love.filesystem.write(configFile, stringConfig)
  print("Config saved in " .. love.filesystem.getSaveDirectory())
end
