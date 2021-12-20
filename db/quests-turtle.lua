pfDB["quests"]["data-turtle"] = {
  -- Puffing Peace
  [40001] = {
    ["start"] = {
      ["U"] = { 60300 },
    },
    ["end"] = {
      ["U"] = { 3185 },
    },
    ["lvl"] = 10,
    ["min"] = 8,
    ["next"] = 40002,
  },
  -- Grand Herbal Theft
  [40002] = {
    ["start"] = {
      ["U"] = { 3185 },
    },
    ["end"] = {
      ["U"] = { 60300 },
    },
    ["obj"] = {
      ["I"] = { 60000 },
    },
    ["lvl"] = 10,
    ["min"] = 8,
    ["next"] = 40003,
    ["pre"] = { 40001 },
  },
  -- Hookah For Your Troubles
  [40003] = {
    ["start"] = {
      ["U"] = { 60300 },
    },
    ["end"] = {
      ["U"] = { 60300 },
    },
    ["lvl"] = 10,
    ["min"] = 8,
    ["pre"] = { 40001, 40002 },
  },
  -- A Glittering Opportunity
  [80395] = {
    ["start"] = {
      ["U"] = { 3658 },
    },
    ["end"] = {
      ["U"] = { 81041 },
    },
    ["lvl"] = 13,
    ["min"] = 13,
    ["next"] = 80396,
  },
}
