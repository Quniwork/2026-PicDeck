#!/usr/bin/env python3
"""產生 PicDeck 的 App 圖示（1024x1024，不含透明與圓角，圓角由系統套用）。

風格跟系統的「健康」「News」一樣：純白底，中間一個系統藍漸層的單一圖形。
圖形直接用系統的 SF Symbol `tray.full.fill`（收件匣），跟 App 底部「整理」分頁的圖標一致。

用法：python3 tools/make_app_icon.py
需要 macOS（用 swift 把 SF Symbol 畫成形狀）。
輸出：PicDeck/Assets.xcassets/AppIcon.appiconset/AppIcon.png
"""
import subprocess
import tempfile
from pathlib import Path
from PIL import Image, ImageChops, ImageFilter

ROOT = Path(__file__).resolve().parent
OUT = ROOT.parent / "PicDeck/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
SYMBOL = "tray.full.fill"
S = 2048
GLYPH_WIDTH = 0.60  # 圖形寬度佔整張圖的比例


def gradient(size, c1, c2):
    small = Image.new("RGB", (256, 256))
    px = small.load()
    for y in range(256):
        for x in range(256):
            t = (x + y) / 510
            px[x, y] = tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))
    return small.resize(size, Image.BICUBIC)


def symbol_mask():
    with tempfile.TemporaryDirectory() as tmp:
        png = Path(tmp) / "symbol.png"
        subprocess.run(["swift", str(ROOT / "render_symbol.swift"), SYMBOL, str(png), "1400"],
                       check=True, capture_output=True)
        raw = Image.open(png).convert("RGBA")
    alpha = raw.split()[3].crop(raw.split()[3].getbbox())
    width = int(S * GLYPH_WIDTH)
    height = int(alpha.height * width / alpha.width)
    alpha = alpha.resize((width, height), Image.LANCZOS)
    mask = Image.new("L", (S, S), 0)
    mask.paste(alpha, ((S - width) // 2, (S - height) // 2))
    return mask


def main():
    glyph = symbol_mask()
    fill = gradient((S, S), (64, 156, 255), (0, 110, 255)).convert("RGBA")
    fill.putalpha(glyph)

    canvas = Image.new("RGBA", (S, S), (255, 255, 255, 255))
    sh = glyph.filter(ImageFilter.GaussianBlur(S * 0.02)).point(lambda v: int(v * 0.20))
    shadow = Image.new("RGBA", (S, S), (0, 80, 200, 0))
    shadow.putalpha(ImageChops.offset(sh, 0, int(S * 0.014)))
    canvas.alpha_composite(shadow)
    canvas.alpha_composite(fill)

    icon = canvas.convert("RGB").resize((1024, 1024), Image.LANCZOS)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    icon.save(OUT)
    print("已輸出", OUT)


if __name__ == "__main__":
    main()
