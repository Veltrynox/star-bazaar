#!/usr/bin/env python3
"""Generates assets/audio/ambient_space.ogg: a quiet, slowly evolving, seamlessly looping space ambience
(drone pads, filter-swept resonant pads, FM shimmer, a low pulsing reactor drone, slow filtered-noise wind,
faint tonal swells, very sparse seeded telemetry chirps). No melody, no beat, no third-party samples.

THIS OUTPUT IS GENERATED. Do not edit the .ogg by hand. Rebuild it with:
    python3 tools/make_ambient.py
(standard library plus /opt/homebrew/bin/ffmpeg with its native vorbis encoder; scratch WAV goes to logs/ambient/.)

Seamless loop: every tone and LFO completes a whole number of cycles in LOOP_SECONDS, and the noise
is cross-faded end into start, so the last sample flows into the first.
"""
import math, random, struct, subprocess, os, wave

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RATE = 24000
LOOP_SECONDS = 72
N = RATE * LOOP_SECONDS
OUT = os.path.join(ROOT, "assets", "audio", "ambient_space.ogg")
WAV = os.path.join(ROOT, "logs", "ambient", "ambient_space.wav")
FFMPEG = "/opt/homebrew/bin/ffmpeg"
TAU = math.tau

def cyc(hz):
    """Snap a frequency so it makes a whole number of cycles per loop."""
    return max(1, round(hz * LOOP_SECONDS)) / LOOP_SECONDS

def lfo(hz, phase, i):
    return math.sin(TAU * cyc(hz) * i / RATE + phase)

def wind(seed):
    """Slow looping filtered noise: low-passed twice, then the tail is cross-faded into the head."""
    rng = random.Random(seed)
    pad = RATE * 6
    raw = []
    a = b = 0.0
    for _ in range(N + pad):
        a += (rng.uniform(-1, 1) - a) * 0.02
        b += (a - b) * 0.05
        raw.append(b)
    out = raw[:N]
    for k in range(pad):
        w = k / pad
        out[k] = raw[k] * w + raw[N + k] * (1 - w)
    peak = max(abs(x) for x in out) or 1.0
    return [x / peak for x in out]

# Pad voices: (hz, level, left pan, lfo hz, lfo phase). Detuned unison around a low open fifth; no melody.
PADS = [(55.0, 0.30, 0.5, 0.013, 0.0), (55.35, 0.22, 0.3, 0.017, 1.0), (82.4, 0.16, 0.7, 0.011, 2.0),
        (110.2, 0.10, 0.4, 0.019, 3.0), (164.9, 0.05, 0.6, 0.015, 4.0), (220.3, 0.03, 0.5, 0.021, 5.0)]
# Faint distant swells: (hz, peak level, centre fraction of the loop, width fraction, pan left)
SWELLS = [(329.6, 0.035, 0.22, 0.12, 0.25), (493.9, 0.025, 0.58, 0.10, 0.75), (392.0, 0.03, 0.86, 0.12, 0.5)]

