local Entity = require 'entities/entity'
local Effect = Entity:subclass('Effect')

-- Constructeur
function Effect:initialize(x, y, angle)
  Entity.initialize(self, x, y, angle)
end

-- Mise à jour de l'effet
function Effect:update(dt)
  if self.ps then
    self.ps:update(dt)
  end
end

-- Affichage de l'effet
function Effect:draw()
  if self.ps then
    love.graphics.draw(self.ps, self.pos.x, self.pos.y, self.angle)
  end
end

-- Raccourci pour démarrer l'effet
function Effect:start()
  if self.ps then
    self.ps:start()
  end
end

-- Raccourci pour stopper l'effet
function Effect:stop()
  if self.ps then
    self.ps:stop()
  end
end

return Effect
