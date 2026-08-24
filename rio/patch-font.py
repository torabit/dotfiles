#!/usr/bin/env python3
"""HackGen に U+2733 (✳) のグリフを移植する。

Rio のタブタイトルは文字列の先頭 1 文字だけでフォントを決め、その 1 フォントで
文字列全体をシェーピングする。Claude Code のタイトルは "✳ ..." で始まるため、
HackGen が U+2733 を持たないと絵文字フォントが選ばれ、日本語が全て豆腐になる。
HackGen 自身に U+2733 を持たせることで、1 フォントで全体を描けるようにする。

ドナーは Windows 同梱の Segoe UI Symbol。生成物はローカル利用のみを想定する。
"""

import sys
from pathlib import Path

from fontTools.misc.transform import Transform
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont

TARGET_CP = 0x2733
GLYPH_NAME = "uni2733"
# 縦位置と字幅を合わせる基準。HackGen が持つ最も近い記号。
REFERENCE_CP = 0x273D


def transplant(target_path: Path, donor_path: Path, out_path: Path) -> None:
    target = TTFont(target_path, fontNumber=0)
    donor = TTFont(donor_path, fontNumber=0)

    if TARGET_CP in target.getBestCmap():
        raise SystemExit(f"error: {target_path.name} は既に U+{TARGET_CP:04X} を持つ")

    donor_name = donor.getBestCmap().get(TARGET_CP)
    if donor_name is None:
        raise SystemExit(f"error: ドナーに U+{TARGET_CP:04X} が無い: {donor_path}")

    ref_name = target.getBestCmap().get(REFERENCE_CP)
    if ref_name is None:
        raise SystemExit(f"error: 基準グリフ U+{REFERENCE_CP:04X} が無い")

    scale = target["head"].unitsPerEm / donor["head"].unitsPerEm
    donor_glyph = donor["glyf"][donor_name]
    ref_glyph = target["glyf"][ref_name]
    ref_adv = target["hmtx"][ref_name][0]

    # スケール後の bbox 中心を基準グリフの中心に合わせる。
    # 水平は字幅の中心に置く。ドナーの ✳ は正方形なので歪めずに等倍縮小する。
    sx0, sy0 = donor_glyph.xMin * scale, donor_glyph.yMin * scale
    sx1, sy1 = donor_glyph.xMax * scale, donor_glyph.yMax * scale
    dx = ref_adv / 2 - (sx0 + sx1) / 2
    dy = (ref_glyph.yMin + ref_glyph.yMax) / 2 - (sy0 + sy1) / 2

    pen = TTGlyphPen(donor.getGlyphSet())
    donor_glyph.draw(TransformPen(pen, Transform(scale, 0, 0, scale, dx, dy)), donor["glyf"])
    new_glyph = pen.glyph()
    new_glyph.recalcBounds(target["glyf"])

    target.setGlyphOrder(target.getGlyphOrder() + [GLYPH_NAME])
    target["glyf"].glyphs[GLYPH_NAME] = new_glyph
    target["glyf"].glyphOrder = target.getGlyphOrder()
    target["hmtx"].metrics[GLYPH_NAME] = (ref_adv, new_glyph.xMin)

    # Unicode を引く全サブテーブルに登録する。1 つ漏らすと環境次第で解決に失敗する。
    mapped = 0
    for sub in target["cmap"].tables:
        if sub.isUnicode():
            sub.cmap[TARGET_CP] = GLYPH_NAME
            mapped += 1
    if mapped == 0:
        raise SystemExit("error: Unicode cmap サブテーブルが無い")

    target.save(out_path)
    print(
        f"{out_path.name}: U+{TARGET_CP:04X} -> {GLYPH_NAME} "
        f"bbox=({new_glyph.xMin},{new_glyph.yMin},{new_glyph.xMax},{new_glyph.yMax}) "
        f"adv={ref_adv} cmap_subtables={mapped} "
        f"[ref {ref_name} bbox=({ref_glyph.xMin},{ref_glyph.yMin},{ref_glyph.xMax},{ref_glyph.yMax}) adv={ref_adv}]"
    )


if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise SystemExit("usage: patch_font.py <target.ttf> <donor.ttf> <out.ttf>")
    transplant(Path(sys.argv[1]), Path(sys.argv[2]), Path(sys.argv[3]))