def main():
    wl, wr = wind(1), wind(2)
    left = [0.0] * N
    right = [0.0] * N
    for hz, lv, pan, lf, ph in PADS:
        f = cyc(hz)
        for i in range(N):
            amp = lv * (0.65 + 0.35 * lfo(lf, ph, i))
            s = math.sin(TAU * f * i / RATE) * amp
            left[i] += s * pan * 2 * 0.5
            right[i] += s * (1 - pan) * 2 * 0.5
    for hz, lv, centre, width, pan in SWELLS:
        f = cyc(hz)
        for i in range(N):
            d = (i / N - centre + 0.5) % 1.0 - 0.5          # wrapped distance: swells loop too
            g = math.exp(-(d / width) ** 2)
            if g < 0.001:
                continue
            s = (math.sin(TAU * f * i / RATE) + 0.4 * math.sin(TAU * f * 2.003 * i / RATE)) * lv * g
            left[i] += s * pan * 2
            right[i] += s * (1 - pan) * 2
    # Filter-swept resonant pads: additive saw-like stack whose resonant peak glides up and down the harmonics.
    for root_hz, lf, ph, side in ((110.0, 0.014, 0.0, 0), (110.55, 0.011, 2.0, 1)):
        f0 = cyc(root_hz)
        for i in range(N):
            c = 3.5 + 2.5 * lfo(lf, ph, i)
            acc = 0.0
            for h in range(1, 11):
                acc += math.sin(TAU * f0 * h * i / RATE) * (1.0 / h) * (0.35 + 2.2 * math.exp(-((h - c) / 0.9) ** 2))
            acc *= 0.05 * (0.7 + 0.3 * lfo(0.017, ph + 1, i))
            (left if side == 0 else right)[i] += acc * 0.9
            (right if side == 0 else left)[i] += acc * 0.3
    # Gentle FM / ring-mod shimmer, opposite phases left and right.
    fc, fm = cyc(880.0), cyc(880.0 * 1.5)
    for i in range(N):
        idx = 1.2 + 1.0 * lfo(0.021, 0.0, i)
        amp = 0.010 * (0.5 + 0.5 * lfo(0.016, 1.0, i)) ** 2
        left[i] += math.sin(TAU * fc * i / RATE + idx * math.sin(TAU * fm * i / RATE)) * amp
        right[i] += math.sin(TAU * fc * i / RATE + idx * math.sin(TAU * fm * i / RATE + 1.7)) * amp
    # Subtle low pulsing reactor drone (18 pulses per loop, 0.25 Hz).
    for i in range(N):
        pulse = 0.55 + 0.45 * lfo(0.25, 0.0, i)
        d = (math.sin(TAU * cyc(41.2) * i / RATE) + 0.35 * math.sin(TAU * cyc(82.4) * i / RATE)) * 0.11 * pulse
        left[i] += d
        right[i] += d
    # Sparse telemetry chirps: seeded, so the file is reproducible; positions wrap so the loop stays seamless.
    trng = random.Random(77)
    for _ in range(14):
        start = trng.randrange(N)
        f_a, f_b = trng.uniform(1300, 2200), trng.uniform(2600, 4200)
        if trng.random() < 0.5:
            f_a, f_b = f_b, f_a
        pan = trng.uniform(0.15, 0.85)
        ln = int(RATE * trng.uniform(0.05, 0.11))
        ph_c = 0.0
        for k in range(ln):
            p = k / ln
            ph_c += TAU * (f_a + (f_b - f_a) * p) / RATE
            g = math.sin(math.pi * p) ** 2 * 0.012 * math.sin(ph_c)
            j = (start + k) % N
            left[j] += g * pan * 2
            right[j] += g * (1 - pan) * 2
    # Faint high pad (slowly evolving partials) and a very sparse granular sparkle, both seeded and wrapped.
    for hz, ph, lf in ((1320.0, 0.0, 0.012), (1331.0, 2.0, 0.015), (1980.0, 4.0, 0.010), (2640.5, 1.0, 0.018)):
        f = cyc(hz)
        for i in range(N):
            a = 0.0030 * (0.5 + 0.5 * lfo(lf, ph, i)) ** 2
            s = math.sin(TAU * f * i / RATE) * a
            left[i] += s * (1.2 if hz < 1500 else 0.8)
            right[i] += s * (0.8 if hz < 1500 else 1.2)
    grng = random.Random(123)
    for _ in range(70):
        start = grng.randrange(N)
        gf = grng.uniform(4000, 8000)
        gl = int(RATE * grng.uniform(0.006, 0.014))
        pan = grng.uniform(0.1, 0.9)
        for k in range(gl):
            g = math.sin(math.pi * k / gl) ** 2 * 0.0035 * math.sin(TAU * gf * k / RATE)
            j = (start + k) % N
            left[j] += g * pan * 2
            right[j] += g * (1 - pan) * 2
    for i in range(N):
        g = 0.10 * (0.6 + 0.4 * lfo(0.02, 0.5, i))
        left[i] += wl[i] * g
        right[i] += wr[i] * g
    peak = max(max(abs(x) for x in left), max(abs(x) for x in right))
    k = 0.6 / peak
    os.makedirs(os.path.dirname(WAV), exist_ok=True)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with wave.open(WAV, "wb") as w:
        w.setnchannels(2)
        w.setsampwidth(2)
        w.setframerate(RATE)
        frames = bytearray()
        for i in range(N):
            frames += struct.pack("<hh", int(left[i] * k * 32767), int(right[i] * k * 32767))
        w.writeframes(bytes(frames))
    subprocess.run([FFMPEG, "-y", "-loglevel", "error", "-i", WAV, "-c:a", "vorbis", "-strict", "-2", "-b:a", "96k", OUT], check=True)
    print("wrote", OUT, os.path.getsize(OUT), "bytes,", LOOP_SECONDS, "s")

if __name__ == "__main__":
    main()
