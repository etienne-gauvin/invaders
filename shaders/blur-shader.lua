local Shader = require 'shaders/shader'
local BlurShader = Shader:subclass('BlurShader')

-- Création du shader
function BlurShader:initialize(intensity, x, y, width, height)
  Shader.initialize(self)
  
  self.pos = Vector(x or 0, y or 0)
  self.width = width or syst.width
  self.height = height or syst.height
  
  self.shader = love.graphics.newPixelEffect('glsl/blur.glsl')
  self.shader:send('imageSize', {self.width, self.height})
  
  self.intensity = intensity or 0
  
  self.transition = false
  self.targetIntensity = 0
  
  self.canvasb = love.graphics.newCanvas()
end

-- Afficher le contenu
function BlurShader:update(dt)
  if self.transition then
    if self.targetIntensity > self.intensity then
      self.intensity = self.intensity + 0.1
      
      if self.intensity >= self.targetIntensity then
        self.transition = false
      end
    else
      self.intensity = self.intensity - 0.1
      
      if self.intensity <= self.targetIntensity then
        self.transition = false
      end
    end
  end
  
  self.shader:send('intensity', self.intensity * 5)
end

-- Afficher le contenu
function BlurShader:draw()
  love.graphics.setBlendMode('premultiplied')
  
  if self.intensity > 0 then
    self.previousCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvasb)
    self.shader:send('direction', {1, 0})
    love.graphics.setPixelEffect(self.shader)
    love.graphics.draw(self.canvas, self.pos.x, self.pos.y)
    
    love.graphics.setCanvas(self.previousCanvas)
    self.shader:send('direction', {0, 1})
    love.graphics.setPixelEffect(self.shader)
    love.graphics.draw(self.canvasb)
    love.graphics.setPixelEffect()
  else
    love.graphics.draw(self.canvas)
  end
  
  love.graphics.setBlendMode('alpha')
  
  self.canvas:clear()
  self.canvasb:clear()
end

-- Afficher le contenu
function BlurShader:transitionTo(intensity, duration)
  self.transition = true
  self.targetIntensity = intensity or 0.5
end

return BlurShader
