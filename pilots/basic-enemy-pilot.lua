local Pilot = require 'pilot'
local BasicEnemyPilot = Pilot:subclass('BasicEnemyPilot')

local keyConfigFile = 'key-config'

-- Classe contrôlant un vaisseau
-- Humain sur l'ordinateur
-- Il ne doit y avoir qu'une seule instance de cette classe
function BasicEnemyPilot:initialize(ship)
  Pilot.initialize(self, ship)
  
  -- Portée du radar (détection des ennemis)
  self.radarRadius = 600
  
  -- Distance maximale de suivi (> radarRadius)
  self.followingRadius = 1000
  
  -- Objectif principal du vaisseau
  self.goal = false
  self.isGoalVisible = false
  
  -- Temps depuis la dernière mise à jour de la cible
  self.lastGoalUpdate = 0
end

-- Mise à jour de la cible
function BasicEnemyPilot:updateGoal()
  local lastD = false
  local radarRadius2 = self.radarRadius * self.radarRadius
  
  if self.goal and self.ship.pos:dist(self.goal.pos) > self.followingRadius then
    self.goal = false
  end

  local lx1, ly1, lx2, ly2 = self.ship.pos.x, self.ship.pos.y, self.ship.pos.x + self.followingRadius, self.ship.pos.y
  local hitx, hity = false, false
  
  if not self.goal then
    for e, entity in ipairs(game.entities) do
      if entity.enabled and not entity.toDestroy
        and entity ~= self.ship then
        
        if entity.team and entity.body then
          -- Enemi le plus près
          if entity.team and entity.team.id ~= self.ship.team.id then
            local d = self.ship.pos:dist2(entity.pos)
            
            if (not lastD or d > lastD) and d <= radarRadius2 then
              lastD = d
              self.goal = entity
            end
          end
        end
      end
    end
  end
end

-- Mise à jour des commandes
function BasicEnemyPilot:update(dt)
  
  -- Mise à jour de la cible, si nécessaire
  self.lastGoalUpdate = self.lastGoalUpdate + dt
  if self.lastGoalUpdate >= 0.5 then
    self:updateGoal()
    self.lastGoalUpdate = 0
  end
  
  if self.goal then
    -- Mise à jour du pointeur
    self.controls.pointer_x, self.controls.pointer_y = self.goal.pos.x, self.goal.pos.y
    
    local goalDist = self.ship.pos:dist(self.goal.pos)
    self.controls.dir_up = goalDist > 200
    
    -- Vérifier que le vaisseau ennemi est bien visé directement
    local lx1, ly1, lx2, ly2 = self.ship.pos.x, self.ship.pos.y, self.ship.pos.x + math.cos(self.ship.angle) * syst.width, self.ship.pos.y + math.sin(self.ship.angle) * syst.width
    local hitEntity = false
    
    if self.goal.enabled
      and not self.goal.toDestroy
      and self.goal.body then
      
      -- Pour chaque fixture de l'entité
      for f, fixture in ipairs(self.goal.body:getFixtureList()) do
        local xn, yn, fraction = fixture:rayCast(lx1, ly1, lx2, ly2, 1)
        
        if xn then
          hitEntity = true
          break
        end
      end
    end
    
    self.controls.fire_main = hitEntity and goalDist > 200
    
  -- Le vaisseau n'a pas d'objectif
  else
    self.controls.fire_main = false
    self.controls.dir_up = false
  end
end

return BasicEnemyPilot
