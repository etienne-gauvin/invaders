local Vector = require 'libs/vector'
local Effect = require 'entities/effect'
local BulletTraceEffect = Effect:subclass('BulletTraceEffect')

-- Image utilisée par l'effet
local particleImage = love.graphics.newImage('assets/images/bullet.png')

-- Constructeur
function BulletTraceEffect:initialize(parent, x, y, angle)
  Effect.initialize(self, x, y, angle)
  
  self.parent = parent
  self.color = parent.color or Color:new()
  
  self.ps = love.graphics.newParticleSystem(particleImage, 100)
  self.ps:setEmissionRate(100)
  self.ps:setSpeed(100)
  self.ps:setSizes(1, 0)
  self.ps:setParticleLife(0.6)
  self.ps:setLifetime(1)
  self.ps:setSpread(0)
  self.ps:start()
end

function BulletTraceEffect:update(dt)
  self.ps:start()
  
  local c = self.color
  self.ps:setColors(
    c.r, c.g, c.b, 255,
    c.r, c.g, c.b, 255,
    c.r, c.g, c.b, 0)
  
  Effect.update(self, dt)
end

function BulletTraceEffect:draw()
  Effect.draw(self)
end

return BulletTraceEffect
