local _, NS = ...

local RecipeKnowledge = {}
NS.Systems.RecipeKnowledge = RecipeKnowledge

function RecipeKnowledge:Observe(skillID, known)
  if NS.Systems.AltProfessions then NS.Systems.AltProfessions:ObserveRecipe(skillID, known) end
end

function RecipeKnowledge:GetCrafters(skillID)
  if not tonumber(skillID) then return {}, false, 0 end
  return NS.Systems.AltProfessions:GetCrafterNames(skillID)
end

function RecipeKnowledge:HasAlt(skillID)
  local _, hasAlt = self:GetCrafters(skillID)
  return hasAlt
end

function RecipeKnowledge:GetCharacterCount()
  return #NS.Systems.AltProfessions:GetCharacters()
end

function RecipeKnowledge:IsCurrentKnown(skillID)
  return NS.Systems.AltProfessions:IsCurrentKnown(skillID)
end

return RecipeKnowledge
