local loc = GetLocale()
local dbs = { "items", "quests", "quests-itemreq", "objects", "units", "zones", "professions", "areatrigger", "refloot" }
local noloc = { "items", "quests", "objects", "units" }

-- Patch databases to merge TurtleWoW data
local function patchtable(base, diff)
  for k, v in pairs(diff) do
    if base[k] and type(v) == "table" then
      patchtable(base[k], v)
    elseif type(v) == "string" and v == "_" then
      base[k] = nil
    else
      base[k] = v
    end
  end
end

local loc_core, loc_update
for _, db in pairs(dbs) do
  if pfDB[db]["data-turtle"] then
    patchtable(pfDB[db]["data"], pfDB[db]["data-turtle"])
  end

  for loc, _ in pairs(pfDB.locales) do
    if pfDB[db][loc] and pfDB[db][loc.."-turtle"] then
      loc_update = pfDB[db][loc.."-turtle"] or pfDB[db]["enUS-turtle"]
      patchtable(pfDB[db][loc], loc_update)
    end
  end
end

loc_core = pfDB["professions"][loc] or pfDB["professions"]["enUS"]
loc_update = pfDB["professions"][loc.."-turtle"] or pfDB["professions"]["enUS-turtle"]
if loc_update then patchtable(loc_core, loc_update) end

if pfDB["minimap-turtle"] then patchtable(pfDB["minimap"], pfDB["minimap-turtle"]) end
if pfDB["meta-turtle"] then patchtable(pfDB["meta"], pfDB["meta-turtle"]) end

-- Reload all pfQuest internal database shortcuts
pfDatabase:Reload()
