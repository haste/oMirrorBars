-- Rename this file to config.lua if you want it to override the default
-- settings.
--
-- Values that aren't set will fallback to their default option. This is
-- also true for sub-tables.

local _, settings = ...

settings.width = 220
settings.height = 18
settings.texture = [[Interface\AddOns\oMirrorBars\textures\statusbar]]

-- The syntax used here is equal to: http://wowprogramming.com/docs/widgets/Region/SetPoint
settings.position = {
	BREATH = string.join('#', 'TOP', 'UIParent', 'TOP', 0, -96),
	EXHAUSTION = string.join('#', 'TOP', 'UIParent', 'TOP', 0, -119),
	FEIGNDEATH = string.join('#', 'TOP', 'UIParent', 'TOP', 0, -142),
}

settings.colors = {
	EXHAUSTION = {1, .9, 0},
	BREATH = {0, .5, 1},
	DEATH = {1, .7, 0},
	FEIGNDEATH = {1, .7, 0},
}
