#!/usr/bin/env bash
# Synthesizes Brain Land's original sound effects (no samples, no third-party audio).
# Usage: tools/audio/make_sfx.sh   → writes assets/audio/sfx/*.wav
set -euo pipefail
cd "$(dirname "$0")/../.."
out=assets/audio/sfx
mkdir -p "$out"

# note FREQ START DUR → a soft sine "pluck" with a fast attack and exponential decay.
note() { echo "if(between(t,$2,$2+$3), sin(2*PI*$1*(t-$2))*exp(-(t-$2)*9)*min(1,(t-$2)*200), 0)"; }

make() { # name duration expression
  ffmpeg -loglevel error -y -f lavfi -i "aevalsrc='$3':s=44100:d=$2" -ac 1 -c:a pcm_s16le "$out/$1.wav"
}

make tap 0.08 "0.35*sin(2*PI*900*t)*exp(-t*60)"
make correct 0.45 "0.4*($(note 1046.5 0 0.4) + $(note 1318.5 0.11 0.34))"
make oops 0.3 "0.3*sin(2*PI*(330-250*t)*t)*exp(-t*9)"
make flip 0.12 "0.22*sin(2*PI*(500+2500*t)*t)*exp(-t*28)"
make place 0.18 "0.45*sin(2*PI*196*t)*exp(-t*30) + 0.15*sin(2*PI*784*t)*exp(-t*50)"
make complete 0.9 "0.35*($(note 523.3 0 0.5) + $(note 659.3 0.12 0.5) + $(note 784 0.24 0.5) + $(note 1046.5 0.36 0.54))"
make star 0.5 "0.25*($(note 1568 0 0.4) + $(note 2093 0.07 0.4) + $(note 2637 0.14 0.36))"
ls -la "$out"
