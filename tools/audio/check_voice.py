"""Transcribes every voice clip with Whisper (faster-whisper, small) and compares
it with the line's text. Clips below the threshold are reported and, with
--remove, deleted so the game shows that line as text only.

  python tools/audio/check_voice.py ar|en [--remove]
Arabic is held to a higher bar (0.9, Whisper medium): a mispronounced
instruction is worse for a young child than reading the text.
"""
import difflib
import json
import re
import sys
from pathlib import Path

from faster_whisper import WhisperModel

ROOT = Path(__file__).resolve().parents[2]
lang, remove = sys.argv[1], "--remove" in sys.argv
text = json.loads((ROOT / f"lib/l10n/app_{lang}.arb").read_text("utf-8"))
THRESHOLD = 0.9 if lang == "ar" else 0.75


def norm(s: str) -> str:
    s = re.sub(r"[ً-ْـ]", "", s.lower())  # tashkeel, tatweel
    s = s.replace("أ", "ا").replace("إ", "ا").replace("آ", "ا").replace("ة", "ه").replace("ى", "ي")
    return re.sub(r"[^\w\s]", "", s).strip()


model = WhisperModel("medium" if lang == "ar" else "small", device="cpu", compute_type="int8")
report, failed = {}, []
for clip in sorted((ROOT / f"assets/audio/voice/{lang}").glob("*.m4a")):
    segments, _ = model.transcribe(str(clip), language=lang, beam_size=5)
    heard = " ".join(s.text for s in segments).strip()
    expected = text[clip.stem]
    score = difflib.SequenceMatcher(None, norm(heard), norm(expected)).ratio()
    report[clip.stem] = {"expected": expected, "heard": heard, "score": round(score, 2)}
    ok = score >= THRESHOLD
    print(f"{'ok  ' if ok else 'FAIL'} {score:.2f} {clip.stem}: {heard}", flush=True)
    if not ok:
        failed.append(clip.stem)
        if remove:
            clip.unlink()
(ROOT / f"assets/audio/voice/check-{lang}.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", "utf-8")
print(f"{len(report) - len(failed)}/{len(report)} clips pass; failed: {failed}")
