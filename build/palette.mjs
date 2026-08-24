// パレットの平坦化と参照解決。IO を持たない純関数だけを置く。
const REF = /^\{([\w.-]+)\}$/

export function flatten(obj, prefix = "") {
	const out = new Map()
	for (const [key, value] of Object.entries(obj)) {
		const path = prefix ? `${prefix}.${key}` : key
		if (value !== null && typeof value === "object" && !Array.isArray(value)) {
			for (const [k, v] of flatten(value, path)) out.set(k, v)
		} else {
			out.set(path, String(value))
		}
	}
	return out
}

export function resolve(map) {
	const out = new Map(map)
	for (const key of map.keys()) {
		// key から参照を辿り、hex に着くまで進む。辿った先を key に書き戻す。
		const seen = [key]
		let cursor = key
		for (;;) {
			const match = REF.exec(out.get(cursor))
			if (!match) break
			const target = match[1]
			if (!out.has(target)) throw new Error(`未定義の参照: ${cursor} -> {${target}}`)
			if (seen.includes(target)) throw new Error(`循環参照: ${[...seen, target].join(" -> ")}`)
			seen.push(target)
			cursor = target
		}
		out.set(key, out.get(cursor))
	}
	return out
}
