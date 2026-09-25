"""Frames real Brain Land captures for the stores and writes manifest.json.

Input : captures saved by integration_test/app_test.dart (flutter drive) in
        build/shots/<device>_<locale>_<NN_name>.png, copied by tools/capture.sh to
        raw/<target>-<locale>/<NN_name>.png together with raw/runs.json.
Output: <store>/<folder>/<locale>/<NN_name>.png at the size each store requires,
        and manifest.json.

The screen content is never edited: each capture is only scaled and placed in a
device frame on a world-themed background, under a caption from metadata/captions.json. Needs Pillow with libraqm.
Run: python tools/frame.py
"""
import hashlib
import json
import subprocess
from datetime import date
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, features

from brand import pill
from make_graphics import raster

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT.parent.parent
SVG = APP / "assets/svg"
FONT = APP / "assets/fonts/BalooBhaijaan2-Variable.ttf"
WHITE = (255, 255, 255)
GOLD = (255, 210, 74)
BEZEL = (27, 21, 48)
# Background tone per world (dark top → lighter bottom), matching the game's world colours.
TONES = {
    "map": ((74, 52, 180), (124, 92, 236)),
    "math": ((24, 110, 58), (63, 174, 90)),
    "logic": ((30, 84, 170), (59, 139, 235)),
    "memory": ((10, 112, 128), (27, 175, 194)),
    "shape": ((196, 88, 34), (255, 138, 76)),
}

# Every store set is framed from the iPhone 6.9" and iPad 13" simulator captures (owner rule):
# the game's UI is identical on Android, so the Play sets reuse them.
SOURCE = {"android-phone": "ios-iphone69", "android-tablet": "ios-ipad13", "ios-iphone69": "ios-iphone69", "ios-ipad13": "ios-ipad13"}

# Official sizes, checked 2026-09-25 (sources in README.md).
TARGETS = {
    "android-phone": ("android", "phone", (1080, 1920), "Google Play phone screenshot 9:16, ≥1080 px (answer/9866151)"),
    "android-tablet": ("android", "tablet-10", (1600, 2560), "Google Play 10\" tablet screenshot 9:16 portrait, 1080–7680 px (answer/9866151)"),
    "ios-iphone69": ("ios", "iphone-6.9", (1320, 2868), "App Store iPhone 6.9\" 1320×2868 (screenshot-specifications)"),
    "ios-ipad13": ("ios", "ipad-13", (2064, 2752), "App Store iPad 13\" 2064×2752 (screenshot-specifications)"),
}

STORY = ["01_map", "02_math_question", "04_math_hint", "08_logic_hint", "12_memory_progress",
         "15_shape_progress", "13_memory_done", "17_world_path", "19_parent_gate", "07_pause"]
SELECTION = {key: STORY[:8] if key.startswith("android") else STORY[:10] for key in TARGETS}

_cache: dict = {}


def art(path: str, width: int) -> Image.Image:
    key = (path, width)
    if key not in _cache:
        _cache[key] = raster(SVG / path, width)
    return _cache[key]


def font(size: int, weight: int = 800) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(str(FONT), size, layout_engine=ImageFont.Layout.RAQM)
    f.set_variation_by_axes([weight])
    return f


