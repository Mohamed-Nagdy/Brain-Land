"""ATHRYZA brand mark for store graphics: the company icon plus the wordmark
(English) or «أثريزا» (Arabic), from Company/brand/. Shared by make_graphics.py and frame.py."""
import subprocess
import tempfile
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

TOOLS = Path(__file__).resolve().parent
WORKSPACE = TOOLS.parents[5]
BRAND = WORKSPACE / "Company/brand"
FONT = TOOLS.parents[2] / "assets/fonts/BalooBhaijaan2-Variable.ttf"


def wordmark(height: int, color: str) -> Image.Image:
    svg = (BRAND / "wordmark/athryza-wordmark.svg").read_text().replace("currentColor", color)
    with tempfile.TemporaryDirectory() as tmp:
        src, png = Path(tmp) / "w.svg", Path(tmp) / "w.png"
        src.write_text(svg)
        subprocess.run(["resvg", "-h", str(height * 4), str(src), str(png)], check=True, capture_output=True)
        im = Image.open(png).convert("RGBA")
    im = im.crop(im.getbbox())
    return im.resize((int(im.width * height / im.height), height), Image.LANCZOS)


def pill(locale: str, height: int, dark: bool = False) -> Image.Image:
    """A rounded 'by ATHRYZA' pill; `dark` = light text on a translucent dark pill."""
    fg = "#FFFFFF" if dark else "#1B1530"
    icon = Image.open(BRAND / "icon/athryza-icon-512.png").convert("RGBA").resize((int(height * .74),) * 2, Image.LANCZOS)
    pad, gap = int(height * .32), int(height * .18)
    if locale == "ar":
        f = ImageFont.truetype(str(FONT), int(height * .5), layout_engine=ImageFont.Layout.RAQM)
        f.set_variation_by_axes([750])
        label = "من أثريزا للتكنولوجيا"
        w = int(ImageDraw.Draw(Image.new("L", (1, 1))).textlength(label, font=f, direction="rtl"))
        text = Image.new("RGBA", (w + 4, height), (0, 0, 0, 0))
        ImageDraw.Draw(text).text((2, height * .12), label, font=f, fill=fg, direction="rtl", language="ar")
    else:
        text = wordmark(int(height * .34), fg)
    W = pad + icon.width + gap + text.width + pad
    im = Image.new("RGBA", (W, height), (0, 0, 0, 0))
    ImageDraw.Draw(im).rounded_rectangle([0, 0, W - 1, height - 1], radius=height // 2,
                                         fill=(27, 21, 48, 150) if dark else (255, 255, 255, 235))
    order = [text, icon] if locale == "ar" else [icon, text]
    x = pad
    for part in order:
        im.alpha_composite(part, (x, (height - part.height) // 2))
        x += part.width + gap
    return im
