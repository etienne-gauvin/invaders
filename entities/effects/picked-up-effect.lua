local Vector = require 'libs/vector'
local Effect = require 'entities/effect'
local PickedUpEffect = Effect:subclass('PickedUpEffect')

-- Constructeur
function PickedUpEffect:initialize(x, y, image, width, height, color, double)
  Effect.initialize(self, x, y, math.random() * math.pi * 2)
  
  self.image = image
  self.width = width or 0
  self.height = height or 0
  self.lifetime = 0.1
  self.currentLifetime = 0
  self.color = color or Color:new()
  self.finalScaleX = 4
  self.finalScaleY = 2
  self.double = not not double
  
end

function PickedUpEffect:draw()
  
  self:attach()
  
  local i = self.currentLifetime / self.lifetime
  
  love.graphics.setColor(self.color:get(math.floor(255 * (1 - i / 1.2))))
  love.graphics.draw(self.image,
    - self.width / 2 - self.width * i * self.finalScaleX / 2,
    - self.height * (1 - i) / 2,
    0,
    i * self.finalScaleX + 1,
    1 - i)
  
  love.graphics.draw(self.image,
    - self.width * (1 - i) / 2,
   - self.height / 2  - self.height * i * self.finalScaleY / 2,
    0,
    1 - i,
    i * self.finalScaleY + 1)
  
  self:detach()
  
  -- Effet doublé
  if self.double then
    
    self.angle = self.angle + math.pi / 4
    local averageScale = (self.finalScaleX + self.finalScaleY) / 2
  
    self:attach()
    
    love.graphics.draw(self.image,
      - self.width / 2 - self.width * i * averageScale / 2,
      - self.height * (1 - i) / 2,
      0,
      i * averageScale + 1,
      1 - i)
    
    love.graphics.draw(self.image,
      - self.width * (1 - i) / 2,
     - self.height / 2  - self.height * i * averageScale / 2,
      0,
      1 - i,
      i * averageScale + 1)
    
    self:detach()
  
    self.angle = self.angle - math.pi / 4
  end
  
  Effect.draw(self)
end

function PickedUpEffect:update(dt)
  self.currentLifetime = self.currentLifetime + dt
  
  if self.currentLifetime >= self.lifetime then
    self.enabled = true
    self.toDestroy = true
  end
  
  Effect.update(self, dt)
end

return PickedUpEffect
