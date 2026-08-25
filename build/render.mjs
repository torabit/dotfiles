#!/usr/bin/env node
// palette.json を読み、リポジトリ内の *.in を走査して兄弟パスへ書き出す。
// --check では書かずにディスクの内容と比較する。
import { readFile, writeFile, readdir } from "node:fs/promises"
import { join, dirname, relative } from "node:path"
import { fileURLToPath } from "node:url"
import { flatten, resolve } from "./palette.mjs"
import { render } from "./template.mjs"

const SKIP = new Set([".git", "node_modules", ".direnv"])
const root = dirname(dirname(fileURLToPath(import.meta.url)))
const checkOnly = process.argv.includes("--check")

async function findTemplates(dir) {
	const found = []
	for (const entry of await readdir(dir, { withFileTypes: true })) {
		if (SKIP.has(entry.name)) continue
		const path = join(dir, entry.name)
		if (entry.isDirectory()) found.push(...(await findTemplates(path)))
		else if (entry.name.endsWith(".in")) found.push(path)
	}
	return found
}

const source = JSON.parse(await readFile(join(root, "palette.json"), "utf8"))
const palette = resolve(flatten(source))

const templates = (await findTemplates(root)).sort()
if (templates.length === 0) {
	console.error("テンプレートが 1 つも見つからない")
	process.exit(1)
}

let failed = false
for (const template of templates) {
	const dest = template.slice(0, -".in".length)
	const { out, missing } = render(await readFile(template, "utf8"), palette)
	if (missing.length > 0) {
		console.error(`${relative(root, template)}: 未定義トークン ${missing.join(", ")}`)
		failed = true
		continue
	}
	if (checkOnly) {
		const current = await readFile(dest, "utf8").catch(() => null)
		if (current !== out) {
			console.error(`${relative(root, dest)}: 生成物がテンプレートと一致しない`)
			failed = true
		}
	} else {
		await writeFile(dest, out)
		console.log(`書き出し ${relative(root, dest)}`)
	}
}

if (failed && checkOnly) console.error("\n`just build` を実行して差分を解消する")
process.exit(failed ? 1 : 0)
