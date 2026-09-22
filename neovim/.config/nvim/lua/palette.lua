-- vanadis が書くのは lua/vanadis.lua。ここはその値を固定のテーブルへ載せ替え、
-- 登録された貼り直しを順に呼ぶ。
--
-- require("palette") が返すテーブルの同一性を変えない。local p = require("palette")
-- で掴んでいる側は再読込を意識せず p.bg を読み続けられる。中身だけが入れ替わる。
-- package.loaded を捨てて require し直すだけだと、既にロード済みのモジュールが
-- upvalue に持っている古いテーブルが残る。
--
-- 貼り直しは on_apply に渡す。登録した順に呼ばれるので、起動時の実行順がそのまま
-- 再現される。reload は走っている nvim へ vanadis-reload-nvim が投げる。

local colors = require("vanadis")
local appliers = {}

local M = setmetatable({}, {
	__index = function(_, key)
		return colors[key]
	end,
})

-- 貼り直しを登録し、その場で 1 回呼ぶ。
function M.on_apply(fn)
	appliers[#appliers + 1] = fn
	fn()
end

function M.reload()
	package.loaded["vanadis"] = nil
	colors = require("vanadis")
	for _, fn in ipairs(appliers) do
		fn()
	end
end

-- --remote-expr の入口。v:lua.VanadisReload() で呼ぶ。式なので値を返す。
_G.VanadisReload = function()
	M.reload()
	return "ok"
end

return M
