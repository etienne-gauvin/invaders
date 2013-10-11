require 'libs/config'
require 'libs/middleclass'
Vector = require 'libs/vector'
Color = require 'libs/color'

local gamestate = require "libs/hump/gamestate"
local Background = require "entities/background"
local Camera = require "libs/hump/camera"

-- Syst
syst = {width = love.graphics.getWidth(), height = love.graphics.getHeight()}

-- Configuration
loadConfig()
love.graphics.setMode(syst.config.resolutionX, syst.config.resolutionY, syst.config.fullscreen)

-- Variables globales
syst.width = love.graphics.getWidth()
syst.height = love.graphics.getHeight()
game = (require "states/gamestate"):new()
menu = (require "states/menustate"):new()
syst.currentState = menu
vector = require "libs/vector-light"

-- Chargement du jeu
function love.load()
  
  -- Sauvegarde(s)
  syst.save = false
  
  -- Hauteur et largeur de la fenêtre
  syst.width, syst.height = love.graphics.getWidth(), love.graphics.getHeight()
  
  -- Chargement de la police
  syst.fontname = "assets/font/ubuntu-condensed.ttf"
  syst.font = {
    [14] = love.graphics.newFont(syst.fontname, 14),
    [18] = love.graphics.newFont(syst.fontname, 18),
    [20] = love.graphics.newFont(syst.fontname, 20),
    [30] = love.graphics.newFont(syst.fontname, 30),
    [40] = love.graphics.newFont(syst.fontname, 40),
    [60] = love.graphics.newFont(syst.fontname, 60)
  }
  
  -- Curseurs
  syst.gamePointerPath = 'assets/images/' .. syst.config.pointer
  syst.gamePointer = love.graphics.newImage(syst.gamePointerPath)
  
  -- Caméra
  syst.camera = Camera(0, 0)
  
  -- Fond d'écran
  syst.background = Background(syst.camera)
  love.graphics.setBackgroundColor(13, 14, 26);
  
  -- Niveau de brouillage de l'écran
  syst.interference = 0.1
  
  -- Souris
  love.mouse.setVisible(false)
  
  -- Son
  love.audio.setVolume(0)
  
  -- Démarrage du jeu
  gamestate.registerEvents();
  gamestate.switch(menu);
end

-- Fonctions toujours disponibles au clavier
function love.keypressed(key)
  -- Quitter
  if key == 'f1' then
    love.event.push('quit')
  end
  
  -- Retourner au menu principal
  if key == 'f2' then
    gamestate.switch(menu);
    game = (require "states.gamestate"):new()
  end
  
  -- Allumer/éteindre le son
  if key == 'f3' then
    love.audio.setVolume(love.audio.getVolume() == 0 and 1 or 0)
  end
  
  -- (Dés)activer le mode plein écran
  if false and key == 'f11' then
    local modes = love.graphics.getModes()
    local fsmode = modes[table.getn(modes) - 1]
    local width, height, flags = love.graphics.getMode()
    
--     if flags and flags.fullscreen then -- love2d 0.9.0
    if flags then -- love2d 0.8.0
      print('unset fullscreen')
--       love.graphics.setMode(1024, 768, {fullscreen = false}) -- love2d 0.9.0
      love.graphics.setMode(1024, 768, false) -- love2d 0.8.0
    else
      print('set fullscreen')
--       love.graphics.setMode(fsmode.width, fsmode.height, {fullscreen = true}) -- love2d 0.9.0
      love.graphics.setMode(fsmode.width, fsmode.height, true) -- love2d 0.8.0
    end
  end
end

-- Position précédente de la souris
local pmousex, pmousey = love.mouse.getPosition()
local sensi = 2

-- Mise à jour du jeu
function love.update(dt)
  -- Sensibilité de la souris
  if love.mouse.isGrabbed() and sensi ~= 1 then
    nmousex, nmousey = love.mouse.getPosition()
    local diffx, diffy = pmousex - nmousex, pmousey - nmousey
    love.mouse.setPosition(pmousex - diffx * sensi, pmousey - diffy * sensi)
  end
  
  pmousex, pmousey = love.mouse.getPosition()
end

-- Affichage du jeu
function love.draw()
end

-- Fin du jeu, enregistrement de la configuration
function love.quit()
  writeConfig()
end

