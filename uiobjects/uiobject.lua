local Vector = require 'libs/vector'
local UIObject = Object:subclass('UIObject')
local counter = 0

-- Constructeur
function UIObject:initialize(container, x, y)
  counter = counter + 1
  self.id = self.class.name .. '_' .. counter
  self.pos = Vector(x or 0, y or 0)
  self.enabled = true
  self.hidden = false
  self.container = container or false
  
  self.transition = {
    t = 0,
    delay = 0.2,
    enabled = 0, -- -1=décroissant|1=croissant
  }
end

-- Effectuer une translation de la zone de dessin
-- Pour afficher ensuite des éléments relativement à l'objet actuel
function UIObject:attach()
  love.graphics.push()
  love.graphics.translate(self.pos.x, self.pos.y)
end

-- Terminer le dessin relatif à l'objet
function UIObject:detach()
  love.graphics.pop()
end

-- Affichage
function UIObject:draw(dt)
end

-- Mise à jour
function UIObject:update(dt)
  if self.enabled then
    -- Mise à jour de la transition
    self.transition.t = self.transition.t + self.transition.enabled * dt
    
    if self.transition.t < 0 and self.transition == -1 then
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
  end
end

-- Tester si la souris se trouve au dessus de l'objet
function UIObject:isHover(x, y)
end

-- Actions
function UIObject:onHover() end
function UIObject:onBlur() end
function UIObject:onClickDown() end
function UIObject:onClickReleased() end

return UIObject
