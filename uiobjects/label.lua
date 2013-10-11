local UIObject = require "uiobjects/uiobject"

-- Classe Label pour la gestion des textes
local Label = UIObject:subclass('Label')

-- Constructeur
function Label:initialize(content, container, x, y, color)
  UIObject.initialize(self, container, x, y)
  
  self.content = content
  self.color = Color:new(color)
  self.fontSize = fontSize or 30
  self.fixedWidth = true
  self.fixedHeight = true
  self.textColor = {255, 255, 255}
  self.textAlign = 'center'
  
  -- Marge interne
  self.padding = {
    left = 10,
    top = 10,
    right = 10,
    bottom = 10
  }
  
  -- Dimensions
  if type(self.content) == 'string' then
    self.width = #self.content * self.fontSize + self.padding.right + self.padding.left
    self.height = self.fontSize + self.padding.top + self.padding.bottom
  else
    self.width = self.content:getWidth() + self.padding.right + self.padding.left
    self.height = self.content:getHeight() + self.padding.top + self.padding.bottom
  end
end

-- Affichage du label
function Label:draw()
  UIObject.draw(self)
  
  if not self.hidden then
    -- Texte
    love.graphics.setFont(syst.font[self.fontSize])
    love.graphics.setColor(self.color:get())
    if type(self.content) == 'string' then
      love.graphics.printf(self.content,
        self.container.pos.x + self.pos.x,
        self.container.pos.y + self.pos.y + self.padding.top,
        self.width, self.textAlign)
    else
      love.graphics.draw(self.content,
        self.container.pos.x + self.pos.x + self.width / 2 - self.content:getWidth() / 2,
        self.container.pos.y + self.pos.y + self.height / 2 - self.content:getHeight() / 2)
    end
  end
end

-- Mise à jour du label
function Label:update(dt)
  UIObject.update(self, dt)
  
  if self.enabled then
    if type(self.content) == 'string' then
      if not self.fixedWidth then
        self.width = #self.content * self.fontSize + self.padding.right + self.padding.left end
      if not self.fixedHeight then
        self.height = self.fontSize + self.padding.top + self.padding.bottom end
    else
      if not self.fixedWidth then
        self.width = self.content:getWidth() + self.padding.right + self.padding.left end
      if not self.fixedHeight then
        self.height = self.content:getHeight() + self.padding.top + self.padding.bottom end
    end
  end
end

return Label
