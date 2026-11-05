#!/usr/bin/env python3
"""Generate narration audio for story/tutorial text with a local TTS model (Kokoro-82M, Apache-2.0).

Reads data/story_text.json (built by tools/build_story.py), picks the lines that are narrated,
and writes one .ogg per line to assets/voice/<ID>.ogg. A manifest (assets/voice/manifest.json)
stores a hash of (text, voice settings) per ID, so only new or changed lines are regenerated and
audio for removed lines is deleted.

Usage (from the project root):
  tools/voice/run.sh                 # generate what is new or changed
  tools/voice/run.sh --dry-run       # list what would be generated, load no model
  tools/voice/run.sh --only TUT_C1_PLANET EV_MIN_A3_BODY_A
  tools/voice/run.sh --force         # regenerate everything
  tools/voice/run.sh --list-skipped  # show narrated-looking lines that were skipped and why

Config: tools/voice/voice_config.json (which ID patterns are narrated, name map, voice sample).
"""
import argparse
import hashlib
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
CONFIG_PATH = Path(__file__).resolve().parent / "voice_config.json"
PLACEHOLDER_RE = re.compile(r"\{(\w+)\}")


def load_config() -> dict:
    return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))


def spoken_text(text: str, cfg: dict):
    """Return (text to speak, None) or (None, reason). Placeholders must be in the name map."""
    names = cfg["placeholders"]
    missing = sorted({p for p in PLACEHOLDER_RE.findall(text) if p not in names})
    if missing:
        return None, "unresolved placeholder " + ", ".join("{%s}" % m for m in missing)
    out = PLACEHOLDER_RE.sub(lambda m: names[m.group(1)], text)
    for src, dst in cfg.get("pronunciations", {}).items():
        out = re.sub(r"\b%s\b" % re.escape(src), dst, out)
    out = re.sub(r"\s*\n\s*", " ", out).strip()
    return out, None


def select_lines(cfg: dict):
    """Return (lines {id: spoken}, skipped [(id, reason)])."""
    story = json.loads((ROOT / "data" / "story_text.json").read_text(encoding="utf-8"))
    if isinstance(story, dict):  # generated file: {"generated": marker, "entries": [...]}
        story = story["entries"]
    include = [re.compile(p) for p in cfg["include"]]
    exclude = [re.compile(p) for p in cfg.get("exclude", [])]
    lines, skipped = {}, []
    for entry in story:
        eid = entry["id"]
        if not any(r.fullmatch(eid) for r in include) or any(r.fullmatch(eid) for r in exclude):
            continue
        # "spoken" holds voice-only wording (e.g. a lead-in word); the on-screen text stays as written
        text, reason = spoken_text(cfg.get("spoken", {}).get(eid, entry["text"]), cfg)
        if text is None:
            skipped.append((eid, reason))
        else:
            lines[eid] = text
    return lines, skipped


def line_hash(text: str, cfg: dict) -> str:
    v = cfg["voice"]
    key = json.dumps([text, cfg.get("engine"), v, cfg.get("model_version"), cfg.get("post_filter")], sort_keys=True)
    return hashlib.sha1(key.encode()).hexdigest()[:16]


def make_synth(cfg: dict):
    """Return (synth(text) -> float numpy array, sample rate) for the configured engine."""
    import numpy as np

    v = cfg["voice"]
    if cfg["engine"] == "kokoro":
        from kokoro import KPipeline

        pipe = KPipeline(lang_code=v.get("lang", "a"))

        def synth(text):
            parts = [np.asarray(a) for _, _, a in pipe(text, voice=v["name"], speed=v.get("speed", 1.0))]
            return np.concatenate(parts)

        return synth, 24000
    raise SystemExit("unknown engine: " + str(cfg["engine"]))


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawTextHelpFormatter)
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--force", action="store_true")
    ap.add_argument("--only", nargs="+", metavar="ID")
    ap.add_argument("--list-skipped", action="store_true")
    ap.add_argument("--limit", type=int, help="generate at most N lines this run")
    args = ap.parse_args()

    cfg = load_config()
    out_dir = ROOT / cfg["output_dir"]
    manifest_path = out_dir / "manifest.json"
    manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}

    lines, skipped = select_lines(cfg)
    if args.list_skipped:
        for eid, why in skipped:
            print(f"{eid}: {why}")
        print(f"{len(skipped)} skipped, {len(lines)} narrated")
        return 0

    todo = [i for i, t in lines.items()
            if args.force or manifest.get(i) != line_hash(t, cfg) or not (out_dir / f"{i}.ogg").exists()]
    if args.only:
        todo = [i for i in args.only if i in lines]
        unknown = [i for i in args.only if i not in lines]
        if unknown:
            print("not narrated / unknown:", ", ".join(unknown), file=sys.stderr)
    removed = [i for i in manifest if i not in lines]
    if args.limit:
        todo = todo[: args.limit]

    chars = sum(len(lines[i]) for i in todo)
    print(f"{len(lines)} narrated lines, {len(todo)} to generate ({chars} chars), "
          f"{len(removed)} to remove, {len(skipped)} skipped (placeholders)")
    if args.dry_run:
        for i in todo[:20]:
            print(f"  + {i}: {lines[i][:70]}")
        if len(todo) > 20:
            print(f"  ... and {len(todo) - 20} more")
        for i in removed:
            print(f"  - {i}")
        return 0

    out_dir.mkdir(parents=True, exist_ok=True)
    for i in removed:
        for ext in (".ogg", ".ogg.import"):
            (out_dir / f"{i}{ext}").unlink(missing_ok=True)
        del manifest[i]

    if todo:
        import soundfile as sf

        synth, sr_in = make_synth(cfg)
        for n, i in enumerate(todo, 1):
            audio = synth(lines[i])
            with tempfile.TemporaryDirectory() as tmp:
                wav_path = Path(tmp) / "line.wav"
                sf.write(wav_path, audio, sr_in)
                norm_path = Path(tmp) / "norm.wav"
                subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav_path),
                                "-filter_complex", "[0]" + cfg["post_filter"] + "[pre];[pre]"
                                "silenceremove=start_periods=1:start_threshold=-50dB,"
                                "loudnorm=I=-18:TP=-2",
                                "-ac", "1", "-ar", "24000", str(norm_path)], check=True)
                data, sr = sf.read(norm_path)
                sf.write(out_dir / f"{i}.ogg", data, sr, format="OGG", subtype="VORBIS")
            manifest[i] = line_hash(lines[i], cfg)
            manifest_path.write_text(json.dumps(manifest, indent=1, sort_keys=True))
            print(f"[{n}/{len(todo)}] {i}", flush=True)

    manifest_path.write_text(json.dumps(manifest, indent=1, sort_keys=True))
    print("done")
    return 0


if __name__ == "__main__":
    sys.exit(main())
