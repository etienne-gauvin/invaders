local Effect = require 'entities/effect'
local LightPulseEffect = Effect:subclass('LightPulseEffect')

local shader = love.graphics.newPixelEffect [[
  extern number t;
  extern number alpha = 1;
  extern vec2 position = vec2(0, 0);
  extern number radius = 28;
  extern number hiddenRadius = 0;
  extern vec4 color1 = vec4(1);
  extern vec4 color2 = vec4(1);
  extern number weight = 3;
  extern number speed = 3;
  extern number direction = 1;
   
  vec4 effect(vec4 mcolor, Image tex, vec2 tc, vec2 pc)
  {
    vec4 color = Texel(tex, tc);
    number d = distance(position, pc);
    
    if (d <= radius && d > hiddenRadius) {
      number lum = d / radius;
      color = (color1 * lum + color2 * (1 - lum)) * 1.5 * clamp(cos(weight * radius / d + t * speed * direction), 0.5, 1) * (1 - lum) * alpha;
    }
    
    return color;
  }
]]

-- Constructeur
-- x, y = position
-- direction[=1] = -1 (intérieur) ou 1 (extérieur) sens de la pulsation
-- color1, color2 = changements de couleur de la lumière (tout blanc = {1,1,1,1} par défaut)
-- speed[=3] = vitesse de la pulsation {1,10}
-- radius[=50] = rayon de l'effet en pixels
-- weight[3] = épaisseur de chaque vague {1=large, 10=fine}
function LightPulseEffect:initialize(x, y, direction, color1, color2, speed, radius, weight)
  Effect.initialize(self, x, y, 0)
  
  self.color1 = color1 or {1, 1, 1, 1}
  self.color2 = color2 or {1, 1, 1, 1}
  self.speed = speed or 3
  self.radius = radius or 50
  self.hiddenRadius = hiddenRadius or 0
  self.weight = weight or 3
  self.direction = direction or 1
  
  self.t = math.random() * 10 + 10
  self.startTime = 0
  self.stopTime = -1 -- infini
  self.destroyAtEnd = false
  self.fadeOutDuration = 0.3
  self.fadeInDuration = 0.3
end

-- Affichage
function LightPulseEffect:draw()
  local cx, cy = syst.camera:cameraCoords(self.pos.x, self.pos.y)
  local i = 1
 
  if self.t <= self.startTime + self.fadeInDuration then
    i = 1 - (self.startTime + self.fadeInDuration - self.t) / self.fadeInDuration
  
  elseif self.stopTime > 0 and self.t >= self.stopTime - self.fadeOutDuration then
    i = (self.stopTime - self.t) / self.fadeOutDuration
  end
  
  shader:send('t', self.t)
  shader:send('position', {cx, syst.height - cy})
  shader:send('radius', self.radius)
  shader:send('hiddenRadius', self.hiddenRadius)
  shader:send('color1', self.color1)
  shader:send('color2', self.color2)
  shader:send('weight', self.weight)
  shader:send('speed', self.speed)
  shader:send('direction', self.direction)
  shader:send('alpha', i)
  
  love.graphics.setPixelEffect(shader)
  love.graphics.setColor(255, 255, 255, 0)
  love.graphics.rectangle('fill', self.pos.x - self.radius, self.pos.y - self.radius, self.radius * 2, self.radius * 2)
  love.graphics.setPixelEffect()
end

-- Démarrer la pulsation
function LightPulseEffect:start(fadeInDuration, effectDuration, fadeOutDuration)
  self.fadeInDuration = fadeInDuration or self.fadeInDuration or 0.3
  self.startTime = self.t
  self.fadeOutDuration = fadeOutDuration or self.fadeOutDuration or 0.3
  self.stopTime = effectDuration and self.t + effectDuration + self.fadeOutDuration or -1
end

-- Arrêter la pulsation
function LightPulseEffect:stop(fadeOutDuration, destroyAtEnd)
  self.fadeOutDuration = fadeOutDuration or self.fadeOutDuration or 0.3
  self.stopTime = self.t + self.fadeOutDuration
  self.destroyAtEnd = destroyAtEnd or false
end

-- Mise à jour
function LightPulseEffect:update(dt)
  self.t = self.t + dt
  self.visibleRadius = self.radius
  
  if self.destroyAtEnd and self.stopTime > 0 and self.t >= self.stopTime then
    self.enabled = true
    self.toDestroy = true
  end
end

return LightPulseEffect
