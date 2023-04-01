#!/usr/bin/env lua

-- A little script to create a diff from both pfQuest and the turtle fork.
-- Requires you to have both versions of pfQuest checked out as following:
--   ./pfQuest (https://github.com/shagu/pfQuest)
--   ./pfQuest-Fork (https://github.com/Haaxor1689/pfQuest)

function smalltable(tbl)
  local size = tblsize(tbl)
  if size > 10 then return end
  if size < 1 then return end

  for i=1, size do
    if not tbl[i] then return end
    if type(tbl[i]) == "table" then return end
  end

  return true
end

function sanitize(str)
  str = string.gsub(str, "\\", "\\\\")
  str = string.gsub(str, "\"", "\\\"")
  str = string.gsub(str, "\'", "\\\'")
  str = string.gsub(str, "\r", "")
  str = string.gsub(str, "\n", "")
  return str
end

function sanitize_table(tbl)
  if not type(tbl) == "table" then return end

  for k, v in pairs(tbl) do
    if type(v) == "string" then
      tbl[k] = sanitize(v)
    elseif type(v) == "table" then
      sanitize_table(v)
    end
  end
end

function __genOrderedIndex( t )
  local orderedIndex = {}
  for key in pairs(t) do
    table.insert( orderedIndex, key )
  end
  table.sort( orderedIndex )
  return orderedIndex
end

function orderedNext(t, state)
  local key = nil
  if state == nil then
    t.__orderedIndex = __genOrderedIndex( t )
    key = t.__orderedIndex[1]
  else
    for i = 1,#t.__orderedIndex do
      if t.__orderedIndex[i] == state then
        key = t.__orderedIndex[i+1]
      end
    end
  end

  if key then
    return key, t[key]
  end

  t.__orderedIndex = nil
  return
end

function opairs(t)
  return orderedNext, t, nil
end

function tblsize(tbl)
  local count = 0
  for _ in pairs(tbl) do
    count = count + 1
  end
  return count
end

-- return true if the base table or any of its subtables
-- has different values than the new table
function isdiff(new, base)
  -- different types
  if type(new) ~= type(base) then
    return true
  end

  -- different values
  if type(new) ~= "table" then
    if new ~= base then
      return true
    end
  end

  -- recursive on tables
  if type(new) == "table" then
    for k, v in pairs(new) do
      local result = isdiff(new[k], base[k])
      if result then return true end
    end
  end

  return nil
end

-- create a new table with only those indexes that are
-- either different or non-existing in the base table
function tablesubstract(new, base)
  local result = {}

  -- write turtle-wow values
  for k, v in pairs(new) do
    if new[k] and not base[k] then
      -- write new entries
      result[k] = new[k]
    elseif new[k] and base[k] and isdiff(new[k], base[k]) then
      -- write different entries
      result[k] = new[k]
    end
  end

  -- remove obsolete entries
  for k, v in pairs(base) do
    if base[k] and not new[k] then
      result[k] = "_"
    end
  end

  return result
end

function serialize(file, name, tbl, spacing, flat)
  local closehandle = type(file) == "string"
  local file = type(file) == "string" and io.open(file, "w") or file
  local spacing = spacing or ""

  if tblsize(tbl) == 0 then
    file:write(spacing .. name .. " = {},\n")
  else
    file:write(spacing .. name .. " = {\n")

    for k, v in opairs(tbl) do
      local prefix = "["..k.."]"
      if type(k) == "string" then
        prefix = "[\""..k.."\"]"
      end

      if type(v) == "table" and flat then
        file:write("  "..spacing..prefix .. " = {},\n")
      elseif type(v) == "table" and smalltable(v) then
        local init
        local line = spacing.."  "..prefix.." = { "
        for _, v in pairs(v) do
          line = line .. (init and ", " or "") .. (type(v) == "string" and "\""..v.."\"" or v)
          if not init then
            init = true
          end
        end
        line = line .. " },\n"
        file:write(line)

      elseif type(v) == "table" then
        serialize(file, prefix, v, spacing .. "  ")
      elseif type(v) == "string" then
        file:write("  "..spacing..prefix .. " = " .. "\"" .. v .. "\",\n")
      elseif type(v) == "number" then
        file:write("  "..spacing..prefix .. " = " .. v .. ",\n")
      end
    end

    file:write(spacing.."}" .. (not closehandle and "," or "") .. "\n")
  end

  if closehandle then file:close() end
end

-- [ Load pfQuest-fork ] --
-- base table to load into
pfDB = {
  ["areatrigger"] = {},
  ["units"] = {},
  ["objects"] = {},
  ["items"] = {},
  ["refloot"] = {},
  ["quests"] = {},
  ["quests-itemreq"] = {},
  ["zones"] = {},
  ["minimap"] = {},
  ["meta"] = {},
  ["zones"] = {},
  ["professions"] = {},
}

local list = { "areatrigger", "units", "objects", "items", "refloot", "quests", "quests-itemreq", "zones", "minimap", "meta" }
local loclist = { "items", "objects", "professions", "quests", "units", "zones" }

for id, name in pairs(list) do
  dofile("pfQuest-fork/db/"..name..".lua")
end

for id, name in pairs(loclist) do
  dofile("pfQuest-fork/db/enUS/"..name..".lua")
end

sanitize_table(pfDB)

local pfDBF = pfDB

-- [ Load pfQuest ] --
-- base table to load into
pfDB = {
  ["areatrigger"] = {},
  ["units"] = {},
  ["objects"] = {},
  ["items"] = {},
  ["refloot"] = {},
  ["quests"] = {},
  ["quests-itemreq"] = {},
  ["zones"] = {},
  ["minimap"] = {},
  ["meta"] = {},
  ["zones"] = {},
  ["professions"] = {},
}

for id, name in pairs(list) do
  dofile("pfQuest/db/"..name..".lua")
end

for id, name in pairs(loclist) do
  dofile("pfQuest/db/enUS/"..name..".lua")
end

sanitize_table(pfDB)

-- [ Create Diff ] --
local data = "data-turtle"
local base = "data"
local locale_base = "enUS"
local locale_new = "enUS-turtle"

pfDB["areatrigger"]["data-turtle"] = tablesubstract(pfDBF["areatrigger"]["data"], pfDB["areatrigger"]["data"])
pfDB["units"]["data-turtle"] = tablesubstract(pfDBF["units"]["data"], pfDB["units"]["data"])
pfDB["objects"]["data-turtle"] = tablesubstract(pfDBF["objects"]["data"], pfDB["objects"]["data"])
pfDB["items"]["data-turtle"] = tablesubstract(pfDBF["items"]["data"], pfDB["items"]["data"])
pfDB["refloot"]["data-turtle"] = tablesubstract(pfDBF["refloot"]["data"], pfDB["refloot"]["data"])
pfDB["quests"]["data-turtle"] = tablesubstract(pfDBF["quests"]["data"], pfDB["quests"]["data"])
pfDB["quests-itemreq"]["data-turtle"] = tablesubstract(pfDBF["quests-itemreq"]["data"], pfDB["quests-itemreq"]["data"])
pfDB["zones"]["data-turtle"] = tablesubstract(pfDBF["zones"]["data"], pfDB["zones"]["data"])
pfDB["minimap-turtle"] = tablesubstract(pfDBF["minimap"], pfDB["minimap"])
pfDB["meta-turtle"] = tablesubstract(pfDBF["meta"], pfDB["meta"])

-- [ Locales ] --
pfDB["units"]["enUS-turtle"] = tablesubstract(pfDBF["units"]["enUS"], pfDB["units"]["enUS"])
pfDB["objects"]["enUS-turtle"] = tablesubstract(pfDBF["objects"]["enUS"], pfDB["objects"]["enUS"])
pfDB["items"]["enUS-turtle"] = tablesubstract(pfDBF["items"]["enUS"], pfDB["items"]["enUS"])
pfDB["quests"]["enUS-turtle"] = tablesubstract(pfDBF["quests"]["enUS"], pfDB["quests"]["enUS"])
pfDB["zones"]["enUS-turtle"] = tablesubstract(pfDBF["zones"]["enUS"], pfDB["zones"]["enUS"])
pfDB["professions"]["enUS-turtle"] = tablesubstract(pfDBF["professions"]["enUS"], pfDB["professions"]["enUS"])

-- [ Write ] --
local loc = "enUS"
local exp = "-turtle"
local data = "data-turtle"

serialize(string.format("../db/areatrigger%s.lua", exp), "pfDB[\"areatrigger\"][\""..data.."\"]", pfDB["areatrigger"][data])
serialize(string.format("../db/units%s.lua", exp), "pfDB[\"units\"][\""..data.."\"]", pfDB["units"][data])
serialize(string.format("../db/objects%s.lua", exp), "pfDB[\"objects\"][\""..data.."\"]", pfDB["objects"][data])
serialize(string.format("../db/items%s.lua", exp), "pfDB[\"items\"][\""..data.."\"]", pfDB["items"][data])
serialize(string.format("../db/refloot%s.lua", exp), "pfDB[\"refloot\"][\""..data.."\"]", pfDB["refloot"][data])
serialize(string.format("../db/quests%s.lua", exp), "pfDB[\"quests\"][\""..data.."\"]", pfDB["quests"][data])
serialize(string.format("../db/quests-itemreq%s.lua", exp), "pfDB[\"quests-itemreq\"][\""..data.."\"]", pfDB["quests-itemreq"][data])
serialize(string.format("../db/zones%s.lua", exp), "pfDB[\"zones\"][\""..data.."\"]", pfDB["zones"][data])
serialize(string.format("../db/minimap%s.lua", exp), "pfDB[\"minimap"..exp.."\"]", pfDB["minimap"..exp])
serialize(string.format("../db/meta%s.lua", exp), "pfDB[\"meta"..exp.."\"]", pfDB["meta"..exp])

serialize(string.format("../db/%s/units%s.lua", loc, exp), "pfDB[\"units\"][\""..loc..exp.."\"]", pfDB["units"][loc..exp])
serialize(string.format("../db/%s/objects%s.lua", loc, exp), "pfDB[\"objects\"][\""..loc..exp.."\"]", pfDB["objects"][loc..exp])
serialize(string.format("../db/%s/items%s.lua", loc, exp), "pfDB[\"items\"][\""..loc..exp.."\"]", pfDB["items"][loc..exp])
serialize(string.format("../db/%s/quests%s.lua", loc, exp), "pfDB[\"quests\"][\""..loc..exp.."\"]", pfDB["quests"][loc..exp])
serialize(string.format("../db/%s/professions%s.lua", loc, exp), "pfDB[\"professions\"][\""..loc..exp.."\"]", pfDB["professions"][loc..exp])
serialize(string.format("../db/%s/zones%s.lua", loc, exp), "pfDB[\"zones\"][\""..loc..exp.."\"]", pfDB["zones"][loc..exp])
