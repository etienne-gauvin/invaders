local Vector = require 'libs/vector'
local Entity = require 'entities/entity'
local Ship = require 'entities/ship'
local Bullet = require 'entities/bullet'
local BasicGun = require 'entities/guns/basic-gun'
local BasicEnemyPilot = require 'pilots/basic-enemy-pilot'
local ReactorEffect = require 'entities/effects/reactor-effect'
local LightPulseEffect = require 'entities/effects/light-pulse-effect'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe BasicEnemyShip
local BasicEnemyShip = Ship:subclass('BasicEnemyShip')

-- Image
local shipImage = love.graphics.newImage('assets/images/basic-enemy-ship.png')
local laserDotImage = love.graphics.newImage('assets/images/laser-dot.png')

-- Constructeur
function BasicEnemyShip:initialize(x, y, team)
  Ship.initialize(self, x, y, team)
  self.pilot = BasicEnemyPilot:new(self)
  self.image = shipImage
  
  -- Stats
  self.health = 50
  self.maxHealth = 50
  self.rotSpeed = 15
  self.acceleration = 100
  self.maxSpeed = 200
  
  -- Laser
  self.hasLaser = false
  self.laserPulse = 0
  
  -- Création de l'élément dans le monde physique
  local mx, my, mass, inertia = self.body:getMassData()
  self.body:setMassData(mx, my, mass, inertia)
  
  self.shape = love.physics.newPolygonShape(16, 0, 0, -12, -16, -16, -16, 16, 0, 12)
  
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData({entity = self})
  self.fixture:setFriction(1)
  
  --  Création du réacteur (générateur de particules)
  self.reactor = ReactorEffect:new(self, 0, 0, 0, self.secondaryColor)
  self.reactor.angle = - math.pi
  self.reactor.ps:setPosition(12, 0)
  
  -- Canons
  self.gun = BasicGun:new(self.pos.x, self.pos.y, self)
end

-- Affichage
function BasicEnemyShip:draw()
  Ship.draw(self)
  
  -- Laser
  if self.hasLaser then
    
    local lx1, ly1, lx2, ly2 = self.pos.x, self.pos.y, self.pos.x + math.cos(self.angle) * syst.width, self.pos.y + math.sin(self.angle) * syst.width
    local hitx, hity = false, false
    
    -- Pour chaque entité visible du jeu
    for e, entity in ipairs(game:getVisibleEntities()) do
      
      if entity.enabled
        and not entity.toDestroy
        and entity.body
        and entity ~= self
        and not (entity.isBullet and entity.parent == self) then
        
        -- Pour chaque fixture de l'entité
        for f, fixture in ipairs(entity.body:getFixtureList()) do
          local xn, yn, fraction = fixture:rayCast(lx1, ly1, lx2, ly2, 1)
          
          if xn then
            hitx, hity = lx1 + (lx2 - lx1) * fraction, ly1 + (ly2 - ly1) * fraction
            break
          end
        end
        
        if hitx then break end
      end
    end
    
    local sc = self.secondaryColor
    love.graphics.setLineWidth(1)
    love.graphics.setColor(self.secondaryColor:get(128 - 24 * math.cos(self.laserPulse)))
    
    love.graphics.line(lx1, ly1, hitx or lx2, hity or ly2)
    
    if hitx then
      love.graphics.draw(laserDotImage, hitx - laserDotImage:getWidth() / 2, hity - laserDotImage:getHeight() / 2)
    end
  end
  
  -- Pulsation lumineuse lors du ramassage d'un item
  self.healthIndicatorEffect:draw()
  
  -- Canons
  self.gun:draw()
  
  -- Vaisseau
  self:attach()
  
  -- Réacteur
  love.graphics.setColor(255, 255, 255, 255)
  self.reactor:draw()
  
  -- Image du vaisseau
  love.graphics.setColor(self.color:get())
  love.graphics.draw(self.image, self.width / 2, - self.height / 2, math.pi / 2)
  
  self:detach()
  
end

-- Mise à jour
function BasicEnemyShip:update(dt)
  Ship.update(self, dt)
  
  if self.enabled and not self.toDestroy then
    -- Mise à jour du réacteur (générateur de particules)
    self.reactor:update(dt)
    
    -- Mise à jour du laser (clignotement)
    self.laserPulse = self.laserPulse + dt * 10
    
    -- Mise à jour du tir des canons
    self.gun.firing = self.pilot.controls.fire_main
    self.gun:update(dt)
  end
end

return BasicEnemyShip
