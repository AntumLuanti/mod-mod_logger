
local mod_logger = {}
local debug_mods = core.settings:get_bool("debug_mods", false)


--- Core logging function.
--
--  @param mod_name
--    Name of logging mod.
--  @param mod_table
--    Table containing logging info.
--  @param lvl
--    Logging level. Can be one of "warn", "error", or "debug". If its value is `nil` the standard
--    message logging level will be used (same as `log(msg)`).
--  @param msg
--    Logging message text.
local log = function(mod_name, mod_table, lvl, msg)
	if msg == nil then
		msg = lvl
		lvl = nil
	end

	local prefix = "["..mod_name.."]"
	if lvl ~= nil then
		lvl = lvl:lower()

		if lvl == "debug" and not debug_mods then
			return
		elseif lvl == "warn" then
			lvl = "warning"
		end

		-- exclude prefixes already added by Luanti engine
		if lvl ~= "warning" and lvl ~= "error" then
			prefix = lvl:upper()..prefix
		end
	end

	msg = prefix.." "..msg
	if not lvl or lvl == "debug" then
		core.log(msg)
	else
		core.log(lvl, msg)
	end
end


--- Registers logging functions to mod.
--
--  Functions added to `mod_table`:
--  - `mod_table.log(lvl, msg)`
--  - `mod_table.log(msg)`
--  - `mod_table.warn(msg)`
--  - `mod_table.error(msg)`
--  - `mod_table.debug(msg)`
--
--  @param mod_table
--    Table to which logging functions will be added.
register_mod_logger = function(mod_table)
	local mod_name = core.get_current_modname()

	-- main logging function
	mod_table.log = function(lvl, msg)
		log(mod_name, mod_table, lvl, msg)
	end

	-- wrapper for logging warning level messages
	mod_table.warn = function(msg)
		log(mod_name, mod_table, "warn", msg)
	end

	-- wrapper for logging error level messages
	mod_table.error = function(msg)
		log(mod_name, mod_table, "error", msg)
	end

	-- wrapper for logging debug level message
	mod_table.debug = function(msg)
		log(mod_name, mod_table, "debug", msg)
	end

	if mod_logger.debug then
		mod_logger.debug("registered logger for mod '"..mod_name.."'")
	end
end


-- register logger for this mod
register_mod_logger(mod_logger)

-- debug
if debug_mods then
	mod_logger.log("default log message")
	mod_logger.warn("warning log message")
	mod_logger.error("error log message")
	mod_logger.debug("debug log message")
end
