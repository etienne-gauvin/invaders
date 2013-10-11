local Color = Object:subclass('Color')

-- Initialisation
-- c : {r, g, b, [a]} ou {h, s, l, [a]} ou rien pour du blanc
function Color:initialize(c)
  if c then
    self:set(c)
  else
    self.r, self.g, self.b, self.a = 255, 255, 255, 255
  end
end

-- Définir la couleur (similaire au constructeur)
-- c : {r, g, b, [a]} ou {h, s, l, [a]}
function Color:set(c)
  if c then
    if c.r and c.g and c.g then
      self.r = c.r
      self.g = c.g
      self.b = c.b
      self.a = c.a or 255
    elseif c.h and c.s and c.l then
      self.r, self.g, self.b, self.a = hsl2rgb(c.h, c.s, c.l, c.a or 255)
    end
  else
    self.r, self.g, self.b, self.a = 255, 255, 255, 255
  end
end

-- Retourne la couleur
function Color:get(alpha)
  return self.r, self.g, self.b, alpha or self.a or 255
end

-- Retourne un clone de la couleur
function Color:clone()
  return Color:new(self)
end

-- Inverse la couleur
-- invertAlpha = false
function Color:invert(invertAlpha)
  self:set({r = 255 - self.r, g = 255 - self.g, b = 255 - self.b, a = invertAlpha and 255 - self.a or self.a})
end

-- Convertir hsla -> rgba
-- https://www.love2d.org/wiki/HSL_color
local function hsl2rgb(h, s, l, a)
  if s <= 0 then return l, l, l, a end

  h, s, l = h/256*6, s/255, l/255
  
  local c = (1 - math.abs(2 * l - 1)) * s
  local x = (1 - math.abs(h % 2 - 1)) * c
  local m, r, g, b = (l - .5 * c), 0, 0, 0
  
  if h < 1     then r,g,b = c,x,0
  elseif h < 2 then r,g,b = x,c,0
  elseif h < 3 then r,g,b = 0,c,x
  elseif h < 4 then r,g,b = 0,x,c
  elseif h < 5 then r,g,b = x,0,c
  else              r,g,b = c,0,x
  end return (r + m) * 255, (g + m) * 255, (b + m) * 255, a
end

return Color
