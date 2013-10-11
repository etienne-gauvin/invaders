local Vector = require 'libs/vector'
local Entity = require 'entities/entity'
local LightPulseEffect = require 'entities/effects/light-pulse-effect'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe Item
local Item = Entity:subclass('Item')

-- Sons
local destructionSound = love.audio.newSource("assets/sounds/destruction.ogg", "static")

-- Constructeur
function Item:initialize(x, y)
  Entity.initialize(self, x, y, 0)
  self.isItem = true
  self.visibleRadius = 16
  
  -- Lumière
  self.light = LightPulseEffect:new(self.pos.x, self.pos.y)
  self.light.hiddenRadius = 10
  table.insert(game.entities, self.light)
end

-- Affichage
function Item:draw()
end

-- Mise à jour
function Item:update(dt)
  -- Mise à jour de la position et de l'angle
  if self.body then
    self.pos.x, self.pos.y = self.body:getX(), self.body:getY()
    self.angle = (self.body:getAngle() + math.pi) % (math.pi * 2) - math.pi
  end
  
  -- Mise à jour de la lumière
  self.light.pos.x, self.light.pos.y = self.pos.x, self.pos.y
end

-- Collision avec un autre objet
function Item:beginContact(entity, contact, velocity)
  Entity.beginContact(self, entity, contact, velocity)
  
  -- Annulation de la collision
  contact:setEnabled(false)
  if not entity.isItem then
    self.enabled = false
    self.toDestroy = true
    self.light:stop(nil, true)
    destructionSound:rewind()
    destructionSound:play()
  end
end

return Item
