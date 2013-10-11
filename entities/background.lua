local Background = Object:subclass('Background')

-- Images
local images = {
  love.graphics.newImage("assets/images/background-layer-1.png"),
  love.graphics.newImage("assets/images/background-layer-2.png"),
  love.graphics.newImage("assets/images/background-layer-3.png")
}

function Background:initialize(camera)
  self.layers = {}
  
  -- Vitesse de déplacement du décalage de l'arrière-plan
  self.speed = 0.5 
  
  if camera then
    self.camera = camera
  else
    self.camera = false
  end
  
  -- Angle du mouvement automatique (rotation)
  self.mvt = 0
  
  -- Vitesse et distance du mouvement automatique
  self.mvtDistance = 100 -- pixels
  self.mvtSpeed = 0.2 -- [0;1]
  
  
  for i, image in pairs(images) do
    table.insert(self.layers, image)
  end
end

-- Affichage du fond d'écran
function Background:draw()
  
  love.graphics.setColor(7, 9, 15, 255)
  local bx, by = self.camera:worldCoords(0, 0)
  love.graphics.rectangle('fill', bx, by, syst.width, syst.height)
  love.graphics.setColor(255, 255, 255, 255)
  
  local n = table.getn(self.layers)
  -- Fond mobile
    
  for l, layer in pairs(self.layers) do
    local w, h = layer:getWidth(), layer:getHeight()
    local tx, ty = math.floor(self.camera.x / w), math.floor(self.camera.y / h)
    local x, y =
      (self.camera.x + math.cos(self.mvt) * self.mvtDistance) / (l + 1) * self.speed % w,
      (self.camera.y + math.sin(self.mvt) * self.mvtDistance) / (l + 1) * self.speed % h
    
    for ix = -3, 2 do
      for iy = -3, 2 do
        love.graphics.draw(layer,
          (tx + ix) * w + x,
          (ty + iy) * h + y)
      end
    end
  end --]]--
  
  --[[ Fond immobile
  
  for l, layer in pairs(self.layers) do
    local w, h = layer:getWidth(), layer:getHeight()
    local tx, ty = math.floor(self.camera.x / w), math.floor(self.camera.y / h)
    
    for ix = -2, 1 do
      for iy = -2, 1 do
        love.graphics.draw(layer, (tx + ix) * w, (ty + iy) * h, self.angle)
      end
    end
  end --]]--
end

-- Mise à jour du fond d'écran
function Background:update(dt)

  -- Lent déplacement du fond
  self.mvt = (self.mvt + dt * self.mvtSpeed) % (math.pi * 2)
end

return Background
