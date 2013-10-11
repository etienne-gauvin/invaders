local Vector = require 'libs/vector'
local Entity = Object:subclass('Entity')
local counters = {}

-- Constructeur
function Entity:initialize(x, y, angle, ox, oy)
  counters[self.class.name] = (counters[self.class.name] or 0) + 1
  self.id = self.class.name .. '_' .. counters[self.class.name]
  self.pos = Vector(x or 0, y or 0) -- Position de l'entité
  self.origin = Vector(ox or 0, oy or 0) -- Point central de l'entité
  self.angle = angle or 0
  self.enabled = true
  self.toDestroy = false
  self.visibleRadius = 1
  
  --print("Nouvelle entité #" .. self.id)
end

-- Effectuer une rotation et translation de la zone de dessin
-- Pour afficher ensuite des éléments relativement à l'entité actuelle
function Entity:attach()
  love.graphics.push()
  love.graphics.translate(self.pos.x + self.origin.x, self.pos.y + self.origin.y)
  love.graphics.rotate(self.angle)
  love.graphics.translate(- self.origin.x, - self.origin.y)
end

-- Terminer le dessin relatif à l'entité
function Entity:detach()
  love.graphics.pop()
end

-- Destruction de l'entité
function Entity:destroy()
  
  -- Fixtures "auto-détruites" lors de la destruction du body ?
  --[[if self.fixture then
    self.fixture:destroy()
  elseif self.fixtures then
    for i in ipairs(self.fixtures) do
      self.fixtures[i]:destroy()
    end
  end]]
  
  if self.body then self.body:destroy() end
  
  --print("Destruction de l'entité #" .. self.id)
end

-- Mise à jour de la position et de l'angle
function Entity:update(dt)
  if self.body then
    self.pos.x, self.pos.y = self.body:getX(), self.body:getY()
    self.angle = (self.body:getAngle() + math.pi) % (math.pi * 2) - math.pi
  elseif self.parent and self.parent.body then
    self.pos.x, self.pos.y = self.parent.body:getX(), self.parent.body:getY()
    self.angle = (self.parent.body:getAngle() + math.pi) % (math.pi * 2) - math.pi
  end
end

-- Lors d'une collision
function Entity:beginContact(entity, contact, velocity) end
function Entity:endContact(entity, contact, velocity) end
function Entity:preSolve(entity, contact, velocity) end
function Entity:postSolve(entity, contact, velocity) end

return Entity
