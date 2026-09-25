"""Brand graphics for the stores, composed from the game's own SVG artwork.

Writes source/:
  icon-1024.png                 App Store icon (opaque, from assets/icon/icon.png)
  icon-512.png                  Google Play icon (32-bit PNG)
  feature-graphic-{ar,en}.png   Google Play feature graphic, 1024×500, no alpha
  cover-1200x630.png            text-free share image (athryza.com project cover)

SVGs are rasterized with resvg (brew install resvg). Needs Pillow with libraqm.
Run: python tools/make_graphics.py
"""
import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, features

from brand import pill

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT.parent.parent
SVG = APP / "assets/svg"
FONT = APP / "assets/fonts/BalooBhaijaan2-Variable.ttf"
OUT = ROOT / "source"
INK = (46, 34, 64)
PURPLE = (107, 76, 230)

TEXT = {
    "en": ("Brain Land", "Four worlds of puzzle missions"),
    "ar": ("Brain Land", "أربعة عوالم من مهام الألغاز"),
}


def raster(svg: Path, width: int) -> Image.Image:
    with tempfile.TemporaryDirectory() as tmp:
        png = Path(tmp) / "out.png"
        subprocess.run(["resvg", "-w", str(width), str(svg), str(png)], check=True, capture_output=True)
        im = Image.open(png).convert("RGBA")
        return im.crop(im.getbbox())


def font(size: int, weight: int) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(str(FONT), size, layout_engine=ImageFont.Layout.RAQM)
    f.set_variation_by_axes([weight])
    return f


def rounded(im: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, *im.size], radius=radius, fill=255)
    im = im.copy()
    im.putalpha(mask)
    return im


def shadowed(canvas: Image.Image, im: Image.Image, xy, blur=10, offset=(0, 8)):
    shadow = Image.new("RGBA", im.size, (46, 34, 64, 90))
    shadow.putalpha(im.getchannel("A").point(lambda a: int(a * 0.35) if a > 60 else 0))
    canvas.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(blur)), (xy[0] + offset[0], xy[1] + offset[1]))
    canvas.alpha_composite(im, xy)


def feature_graphic(locale: str) -> Image.Image:
    W, H = 1024, 500
    rtl = locale == "ar"
    bg = raster(SVG / "worlds/map_bg.svg", W)
    canvas = bg.crop((0, 560, W, 560 + H)).convert("RGBA")

    # Title on the reading-start side, then the mascot, then the four worlds.
    tile_w, tile_h, gap = 176, 132, 14
    grid_x = W - 36 - 2 * tile_w - gap if not rtl else 36
    for i, world in enumerate(["math", "logic", "memory", "shape"]):
        tile = rounded(raster(SVG / f"worlds/world_{world}.svg", tile_w * 2).resize((tile_w, tile_h), Image.LANCZOS), 20)
        col = i % 2 if not rtl else 1 - i % 2
        shadowed(canvas, tile, (grid_x + col * (tile_w + gap), 110 + (i // 2) * (tile_h + gap)))

    mascot = raster(SVG / "mascot/mascot_cheer.svg", 800)
    mascot = mascot.resize((int(mascot.width * 285 / mascot.height), 285), Image.LANCZOS)
    if rtl:
        mascot = mascot.transpose(Image.FLIP_LEFT_RIGHT)
    mx = 356 if not rtl else W - 356 - mascot.width
    shadowed(canvas, mascot, (mx, H - mascot.height - 40), blur=14)

    d = ImageDraw.Draw(canvas)
    title, tagline = TEXT[locale]
    direction = "rtl" if rtl else "ltr"
    block_w = 380 if rtl else 330
    def put(text, fnt, y, fill, stroke):
        w = d.textlength(text, font=fnt, direction=direction)
        x = 44 if not rtl else W - 44 - w
        d.text((x, y), text, font=fnt, fill=fill, direction=direction, language=locale,
               stroke_width=stroke, stroke_fill="white")
    tf = font(84, 800)
    put(title, tf, 118, INK, 7)
    gf = font(36, 700)
    words, lines, line = tagline.split(), [], ""
    for word in words:
        trial = f"{line} {word}".strip()
        if d.textlength(trial, font=gf, direction=direction) > block_w and line:
            lines.append(line)
            line = word
        else:
            line = trial
    lines.append(line)
    for k, part in enumerate(lines):
        put(part, gf, 236 + k * 46, PURPLE, 5)
    mark = pill(locale, 52)
    y = 236 + len(lines) * 46 + 26
    canvas.alpha_composite(mark, (44 if not rtl else W - 44 - mark.width, y))
    return canvas.convert("RGB")


def cover() -> Image.Image:
    W, H = 1200, 630
    canvas = raster(SVG / "worlds/map_bg.svg", W).crop((0, 620, W, 620 + H)).convert("RGBA")
    tile_w, tile_h = 250, 188
    spots = [(70, 70), (70, 350), (W - 70 - tile_w, 70), (W - 70 - tile_w, 350)]
    for (x, y), world in zip(spots, ["math", "memory", "logic", "shape"]):
        tile = rounded(raster(SVG / f"worlds/world_{world}.svg", tile_w * 2).resize((tile_w, tile_h), Image.LANCZOS), 24)
        shadowed(canvas, tile, (x, y))
    mascot = raster(SVG / "mascot/mascot_cheer.svg", 900)
    mascot = mascot.resize((int(mascot.width * 470 / mascot.height), 470), Image.LANCZOS)
    shadowed(canvas, mascot, ((W - mascot.width) // 2, H - mascot.height - 60), blur=16)
    mark = pill("en", 56)
    canvas.alpha_composite(mark, ((W - mark.width) // 2, H - mark.height - 16))
    return canvas.convert("RGB")


def main():
    assert features.check("raqm"), "Pillow needs libraqm for Arabic shaping"
    OUT.mkdir(exist_ok=True)
    icon = Image.open(APP / "assets/icon/icon.png").convert("RGB")
    icon.resize((1024, 1024), Image.LANCZOS).save(OUT / "icon-1024.png", optimize=True)
    icon.resize((512, 512), Image.LANCZOS).convert("RGBA").save(OUT / "icon-512.png", optimize=True)
    for locale in TEXT:
        feature_graphic(locale).save(OUT / f"feature-graphic-{locale}.png", optimize=True)
    cover().save(OUT / "cover-1200x630.png", optimize=True)
    print("wrote", ", ".join(sorted(p.name for p in OUT.glob("*.png"))))


if __name__ == "__main__":
    main()
