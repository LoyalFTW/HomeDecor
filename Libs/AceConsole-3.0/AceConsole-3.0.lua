--- AceConsole-3.0 adds chat command registration and argument parsing utilities.
-- @class file
-- @name AceConsole-3.0.lua
-- @release $Id: AceConsole-3.0.lua 1284 2022-09-25 09:15:30Z nevcairiel $
local MAJOR, MINOR = "AceConsole-3.0", 7
local AceConsole, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not AceConsole then return end

-- Lua APIs
local pairs, select, type, tostring = pairs, select, type, tostring
local strfind, strsub, format       = string.find, string.sub, string.format
local max                           = math.max

-- WoW APIs
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME

AceConsole.embeds          = AceConsole.embeds          or {}
AceConsole.commands        = AceConsole.commands        or {}
AceConsole.weakcommands    = AceConsole.weakcommands    or {}

--- Register a simple chat command
-- @param command Chat command to register (without the slash, e.g. "hd")
-- @param func Callback function or method name
-- @param persist If true the command persists across DISABLE
function AceConsole:RegisterChatCommand(command, func, persist)
	if type(command) ~= "string" then
		error("AceConsole:RegisterChatCommand(command, func): command must be a string", 2)
	end

	local name = command:upper()
	local globalName = "SLASH_" .. (self.name or tostring(self)) .. name .. "1"
	local slashCount = 1

	-- find next available slot
	while _G["SLASH_" .. (self.name or tostring(self)) .. name .. slashCount] do
		slashCount = slashCount + 1
	end

	local prefix = "SLASH_" .. (self.name or tostring(self)) .. name

	-- grab first free SLASH_CMD slot by using addon name + command as key
	local cmdKey = (self.name or tostring(self)) .. "_" .. name
	_G["SLASH_" .. cmdKey .. "1"] = "/" .. command:lower()

	local callback
	if type(func) == "string" then
		callback = function(msg) return self[func] and self[func](self, msg) end
	elseif type(func) == "function" then
		callback = func
	else
		error("AceConsole:RegisterChatCommand(command, func): func must be a string or function", 2)
	end

	SlashCmdList[cmdKey] = callback

	if not persist then
		AceConsole.commands[self] = AceConsole.commands[self] or {}
		AceConsole.commands[self][command] = cmdKey
	else
		AceConsole.weakcommands[self] = AceConsole.weakcommands[self] or {}
		AceConsole.weakcommands[self][command] = cmdKey
	end
end

--- Unregister a chat command
-- @param command The command to unregister (without slash)
function AceConsole:UnregisterChatCommand(command)
	local cmds = AceConsole.commands[self]
	if not cmds then return end
	local cmdKey = cmds[command]
	if not cmdKey then return end
	SlashCmdList[cmdKey] = nil
	_G["SLASH_" .. cmdKey .. "1"] = nil
	cmds[command] = nil
end

--- Unregister all chat commands for the current object
function AceConsole:UnregisterAllChatCommands()
	local cmds = AceConsole.commands[self]
	if not cmds then return end
	for command in pairs(cmds) do
		self:UnregisterChatCommand(command)
	end
end

--- Print to the default chat frame with an optional prefix
function AceConsole:Print(...)
	local prefix = self.chatPrefix
	if prefix then
		DEFAULT_CHAT_FRAME:AddMessage(prefix .. " " .. format(...))
	else
		DEFAULT_CHAT_FRAME:AddMessage(format(...))
	end
end

--- Print a formatted string
function AceConsole:Printf(...)
	self:Print(format(...))
end

-- embedding
local mixins = {
	"RegisterChatCommand", "UnregisterChatCommand", "UnregisterAllChatCommands",
	"Print", "Printf",
}

function AceConsole:Embed(target)
	for _, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

function AceConsole:OnEmbedDisable(target)
	target:UnregisterAllChatCommands()
end

for target in pairs(AceConsole.embeds) do
	AceConsole:Embed(target)
end
