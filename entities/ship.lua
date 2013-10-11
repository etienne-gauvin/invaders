local Vector = require 'libs/vector'
local Entity = require 'entities/entity'
local Bullet = require 'entities/bullet'
local Team = require 'team'
local ReactorEffect = require 'entities/effects/reactor-effect'
local LightPulseEffect = require 'entities/effects/light-pulse-effect'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe Ship
local Ship = Entity:subclass('Ship')

-- Sons
local healthUpSound = love.audio.newSource("assets/sounds/health-up.ogg", "static")
local destructionSound = love.audio.newSource("assets/sounds/destruction.ogg", "static")
destructionSound:setVolume(1.5)

-- Constructeur
function Ship:initialize(x, y, team)
  Entity.initialize(self, x, y, 0)
  self.isShip = true
  self.pilot = false
  self.team = team or getTeams()[1]
  self.team.ships[#self.team.ships+1] = self
  
  self.width = 32
  self.height = 32
  
  -- Stats
  self.health = 100
  self.maxHealth = 100
  self.color = self.team.color
  self.secondaryColor = self.team.secondaryColor
  self.rotSpeed = 4 -- (1 = instantané, 4 = rapide, 7 = moyen, 10 = lent)
  self.acceleration = 200
  self.maxSpeed = 400
  self.visibleRadius = self.width > self.height and self.width / 2 or self.height / 2
  
  -- Temps d'affichage de l'indicateur de vie
  self.healthDrawDuration = 2
  
  -- Temps depuis le dernier
  self.laserPulse = 0
  self.lastHealthChangeTime = self.healthDrawDuration
  
  -- Temps d'affichage de l'indicateur de vie
  self.healthDrawDuration = 3
  
  -- Création de l'élément dans le monde physique (sans forme)
  self.body = love.physics.newBody(game.world, self.pos.x, self.pos.y, 'dynamic')
  self.body:setAngle(self.angle)
  self.body:setLinearDamping(0.1)
  self.body:setAngularDamping(8)
  self.fixture = false
  
  -- Pulsations lumineuses
  self.healthIndicatorEffect = LightPulseEffect:new(0, 0, -1, {1, 0, 0, 1}, {1, 0, 0, 1}, 35, 50, 3)
  self.healthIndicatorEffect.hiddenRadius = 10
  self.healthIndicatorEffect:stop(0)
  
  self.armorIndicatorEffect = LightPulseEffect:new(0, 0, -1, {0, 0, 1, 1}, {0, 0, 1, 1}, 35, 50, 3)
  self.armorIndicatorEffect.hiddenRadius = 10
  self.armorIndicatorEffect:stop(0)
end

-- Affichage
function Ship:draw()
  
  -- Pulsations lumineuses
  self.healthIndicatorEffect:draw()
  self.armorIndicatorEffect:draw()
  
  -- Affichage de la vie
  if self.lastHealthChangeTime < self.healthDrawDuration then
    love.graphics.setColor(self.secondaryColor:get(192 * (1 - self.lastHealthChangeTime / self.healthDrawDuration)))
    
    local x, y, a1, a2 =
      self.pos.x - 3 * math.cos(self.angle),
      self.pos.y - 3 * math.sin(self.angle),
      - math.pi / 2,
      - math.pi / 2 - math.pi * 2 * self.health / self.maxHealth
    
    love.graphics.arc('fill', x, y, self.visibleRadius + 10, a1, a2)
    love.graphics.setBlendMode('subtractive')
    love.graphics.arc('fill', x, y, self.visibleRadius + 6, a1, a2)
    love.graphics.setBlendMode('alpha')
  end
  
  love.graphics.setColor(self.secondaryColor:get())
  --love.graphics.print(self.health, self.pos.x + 20, self.pos.y + 20)
  
  
  -- Hitbox
  --love.graphics.setColor(0, 255, 0, 128)
  --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
end

-- Mise à jour
function Ship:update(dt)
  if self:updateHealth(dt) then
    Entity.update(self, dt)
    
    self.lastHealthChangeTime = self.lastHealthChangeTime + dt
      
    -- Mise à jour des commandes de déplacement
    self.pilot:update(dt)
    self:updateMovements(dt)
    
    -- Pulsation lumineuse (vie)
    self.healthIndicatorEffect.pos.x,
    self.healthIndicatorEffect.pos.y =
      self.pos.x - math.cos(self.angle) * 5,
      self.pos.y - math.sin(self.angle) * 5
    
    self.healthIndicatorEffect:update(dt)
    
    -- Pulsation lumineuse (armure)
    self.armorIndicatorEffect.pos.x,
    self.armorIndicatorEffect.pos.y =
      self.pos.x - math.cos(self.angle) * 5,
      self.pos.y - math.sin(self.angle) * 5
    
    self.armorIndicatorEffect:update(dt)
  end
end

-- Destruction
function Ship:destroy()
  if self.team then
    for e in ipairs(self.team.ships) do
      if self.team.ships[e] == self then
        table.remove(self.team.ships, e)
        break
      end
    end
  end
  
  Entity.destroy(self)
end

-- Mise à jour de la vie
-- Explose le vaisseau si nécessaire
-- retourne vrai si le vaisseau reste en vie
function Ship:updateHealth(dt)
  -- Destruction du vaisseau si sa vie <= 0
  if self.health <= 0 then
    self.health = 0
    self.enabled = false
    self.toDestroy = true
    
    -- Effet de destruction
    local effect = PickedUpEffect(
      self.pos.x, self.pos.y, self.image,
      self.width, self.height, self.color, true)
    
    effect.finalScaleX = 5
    effect.finalScaleY = 3
    effect.lifetime = 0.15
    table.insert(game.entities, effect)
    
    -- Son de destruction
    destructionSound:rewind()
    destructionSound:play()
    
  -- Vie limitée à 100
  else
    if self.health > self.maxHealth then
      self.health = self.maxHealth
    end
  end
  
  return self.enabled and not self.toDestroy
end

-- Mise à jour des mouvements du vaisseau
function Ship:updateMovements(dt)
  
  local controls, cos, sin = self.pilot.controls, math.cos, math.sin
  
  -- Déplacement nord-sud-est-ouest
  if controls.dir_north then
    self.body:applyForce(0, - self.acceleration)
  end
  
  if controls.dir_south then
    self.body:applyForce(0, self.acceleration)
  end
  
  if controls.dir_east then
    self.body:applyForce(- self.acceleration, 0)
  end
  
  if controls.dir_west then
    self.body:applyForce(self.acceleration, 0)
  end
  
  -- Déplacement relatif au vaisseau
  if controls.dir_up then
    self.body:applyForce(
      self.acceleration * cos(self.angle),
      self.acceleration * sin(self.angle)
    )
  end
  
  if controls.dir_down then
    self.body:applyForce(
      self.acceleration * cos(self.angle - math.pi),
      self.acceleration * sin(self.angle - math.pi)
    )
  end
  
  if controls.dir_right then
    self.body:applyForce(
      self.acceleration * cos(self.angle + math.pi / 2),
      self.acceleration * sin(self.angle + math.pi / 2)
    )
  end
  
  if controls.dir_left then
    self.body:applyForce(
      self.acceleration * cos(self.angle - math.pi / 2),
      self.acceleration * sin(self.angle - math.pi / 2)
    )
  end
  
  -- Limitation de la vitesse
  -- Sans tenir compte de l'angle du vaisseau
  local vel = Vector(self.body:getLinearVelocity())
  local speedD = vel:len() / self.maxSpeed
  
  if speedD > 1 then
    vel = vel - vel * (speedD - 1)
    self.body:setLinearVelocity(vel.x, vel.y)
  end
  
  -- Position du pointeur (relative au vaisseau et normalisée)
  local pointer = Vector(controls.pointer_x - self.pos.x, controls.pointer_y - self.pos.y):normalized()
  
  -- Angle du pointeur
  local angle = math.acos(pointer.x) * (math.asin(pointer.y) < 0 and -1 or 1)
  
  -- Angle de différence entre le pointeur et le vaisseau
  local diff = ((angle - self.angle) + math.pi) % (math.pi * 2) - math.pi
  
  -- Appliquer l'angle
  self.body:setAngle(self.angle + diff / self.rotSpeed)
end

-- Collision avec un autre objet
function Ship:beginContact(entity, contact, velocity)
  Entity.beginContact(self, entity, contact, velocity)
  
  if entity.isItem then
    if entity.healthValue then
      self.health = self.health + entity.healthValue
      self.healthIndicatorEffect:start(0.1, 0.1, 2.5)
    end
    
    if self.armor and entity.armorValue then
      self.armor.health = self.armor.health + entity.armorValue
      self.armorIndicatorEffect:start(0.1, 0.1, 2.5)
    end
    
    -- Son de récupération de vie
    if self == game.player then
      healthUpSound:rewind()
      healthUpSound:play()
    end
  
  elseif entity.isBullet and entity.parent.team ~= self.team then
    self.health = self.health - entity.damages
    self.lastHealthChangeTime = 0
  end
end

return Ship
