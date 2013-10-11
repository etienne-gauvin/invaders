local Vector = require 'libs/vector'
local Ease = require 'libs/ease'
local BlurShader = require 'shaders/blur-shader'
local GUI = Object:subclass('GUI')

-- Création de l'interface
function GUI:initialize(x, y, width, height)
  
  -- Taille
  self.width = width or syst.width or 0
  self.height = height or syst.height or 0
  
  -- Positionnement
  if x == 'center' then
    x = syst.width / 2 - self.width / 2
  end
  
  if y == 'center' then
    y = syst.height / 2 - self.height / 2
  end
  
  self.pos = Vector(x or 0, y or 0)
  
  -- Interface activée/désactivée
  self.enabled = false
  
  -- Fonction appelée lors de la fin de la disparition
  self.endCallback = false
  
  -- Liste des éléments de l'interface
  self.uiobjects = {}
  
  -- Transition pour l'affichage
  self.transition = {
    t = 0,
    delay = 0.15,
    enabled = 0, -- -1=décroissant|1=croissant
  }
  
  -- Canvas d'affichage
  self.canvas = love.graphics.newCanvas()
  
  -- Activer les effets lors de l'apparition/la disparition
  self.blurEffect = true
  self.movingEffect = true
  
  -- Flou
  self.shader = BlurShader:new()
  
  -- Souris cliquée/relâchée
  self.released = false
  self.pressed = false
end

-- Mise à jour de l'interface graphique
function GUI:update(dt)
  
  -- Mise à jour de la détection du relâchement du clic
  if love.mouse.isDown('l') then
    self.released = false
    self.pressed = true
  else
    self.released = self.pressed
    self.pressed = false
  end
  
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
  
  -- Mise à jour du shader
  if self.blurEffect then
    self.shader.intensity = Ease.out(self.transition.t, 2, -2, self.transition.delay)
    self.shader:update(dt)
  end
  
  -- Mise à jour des éléments
  if self.enabled then
    for e, entity in ipairs(self.uiobjects) do
      entity:update(dt)
    end
  end
end

-- Afficher l'interface graphique
function GUI:draw()
  
  local transitiond = self.transition.t / self.transition.delay
  
  -- Affichage si activé et/ou que la transition n'est pas terminée
  if self.enabled or transitiond > 0 then
    
    local prevCanvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.canvas)
    
    syst.camera:attach()
    
    --love.graphics.setColor(255, 255, 0, 128)
    --love.graphics.rectangle('line', self.pos.x, self.pos.y, self.width, self.height)
    
    -- Affichage des éléments
    for e, entity in ipairs(self.uiobjects) do
      entity:draw()
    end
    
    syst.camera:detach()
    
    love.graphics.setCanvas(prevCanvas)
    
    if self.blurEffect then
      self.shader:attach()
    end
    
    love.graphics.setColor(255, 255, 255, self.transition.t / self.transition.delay * 255)
    love.graphics.draw(self.canvas,
      self.movingEffect and Ease.out(self.transition.t, -30, 30, self.transition.delay) or 0,
      self.movingEffect and Ease.out(self.transition.t, -10, 10, self.transition.delay) or 0)
    self.canvas:clear()
    
    if self.blurEffect then
      self.shader:detach()
      self.shader:draw()
    end
  end
end

-- Activer l'interface graphique
function GUI:enable()
  if not self.enabled then
    self.enabled = true
    self.transition.t = 0
    self.transition.enabled = 1
  end
end

-- Désactiver l'interface graphique
function GUI:disable(callback)
  if self.enabled then
    self.enabled = false
    self.transition.t = self.transition.delay
    self.transition.enabled = -1
    
    self.endCallback = callback or false
  end
end

-- Ajouter un élément
function GUI:add(uiobject)
  self.uiobjects[#self.uiobjects + 1] = uiobject
end

return GUI
