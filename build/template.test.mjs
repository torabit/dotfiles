import { test } from "node:test"
import assert from "node:assert/strict"
import { render } from "./template.mjs"

const palette = new Map([
	["role.bg", "#eeeeee"],
	["role.accent", "#d70087"],
	["ansi.10", "#d70087"],
])

test("トークンを置換する", () => {
	const { out, missing } = render('background = "{{role.bg}}"', palette)
	assert.equal(out, 'background = "#eeeeee"')
	assert.deepEqual(missing, [])
})

test("同じトークンを複数回置換する", () => {
	const { out } = render("{{role.bg}} {{role.bg}}", palette)
	assert.equal(out, "#eeeeee #eeeeee")
})

test("数値を含むパスを置換する", () => {
	const { out } = render("{{ansi.10}}", palette)
	assert.equal(out, "#d70087")
})

test("ハイフンを含むパスを置換する", () => {
	const { out } = render("{{role.accent}}", palette)
	assert.equal(out, "#d70087")
})

test("トークンが無いテキストは素通しする", () => {
	const text = "set -g mouse on\n# コメント\n"
	assert.equal(render(text, palette).out, text)
})

test("未定義トークンを全件集める", () => {
	const { missing } = render("{{a.b}} {{role.bg}} {{c.d}}", palette)
	assert.deepEqual(missing, ["a.b", "c.d"])
})

test("未定義トークンは重複を除いて返す", () => {
	const { missing } = render("{{a.b}} {{a.b}}", palette)
	assert.deepEqual(missing, ["a.b"])
})

test("単一波括弧は置換しない", () => {
	const text = "{role.bg} #{pane_current_path}"
	assert.equal(render(text, palette).out, text)
})
