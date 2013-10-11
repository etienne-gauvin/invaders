local Pilot = require 'pilot'
local PlayerPilot = Pilot:subclass('PlayerPilot')

local keyConfigFile = 'key-config'

-- Classe contrôlant un vaisseau
-- Humain sur l'ordinateur
-- Il ne doit y avoir qu'une seule instance de cette classe
function PlayerPilot:initialize(ship)
  Pilot.initialize(self, ship)
  
  -- Réglage des commandes
  self.keys = {
    fire_main = 'mouse.l',
    fire_secondary = 'mouse.r',
    
    dir_up = 'up',
    dir_down = 'down',
    dir_right = 'right',
    dir_left = 'left',
    
    dir_north = 'z',
    dir_south = 's',
    dir_east = 'q',
    dir_west = 'd'
  }
  
  -- Réglage des commandes depuis le fichier de configuration
  if love.filesystem.isFile(keyConfigFile) then
    local keyConfigRaw = love.filesystem.read(keyConfigFile)
    
    for c, key in string.gmatch(keyConfigRaw, "(%w+)=(%w+)\n") do
      self.keys[c] = key
    end
  end
end

-- Mise à jour des commandes
function PlayerPilot:update()
  
  local k = self.keys
  
  -- Mise à jour de toutes les touches
  for c in pairs(self.controls) do
    if self.keys[c] then
      if string.find(self.keys[c], '^mouse.') then
        self.controls[c] = love.mouse.isDown(string.sub(self.keys[c], 7))
      else
        self.controls[c] = love.keyboard.isDown(self.keys[c])
      end
    end
  end
  
  -- Mise à jour du pointeur
  self.controls.pointer_x, self.controls.pointer_y = syst.camera:worldCoords(love.mouse.getPosition())
end

return PlayerPilot
