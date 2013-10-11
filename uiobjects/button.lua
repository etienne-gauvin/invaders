local Label = require "uiobjects/label"

-- Classe Bouton pour la gestion des boutons du menu
local Button = Label:subclass('Button')

-- Constructeur
function Button:initialize(content, container, x, y)
  Label.initialize(self, content, container, x, y)
  
  -- Couleurs inversées
  self.invertColors = false
  self.data = {}
  
  -- Transition au survol
  self.transition = {
    t = 0,
    delay = 0.5,
    enabled = 0
  }
  
  -- Fonction appelée lors du clic
  self.onclick = false
end

-- Affichage du bouton
function Button:draw()
  if not self.hidden then
    -- Rectangle
    if self.invertColors then
      love.graphics.setColor(255, 255, 255, 192 + self.transition.t / self.transition.delay * 63)
    else
      love.graphics.setColor(0, 0, 0, 192 + self.transition.t / self.transition.delay * 63)
    end
    
    love.graphics.rectangle('fill',
      self.container.pos.x + self.pos.x,
      self.container.pos.y + self.pos.y,
      self.width, self.height)
  end
  
  if self.invertColors then
    local normalColor = self.color:clone()
    self.color:invert()
    Label.draw(self)
    self.color:set(normalColor)
  else
    Label.draw(self)
  end
end

-- Mise à jour du bouton
function Button:update(dt)
  Label.update(self, dt)
  
  if self.enabled then
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
    
    if self:isMouseOver() and self.transition.enabled ~= 1 then
      self.transition.t = self.transition.delay
      self.transition.enabled = -1
    
    elseif not self:isMouseOver() and self.transition.enabled ~= -1 then
      self.transition.t = 0
      self.transition.enabled = 1
    end
    
    -- Lors du clic
    if self.container.released and self:isMouseOver() and self.onclick then
      self.onclick(self)
  end
  end
end

-- Tester si la souris est au dessus
function Button:isMouseOver()
  if not self.hidden then
    local mx, my = syst.camera:worldCoords(love.mouse.getPosition())
    local bx, by = self.container.pos.x + self.pos.x, self.container.pos.y + self.pos.y
    
    return mx >= bx and mx < bx + self.width and my >= by and my < by + self.height
  end
end

return Button
