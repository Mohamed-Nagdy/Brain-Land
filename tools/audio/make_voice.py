"""Renders the voice guide: one clip per mascot line (lib/core/lines.dart),
text taken from lib/l10n/app_<lang>.arb, written to assets/audio/voice/<lang>/<line>.m4a.

Arabic: Resemble AI Chatterbox Multilingual (MIT), default voice.
English: hexgrad Kokoro-82M (Apache-2.0), voice af_heart.
Each engine lives in its own Python environment; see assets/audio/voice/README.md.

  python tools/audio/make_voice.py ar [line ...]   # in the Chatterbox environment
  python tools/audio/make_voice.py en [line ...]   # in the Kokoro environment
Set VOICE_OUT=<dir> to write takes somewhere else (for picking the best of several).
"""
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
lang = sys.argv[1]
lines = re.findall(r"^  (\w+)[,;]", (ROOT / "lib/core/lines.dart").read_text(), re.M)
only = set(sys.argv[2:])
text = json.loads((ROOT / f"lib/l10n/app_{lang}.arb").read_text("utf-8"))
out_dir = Path(os.environ.get("VOICE_OUT", ROOT / f"assets/audio/voice/{lang}"))
out_dir.mkdir(parents=True, exist_ok=True)

if lang == "ar":
    import torch
    import torchaudio
    from chatterbox.mtl_tts import ChatterboxMultilingualTTS

    device = "mps" if torch.backends.mps.is_available() else "cpu"
    model = ChatterboxMultilingualTTS.from_pretrained(device=device)

    def render(sentence: str, wav: str) -> None:
        audio = model.generate(sentence, language_id="ar", cfg_weight=0.5)
        torchaudio.save(wav, audio.cpu(), model.sr)
else:
    import espeakng_loader
    import numpy as np
    import soundfile as sf
    from phonemizer.backend.espeak.wrapper import EspeakWrapper

    EspeakWrapper.set_library(espeakng_loader.get_library_path())
    EspeakWrapper.set_data_path(os.environ.get("ESPEAK_DATA_PATH", espeakng_loader.get_data_path()))
    from kokoro import KPipeline

    pipeline = KPipeline(lang_code="a")

    def render(sentence: str, wav: str) -> None:
        sf.write(wav, np.concatenate([a for _, _, a in pipeline(sentence, voice="af_heart")]), 24000)

# Trim leading/trailing silence, even out loudness, AAC mono.
FILTER = ("silenceremove=start_periods=1:start_threshold=-45dB,areverse,"
          "silenceremove=start_periods=1:start_threshold=-45dB,areverse,"
          "loudnorm=I=-18:TP=-2,apad=pad_dur=0.15")

for line in lines:
    if only and line not in only:
        continue
    with tempfile.TemporaryDirectory() as tmp:
        wav = f"{tmp}/{line}.wav"
        render(text[line], wav)
        dest = out_dir / f"{line}.m4a"
        subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", wav, "-af", FILTER,
                        "-ac", "1", "-ar", "24000", "-c:a", "aac", "-b:a", "64k", str(dest)], check=True)
    print("wrote", dest, flush=True)
