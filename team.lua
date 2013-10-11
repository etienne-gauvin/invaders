local Team = Object:subclass('Team')
local teams = {}

-- Équipe
function Team:initialize()
  self.id = #teams + 1
  teams[#teams + 1] = self
  
  self.color = Color:new({r=255, g=255, b=255})
  self.secondaryColor = Color:new({r=255, g=255, b=255})
  
  self.ships = {}
  self.enemies = {}
end

-- Vérifier si l'équipe est ennemie d'une autre
function Team:isEnemyOf(team)
  for e, enemy in enemies do
    if enemy == team then
      return true
    end
  end
end

-- Retourne la liste des équipes
function getTeams()
  return teams
end

-- Team par défaut
teams[1] = Team:new()

return Team
