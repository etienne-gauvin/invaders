local GUI = require 'gui'
local Label = require "uiobjects/label"
local Button = require "uiobjects/button"
local Color = require "libs/color"
local gamestate = require "libs/hump/gamestate"
local ParamsGUI = GUI:subclass('ParamsGUI')

-- Images ON/OFF
local onImage = love.graphics.newImage('assets/images/on.png')
local offImage = love.graphics.newImage('assets/images/off.png')

-- Liste des pointeurs disponibles pendant le jeu
local pointers = { "pointer-1.png", "pointer-2.png", "pointer-3.png", "pointer-4.png", "pointer-6.png", "pointer-7.png" }
local pointerImages = {}

--- Images des pointeurs
for p, pointer in ipairs(pointers) do
  pointerImages[#pointerImages + 1] = love.graphics.newImage("assets/images/" .. pointer)
end

-- Liste des résolutions disponibles
local resolutions = love.graphics.getModes()
local currentResI = 1

-- Insère la résolution actuelle dans la liste si elle n'existe pas
local ok = false
for ir, r in ipairs(resolutions) do
  if r.width == syst.config.resolutionX and r.height == syst.config.resolutionY then
    ok = true
  end
end
if not ok then
  resolutions[#resolutions + 1] = {width = syst.config.resolutionX, height = syst.config.resolutionY}
end

-- Tri
table.sort(resolutions, function(a, b) return (a.width < b.width and a.height < b.height) end)

-- Recherche de la définition actuelle dans la liste
for ir, r in ipairs(resolutions) do
  if r.width == syst.config.resolutionX and r.height == syst.config.resolutionY then
    currentResI = ir
  end
end


-- Création de l'interface
function ParamsGUI:initialize(x, y, width, height)
  GUI.initialize(self, x, y, width, height)
  
  -- Liste des boutons
  local b = {}
  self.buttons = b
  
  b.selectPointer = Label('Curseur :', self, 20, 0)
  b.selectPointer.textAlign = "left"
  b.selectPointer.height = 60
  b.selectPointer.width = 140
  
  -- Fonction de sélection du pointeur
  local selectPointer = function(button)
    for ib in pairs(self.buttons) do
      if string.sub(ib, 1, 7) == 'pointer' then
        self.buttons[ib].invertColors = false
      end
    end
    
    button.invertColors = true
    syst.gamePointer = button.data.pointerImage
    syst.gamePointerPath = button.data.pointerImagePath
    syst.config.pointer = button.data.pointerImagePath
  end
  
  -- Pointeurs
  for p, pointerImage in ipairs(pointerImages) do
    local pn = 'pointer' .. p
    
    b[pn] = Button(pointerImage, self, b.selectPointer.width + 20 + (p - 1) * 60, 0)
    b[pn].data.pointerImage = pointerImage
    b[pn].data.pointerImagePath = pointers[p]
    b[pn].width = 60
    b[pn].height = 60
    b[pn].invertColors = "assets/images/" .. pointers[p] == syst.gamePointerPath
    b[pn].onclick = selectPointer
  end
  
  -- Label d'affichage de la résolution
  b.resolution = Label("Résolution : " .. resolutions[currentResI].width .. 'x' .. resolutions[currentResI].height, self, 20, 80)
  b.resolution.width = 300
  b.resolution.textAlign = "left"
  
  -- Boutons de changement de résolution
  b.nextRes = Button('+', self, b.resolution.pos.x + b.resolution.width + 60, 80)
  b.nextRes.width = 60
  b.nextRes.height = 60
  b.nextRes.onclick = function()
    currentResI = currentResI + 1
    if currentResI > #resolutions then
      currentResI = 1
    end
    
    syst.config.resolutionX = resolutions[currentResI].width
    syst.config.resolutionY = resolutions[currentResI].height
    b.resolution.content = "Résolution : " .. resolutions[currentResI].width .. 'x' .. resolutions[currentResI].height
    b.restartlabel.hidden = false
  end
  
  b.prevRes = Button('-', self, b.resolution.pos.x + b.resolution.width, 80)
  b.prevRes.width = 60
  b.prevRes.height = 60
  b.prevRes.onclick = function()
    currentResI = currentResI - 1
    if currentResI <= 0 then
      currentResI = #resolutions
    end
    
    syst.config.resolutionX = resolutions[currentResI].width
    syst.config.resolutionY = resolutions[currentResI].height
    b.resolution.content = "Résolution : " .. resolutions[currentResI].width .. 'x' .. resolutions[currentResI].height
    b.restartlabel.hidden = false
  end
  
  -- Label "Plein écran"
  b.fullscreenLabel = Label("Plein écran :", self, 20, 160)
  b.fullscreenLabel.width = 300
  b.fullscreenLabel.textAlign = "left"
  
  b.fullscreen = Button(
    syst.config.fullscreen and onImage or offImage,
    self, b.fullscreenLabel.pos.x + b.fullscreenLabel.width, 160)
  b.fullscreen.data.on = syst.config.fullscreen
  b.fullscreen.width = 60
  b.fullscreen.height = 60
  b.fullscreen.onclick = function(fsButton)
    fsButton.data.on = not fsButton.data.on
    fsButton.content = fsButton.data.on and onImage or offImage
    syst.config.fullscreen = fsButton.data.on
    
    b.restartlabel.hidden = false
  end
  
  -- Label "Redémarrer pour prendre les changements en compte"
  b.restartlabel = Label("Redémarrer le jeu pour appliquer la nouvelle configuration", self, 20, 240)
  b.restartlabel.fontSize = 20
  b.restartlabel.fixedHeight = false
  b.restartlabel.textAlign = "left"
  b.restartlabel.hidden = true
  
  
  -- Bouton de retour au menu
  b.back = Button('Retour', self, self.width - 270, nil)
  b.back.width = 250
  b.back.pos.y = self.height - b.back.height - 20
  b.back.fixedWidth = true
  b.back.onclick = function()
    menu:goToMainMenu()
  end
  
  for ib in pairs(b) do
    self:add(b[ib])
  end
end

return ParamsGUI
