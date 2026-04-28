require("nvim-ts-autotag").setup({})

require("template-string").setup({})

-- tsconfig.local.json があればそちらを tsserver に渡す
local TsserverProvider = require("typescript-tools.tsserver_provider")
local Path = require("plenary.path")
local _orig_get_tsconfig = TsserverProvider.get_tsconfig_path

function TsserverProvider:get_tsconfig_path()
	local local_config = Path:new(self.root_dir, "tsconfig.local.json")
	if local_config:exists() then
		return local_config
	end
	return _orig_get_tsconfig(self)
end

require("typescript-tools").setup({
	settings = {
		tsserver_plugins = {
			"@styled/typescript-styled-plugin",
		},
		tsserver_max_memory = 4096,
		tsserver_file_preferences = {
			includeInlayParameterNameHints = "literals",
			includeCompletionsForModuleExports = true,
		},
	},
})
