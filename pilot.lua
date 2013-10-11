local Pilot = Object:subclass('Pilot')

-- Classe (abstraite) contrôlant un vaisseau
-- Humain/IA
function Pilot:initialize(ship)
  self.ship = ship or false
  
  self.controls = {
    fire_main = false,
    fire_secondary = false,
    
    dir_up = false,
    dir_down = false,
    dir_right = false,
    dir_left = false,
    
    dir_north = false,
    dir_south = false,
    dir_east = false,
    dir_west = false,
  
    pointer_x = 0,
    pointer_y = 0
  }
end

-- Mise à jour des commandes
function Pilot:update(dt)
end

-- Afficher les commandes à l'écran
-- Pour le déboguage
function Pilot:draw(dt)
  local x, y = 20, 20
  local count = 0
  for k in pairs(self.controls) do count = count + 1 end
  
  love.graphics.setFont(syst.font.small)
  love.graphics.setColor(0, 0, 0, 240)
  love.graphics.rectangle('fill', x, y, 220, count * 20 + 20)
  love.graphics.setColor(self.ship.secondaryColor or unpack{255, 255, 255})
  
  local i = 0
  for k, v in pairs(self.controls) do
    love.graphics.printf(k .. " = " .. (v and 1 or 0), x + 10, y + 10 + 20 * i, 200, 'left')
    i = i + 1
  end
  
  love.graphics.setColor(255, 255, 255)
end

return Pilot
