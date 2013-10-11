local Vector = require 'libs/vector'
local Gun = require 'entities/gun'
local Bullet = require 'entities/bullet'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe BasicGun
local BasicGun = Gun:subclass('BasicGun')

-- Sons
local shootSound = love.audio.newSource("assets/sounds/shoot2.wav", "static")
shootSound:setVolume(4)

-- Constructeur
function BasicGun:initialize(x, y, parent, controller)
  Gun.initialize(self, x, y, 0)
  self.isGun = true
  self.parent = parent
  self.controller = controller or 'parent' -- 'ia' ou 'parent'
  self.firing = false
  
  -- Stats
  self.health = 20
  self.color = color or Color:new()
  self.fireRate = 0.4
  self.imprecision = math.pi / 120
  self.bulletSpeed = 1200
  
  -- Points de tir
  self.gun = {
    { x =  14, y = 0 },
    { x = -14, y = 0 },
  }
  
  self.lastGunUsed = 1
  
  -- Temps depuis le dernier
  self.fireTime = 0
  
  -- Création de l'élément dans le monde physique
  self.shapes = {
    love.physics.newEdgeShape(3,  11.5, -10,  11.5),
    love.physics.newEdgeShape(3, -11.5, -10, -11.5)
  }
  
  self.fixtures = {
    love.physics.newFixture(self.parent.body, self.shapes[1], 1),
    love.physics.newFixture(self.parent.body, self.shapes[2], 1)
  }
  
  self.fixtures[1]:setUserData({entity = self})
  self.fixtures[2]:setUserData({entity = self})
end

-- Affichage
function BasicGun:draw()
  love.graphics.setColor(self.parent.color:get())
  love.graphics.setLineWidth(1.5)
  love.graphics.line(self.parent.body:getWorldPoints(self.shapes[1]:getPoints()))
  love.graphics.line(self.parent.body:getWorldPoints(self.shapes[2]:getPoints()))
end

-- Mise à jour
function BasicGun:update(dt)
  Gun.update(self, dt)
  
  if self.enabled and not self.toDestroy then
    
    -- Tirer
    if self.firing and self.fireTime > self.fireRate then
      self.lastGunUsed = self.lastGunUsed + 1 <= #self.gun and self.lastGunUsed + 1 or 1
      
      local c, s = math.cos(- self.angle), math.sin(- self.angle)
      local gun = self.gun[self.lastGunUsed]
      
      local bullet = Bullet:new(
        self.parent.pos.x + s * gun.x - c * gun.y,
        self.parent.pos.y + c * gun.x - s * gun.y,
        self.bulletSpeed, self.parent.angle
          + 0.012 * (self.lastGunUsed == 1 and -1 or 1) -- Correction de trajectoire
          + self.imprecision * (math.random() - 0.5), -- Imprécision du tir
        self.parent)
      
      table.insert(game.entities, bullet)
      self.fireTime = 0
      
      shootSound:rewind()
      shootSound:play()
    end
  end
end

-- Mise à jour de la vie
function BasicGun:updateHealth(dt)
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
function BasicGun:beginContact(entity, contact, velocity, fixture)
  if entity.isBullet and entity.parent ~= self.parent then
    self.health = self.health - entity.damages
  
  elseif entity.isItem then
    self.parent:beginContact(entity, contact, velocity)
  end
end

return BasicGun
