local GUI = require 'gui'
local Button = require "uiobjects/button"
local gamestate = require "libs/hump/gamestate"
local MainMenuGUI = GUI:subclass('MainMenuGUI')

-- Création de l'interface
function MainMenuGUI:initialize(x, y, width, height)
  GUI.initialize(self, x, y, width, height)
  
  -- Liste des boutons
  local b = {}
  self.buttons = b
  
  -- Boutons
  b.continue = Button('Continuer', self, 0, 0)
  b.continue.width = 300
  b.continue.fixedWidth = true
  b.continue.enabled = syst.save
  b.continue.hidden = not syst.save
  b.continue.onclick = function()
    self:disable(function()
      syst.currentState = game
      gamestate.switch(game)
    end)
  end
  
  b.newgame = Button('Nouvelle partie', self, 0, b.continue.pos.y + b.continue.height + 20)
  b.newgame.width = 300
  b.newgame.fixedWidth = true
  b.newgame.onclick = function()
    self:disable(function()
      syst.currentState = game
      gamestate.switch(game)
    end)
  end
  
  b.params = Button('Paramètres', self, 0, b.newgame.pos.y + b.newgame.height + 20)
  b.params.width = 300
  b.params.fixedWidth = true
  b.params.onclick = function()
    print(menu)
    menu:goToParams()
  end
  
  b.quit = Button('Quitter', self, 0, b.params.pos.y + b.params.height + 20)
  b.quit.width = 300
  b.quit.fixedWidth = true
  b.quit.onclick = function() love.event.quit() end
  
  for ib in pairs(b) do
    self:add(b[ib])
  end
end

return MainMenuGUI
