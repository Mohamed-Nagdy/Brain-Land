# Brain Land SVG art library

Flat-vector artwork for Brain Land, written to render with `flutter_svg`.

## Style spec

- **Outline:** one solid outline colour, `#3B2A4A`, used on every character, object, icon and token. It has round joins and round caps. Distant scenery and the map backdrop have no outline, which gives the scenes depth.
- **Shading:** each shape gets a flat base fill, one darker shade layer and one light highlight layer. The shade is an inner crescent at the bottom right, made by clipping an offset copy of the shape. The highlight is a small light blob or stroke at the top left. No blur and no filters.
- **Outline widths by canvas size:**

| Canvas | Outline |
|---|---|
| mascot 512 | 6 |
| scenes 800x600 | 4.5 (3.5 on mid-distance objects) |
| ui 96 | 4.5 (chunky, so icons read at 28-48 px) |
| math / tokens 128 | 5.5 |
| memory 160x200 | 4 (card frame 5) |
| rewards 256 | 7 |

- **Palette:**
  - App: purple `#6B4CE6`, `#9B6CE8`, indigo `#667EEA`, plum `#764BA2`, cream `#FFF6E6`.
  - Worlds: Math Forest `#3FAE5A`, Logic Mountain `#3B8BEB`, Memory River `#1BAFC2`, Shape Valley `#FF8A4C`.
  - Stars and gold: `#FFC83D`, shade `#F29A2E`.
  - Mascot:
    - brain `#F59BB4`, folds `#E7799A`, highlight `#FFC7D6`
    - helmet `#D9B47A`, band `#A8804A`
    - backpack `#8A5A36`, bedroll `#7C9A4E`
    - eyes `#3B2418`, limbs `#6B3F2A`
- **Allowed SVG only:** `svg` with `viewBox`, `g`, `path`, `circle`, `ellipse`, `rect`, `linearGradient`, `clipPath`, transforms, `opacity`, `fill-opacity`, `stroke-opacity`, `fill-rule`, `stroke-linecap`, `stroke-linejoin` and `stroke-dasharray`.
  - None of these: `filter`, `text`, `image`, `style` or CSS classes, `mask`, `use`, `foreignObject`.
  - Every file is under 40 KB.

## Runtime notes

- **tokens/**: the main fill is exactly `fill="#C0FFEE"`. Swap that string for a colour at runtime. Shading is drawn on top with `#000000` and `#FFFFFF` at partial `fill-opacity`, so it works with any colour.
- **slots/**: same geometry as the matching token. Each is a recessed sand hollow (`#E9D8B8`) with an inner rim (`#C9AE82`) and a dashed outline.
- **mascot/**: transparent background, feet at about y=480, with a soft ground shadow ellipse.

## Files (78 SVGs)

| Folder | viewBox | Files |
|---|---|---|
| mascot/ | 0 0 512 512 | mascot_idle, mascot_happy, mascot_think, mascot_oops, mascot_cheer, mascot_sleep, mascot_point, mascot_wave |
| worlds/ | 0 0 800 600 | world_math, world_logic, world_memory, world_shape |
| worlds/ | 0 0 900 1600 | map_bg |
| ui/ | 0 0 96 96 | play, back, next, home, pause, parents, sound_on, sound_off, voice_on, voice_off, hint, retry, star_full, star_empty, lock, check, close, motion, language, trophy, speaker, digits, trash, info, break |
| math/ | 0 0 128 128 | acorn, mushroom, berry, leaf |
| tokens/ | 0 0 128 128 | circle, square, triangle, star, heart, diamond, hexagon, rectangle |
| slots/ | 0 0 128 128 | circle, square, triangle, star, heart, diamond, hexagon, rectangle |
| memory/ | 0 0 160 200 | card_back, owl, fish, turtle, fox, bee, snail, frog, rabbit, crab, butterfly, hedgehog, whale |
| rewards/ | 0 0 256 256 | trophy_math, trophy_logic, trophy_memory, trophy_shape, star_burst, sticker_locked |
| brand/ | 0 0 512 512 | brainland_logo_mark |

## Provenance

All SVG artwork in this folder is original work authored for Brain Land by ATHRYZA Technologies in 2026-09; no third-party art, fonts, or icon sets were used.

Removed in 1.1.0 because the game never shows them: `ui/trophy.svg`, `ui/break.svg`, `mascot/mascot_think.svg`.
