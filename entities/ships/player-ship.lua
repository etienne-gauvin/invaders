local Vector = require 'libs/vector'
local Entity = require 'entities/entity'
local Ship = require 'entities/ship'
local Bullet = require 'entities/bullet'
local Armor = require 'entities/armor'
local BasicGun = require 'entities/guns/basic-gun'
local PlayerPilot = require 'pilots/player-pilot'
local ReactorEffect = require 'entities/effects/reactor-effect'
local LightPulseEffect = require 'entities/effects/light-pulse-effect'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe PlayerShip
local PlayerShip = Ship:subclass('PlayerShip')

-- Image
local shipImage = love.graphics.newImage('assets/images/ship.png')
local laserDotImage = love.graphics.newImage('assets/images/laser-dot.png')

-- Constructeur
function PlayerShip:initialize(x, y, team)
  Ship.initialize(self, x, y, team)
  self.pilot = PlayerPilot:new(self)
  self.image = shipImage
  
  -- Stats
  self.health = 1000
  self.maxHealth = 1000
  
  -- Armure
  self.armor = Armor:new(self)
  table.insert(game.entities, self.armor)
  
  -- Laser
  self.hasLaser = true
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
function PlayerShip:draw()
  Ship.draw(self)
  
  -- Canon(s)
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
  
  -- Laser
  if self.hasLaser and self == game.player then
    
    local lx1, ly1, lx2, ly2 = self.body:getWorldPoints(self.width / 2, 0, syst.width, 0)
    local hitx, hity = false, false
    
    -- Pour chaque entité visible du jeu
    for e, entity in ipairs(game:getVisibleEntities()) do
      
      if entity.enabled
        and not entity.toDestroy
        and entity.body
        and entity ~= self
        and not entity.isBullet
        and not entity.isArmor then
        
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
    
    love.graphics.setLineWidth(1)
    love.graphics.setColor(self.secondaryColor:get(192 - 24 * math.cos(self.laserPulse)))
    love.graphics.line(lx1, ly1, hitx or lx2, hity or ly2)
    
    if hitx then
      love.graphics.draw(laserDotImage, hitx - laserDotImage:getWidth() / 2, hity - laserDotImage:getHeight() / 2)
    end
  end
end

-- Mise à jour
function PlayerShip:update(dt)
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

return PlayerShip