def background(size, world: str) -> Image.Image:
    W, H = size
    top, bottom = TONES[world]
    canvas = Image.composite(Image.new("RGB", size, bottom), Image.new("RGB", size, top),
                             Image.linear_gradient("L").resize(size)).convert("RGBA")
    # The world's own scene, faint, across the lower half.
    scene = art("worlds/map_bg.svg" if world == "map" else f"worlds/world_{world}.svg", W)
    scene = scene.resize((W, int(scene.height * W / scene.width)), Image.LANCZOS)
    scene.putalpha(scene.getchannel("A").point(lambda a: int(a * 0.22)))
    canvas.alpha_composite(scene, (0, H - scene.height))
    # Soft light behind the headline.
    glow = Image.new("L", size, 0)
    ImageDraw.Draw(glow).ellipse([-W * 0.2, -H * 0.12, W * 1.2, H * 0.28], fill=70)
    canvas.alpha_composite(Image.new("RGBA", size, (255, 255, 255, 0)), (0, 0))
    canvas = Image.composite(Image.new("RGBA", size, (255, 255, 255, 255)), canvas, glow.filter(ImageFilter.GaussianBlur(W // 12)).point(lambda v: v // 3))
    return canvas


def tokens(text: str):
    """Words with their colour: **highlighted** words are gold."""
    out, gold = [], False
    for part in text.split("**"):
        out += [(w, GOLD if gold else WHITE) for w in part.split()]
        gold = not gold
    return out


def headline(canvas, text, locale, box):
    """Draws a centred, wrapped, two-tone headline in `box` (x, y, w); returns its bottom."""
    x0, y, width = box
    d = ImageDraw.Draw(canvas)
    rtl = locale == "ar"
    direction = "rtl" if rtl else "ltr"
    size = int(width * 0.105)
    while True:
        f = font(size)
        space = d.textlength(" ", font=f)
        lines, line, w = [], [], 0
        for word, color in tokens(text):
            ww = d.textlength(word, font=f, direction=direction)
            if line and w + space + ww > width:
                lines.append((line, w))
                line, w = [], 0
            w += (space if line else 0) + ww
            line.append((word, color, ww))
        lines.append((line, w))
        if len(lines) <= 2 or size < width * 0.06:
            break
        size = int(size * 0.92)
    lh = int(size * 1.22)
    for words, w in lines:
        x = x0 + (width - w) / 2
        seq = list(reversed(words)) if rtl else words
        for word, color, ww in seq:
            d.text((x + 2, y + 6), word, font=f, fill=(0, 0, 0, 60), direction=direction, language=locale)
            d.text((x, y), word, font=f, fill=color, direction=direction, language=locale)
            x += ww + space
        y += lh
    return y


def device(shot: Image.Image, width: int, tablet: bool) -> Image.Image:
    """The real capture inside a simple device frame with a soft shadow."""
    b = int(width * (0.028 if tablet else 0.034))
    sw = width - 2 * b
    sh = int(shot.height * sw / shot.width)
    screen = shot.resize((sw, sh), Image.LANCZOS).convert("RGBA")
    r_screen = int(sw * (0.045 if tablet else 0.11))
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw - 1, sh - 1], radius=r_screen, fill=255)
    pad = int(width * 0.08)
    out = Image.new("RGBA", (width + 2 * pad, sh + 2 * b + 2 * pad), (0, 0, 0, 0))
    shadow = Image.new("L", out.size, 0)
    ImageDraw.Draw(shadow).rounded_rectangle([pad, pad + b, pad + width, pad + sh + 2 * b + b], radius=r_screen + b, fill=110)
    out.putalpha(shadow.filter(ImageFilter.GaussianBlur(pad // 2)))
    body = Image.new("RGBA", out.size, (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle([pad, pad, pad + width, pad + sh + 2 * b], radius=r_screen + b, fill=BEZEL)
    out = Image.alpha_composite(Image.merge("RGBA", (*Image.new("RGB", out.size, (20, 12, 40)).split(), out.getchannel("A"))), body)
    screen.putalpha(mask)
    out.alpha_composite(screen, (pad + b, pad + b))
    return out, pad


def frame(capture: Path, cap: dict, locale: str, size) -> Image.Image:
    W, H = size
    tablet = W / H > 0.6
    canvas = background(size, cap["world"])
    rtl = locale == "ar"

    mark = pill(locale, int(W * 0.05), dark=True)
    canvas.alpha_composite(mark, ((W - mark.width) // 2, int(H * 0.022)))

    # Headline beside the mascot (mascot on the reading-end side).
    mascot = art(f"mascot/mascot_{cap['mood']}.svg", int(W * 0.5))
    mh = int(H * (0.13 if tablet else 0.12))
    mascot = mascot.resize((int(mascot.width * mh / mascot.height), mh), Image.LANCZOS)
    if rtl:
        mascot = mascot.transpose(Image.FLIP_LEFT_RIGHT)
    top = int(H * 0.022) + mark.height + int(H * 0.018)
    text_w = int(W * 0.9) - mascot.width
    text_x = int(W * 0.05) + (mascot.width if rtl else 0)
    bottom = headline(canvas, cap[locale], locale, (text_x, top, text_w))
    mx = int(W * 0.035) if rtl else W - int(W * 0.035) - mascot.width
    my = top + max(0, (bottom - top - mh) // 2)
    canvas.alpha_composite(mascot, (mx, my))
    bottom = max(bottom, my + mh)

    shot = Image.open(capture).convert("RGB")
    area_top = bottom + int(H * 0.025)
    avail_h = H - area_top - int(H * 0.02)
    dev_w = int(W * (0.84 if tablet else 0.8))
    dev, pad = device(shot, dev_w, tablet)
    visible_h = dev.height - 2 * pad
    if visible_h > avail_h:
        scale = avail_h / visible_h
        dev = dev.resize((int(dev.width * scale), int(dev.height * scale)), Image.LANCZOS)
        pad = int(pad * scale)
    canvas.alpha_composite(dev, ((W - dev.width) // 2, area_top - pad))
    return canvas.convert("RGB")


def main():
    assert features.check("raqm"), "Pillow needs libraqm for Arabic shaping"
    captions = json.loads((ROOT / "metadata/captions.json").read_text("utf-8"))
    runs = json.loads((ROOT / "raw/runs.json").read_text("utf-8"))
    sha = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=APP, capture_output=True, text=True).stdout.strip()
    entries = []
    for key, (store, folder, size, requirement) in TARGETS.items():
        for locale in ("ar", "en"):
            src = ROOT / f"raw/{SOURCE[key]}-{locale}"
            if not src.exists():
                continue
            out = ROOT / store / folder / locale
            out.mkdir(parents=True, exist_ok=True)
            for name in SELECTION[key]:
                capture = src / f"{name}.png"
                if not capture.exists():
                    continue
                img = frame(capture, captions[name], locale, size)
                dest = out / f"{name}.png"
                img.save(dest, optimize=True)
                raw = Image.open(capture)
                run = runs.get(f"{SOURCE[key]}-{locale}", {})
                entries.append({
                    "file": str(dest.relative_to(ROOT)),
                    "store": store,
                    "field": "Phone screenshots" if key == "android-phone" else "10-inch tablet screenshots" if key == "android-tablet" else f"{folder} screenshots",
                    "device": run.get("device", folder),
                    "locale": locale,
                    "width": img.width,
                    "height": img.height,
                    "alpha": img.mode in ("RGBA", "LA"),
                    "caption": captions[name][locale].replace("**", ""),
                    "source_capture": str(capture.relative_to(ROOT)),
                    "source_capture_size": [raw.width, raw.height],
                    "source_capture_sha256": hashlib.sha256(capture.read_bytes()).hexdigest(),
                    "source_build": run.get("build", f"git {sha}"),
                    "requirement": requirement,
                    "target": key,
                    "validation": "size, no alpha and caption checked by tools/frame.py; visually reviewed at full and store-preview size",
                })
    for extra, field in (("icon-1024.png", "App Store icon"), ("icon-512.png", "Google Play app icon"),
                         ("feature-graphic-ar.png", "Google Play feature graphic (ar)"),
                         ("feature-graphic-en.png", "Google Play feature graphic (en-US)")):
        p = ROOT / "source" / extra
        if p.exists():
            im = Image.open(p)
            entries.append({"file": str(p.relative_to(ROOT)), "field": field, "width": im.width,
                            "height": im.height, "alpha": im.mode in ("RGBA", "LA")})
    for e in entries:
        if "store" in e:
            assert (e["width"], e["height"]) == TARGETS[e["target"]][2], e["file"]
            assert not e["alpha"]
    manifest = {"generated": date.today().isoformat(), "git": sha, "app_version": "1.1.0 (2)", "assets": entries}
    (ROOT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"framed {len([e for e in entries if 'store' in e])} screenshots")


if __name__ == "__main__":
    main()
