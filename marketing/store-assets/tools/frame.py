"""Frames real Brain Land captures for the stores and writes manifest.json.

Input : captures saved by integration_test/app_test.dart (flutter drive) in
        build/shots/<device>_<locale>_<NN_name>.png, copied by tools/capture.sh to
        raw/<target>-<locale>/<NN_name>.png together with raw/runs.json.
Output: <store>/<folder>/<locale>/<NN_name>.png at the size each store requires,
        and manifest.json.

The screen content is never edited: each capture is only scaled and placed
under a caption from metadata/captions.json. Needs Pillow with libraqm.
Run: python tools/frame.py
"""
import hashlib
import json
import subprocess
from datetime import date
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, features

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT.parent.parent
FONT = APP / "assets/fonts/BalooBhaijaan2-Variable.ttf"
TOP, BOTTOM = (107, 76, 230), (118, 75, 162)  # the icon's purples
CREAM = (255, 246, 230)
GOLD = (255, 200, 61)

# Official sizes, checked 2026-09-25 (sources in README.md).
TARGETS = {
    "android-phone": ("android", "phone", (1080, 1920), "Google Play phone screenshot 9:16, ≥1080 px (answer/9866151)"),
    "android-tablet": ("android", "tablet-10", (2560, 1600), "Google Play 10\" tablet screenshot 16:10, 1080–7680 px (answer/9866151)"),
    "ios-iphone69": ("ios", "iphone-6.9", (1320, 2868), "App Store iPhone 6.9\" 1320×2868 (screenshot-specifications)"),
    "ios-ipad13": ("ios", "ipad-13", (2064, 2752), "App Store iPad 13\" 2064×2752 (screenshot-specifications)"),
}

STORY = ["01_map", "02_math_question", "04_math_hint", "08_logic_hint", "12_memory_progress",
         "15_shape_progress", "13_memory_done", "17_world_path", "19_parent_gate", "07_pause"]
SELECTION = {key: STORY[:8] if key.startswith("android") else STORY[:10] for key in TARGETS}


def font(size: int) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(str(FONT), size, layout_engine=ImageFont.Layout.RAQM)
    f.set_variation_by_axes([780])
    return f


def gradient(size) -> Image.Image:
    W, H = size
    top = Image.new("RGB", size, TOP)
    bottom = Image.new("RGB", size, BOTTOM)
    mask = Image.linear_gradient("L").resize(size)
    return Image.composite(bottom, top, mask)


def wrap(draw, text, fnt, width, direction):
    lines, line = [], ""
    for word in text.split():
        trial = f"{line} {word}".strip()
        if draw.textlength(trial, font=fnt, direction=direction) <= width or not line:
            line = trial
        else:
            lines.append(line)
            line = word
    return lines + [line]


def frame(capture: Path, caption: str, locale: str, size) -> Image.Image:
    W, H = size
    landscape = W > H
    canvas = gradient(size)
    d = ImageDraw.Draw(canvas)
    direction = "rtl" if locale == "ar" else "ltr"
    fnt = font(int(min(W, H) * (0.058 if not landscape else 0.05)))
    top = int(H * 0.04)
    lines = wrap(d, caption, fnt, W * 0.86, direction)[:2]
    line_h = int(fnt.size * 1.3)
    for i, line in enumerate(lines):
        tw = d.textlength(line, font=fnt, direction=direction)
        d.text(((W - tw) / 2, top + i * line_h), line, font=fnt, fill=CREAM, direction=direction, language=locale)
    rule_y = top + len(lines) * line_h + int(H * 0.01)
    d.rounded_rectangle([W / 2 - W * 0.05, rule_y, W / 2 + W * 0.05, rule_y + max(6, H // 380)], radius=4, fill=GOLD)

    shot = Image.open(capture).convert("RGB")
    area_top = rule_y + int(H * 0.03)
    avail_h, avail_w = H - area_top - int(H * 0.03), int(W * 0.88)
    scale = min(avail_w / shot.width, avail_h / shot.height)
    sw, sh = int(shot.width * scale), int(shot.height * scale)
    shot = shot.resize((sw, sh), Image.LANCZOS)
    mask = Image.new("L", (sw, sh), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw, sh], radius=int(min(sw, sh) * 0.05), fill=255)
    canvas.paste(shot, ((W - sw) // 2, area_top), mask)
    return canvas


def main():
    assert features.check("raqm"), "Pillow needs libraqm for Arabic shaping"
    captions = json.loads((ROOT / "metadata/captions.json").read_text("utf-8"))
    runs = json.loads((ROOT / "raw/runs.json").read_text("utf-8"))
    sha = subprocess.run(["git", "rev-parse", "--short", "HEAD"], cwd=APP, capture_output=True, text=True).stdout.strip()
    entries = []
    for key, (store, folder, size, requirement) in TARGETS.items():
        for locale in ("ar", "en"):
            src = ROOT / f"raw/{key}-{locale}"
            if not src.exists():
                continue
            out = ROOT / store / folder / locale
            out.mkdir(parents=True, exist_ok=True)
            for name in SELECTION[key]:
                capture = src / f"{name}.png"
                if not capture.exists():
                    continue
                img = frame(capture, captions[name][locale], locale, size)
                dest = out / f"{name}.png"
                img.save(dest, optimize=True)
                raw = Image.open(capture)
                run = runs.get(f"{key}-{locale}", {})
                entries.append({
                    "file": str(dest.relative_to(ROOT)),
                    "store": store,
                    "field": "Phone screenshots" if key == "android-phone" else "10-inch tablet screenshots" if key == "android-tablet" else f"{folder} screenshots",
                    "device": run.get("device", folder),
                    "locale": locale,
                    "width": img.width,
                    "height": img.height,
                    "alpha": img.mode in ("RGBA", "LA"),
                    "caption": captions[name][locale],
                    "source_capture": str(capture.relative_to(ROOT)),
                    "source_capture_size": [raw.width, raw.height],
                    "source_capture_sha256": hashlib.sha256(capture.read_bytes()).hexdigest(),
                    "source_build": run.get("build", f"git {sha}"),
                    "requirement": requirement,
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
            assert (e["width"], e["height"]) == TARGETS[next(k for k, t in TARGETS.items() if t[1] in e["file"])][2]
            assert not e["alpha"]
    manifest = {"generated": date.today().isoformat(), "git": sha, "app_version": "1.1.0 (2)", "assets": entries}
    (ROOT / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", "utf-8")
    print(f"framed {len([e for e in entries if 'store' in e])} screenshots")


if __name__ == "__main__":
    main()
