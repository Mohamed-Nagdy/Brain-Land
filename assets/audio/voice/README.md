# Voice guide

One clip per mascot line (`lib/core/lines.dart`); the text is the ARB string of the same name. The game plays a clip only if it exists, so any line without a clip simply shows as text (and has no replay button).

Coverage in 1.1.0: **English 32/32 lines. Arabic 18/32**: Arabic clips had to score ≥ 0.9 on a Whisper-medium round trip (a mispronounced instruction is worse for a young child than reading it); after three takes, 14 lines did not, so they are text-only until a native speaker records them. See `check-ar.json`.

| Language | Engine | Licence | Source |
|---|---|---|---|
| Arabic (`ar/`) | Chatterbox Multilingual by Resemble AI, built-in default voice, `cfg_weight=0.5` | MIT | https://huggingface.co/ResembleAI/chatterbox · https://github.com/resemble-ai/chatterbox |
| English (`en/`) | Kokoro-82M by hexgrad, voice `af_heart` | Apache-2.0 (weights trained on permissive / non-copyrighted audio per the model card) | https://huggingface.co/hexgrad/Kokoro-82M · https://github.com/hexgrad/kokoro |

Licences checked 2026-09-25. Rejected: Piper `ar_JO-kareem` (dataset has no licence; fine-tuned from research-only Lessac data), `facebook/mms-tts-ara` and `MBZUAI/speecht5_tts_clartts_ar` (CC BY-NC), Coqui XTTS (non-commercial), macOS system voices (Apple licence).

Chatterbox embeds an inaudible Perth watermark in its output; that does not restrict use. Its model card does not list its training datasets.

## Regenerate

```sh
python tools/audio/make_voice.py en            # in a Kokoro environment (pip install kokoro soundfile espeakng-loader)
python tools/audio/make_voice.py ar            # in a Chatterbox environment (pip install chatterbox-tts "setuptools<81")
python tools/audio/check_voice.py ar --remove  # Whisper round-trip; removes clips that don't match their text
```

`check-<lang>.json` records what Whisper (faster-whisper small) heard for each clip and the match score. A person who speaks the language should still listen to every clip before release.
