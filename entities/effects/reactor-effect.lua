local Vector = require 'libs/vector'
local Effect = require 'entities/effect'
local ReactorEffect = Effect:subclass('ReactorEffect')

-- Image utilisée par l'effet
local particleImage = love.graphics.newImage('assets/images/particle.png')

-- Constructeur
function ReactorEffect:initialize(parent, x, y, angle, color)
  Effect.initialize(self, x, y, angle)
  
  self.parent = parent
  self.color = color or Color:new()
  
  self.ps = love.graphics.newParticleSystem(particleImage, 1000)
  self.ps:setEmissionRate(200)
  self.ps:setSpeed(100, 300)
  self.ps:setSizes(0.4, 0.05)
  self.ps:setParticleLife(1)
  self.ps:setLifetime(1)
  self.ps:setDirection(0)
  self.ps:setSpread(0.5)
  self.ps:start()
end

function ReactorEffect:update(dt)
  self.ps:start()
  
  local c = self.color
  self.ps:setColors(
    c.r, c.g, c.b, 255,
    c.r, c.g, c.b, 255,
    c.r, c.g, c.b, 0)
  
  -- Mise à jour de la longueur de la "flamme"
  local speed = Vector(self.parent.body:getLinearVelocity()):len()
  
  if speed > 1000 then
    self.ps:setParticleLife(0.10)
  else
    self.ps:setParticleLife(speed / 1000 * 0.10)
  end
  
  Effect.update(self, dt)
end

function ReactorEffect:draw()
  love.graphics.setColor(255, 255, 255, 255)
  Effect.draw(self)
end

return ReactorEffect
