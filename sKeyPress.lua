local _G = _G
local SlashCmdList = SlashCmdList
local animationsCount, animations = 5, {}
local animationNum = 1
local replace = string.gsub
local texture, animationGroup, alpha1, scale1, scale2, rotation2
local EventFrame = CreateFrame("frame", "EventFrame")
local addon_loaded = false

for i = 1, animationsCount do
	local frame = CreateFrame("Frame")

	texture = frame:CreateTexture()
	texture:SetTexture([[Interface\Cooldown\star4]])
	texture:SetAlpha(0)
	texture:SetAllPoints()
	texture:SetBlendMode("ADD")
	animationGroup = texture:CreateAnimationGroup()

	alpha1 = animationGroup:CreateAnimation("Alpha")
	alpha1:SetFromAlpha(0)
	alpha1:SetToAlpha(1)
	alpha1:SetDuration(0)
	alpha1:SetOrder(1)

	scale1 = animationGroup:CreateAnimation("Scale")
	scale1:SetScale(1.5, 1.5)
	scale1:SetDuration(0)
	scale1:SetOrder(1)

	scale2 = animationGroup:CreateAnimation("Scale")
	scale2:SetScale(0, 0)
	scale2:SetDuration(0.3)
	scale2:SetOrder(2)

	rotation2 = animationGroup:CreateAnimation("Rotation")
	rotation2:SetDegrees(90)
	rotation2:SetDuration(0.3)
	rotation2:SetOrder(2)

	animations[i] = { frame = frame, animationGroup = animationGroup }
end

local function animate(button)
	local animation = animations[animationNum]
	local frame = animation.frame
	local animationGroup = animation.animationGroup
	frame:SetFrameStrata("HIGH")
	--frame:SetFrameStrata(button:GetFrameStrata()) -- caused multiactionbars to show animation behind the bar instead of on top of it
	frame:SetFrameLevel(button:GetFrameLevel() + 10)
	frame:SetAllPoints(button)
	animationGroup:Stop()
	animationGroup:Play()
	animationNum = (animationNum % animationsCount) + 1
	return true
end

local function configButton(name, command)
	local button = _G[name]

	if button ~= nil and not button.hooked then
		local key = GetBindingKey(command)

		if key then
			button:RegisterForClicks("AnyDown")
			SetOverrideBinding(button, true, key, 'CLICK ' .. button:GetName() .. ':LeftButton')
		end

		button.AnimateThis = animate
		SecureHandlerWrapScript(button, "OnClick", button, [[ control:CallMethod("AnimateThis", self) ]])

		button.hooked = true
	end
end

local function configDefaultUiPetBar()
	for i = 1, 10, 1 do
		local button_command = ("BONUSACTIONBUTTON%d"):format(i)
		local button_name = ("PetActionButton%d"):format(i)

		configButton(button_name, button_command)
	end
end

local function configPetBar()
	for i = 1, 10, 1 do
		local button_command = ("BONUSACTIONBUTTON%d"):format(i)
		local bt4_button_name = ("BT4PetButton%d"):format(i)

		configButton(bt4_button_name, button_command)
	end
end

local function configDefaultUiBarOne()
	for i = 1, 12, 1 do
		local button_command = ("ACTIONBUTTON%d"):format(i)
		local bt4_button_name = ("BT4Button%d"):format(i)

		configButton(bt4_button_name, button_command)
	end
end

local function configDefaultUiButtons()
	for i = 1, 12, 1 do
		local button_commands = { ("ActionButton%d"):format(i), ("MultiBarBottomLeftButton%d"):format(i),
			("MultiBarBottomRightButton%d"):format(i), ("MultiBarLeftButton%d"):format(i),
			("MultiBarRightButton%d"):format(i) }

		for j = 1, 5, 1 do
			configButton(button_commands[j], string.upper(button_commands[j]))
		end
	end
end

local function configBartenderButtons()
	for i = 13, 120, 1 do
		local button_command = "CLICK BT4Button" .. i .. ":LeftButton"
		local button_name = ("BT4Button%d"):format(i)

		configButton(button_name, button_command)
	end
end

local function init()
	local bartender_loaded = IsAddOnLoaded("Bartender4")

	if bartender_loaded then
		configDefaultUiBarOne()
		configBartenderButtons()
		configPetBar()
	else
		configDefaultUiButtons()
		configDefaultUiPetBar()
	end
end

local function onStart(self, event)
	if addon_loaded == false and event == "PLAYER_ENTERING_WORLD" then
		addon_loaded = true

		-- EventFrame:UnregisterEvent("ADDON_LOADED")
		-- EventFrame:UnregisterEvent("PLAYER_LOGIN")
		EventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")

		init()
	end
end

EventFrame:SetScript("OnEvent", onStart)
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
-- EventFrame:RegisterEvent("ADDON_LOADED")
-- EventFrame:RegisterEvent("PLAYER_LOGIN")
