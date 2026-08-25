// テンプレートの {{token}} を置換する。出力形式の知識を持たない。
const TOKEN = /\{\{([\w.-]+)\}\}/g

export function render(text, palette) {
	const missing = new Set()
	const out = text.replace(TOKEN, (whole, path) => {
		if (!palette.has(path)) {
			missing.add(path)
			return whole
		}
		return palette.get(path)
	})
	return { out, missing: [...missing] }
}
