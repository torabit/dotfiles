local M = {}

-- j/k: wrap-aware (gj/gk) + jump mark (m') on count > 1
local function jk_map(key)
	local gkey = "g" .. key
	return function()
		if vim.v.count > 1 then
			return "m'" .. vim.v.count .. key
		end
		return vim.v.count == 0 and gkey or key
	end
end

function M.cowboy()
	local jk_overrides = {
		j = jk_map("j"),
		k = jk_map("k"),
	}

	for _, key in ipairs({ "h", "j", "k", "l", "+", "-" }) do
		local count = 0
		local timer = assert(vim.loop.new_timer())
		local map_fn = jk_overrides[key]
		local map = key
		vim.keymap.set("n", key, function()
			if vim.v.count > 0 then
				count = 0
			end
			if count >= 10 then
				vim.notify("🤠 Hold it Cowboy!", vim.log.levels.WARN)
				return ""
			else
				count = count + 1
				timer:start(2000, 0, function()
					count = 0
				end)
				return map_fn and map_fn() or map
			end
		end, { expr = true, silent = true })
	end
end

return M
