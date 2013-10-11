local Vector = require 'libs/vector'
local Entity = require 'entities/entity'
local BulletTraceEffect = require 'entities/effects/bullet-trace-effect'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe Bullet
local Bullet = Entity:subclass('Bullet')

-- Image
local bulletImage = love.graphics.newImage('assets/images/bullet.png')

-- Constructeur
function Bullet:initialize(x, y, speed, angle, parent)
  Entity.initialize(self, x, y, angle)
  self.isBullet = true
  self.radius = 3
  self.visibleRadius = 20
  self.parent = parent or false
  self.color = self.parent.secondaryColor or Color:new()
  
  -- Stats
  self.damages = 10
  
  -- Création de l'élément dans le monde physique
  self.body = love.physics.newBody(game.world, self.pos.x, self.pos.y, 'dynamic')
  self.body:setAngle(self.angle)
  
  local vx, vy = 0, 0
  if self.parent and self.parent.body then
    vx, vy = parent.body:getLinearVelocity()
  end
  
  self.body:setLinearVelocity(
    speed * math.cos(self.angle) + vx * game.bulletveltype,
    speed * math.sin(self.angle) + vy * game.bulletveltype
  )
  
  self.body:setLinearDamping(0)
  self.body:setAngularDamping(1)
  self.body:setBullet(true)
  local mx, my, mass, inertia = self.body:getMassData()
  self.body:setMassData(mx, my, mass, inertia)
  
  self.shape = love.physics.newCircleShape(self.radius)
  
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData({entity = self})
  self.fixture:setFriction(1)
  
  --  Création de la trace (générateur de particules)
  self.trace = BulletTraceEffect:new(self)
  self.trace.ps:setPosition(- bulletImage:getWidth() / 2, 0)
  self.trace.angle = - math.pi
  
  -- Effet d'apparition
  local effect = PickedUpEffect(
    self.pos.x, self.pos.y, bulletImage,
    self.radius * 2, self.radius * 2, self.color, true)
  
  effect.finalScaleX = 8
  effect.finalScaleY = 8
  effect.lifetime = 0.2
  table.insert(game.entities, effect)
end

-- Affichage
function Bullet:draw()
  
  -- Vaisseau
  self:attach()
  
  love.graphics.setColor(self.color:get())
  love.graphics.draw(bulletImage, - bulletImage:getWidth() / 2, - bulletImage:getHeight() / 2)
  
  self.trace:draw()
  
  self:detach()
  
  -- Hitbox
  --love.graphics.setColor(0, 255, 0, 128)
  --love.graphics.circle("fill", self.pos.x, self.pos.y, self.shape:getRadius())
end

-- Mise à jour
function Bullet:update(dt)
  Entity.update(self, dt)
  
  -- Mise à jour de la trace (générateur de particules)
  self.trace:update(dt)
end

-- Collision avec un autre objet
function Bullet:preSolve(entity, contact, velocity)
  
  if entity.isBullet
    or entity.isShip and entity.team ~= self.parent.team
    or entity.isGun and entity.parent.team ~= self.parent.team
    or entity.isArmor and entity.parent.team ~= self.parent.team then
    self.enabled = false
    self.toDestroy = true
    
    local cx, cy = contact:getPositions()
    local effect = PickedUpEffect(cx, cy, bulletImage, self.radius * 2, self.radius * 2, self.color, true)
    effect.finalScaleX = 20
    effect.finalScaleY = 14
    table.insert(game.entities, effect)
    
  else
    contact:setEnabled(false)
  end
end

return Bullet
