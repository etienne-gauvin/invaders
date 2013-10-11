local Vector = require 'libs/vector'
local Entity = require 'entities/entity'
local Bullet = require 'entities/bullet'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe Gun
-- C'est le gestionnaire d'un canon (et notamment des tirs) sur un vaisseau/un objet
local Gun = Entity:subclass('Gun')

-- Constructeur
function Gun:initialize(x, y, parent, controller)
  Entity.initialize(self, x, y, 0)
  self.isGun = true
  self.parent = parent
  self.controller = controller or 'parent' -- 'ia' ou 'parent'
  self.firing = false
  
  -- Stats
  self.health = 20
  self.color = color or Color:new()
  self.fireRate = 0.4
  self.bulletSpeed = 1400
  
  -- Temps depuis le dernier
  self.fireTime = 0
end

-- Affichage
function Gun:draw()
  love.graphics.setColor(self.color:get())
end

-- Mise à jour
function Gun:update(dt)
  self:updateHealth(dt)
  
  if self.enabled and not self.toDestroy then
    Entity.update(self, dt)
    
    -- Mise à jour des commandes de tir
    if self.controller == 'ia' then
      self.firing = false
    end
    
    -- Mise à jour du temps depuis le dernier tir
    self.fireTime = self.fireTime + dt
  end
end

-- Mise à jour de la vie
function Gun:updateHealth(dt)
  self.enabled = self.parent.enabled
  self.toDestroy = self.parent.toDestroy
  
  -- Désactivation du canon si sa vie <= 0
  if self.enabled and not self.toDestroy and self.health < 0 then
    self.health = 0
    self.available = true
  else
    self.available = false
  end
end

-- Collision avec un autre objet
function Gun:beginContact(entity, contact, velocity)
  Entity.beginContact(self, entity, contact, velocity)
  
  if entity.isBullet and entity.parent ~= self.parent then
    self.health = self.health - entity.damages
  
  elseif entity.isItem then
    self.parent:beginContact(entity, contact, velocity)
  end
end

return Gun
