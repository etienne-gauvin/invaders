local Vector = require 'libs/vector'
local MainMenuGUI = require 'gui/main-menu-gui'
local ParamsGUI = require 'gui/params-gui'
local gamestate = require "libs/hump/gamestate"
local MenuState = Object:subclass('MenuState')

-- Images
local pointerImage = love.graphics.newImage('assets/images/pointer-5.png')

-- Affichage du menu
function MenuState:enter()
  
  -- La souris n'est pas accrochée à l'écran ici
  love.mouse.setGrab(false)
  
  -- Centre suivi par la caméra
  self.center = {
    pos = Vector(syst.width / 2, syst.height/2),
    angle = 0
  }
  syst.camera:lookAt(self.center.pos.x, self.center.pos.y)
  
  self.mmgui = MainMenuGUI:new('center', syst.height - 400, 300, 500)
  self.mmgui:enable()
  
  self.pgui = ParamsGUI:new(- syst.width / 4 * 3, syst.height / 6, syst.width / 2, syst.height - syst.height / 6 * 2)
  self.pgui:enable()
end

-- Mise à jour du menu
function MenuState:keypressed(key)
  if key == 'return' then
    syst.currentState = game
    gamestate.switch(game);
  end
  
  local d = 100
  if key == 'z' then self.center.pos.y = self.center.pos.y - d end
  if key == 's' then self.center.pos.y = self.center.pos.y + d end
  if key == 'd' then self.center.pos.x = self.center.pos.x + d end
  if key == 'q' then self.center.pos.x = self.center.pos.x - d end
  
  if key == 'g' then self:goToMainMenu() end
  if key == 'h' then self:goToParams() end
end

-- Mise à jour du menu
function MenuState:update(dt)
  syst.background:update(dt)
  
  -- Mise à jour de la position de la caméra
  -- (Lente rotation)
  if math.abs(syst.camera.x - self.center.pos.x) >= 0.00001 then
    syst.camera.x = syst.camera.x - (syst.camera.x - self.center.pos.x) * dt * 3
  else syst.camera.x = self.center.pos.x end
  
  if math.abs(syst.camera.y - self.center.pos.y) >= 0.00001 then
    syst.camera.y = syst.camera.y - (syst.camera.y - self.center.pos.y) * dt * 3
  else syst.camera.y = self.center.pos.y end
  
  if syst.camera.rot - self.center.angle ~= 0 then
    syst.camera.rot = syst.camera.rot - (syst.camera.rot - self.center.angle) * dt * 3
  end
  
  -- Mise à jour de l'interface graphique
  self.mmgui:update(dt)
  self.pgui:update(dt)
end

-- Affichage du menu
function MenuState:draw()
  
  syst.camera:attach()
  syst.background:draw()
  syst.camera:detach()
  
  -- Affichage de l'interface graphique
  self.mmgui:draw(dt)
  self.pgui:draw(dt)
  
  -- Pointeur
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(pointerImage, love.mouse.getX() - pointerImage:getWidth() / 2, love.mouse.getY() - pointerImage:getHeight() / 2)
end

-- Déplacer la caméra vers l'interface "Paramètres"
function MenuState:goToParams()
  if self.currentGUI ~= self.pgui then
    self.center.pos.x = - syst.width / 2
    self.center.pos.y = syst.height / 2
  end
end

-- Déplacer la caméra vers l'interface "Paramètres"
function MenuState:goToMainMenu()
  if self.currentGUI ~= self.mmgui then
    self.center.pos.x = syst.width / 2
    self.center.pos.y = syst.height / 2
  end
end

return MenuState
