local ADDON, NS = ...
NS.Systems.EditMode = NS.Systems.EditMode or {}

local EM = NS.Systems.EditMode

EM.defaults = {
	on            = true,
	hud           = true,
	clipboard     = true,
	batchPlace    = true,
	batchRotate   = true,
	batchStep     = 15,
	lock          = true,
	rotPanel      = true,
	rotPanelStep  = 15,
	locks         = {},
	keybinds      = {
		copy      = "CTRL-C",
		cut       = "CTRL-X",
		paste     = "CTRL-V",
		duplicate = "CTRL-D",
		lock      = "L",
	},
}

function EM.GetKeybind(action)
	local db = EM.DB()
	if db.keybinds and db.keybinds[action] ~= nil then
		return db.keybinds[action]
	end
	return EM.defaults.keybinds[action]
end

function EM.SetKeybind(action, key)
	local db = EM.DB()
	db.keybinds = db.keybinds or {}
	if key == nil then
		db.keybinds[action] = EM.defaults.keybinds[action]
	else
		db.keybinds[action] = key
	end
	if EM.Keys and EM.Keys.Apply then EM.Keys.Apply() end
end

function EM.DB()
	local db = NS.db and NS.db.profile and NS.db.profile.editMode
	if not db then return EM.defaults end
	return db
end

function EM.On(key)
	local db = EM.DB()
	if db.on == false then return false end
	local v = db[key]
	if v == nil then return EM.defaults[key] ~= false end
	return v ~= false
end
