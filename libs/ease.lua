local Ease = {}

-- t : avancement dans le temps
-- b : valeur initiale
-- c : valeur ajoutée
-- d : durée
Ease["in"] = function(t, b, c, d)
  t = t / d
  return c * t * t + b
end

-- t : avancement dans le temps
-- b : valeur initiale
-- c : valeur ajoutée
-- d : durée
Ease.out = function(t, b, c, d)
  t = t / d
  return - c * t * (t - 2) + b
end

-- t : avancement dans le temps
-- b : valeur initiale
-- c : valeur ajoutée
-- d : durée
Ease.inout = function(t, b, c, d)
  t = t / d / 2
  if t < 1 then return c / 2 * t * t + b end
  t = t - 1
  return - c / 2 * (t * (t - 2) - 1) + b
end

return Ease
