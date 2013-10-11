local Vector = require 'libs/vector'
local Item = require 'entities/item'
local PickedUpEffect = require 'entities/effects/picked-up-effect'

-- Classe Item
local HealthItem = Item:subclass('HealthItem')

-- Images
local itemImage = love.graphics.newImage('assets/images/health-item.png')

-- Constructeur
function HealthItem:initialize(x, y)
  Item.initialize(self, x, y, 0)
  
  self.healthValue = 20
  self.width = itemImage:getWidth()
  self.height = itemImage:getHeight()
  
  -- Temps depuis le dernier
  self.pulse = 0
  
  -- Couleur de la pulsation lumineuse
  self.light.color1 = {1, 0, 0, 0.8}
  self.light.color2 = {1, 0, 0, 0.8}
  self.light.speed = math.random() * 2 + 2.5
  
  -- Création de l'élément dans le monde physique
  self.body = love.physics.newBody(game.world, self.pos.x, self.pos.y, 'dynamic')
  self.body:setLinearDamping(8)
  self.body:setAngularDamping(8)
  local mx, my, mass, inertia = self.body:getMassData()
  self.body:setMassData(mx, my, mass, inertia)
  
  self.shape = love.physics.newCircleShape(itemImage:getWidth() / 2 + 1)
  
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData({entity = self})
end

-- Affichage
function HealthItem:draw()
  
  self:attach()
  
  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.draw(itemImage, - self.width / 2, - self.height / 2)
  
  self:detach()
  
  -- Hitbox
  --love.graphics.setColor(0, 255, 0, 128)
  --love.graphics.circle("fill", self.pos.x, self.pos.y, self.shape:getRadius())
end

-- Collision avec un autre objet
function HealthItem:beginContact(entity, contact, velocity)
  Item.beginContact(self, entity, contact, velocity)
  
  if not entity.isItem and not entity.isArmor then
    local effect = PickedUpEffect(self.pos.x, self.pos.y, itemImage, self.width, self.height)
    table.insert(game.entities, effect)
  end
end

return HealthItem
