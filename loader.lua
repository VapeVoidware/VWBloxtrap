repeat task.wait() until game:IsLoaded()
if shared.vape then shared.vape:Uninject() end

if identifyexecutor and ({identifyexecutor()})[1] == 'Argon' then
	getgenv().setthreadidentity = nil
end

getgenv().setthreadidentity = function() end
getgenv().run = function(func)
	local suc, err = pcall(function() func() end)
	if (not suc) then
		warn('Error in module! Error log: '..debug.traceback(tostring(err)))
	end
end

local vape
local loadstring = function(...)
	local res, err = loadstring(...)
	if err and vape then
		vape:CreateNotification('VWBloxtrap', 'Failed to load : '..err, 30, 'alert')
	end
	return res
end
if hookfunction == nil then getgenv().hookfunction = function() end end
local queue_on_teleport = queue_on_teleport or function() end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
getgenv().cloneref = function(obj) return obj end
local cloneref = cloneref or function(obj)
	return obj
end
local playersService = cloneref(game:GetService('Players'))

local oldtbl = {}
local function finishLoading()
	vape.Init = nil
	vape:Load()
	task.spawn(function()
		repeat
			shared.VapeFullyLoaded = vape.Loaded
			vape:Save()
			task.wait(10)
		until not vape.Loaded
	end)
	task.spawn(function()
		repeat
			shared.vape.ObjectsThatCanBeSaved = shared.vape.ObjectsThatCanBeSaved or {}
			if oldtbl ~= vape.Modules then
				oldtbl = vape.Modules
				for i,v in pairs(vape.Modules) do
					v.ToggleButton = function(...)
						v:Toggle(...)
					end
					if tostring(i) == "Breaker" then
						shared.vape.ObjectsThatCanBeSaved.NukerOptionsButton = {Api = v}
					end
					shared.vape.ObjectsThatCanBeSaved[tostring(i).."OptionsButton"] = {Api = v}
				end
			end
			pcall(function()
				local uipallet = vape.libraries.uipallet
				local hue, saturation, value = Color3.toHSV(uipallet.Main)
				shared.vape.ObjectsThatCanBeSaved["Gui ColorSliderColor"] = {Api = {Hue = vape.GUIColor.Hue, Sat = vape.GUIColor.Sat, Value = vape.GUIColor}}
			end)
			shared.GuiLibrary = shared.vape
			task.wait(10)
		until not vape.Loaded
	end)

	local teleportedServers
	vape:Clean(playersService.LocalPlayer.OnTeleport:Connect(function()
		if (not teleportedServers) and (not shared.VapeIndependent) then
			teleportedServers = true
			local teleportScript = [[
				repeat task.wait() until game:IsLoaded()
				
				shared.VapeSwitchServers = true
				shared.vapereload = true
				if shared.VapeDeveloper or shared.VoidDev then
					if isfile('vape/NewMainScript.lua') then
						loadstring(readfile("vape/NewMainScript.lua"))()
					else
						loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))()
					end
				else
					loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/NewMainScript.lua", true))()
				end
			]]
			if shared.VapeDeveloper then
				teleportScript = 'shared.VapeDeveloper = true\n'..teleportScript
			end
			if shared.VoidDev then
				teleportScript = 'shared.VoidDev = true\n'..teleportScript
			end
			if shared.ClosetCheatMode then
				teleportScript = 'shared.ClosetCheatMode = true\n'..teleportScript
			end
			if shared.RiseMode then
				teleportScript = 'shared.RiseMode = true\n'..teleportScript
			end
			if shared.VapePrivate then
				teleportScript = 'shared.VapePrivate = true\n'..teleportScript
			end
			if shared.NoVoidwareModules then
				teleportScript = 'shared.NoVoidwareModules = true\n'..teleportScript
			end
			if shared.ProfilesDisabled then
				teleportScript = 'shared.ProfilesDisabled = true\n'..teleportScript
			end
			if shared.NoAutoExecute then
				teleportScript = 'shared.NoAutoExecute = true\n'..teleportScript
			end
			if shared.TeleportExploitAutowinEnabled then
				teleportScript = 'shared.TeleportExploitAutowinEnabled = true\n'..teleportScript
			end
			if shared.VapeCustomProfile then
				teleportScript = "shared.VapeCustomProfile = '"..shared.VapeCustomProfile.."'\n"..teleportScript
			end
			if shared.TestingMode then
				teleportScript = 'shared.TestingMode = true\n'..teleportScript
			end
			vape:Save()
			queue_on_teleport(teleportScript)
		end
	end))

	if not shared.vapereload then
		if not vape.Categories then return end
		if vape.Categories.Main.Options['GUI bind indicator'].Enabled then
			vape:CreateNotification('Finished Loading', vape.VapeButton and 'Press the button in the top right to open GUI' or 'Press '..table.concat(vape.Keybind, ' + '):upper()..' to open GUI', 5)
		end
	end
end

if not isfile('vape/profiles/gui.txt') then
	writefile('vape/profiles/gui.txt', 'new')
end
local gui = readfile('vape/profiles/gui.txt')

if not isfolder('vape/assets/'..gui) then
	makefolder('vape/assets/'..gui)
end
local VWFunctions = loadstring(game:HttpGet("https://raw.githubusercontent.com/VapeVoidware/VWRewrite/main/libraries/VoidwareFunctions.lua", true))()
--pload('libraries/VoidwareFunctions.lua', true, true)
VWFunctions.GlobaliseObject("VoidwareFunctions", VWFunctions)
VWFunctions.GlobaliseObject("VWFunctions", VWFunctions)

vape = pload('guis/'..gui..'.lua', true, true)
shared.vape = vape
getgenv().vape = vape
getgenv().GuiLibrary = vape
shared.GuiLibrary = vape

getgenv().InfoNotification = function(title, msg, dur)
	warn('info', tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur)
end
getgenv().warningNotification = function(title, msg, dur)
	warn('warn', tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur, 'warning')
end
getgenv().errorNotification = function(title, msg, dur)
	warn("error", tostring(title), tostring(msg), tostring(dur))
	vape:CreateNotification(title, msg, dur, 'alert')
end
--[[pcall(function()
	if (not isfile('vape/discord2.txt')) then
		task.spawn(function() InfoNotification("Whitelist", "Was whitelisted and your whitelist dissapeared? Join back the discord server :D       ", 30) end)
		task.spawn(function() InfoNotification("Discord", "New server! discord.gg/voidware!              ", 30) end)
		task.spawn(function() warningNotification("Discord", "New server! discord.gg/voidware!             ", 30) end)
		task.spawn(function() errorNotification("Discord", "New server! discord.gg/voidware!              ", 30) end)
		writefile('vape/discord2.txt', '')
	end
end)--]]

if not shared.VapeIndependent then
	pload('modules.lua', true)
	finishLoading()
else
	vape.Init = finishLoading
	return vape
end