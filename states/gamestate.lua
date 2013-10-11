local Vector = require 'libs/vector'
local PlayerShip = require 'entities/ships/player-ship'
local BasicEnemyShip = require 'entities/ships/basic-enemy-ship'
local ArmorItem = require 'entities/items/armor-item'
local HealthItem = require 'entities/items/health-item'
local Team = require 'team'
local BlurShader = require 'shaders/blur-shader'
local GameState = Object:subclass('GameState')

-- Sons
local alarmSound = love.audio.newSource("assets/sounds/alarm.ogg", "static")
alarmSound:setLooping(true)

-- Démarrage de la scène
function GameState:enter()
  
  -- Monde physique
  love.physics.setMeter(64)
  self.world = love.physics.newWorld(0, 0, true)
  self.world:setCallbacks(
    function(a, b, c) GameState.beginContact(self, a, b, c) end,
    function(a, b, c) GameState.endContact(self, a, b, c) end,
    function(a, b, c) GameState.preSolve(self, a, b, c) end,
    function(a, b, c) GameState.postSolve(self, a, b, c) end
  )
  
  -- Canvas d'affichage
  self.canvas = {
    background = love.graphics.newCanvas(),
    entities = love.graphics.newCanvas(),
    hud = love.graphics.newCanvas(),
    interface = love.graphics.newCanvas()
  }
  
  -- Shaders
  syst.shaders = {
    blur = BlurShader:new()
  }
  
  -- Pause
  self.pause = false
  self.bulletveltype = 0
  
  -- Type de contrôles
  self.controlType = 1
  
  -- Entitées
  self.entities = {}
  
  -- Équipes
  local team1, team2 = Team:new(), Team:new()
  self.team1, self.team2 = team1, team2
  
  team1.secondaryColor = Color:new({r=255, g=0, b=0})
  team1.enemies[#team2.enemies + 1] = team1
  
  team2.secondaryColor = Color:new({r=0, g=255, b=0})
  team2.enemies[#team2.enemies + 1] = team2
  
  -- Joueur principal
  self.player = PlayerShip:new(0, 0, team1)
  table.insert(self.entities, self.player)
  
  -- Limites de la zone de jeu (circulaire)
  self.limits = {}
  
  -- Limite de visibilité
  if love.graphics.getHeight() > love.graphics.getWidth() then
    self.limits.visible = love.graphics.getHeight() / 2
  else
    self.limits.visible = love.graphics.getWidth() / 2
  end
  
  -- Limite d'apparition des objets
  self.limits.playfield = self.limits.visible * 2
  
  -- Limite de destruction des objets
  self.limits.forbidden = self.limits.visible * 4
  
  -- Centre suivi par la caméra
  self.center = {
    pos = self.player.pos:clone(),
    angle = self.player.angle
  }
  
  -- Création d'ennemis automatique
  self.enemyCreation = true
  self.enemyCreationRate = 1
  self.maxEnemies = 20
  self.lastEnemyCreated = 0
  
  -- Création d'items automatique
  self.itemCreation = true
  self.itemCreationRate = 1
  self.maxItems = 10
  self.lastItemCreated = 0
  
  -- Centrage de la caméra
  syst.camera:lookAt(self.center.pos.x, self.center.pos.y)
  
  -- Attacher la souris à la fenêtre
  love.mouse.setGrab(true)
end

-- Mise à jour du jeu
function GameState:update(dt)
  if not self.pause then
    
    -- Création d'ennemis
    self.lastEnemyCreated = self.lastEnemyCreated + dt
    if self.enemyCreation and self.lastEnemyCreated >= self.enemyCreationRate then
      self:createRandomEnemy()
      self.lastEnemyCreated = 0
    end
    
    -- Création d'items
    self.lastItemCreated = self.lastItemCreated + dt
    if self.itemCreation and self.lastItemCreated >= self.itemCreationRate then
      self:createRandomItem()
      self.lastItemCreated = 0
    end
    
    -- Mise à jour du monde physique
    self.world:update(dt)
    
    -- Mise à jour des objets
    for i, entity in ipairs(self.entities) do
      
      -- L'entité est à détruire ou hors-limite
      if entity.toDestroy or not self:isInAllowedZone(entity.pos.x, entity.pos.y) then
        
        entity:destroy()
        table.remove(self.entities, i)
        
      -- L'entité est active et dans la zone de jeu
      elseif entity.enabled then
        entity:update(dt)
      end
    end
    
    -- Mise à jour de la position de la caméra
    game:updateCameraCenter(dt, self.player.pos.x, self.player.pos.y, self.player.angle)
    
    -- Mise à jour du fond d'écran
    syst.background:update(dt)
  end
  
  -- Mise à jour du flou
  syst.shaders.blur:update(dt)
  
  -- Mise à jour de l'alarme
  -- Activée si la vie du joueur est <= 10
  if self.player.enabled and self.player.health <= 10 then
    alarmSound:play()
  else
    alarmSound:stop()
  end
end

-- Activer/désactiver la pause
function GameState:keyreleased(key)
  if key == 'escape' then
    self.pause = not self.pause
    love.mouse.setGrab(not self.pause)
    
    if self.pause then
      syst.shaders.blur.intensity = 0
      syst.shaders.blur:transitionTo(0.5)
    else
      syst.shaders.blur.intensity = 0.5
      syst.shaders.blur:transitionTo(0)
    end
  end
  
  if key == 'b' then
    self.bulletveltype = self.bulletveltype == 1 and 0 or 1
  end
  
  if key == 'c' then
    self.controlType = self.controlType == 1 and 2 or 1
  end
  
  if key == 'k' then
    self.player.health = self.player.health - 24
  end
  
  if key == 'e' then
    self.player.body:setLinearVelocity(0, 0)
  end
end

-- Met à jour le centre suivi par la caméra
-- x, y Les points sur le monde
function GameState:updateCameraCenter(dt, x, y, angle)
  
  self.center = {
    pos = Vector(x, y),
    angle = angle or 0
  }
  
  -- Distance entre le centre de l'écran et le vaisseau
  local distance = 0
  
  -- Mise à jour de la position de la caméra
  syst.camera:lookAt(
    self.center.pos.x + math.cos(self.center.angle) * distance,
    self.center.pos.y + math.sin(self.center.angle) * distance
  )
end

-- Crée un ennemi aléatoire autour du centre
function GameState:createRandomEnemy()
  local enemiesCount = 0
  for e in ipairs(self.team2.ships) do enemiesCount = enemiesCount + 1 end
  
  if enemiesCount < self.maxEnemies then
    local seed = math.random()
    local angle = math.pi * 2 * seed
    local x, y =
      math.cos(angle) * self.limits.playfield + self.center.pos.x,
      math.sin(angle) * self.limits.playfield + self.center.pos.y
    
    table.insert(self.entities, BasicEnemyShip:new(x, y, self.team2))
  end
end

-- Crée un ennemi aléatoire autour du centre
function GameState:createRandomItem()
  local itemCount = 0
  for i in ipairs(self.entities) do
    if self.entities.isItem then
      itemCount = itemCount + 1
    end
  end
  
  if itemCount < self.maxItems then
    local seed = math.random()
    local angle = math.pi * 2 * seed
    local x, y =
      math.cos(angle) * self.limits.playfield / 3 * 2 + self.center.pos.x,
      math.sin(angle) * self.limits.playfield / 3 * 2 + self.center.pos.y
    
    if seed < 0.5 then
      table.insert(self.entities, HealthItem:new(x, y))
    else
      table.insert(self.entities, ArmorItem:new(x, y))
    end
  end
end

-- Détermine si un point est bien dans la zone considérée comme visible
function GameState:isVisible(entity)
  local cx, cy = syst.camera:cameraCoords(entity.pos.x, entity.pos.y)
  return
    cx - entity.visibleRadius < love.graphics.getWidth() and
    cx + entity.visibleRadius >= 0 and
    cy - entity.visibleRadius < love.graphics.getHeight() and
    cy + entity.visibleRadius >= 0
end

-- Détermine si un point est bien dans la zone de jeu
function GameState:isInPlayfield(x, y)
  return vector.dist(x, y, self.center.pos.x, self.center.pos.y) <= self.limits.playfield
end

-- Détermine si un point est bien dans la zone autorisée
function GameState:isInAllowedZone(x, y)
  return vector.dist(x, y, self.center.pos.x, self.center.pos.y) < self.limits.forbidden
end

-- Retourne la liste des entités visibles
function GameState:getVisibleEntities()
  local visibleEntities = {}
  for i, entity in pairs(self.entities) do
    if entity.enabled and not entity.toDestroy and self:isVisible(entity) then
      visibleEntities[#visibleEntities+1] = entity
    end
  end
  return visibleEntities
end

-- Affichage
function GameState:draw()
  love.graphics.setBlendMode('alpha')
  love.graphics.setColor(255, 255, 255, 255)
  local previousCanvas = love.graphics.getCanvas()
  
  -- Début du dessin des objets
  syst.camera:attach()
  
  -- Fond étoilé
  self.canvas.background:clear()
  love.graphics.setCanvas(self.canvas.background)
  syst.background:draw()
  
  -- Entités
  self.canvas.entities:clear()
  love.graphics.setCanvas(self.canvas.entities)
  for i, entity in pairs(self.entities) do
    if entity.enabled and self:isVisible(entity) then
      entity:draw()
      
       --love.graphics.setColor(255, 0, 255, 128)
       --love.graphics.circle('fill', entity.pos.x, entity.pos.y, 5)
    end
  end
  
  syst.camera:detach()
  
  -- Affichage des infos sur le jeu
  self.canvas.hud:clear()
  love.graphics.setCanvas(self.canvas.hud)
  love.graphics.setFont(syst.font[14])
  love.graphics.setColor(255, 255, 255)
  
  -- Vie du joueur
  if self.player.enabled then
    love.graphics.printf(self.player.health .. " / 100", syst.width - 110, 30, 100, 'right')
  end
  
  -- Affichage tête haute (HUD)
  self.canvas.interface:clear()
  love.graphics.setCanvas(self.canvas.interface)
  
  if self.pause then
    love.graphics.setColor(0, 4, 8, 240)
    love.graphics.rectangle('fill', 0, syst.height / 2 - 34, syst.width, 68)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setFont(syst.font[20])
    love.graphics.printf('PAUSE',
      0,
      syst.height / 2 - 24,
      syst.width, 'center'
    )
  end
  
  -- Retour au canvas par défaut et affichage de tous les canvas
  love.graphics.setCanvas(previousCanvas)
  
  syst.shaders.blur:attach()
  love.graphics.draw(self.canvas.background)
  love.graphics.draw(self.canvas.entities)
  
  love.graphics.draw(self.canvas.hud)
  syst.shaders.blur:detach()
  
  syst.shaders.blur:draw()
  
  if self.pause then
    love.graphics.draw(self.canvas.interface)
  end
  
  -- Affichage des fps
  love.graphics.setFont(syst.font[20])
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(love.timer.getFPS() .. " fps", 10, 10, syst.width - 20, 'right')
  
  -- Affichage d'infos sur la gauche
  love.graphics.setFont(syst.font[20])
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf('', 10, 10, syst.width - 20, 'left')
  
  -- Pointeur
  love.graphics.setColor(self.player.secondaryColor:get())
  love.graphics.draw(syst.gamePointer, love.mouse.getX() - syst.gamePointer:getWidth() / 2, love.mouse.getY() - syst.gamePointer:getHeight() / 2)
end

-- Retourne les paramètres utiles de la collision entre objets
-- return : entityA, entityB, contact, velocity
function getContactParams(fixtureA, fixtureB, contact)
  local x1, y1 = fixtureA:getBody():getLinearVelocity()
  local x2, y2 = fixtureB:getBody():getLinearVelocity()

  return
    fixtureA:getUserData().entity,
    fixtureB:getUserData().entity,
    contact,
    math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

-- Début de la collision de deux objets
function GameState:beginContact(fixtureA, fixtureB, contact)
  local entityA, entityB, contact, velocity = getContactParams(fixtureA, fixtureB, contact)
  print("[coll] (" .. entityA.id .. ", " .. entityB.id .. ")")

  entityA:beginContact(entityB, contact, velocity, fixtureB, fixtureA)
  entityB:beginContact(entityA, contact, velocity, fixtureA, fixtureB)
end

-- Fin de la collision de deux objets
function GameState:endContact(fixtureA, fixtureB, contact)
  local entityA, entityB, contact, velocity = getContactParams(fixtureA, fixtureB, contact)
  
  entityA:endContact(entityB, contact, velocity, fixtureB, fixtureA)
  entityB:endContact(entityA, contact, velocity, fixtureA, fixtureB)
end

-- Début du calcul de la collision de deux objets
function GameState:preSolve(fixtureA, fixtureB, contact)
  local entityA, entityB, contact, velocity = getContactParams(fixtureA, fixtureB, contact)
  
  entityA:preSolve(entityB, contact, velocity, fixtureB, fixtureA)
  entityB:preSolve(entityA, contact, velocity, fixtureA, fixtureB)
end

-- Fin du calcul de la collision de deux objets
function GameState:postSolve(fixtureA, fixtureB, contact)
  local entityA, entityB, contact, velocity = getContactParams(fixtureA, fixtureB, contact)
  
  entityA:postSolve(entityB, contact, velocity, fixtureB, fixtureA)
  entityB:postSolve(entityA, contact, velocity, fixtureA, fixtureB)
end

return GameState
