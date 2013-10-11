local Vector = require 'libs/vector'
local Entity = require 'entities/entity'

-- Classe Armor
local Armor = Entity:subclass('Armor')

-- Image
local armorImage = love.graphics.newImage('assets/images/armor.png')

-- Constructeur
function Armor:initialize(parent)
  Entity.initialize(self)
  self.isArmor = true
  self.parent = parent
  
  -- Stats
  self.health = 100
  self.color = Color:new({r=64, g=64, b=255})
  
  -- Temps écoulé depuis les derniers dégâts
  self.timeSinceLastDamage = 1
  
  -- Création de l'élément dans le monde physique
  self.shape = love.physics.newCircleShape(self.parent.visibleRadius + 15)
  self.fixture = love.physics.newFixture(self.parent.body, self.shape, 0)
  self.fixture:setUserData({entity = self})
end

-- Affichage
function Armor:draw()
  
  local a = 0
  
  if self.timeSinceLastDamage < 0.5 then
    a = 1 - self.timeSinceLastDamage * 2
  end
  
  love.graphics.setColor(self.color:get(192 + 63 * a))
  love.graphics.setLineWidth(1.5)
  local x, y = self.parent.body:getWorldCenter()
  --love.graphics.circle('line', x, y, self.shape:getRadius())
  love.graphics.draw(armorImage, x - armorImage:getWidth() / 2, y - armorImage:getHeight() / 2)
end

-- Mise à jour
function Armor:update(dt)
  Entity.update(self, dt)
  self:updateHealth(dt)
  self.timeSinceLastDamage = self.timeSinceLastDamage + dt
end

-- Mise à jour de la vie
function Armor:updateHealth(dt)
  self.enabled = self.parent.enabled
  self.toDestroy = self.parent.toDestroy
  
  -- Désactivation du canon si sa vie <= 0
  if self.enabled and not self.toDestroy and self.health <= 0 then
    self.health = 0
    self.enabled = false
    self.toDestroy = true
  end
end

-- Destruction
function Armor:destroy()
  self.fixture:destroy()
  Entity.destroy(self)
end

-- Collision avec un autre objet
function Armor:beginContact(entity, contact, velocity, fixture)
  if entity.isBullet and entity.parent ~= self.parent then
    self.health = self.health - entity.damages
    self.timeSinceLastDamage = 0
  
  elseif entity.isItem then
    self.parent:beginContact(entity, contact, velocity, fixture)
  end
end

return Armor
