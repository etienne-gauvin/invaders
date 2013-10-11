local Shader = Object:subclass('Shader')

-- Création du shader
function Shader:initialize()
  self.parameters = {}
  self.previousCanvas = false
  self.canvas = love.graphics.newCanvas()
end

-- Début de l'affichage
function Shader:attach()
  self.previousCanvas = love.graphics.getCanvas()
  love.graphics.setCanvas(self.canvas)
end

-- Fin de l'affichage
function Shader:detach()
  love.graphics.setCanvas(self.previousCanvas)
  self.previousCanvas = false
end

-- Mise à jour du shader
function Shader:update(dt)
end

-- Mise à jour du shader
function Shader:set(parameters)
  for key, val in pairs(parameters) do
    self.parameters[key] = val
  end
end

-- Afficher le contenu
function Shader:draw()
  love.graphics.draw(self.canvas)
  self.canvas:clear()
end

return Shader
