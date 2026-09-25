"""Fails if any store listing field in metadata/listing.json is over its limit,
or if copy uses words the claims guardrails forbid. Run: python tools/check_listing.py"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
listing = json.loads((ROOT / "metadata/listing.json").read_text("utf-8"))
LIMITS = {"title": 30, "short_description": 80, "full_description": 4000, "release_notes": 500,
          "name": 30, "subtitle": 30, "promotional_text": 170, "description": 4000}
FORBIDDEN = re.compile(r"\b(IQ|smarter|brain development|best|#1|teacher[- ]approved|guarantee\w*|learn faster)\b"
                       r"|ATHRIVA|أفضل|الأفضل|ذكاء|تنمية الدماغ|مضمون", re.I)
problems = []
for store in ("android", "ios"):
    for locale, fields in listing[store].items():
        for key, value in fields.items():
            if key in LIMITS and len(value) > LIMITS[key]:
                problems.append(f"{store}/{locale}/{key}: {len(value)} > {LIMITS[key]}")
            if key == "keywords" and len(value.encode()) > 100:
                problems.append(f"{store}/{locale}/keywords: {len(value.encode())} bytes > 100")
            if isinstance(value, str) and (m := FORBIDDEN.search(value)):
                problems.append(f"{store}/{locale}/{key}: forbidden '{m.group(0)}'")
        if store == "android" and "ads" not in fields["full_description"] and "إعلانات" not in fields["full_description"]:
            problems.append(f"android/{locale}: full description must say the app shows ads")
print("\n".join(problems) or "listing OK")
sys.exit(1 if problems else 0)
