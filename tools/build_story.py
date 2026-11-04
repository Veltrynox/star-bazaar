#!/usr/bin/env python3
"""Build data/story_text.json and data/events.json from story/*.md.

This script is the only writer of those two generated files.
Fails (exit 1) on: repeated id, unreadable block.
Over-max texts and ambiguous blocks (a designer note inside the text) are listed on stderr and left
out of the output; exit code is 2 unless --allow-skip is given.
Also writes data/story_text_ru.json from story/ru/*.json (flat {"ID": "text"} objects; localised scope only,
see check_ru). Usage: python3 tools/build_story.py [--allow-skip]
       python3 tools/build_story.py --selftest-ru   (checks of the Russian build on temp fixtures)
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STORY = ROOT / "story"
DATA = ROOT / "data"

ID_RE = re.compile(r"^([A-Z][A-Z0-9_]{2,}) \|")
SKILL_RE = re.compile(r"^([A-C]\d) \| (.+)$")
NOTE_RE = re.compile(r"\((If|Use|Note|Optional|TODO)\b")

errors: list = []
ambiguous: list = []


def err(msg: str) -> None:
    errors.append(msg)


def split_blocks(path: Path, head_re) -> list:
    """Return [(header_line, [text lines], line_no, section)] for each block."""
    blocks = []
    cur = None
    section = ""
    for n, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.rstrip()
        if line.startswith("#"):
            cur = None
            section = line.lstrip("# ").strip()
            continue
        if head_re.match(line):
            cur = [line, [], n, section]
            blocks.append(cur)
            continue
        if cur is not None:
            cur[1].append(line)
    return blocks


def clean_text(lines: list) -> str:
    return "\n".join(lines).strip()


def ending_max(eid: str, fields: list) -> int:
    for f in fields:
        m = re.search(r"max (\d+)", f)
        if m:
            return int(m.group(1))
    if eid.endswith("_EPI"):
        return 140
    if eid in ("END_BARE_HANDS", "END_CORP_BARE"):
        return 350
    if "_FULL_" in eid:
        return 1000
    if eid == "END_LOSS":
        return 600
    return 700  # Partial


def build_text(entries: dict) -> None:
    def add(eid, text, mx, place, src, line):
        if eid in entries:
            err(f"{src}:{line}: repeated id {eid}")
            return
        if not text:
            err(f"{src}:{line}: {eid} has no text")
            return
        if NOTE_RE.search(text):
            ambiguous.append(f"{src}:{line}: {eid}: text holds a designer note: {text!r}")
            return
        if len(text) > mx:
            ambiguous.append(f"{src}:{line}: {eid} is {len(text)} chars, over max {mx}")
            return
        entries[eid] = {"id": eid, "text": text, "max": mx, "place": place}

    # screens.md and endings.md (also the standard-format ids in skills.md)
    for fname in ("screens.md", "skills.md", "endings.md"):
        path = STORY / fname
        head = ID_RE
        for hdr, body, n, section in split_blocks(path, head):
            f = [x.strip() for x in hdr.split(" | ")]
            eid = f[0]
            text = clean_text(body)
            src = f"story/{fname}"
            if len(f) >= 2 and f[1].startswith("Mood:"):  # ending header
                name = next((x[5:].strip() for x in f if x.startswith("Name:")), "")
                add(eid, text, ending_max(eid, f), f"Ending: {name}", src, n)
                continue
            if len(f) < 3 or not f[1].isdigit():
                err(f"{src}:{n}: cannot read header of {eid}: {hdr!r}")
                continue
            mx = int(f[1])
            if len(f) >= 4:
                if text:
                    err(f"{src}:{n}: {eid} has inline text and a text line")
                    continue
                add(eid, f[3], mx, f[2], src, n)
            elif text:
                add(eid, text, mx, f[2], src, n)
            else:
                # three fields, no text line: the third field is the label itself
                add(eid, f[2], mx, section, src, n)

    # skills: A1 | Name / Flavour: / Plain:
    path = STORY / "skills.md"
    for hdr, body, n, section in split_blocks(path, SKILL_RE):
        m = SKILL_RE.match(hdr)
        sid, name = m.group(1), m.group(2).strip()
        fl = [l for l in body if l.startswith("Flavour:")]
        pl = [l for l in body if l.startswith("Plain:")]
        extra = [l for l in body if l.strip() and not l.startswith(("Flavour:", "Plain:"))]
        if len(fl) != 1 or len(pl) != 1 or extra:
            err(f"story/skills.md:{n}: skill {sid} is not name + one Flavour + one Plain")
            continue
        add(f"SK_{sid}_NAME", name, 24, "Skill screen, node name", "story/skills.md", n)
        add(f"SK_{sid}_FLAVOUR", fl[0][len("Flavour:"):].strip(), 90, "Skill screen, detail panel", "story/skills.md", n)
        add(f"SK_{sid}_PLAIN", pl[0][len("Plain:"):].strip(), 110, "Skill screen, detail panel", "story/skills.md", n)

    build_choice_text(entries, add)


EVC_RE = re.compile(r"^(EV\d+_[A-Z_]+) \|")


def evc_max(eid: str) -> int:
    """T98: limits of the choice-event texts (see the header of story/events.md)."""
    if eid.endswith("_TITLE"):
        return 40 if eid.endswith("EV17_TITLE") else 32
    if eid.endswith("_BTN"):
        return 28
    if eid.endswith("_EFF"):
        return 90
    return 280


def build_choice_text(entries: dict, add) -> None:
    for hdr, body, n, section in split_blocks(STORY / "events.md", EVC_RE):
        f = [x.strip() for x in hdr.split(" | ")]
        if len(f) != 3:
            err(f"story/events.md:{n}: cannot read header of {f[0]}: {hdr!r}")
            continue
        add(f[0], f[2], evc_max(f[0]), f[1], "story/events.md", n)


def debris_event() -> dict:
    """T98: EV17 is a choice event. Texts are looked up by id at runtime ({planet} filled in by the game);
    the fee and the penalty come from data/balance.json (debris_clear_fee, debris_route_penalty)."""
    return {"id": "EV17", "title": "", "text": "", "title_id": "EV17_TITLE", "text_id": "EV17_BODY",
            "tag": "[route efficiency down: random planet]", "kind": "C",
            "choices": [
                {"text": "", "text_id": "EV17_PAY_BTN", "eff_id": "EV17_PAY_EFF", "tag": "[debris: pay]",
                 "popup_title_id": "EV17_PAID_TITLE", "popup_id": "EV17_PAID"},
                {"text": "", "text_id": "EV17_LEAVE_BTN", "eff_id": "EV17_LEAVE_EFF", "tag": "[debris: leave]",
                 "popup_title_id": "EV17_LEFT_TITLE", "popup_id": "EV17_LEFT"}]}


def shield_event() -> dict:
    """T101: EV18 solar shield, a choice event. Cost and shifts come from balance.json (shield_*)."""
    return {"id": "EV18", "title": "", "text": "", "title_id": "EV18_TITLE", "text_id": "EV18_BODY",
            "tag": "[shield: offer]", "kind": "C",
            "choices": [
                {"text": "", "text_id": "EV18_BUILD_BTN", "eff_id": "EV18_BUILD_EFF", "tag": "[shield: build]",
                 "popup_title_id": "EV18_BUILT_TITLE", "popup_id": "EV18_BUILT"},
                {"text": "", "text_id": "EV18_SKIP_BTN", "eff_id": "EV18_SKIP_EFF", "tag": "[shield: skip]",
                 "popup_title_id": "EV18_SKIPPED_TITLE", "popup_id": "EV18_SKIPPED"}]}


def asteroid_event() -> dict:
    """T109: EV20 asteroid approach, a choice event. Cost, odds and storage loss come from balance.json (asteroid_*)."""
    return {"id": "EV20", "title": "", "text": "", "title_id": "EV20_TITLE", "text_id": "EV20_BODY",
            "tag": "[asteroid: offer]", "kind": "C",
            "choices": [
                {"text": "", "text_id": "EV20_PAY_BTN", "eff_id": "EV20_PAY_EFF", "tag": "[asteroid: pay]",
                 "popup_title_id": "EV20_PAID_TITLE", "popup_id": "EV20_PAID"},
                {"text": "", "text_id": "EV20_DECLINE_BTN", "eff_id": "EV20_DECLINE_EFF", "tag": "[asteroid: decline]",
                 "popup_title_id": "EV20_MISS_TITLE", "popup_id": "EV20_MISS"}]}


# Dead-world events EV29 to EV37 are retired (replaced by Minerals chain A, data/chains.json pool_retired).


def build_events() -> list:
    out = []
    seen = set()
    path = STORY / "events.md"
    for hdr, body, n, section in split_blocks(path, re.compile(r"^EV\d+ \|")):
        f = [x.strip() for x in hdr.split(" | ")]
        src = f"story/events.md:{n}"
        if len(f) != 4:
            err(f"{src}: cannot read event header {hdr!r}")
            continue
        eid, title, tag, kind = f
        text = clean_text(body)
        if eid in seen:
            err(f"{src}: repeated id {eid}")
            continue
        seen.add(eid)
        if not text or "\n" in text:
            err(f"{src}: {eid} text is empty or has several paragraphs")
            continue
        if len(title) > 32:
            err(f"{src}: {eid} title is {len(title)} chars, max 32")
        if len(text) > 280:
            err(f"{src}: {eid} text is {len(text)} chars, max 280")
        if not (tag.startswith("[") and tag.endswith("]")) or kind not in ("P", "Q", "I"):
            err(f"{src}: {eid} tag or kind unreadable: {tag!r} {kind!r}")
            continue
        ev = {"id": eid, "title": title, "tag": tag, "kind": kind, "text": text, "choices": []}
        out.append(ev)
    out.append(debris_event())
    out.append(shield_event())
    out.append(asteroid_event())
    return out


RU_SCOPE_RE = re.compile(r"^(EV_|TUT_G\d|TUT_GALAXY_|CH_)")
PH_RE = re.compile(r"\{[^{}]*\}")
DIGIT_RE = re.compile(r"\d")


def build_ru(entries: dict, ru_dir: Path):
    """Return (list of {"id","text"}, list of problem strings, coverage text) from ru_dir/*.json."""
    out: list = []
    problems: list = []
    seen: dict = {}
    for path in sorted(ru_dir.glob("*.json")) if ru_dir.is_dir() else []:
        rel = path.name
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except ValueError as ex:
            problems.append(f"story/ru/{rel}: not valid JSON: {ex}")
            continue
        if not isinstance(data, dict):
            problems.append(f"story/ru/{rel}: must be a flat JSON object {{id: text}}")
            continue
        for eid, text in data.items():
            where = f"story/ru/{rel}: {eid}"
            if eid in seen:
                problems.append(f"{where}: duplicate id (also in {seen[eid]})")
                continue
            seen[eid] = rel
            if not RU_SCOPE_RE.match(eid):
                problems.append(f"{where}: id is outside the localised scope (EV_, TUT_G<digit>, TUT_GALAXY_, CH_)")
                continue
            if eid not in entries:
                problems.append(f"{where}: id is not in the English data")
                continue
            if not isinstance(text, str) or not text.strip():
                problems.append(f"{where}: empty text")
                continue
            en = entries[eid]["text"]
            if sorted(PH_RE.findall(text)) != sorted(PH_RE.findall(en)) or set(PH_RE.findall(text)) != set(PH_RE.findall(en)):
                problems.append(f"{where}: placeholders differ: English {sorted(set(PH_RE.findall(en)))}, Russian {sorted(set(PH_RE.findall(text)))}")
                continue
            en_d, ru_d = set(DIGIT_RE.findall(en)), set(DIGIT_RE.findall(text))
            if en_d != ru_d:
                problems.append(f"{where}: digits differ: English {sorted(en_d)}, Russian {sorted(ru_d)}")
                continue
            limit = int(1.4 * int(entries[eid]["max"]))
            if len(text) > limit:
                problems.append(f"{where}: {len(text)} chars, over {limit} (1.4 x max {entries[eid]['max']})")
                continue
            out.append({"id": eid, "text": text})
    in_scope = [i for i in entries if RU_SCOPE_RE.match(i)]
    have = sum(1 for e in out if e["id"] in set(in_scope))
    return out, problems, f"Russian coverage: {have} of {len(in_scope)} in-scope ids"


def selftest_ru() -> int:
    import tempfile
    en = {
        "EV_A": {"id": "EV_A", "text": "Pay {cost} for 3 crates.", "max": 40},
        "TUT_G1_X": {"id": "TUT_G1_X", "text": "Click.", "max": 10},
        "CH_CUT": {"id": "CH_CUT", "text": "a cut of 5", "max": 20},
        "BTN_OK": {"id": "BTN_OK", "text": "OK", "max": 10},
    }
    cases = [
        ({"EV_A": "Заплатите {cost} за 3 ящика."}, None),
        ({"CH_CUT": "доля 5"}, None),
        ({"CH_CUT": "доля 6"}, "digits differ"),
        ({"EV_NOPE": "x"}, "not in the English data"),
        ({"BTN_OK": "Ладно"}, "outside the localised scope"),
        ({"EV_A": "Заплатите {sum} за 3 ящика."}, "placeholders differ"),
        ({"EV_A": "Заплатите {cost} за 4 ящика."}, "digits differ"),
        ({"EV_A": "Заплатите {cost} за ящики."}, "digits differ"),
        ({"EV_A": "  "}, "empty text"),
        ({"TUT_G1_X": "Нажмите кнопку мыши."}, "over 14"),
        ({"TUT_G1_X": "Жми."}, None),
    ]
    bad = 0
    for data, want in cases:
        with tempfile.TemporaryDirectory() as d:
            (Path(d) / "a.json").write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            out, probs, _ = build_ru(en, Path(d))
            ok = (not probs and len(out) == 1) if want is None else (len(probs) == 1 and want in probs[0] and not out)
            if not ok:
                bad += 1
                print(f"FAIL {data}: want {want!r}, got {probs}")
    with tempfile.TemporaryDirectory() as d:  # duplicate id across files
        (Path(d) / "a.json").write_text('{"EV_A": "Заплатите {cost} за 3."}', encoding="utf-8")
        (Path(d) / "b.json").write_text('{"EV_A": "Заплатите {cost} за 3."}', encoding="utf-8")
        out, probs, _ = build_ru(en, Path(d))
        if not (len(out) == 1 and len(probs) == 1 and "duplicate" in probs[0]):
            bad += 1
            print("FAIL duplicate", probs)
    with tempfile.TemporaryDirectory() as d:  # no files
        out, probs, _ = build_ru(en, Path(d))
        if out or probs:
            bad += 1
            print("FAIL empty dir")
    print("selftest-ru:", "FAILED" if bad else "ok")
    return 1 if bad else 0


def main() -> int:
    if "--selftest-ru" in sys.argv:
        return selftest_ru()
    allow_skip = "--allow-skip" in sys.argv
    entries: dict = {}
    build_text(entries)
    events = build_events()
    ru_out, ru_problems, ru_cov = build_ru(entries, STORY / "ru")
    for e in errors:
        print("ERROR:", e, file=sys.stderr)
    for r in ru_problems:
        print("RU ERROR:", r, file=sys.stderr)
    for a in ambiguous:
        print("AMBIGUOUS (skipped):", a, file=sys.stderr)
    if errors:
        return 1
    if ru_problems and not allow_skip:
        return 1
    if ambiguous and not allow_skip:
        return 2
    (DATA / "story_text.json").write_text(
        json.dumps(list(entries.values()), indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    (DATA / "events.json").write_text(
        json.dumps(events, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    (DATA / "story_text_ru.json").write_text(
        json.dumps(ru_out, indent=1, ensure_ascii=False) + "\n", encoding="utf-8")
    print(ru_cov)
    print(f"story_text.json: {len(entries)} entries; events.json: {len(events)} events; skipped: {len(ambiguous)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
