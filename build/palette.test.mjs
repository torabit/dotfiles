import { test } from "node:test"
import assert from "node:assert/strict"
import { flatten, resolve } from "./palette.mjs"

test("flatten はネストをドットパスに畳む", () => {
	const m = flatten({ colors: { pink: "#d70087" }, role: { accent: "{colors.pink}" } })
	assert.equal(m.get("colors.pink"), "#d70087")
	assert.equal(m.get("role.accent"), "{colors.pink}")
	assert.equal(m.size, 2)
})

test("flatten は数値キーを文字列パスにする", () => {
	const m = flatten({ ansi: { 10: "{colors.pink}" } })
	assert.equal(m.get("ansi.10"), "{colors.pink}")
})

test("resolve は 1 段の参照を解決する", () => {
	const m = resolve(flatten({ colors: { pink: "#d70087" }, role: { accent: "{colors.pink}" } }))
	assert.equal(m.get("role.accent"), "#d70087")
})

test("resolve は多段の参照を解決する", () => {
	const m = resolve(flatten({ a: { x: "#111111" }, b: { y: "{a.x}" }, c: { z: "{b.y}" } }))
	assert.equal(m.get("c.z"), "#111111")
})

test("resolve は元の map を書き換えない", () => {
	const src = flatten({ colors: { pink: "#d70087" }, role: { accent: "{colors.pink}" } })
	resolve(src)
	assert.equal(src.get("role.accent"), "{colors.pink}")
})

test("resolve は未定義参照で投げる", () => {
	assert.throws(() => resolve(flatten({ role: { accent: "{colors.nope}" } })), /未定義の参照/)
})

test("resolve は循環参照で投げる", () => {
	assert.throws(() => resolve(flatten({ a: { x: "{b.y}" }, b: { y: "{a.x}" } })), /循環参照/)
})

test("resolve は自己参照で投げる", () => {
	assert.throws(() => resolve(flatten({ a: { x: "{a.x}" } })), /循環参照/)
})
