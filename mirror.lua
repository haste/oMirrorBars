local _DEFAULTS = {
	width = 220,
	height = 18,

	position = {
		["BREATH"] = 'TOP#UIParent#TOP#0#-96';
		["EXHAUSTION"] = 'TOP#UIParent#TOP#0#-119';
		["FEIGNDEATH"] = 'TOP#UIParent#TOP#0#-142';
	};

	colors = {
		EXHAUSTION = {1, .9, 0};
		BREATH = {0, .5, 1};
		DEATH = {1, .7, 0};
		FEIGNDEATH = {1, .7, 0};
	};
}

local _DB

local Spawn, PauseAll
do
	local barPool = {}

	local savePosition = function(self)
		local p1, frame, p2, x, y = self:GetPoint()

		_DB.position[self.type] = string.join('#', p1, frame, p2, x, y)
	end

	local loadPosition = function(self)
		local pos = _DB.position[self.type]
		local p1, frame, p2, x, y = strsplit("#", pos)

		return self:SetPoint(p1, frame, p2, x, y)
	end

	local OnDragStop = function(self)
		self:StopMovingOrSizing()
		self:savePosition()
	end

	local OnDragStart = function(self)
		self:StartMoving()
	end

	local OnUpdate = function(self, elapsed)
		if(self.paused) then return end

		self:SetValue(GetMirrorTimerProgress(self.type) / 1e3)
	end

	local Start = function(self, value, maxvalue, scale, paused, text)
		if(paused > 0) then
			self.paused = 1
		elseif(self.paused) then
			self.paused = nil
		end

		self.text:SetText(text)

		self:SetMinMaxValues(0, maxvalue / 1e3)
		self:SetValue(value / 1e3)

		if(not self:IsShown()) then self:Show() end
	end

	function Spawn(type)
		if(barPool[type]) then return barPool[type] end
		local frame = CreateFrame('StatusBar', nil, UIParent)

		frame:SetScript("OnUpdate", OnUpdate)
		frame:SetScript('OnDragStart', OnDragStart)
		frame:SetScript('OnDragStop', OnDragStop)

		-- XXX: Toggle this later on:
		--frame:EnableMouse(true)
		frame:SetMovable(true)
		frame:RegisterForDrag'LeftButton'

		local r, g, b = unpack(_DB.colors[type])

		local bg = frame:CreateTexture(nil, 'BACKGROUND')
		bg:SetAllPoints(frame)
		bg:SetTexture[[Interface\AddOns\oMirrorBars\textures\statusbar]]
		bg:SetVertexColor(r * .5, g * .5, b * .5)

		local text = frame:CreateFontString(nil, 'OVERLAY')
		text:SetFont(GameFontNormalSmall:GetFont(), 11)
		text:SetShadowOffset(.8, -.8)
		text:SetShadowColor(0, 0, 0, 1)

		text:SetJustifyH'CENTER'
		text:SetTextColor(1, 1, 1)

		text:SetPoint('LEFT', frame)
		text:SetPoint('RIGHT', frame)
		text:SetPoint('TOP', frame, 0, -3)
		text:SetPoint('BOTTOM', frame)

		frame:SetSize(_DB.width, _DB.height)

		frame:SetStatusBarTexture[[Interface\AddOns\oMirrorBars\textures\statusbar]]
		frame:SetStatusBarColor(r, g, b)

		frame.type = type
		frame.text = text

		frame.Start = Start
		frame.Stop = Stop

		loadPosition(frame)

		barPool[type] = frame
		return frame
	end

	function PauseAll(val)
		for _, bar in next, barPool do
			bar.paused = val
		end
	end
end

local frame = CreateFrame'Frame'
frame:SetScript('OnEvent', function(self, event, ...)
	return self[event](self, ...)
end)

function frame:ADDON_LOADED(addon)
	if(addon == 'oMirrorBars') then
		UIParent:UnregisterEvent'MIRROR_TIMER_START'

		_DB = setmetatable((oMirrorBars or {}), {__index = _DEFAULTS})

		self:UnregisterEvent'ADDON_LOADED'
		self.ADDON_LOADED = nil
	end
end
frame:RegisterEvent'ADDON_LOADED'

function frame:PLAYER_ENTERING_WORLD()
	for i=1, MIRRORTIMER_NUMTIMERS do
		local type, value, maxvalue, scale, paused, text = GetMirrorTimerInfo(i)
		if(type ~= 'UNKNOWN') then
			Spawn(type):Start(value, maxvalue, scale, paused, text)
		end
	end
end
frame:RegisterEvent'PLAYER_ENTERING_WORLD'

function frame:MIRROR_TIMER_START(type, value, maxvalue, scale, paused, text)
	return Spawn(type):Start(value, maxvalue, scale, paused, text)
end
frame:RegisterEvent'MIRROR_TIMER_START'

function frame:MIRROR_TIMER_STOP(type)
	return Spawn(type):Hide()
end
frame:RegisterEvent'MIRROR_TIMER_STOP'

function frame:MIRROR_TIMER_PAUSE(duration)
	return PauseAll((duration > 0 and duration) or nil)
end
frame:RegisterEvent'MIRROR_TIMER_PAUSE'
