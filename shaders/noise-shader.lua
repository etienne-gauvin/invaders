local Shader = require 'shaders/shader'
local NoiseShader = Shader:subclass('NoiseShader')

-- Création du shader
function NoiseShader:initialize(nintensity, sintensity)
  Shader.initialize(self)
  
  self.shader = love.graphics.newPixelEffect('glsl/film.glsl')
  
  self.nintensity = nintensity or 0
  self.sintensity = sintensity or 0
  
  self.transition = {
    t = 0,
    delay = 0.5,
    enabled = 0
  }
end

-- Afficher le contenu
function NoiseShader:update(dt)

  -- Mise à jour de la transition
  self.transition.t = self.transition.t + self.transition.enabled * dt
  
  if self.transition.t <= 0 and self.transition.enabled == -1 then
    self.transition.t = 0
    self.transition.enabled = 0
    
    if self.endCallback then
      self.endCallback(self)
      self.endCallback = false
    end
  
  elseif self.transition.t > self.transition.delay and self.transition.enabled == 1 then
    self.transition.t = self.transition.delay
    self.transition.enabled = 0
  end
  
  local transitiond = self.transition.t / self.transition.delay
  
  self.shader:send('sintensity', self.sintensity * transitiond)
  self.shader:send('nintensity', self.nintensity * transitiond)
end

-- Afficher le contenu
function NoiseShader:drawOn(canvas)
  love.graphics.setBlendMode('premultiplied')
  
  self:attach()
  love.graphics.setPixelEffect(self.shader)
  love.graphics.draw(canvas)
  self:detach()
  
  love.graphics.setBlendMode('alpha')
  
  self.canvas:clear()
  self.canvasb:clear()
end

-- Afficher le contenu
function NoiseShader:transitionTo(intensity, duration)
  self.transition = true
  self.targetIntensity = intensity or 0.5
end

return NoiseShader
