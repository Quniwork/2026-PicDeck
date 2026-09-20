#!/usr/bin/env python3
"""產生一批帶有不同拍攝日期的測試照片，再用 simctl 加進模擬器。

用法：
    python3 tools/make_test_photos.py <模擬器 ID 或 booted> [張數]

例：
    python3 tools/make_test_photos.py 609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D 600

照片是程式畫的漸層與色塊，每張的 EXIF 拍攝時間不同，分佈在 2009 到現在，
而且有些天很多張、有些天只有一張，才能測到年、月、日、時間軸與拖拉軸。
同一個張數與亂數種子產生的內容固定，重跑會得到一樣的照片（時間也一樣）。
"""
import colorsys
import datetime as dt
import random
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

SEED = 20260920
SIZES = [(1200, 900), (900, 1200), (1000, 1000), (1280, 720)]
START_YEAR = 2009


def random_dates(count: int, rng: random.Random) -> list[dt.datetime]:
    """張數集中在少數幾天，接近真實使用：常有連拍或同一天拍很多。"""
    today = dt.datetime.now().replace(hour=12, minute=0, second=0, microsecond=0)
    first = dt.datetime(START_YEAR, 1, 1, 12)
    span_days = (today - first).days

    days: list[dt.datetime] = []
    while len(days) < count:
        day = first + dt.timedelta(days=rng.randrange(span_days))
        # 每個「日子」拍 1 到 14 張，多數只有幾張
        burst = min(count - len(days), rng.choice([1, 1, 1, 2, 2, 3, 4, 6, 9, 14]))
        for _ in range(burst):
            stamp = day.replace(hour=rng.randrange(7, 22), minute=rng.randrange(60), second=rng.randrange(60))
            days.append(stamp)
    return sorted(days)


def draw_photo(index: int, when: dt.datetime, rng: random.Random) -> Image.Image:
    width, height = rng.choice(SIZES)
    hue = rng.random()
    top = tuple(int(c * 255) for c in colorsys.hsv_to_rgb(hue, 0.55, 0.95))
    bottom = tuple(int(c * 255) for c in colorsys.hsv_to_rgb((hue + 0.35) % 1, 0.7, 0.55))

    image = Image.new("RGB", (width, height))
    pixels = ImageDraw.Draw(image)
    for y in range(height):
        t = y / height
        pixels.line([(0, y), (width, y)],
                    fill=tuple(int(top[i] * (1 - t) + bottom[i] * t) for i in range(3)))

    # 幾個色塊，讓縮圖看得出差別
    for _ in range(rng.randrange(3, 7)):
        w, h = rng.randrange(width // 8, width // 3), rng.randrange(height // 8, height // 3)
        x, y = rng.randrange(0, width - w), rng.randrange(0, height - h)
        color = tuple(int(c * 255) for c in colorsys.hsv_to_rgb(rng.random(), 0.6, 0.9))
        pixels.rounded_rectangle([x, y, x + w, y + h], radius=w // 8, fill=color)

    # 把日期印在上面，看畫面就知道是哪一天
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", max(width // 14, 28))
    except OSError:
        font = ImageFont.load_default()
    label = when.strftime("%Y-%m-%d  #") + str(index)
    pixels.text((width // 20, height // 20), label, fill=(255, 255, 255), font=font,
                stroke_width=2, stroke_fill=(0, 0, 0))
    return image


def save_with_exif(image: Image.Image, when: dt.datetime, path: Path) -> None:
    exif = Image.Exif()
    stamp = when.strftime("%Y:%m:%d %H:%M:%S")
    exif[0x0132] = stamp                      # DateTime
    exif.get_ifd(0x8769)[0x9003] = stamp      # DateTimeOriginal
    exif.get_ifd(0x8769)[0x9004] = stamp      # DateTimeDigitized
    image.save(path, "JPEG", quality=85, exif=exif)


def main() -> None:
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    device = sys.argv[1]
    count = int(sys.argv[2]) if len(sys.argv) > 2 else 400

    rng = random.Random(SEED)
    dates = random_dates(count, rng)

    with tempfile.TemporaryDirectory() as tmp:
        folder = Path(tmp)
        files = []
        for index, when in enumerate(dates, start=1):
            path = folder / f"testphoto_{when:%Y%m%d}_{index:04d}.jpg"
            save_with_exif(draw_photo(index, when, rng), when, path)
            files.append(str(path))

        years = sorted({d.year for d in dates})
        print(f"產生 {len(files)} 張，涵蓋 {years[0]} 到 {years[-1]}，共 {len(years)} 年、"
              f"{len({d.date() for d in dates})} 個不同的日子")

        # 分批加，一次太多參數會超過長度上限
        for start in range(0, len(files), 100):
            batch = files[start:start + 100]
            subprocess.run(["xcrun", "simctl", "addmedia", device, *batch], check=True)
            print(f"  已加入 {min(start + 100, len(files))} / {len(files)}")


if __name__ == "__main__":
    main()
