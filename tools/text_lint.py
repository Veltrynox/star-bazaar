#!/usr/bin/env python3
"""Deterministic half of the text loop's Evaluator: checks player text against the HARD rules of story/text_rules.md.

Reads the story source with the parser of tools/build_story.py (same ids, same limits as the build), so a text
that passes here is never skipped by the build for length. Writes nothing in story/ or data/.

Selection (any mix, default = every English id):
  --ids A,B,C           exact ids
  --prefix GIG,TUT_G    ids starting with any of these
  --file story/gigs.md  ids from one source file
Input of draft texts:
  --candidates c.json   {"ID": "text"} drafts; each is checked with the limit and place of the source id of the same
                        name, and its placeholders must match the source text exactly (new ids: limit by suffix).
Output:
  (default)             human list of ids with findings
  --json                full JSON report on stdout (items with id, kind, max, place, src, line, text, findings)
  --out report.json     also write the JSON report to a file
  --dump c.json         write the selected source texts as {"ID": "text"} (round 0 of an audit) and stop
  --ru                  check story/ru/*.json instead (length vs the English max, banned words, placeholders)
Exit code: 1 if any finding has level "fail", else 0. Levels: fail (blocks the text), warn (the Evaluator judges it).
"""
import argparse
import importlib.util
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
_spec = importlib.util.spec_from_file_location("build_story", ROOT / "tools" / "build_story.py")
bs = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(bs)

PH_RE = re.compile(r"\{[^{}]*\}")
WORD_RE = re.compile(r"[A-Za-zЀ-ӿ0-9']+")
EMOJI_RE = re.compile("[\U0001F300-\U0001FAFF☀-➿]")

# Story texts carry the voice and may not hold digits (voice.md, Do not). Everything else is plain UI text.
STORY_FILES = ("story/events.md", "story/gigs.md", "story/endings.md")
STORY_ID_RE = re.compile(r"^(SCR_PREFACE(?!_BTN)|SK_.*_FLAVOUR$|ENDB_|EV_(MIL|LUX|MIN|BIO)_)")
MECH_LINE_RE = re.compile(r"(_EFF|_STD|_BTN|_TITLE|_NAME)$")
CHAIN_RE = re.compile(r"^EV_(MIL|LUX|MIN|BIO)_")
CHAIN_EFF_RE = re.compile(r"^EV_(MIL|LUX|MIN|BIO)_.*_OP[AB]_EFF$")
EFF_SHAPE_RE = re.compile(r"^Get: .+ Cost: .+ Weather: .+$", re.S)

# H6: retired or forbidden words in player text (voice.md glossary and Do not; owner rules). (pattern, rule note)
BANNED = [
    (r"\b(rivals?|competitors?|standings)\b", "retired term (T287: houses are weather, not rivals)"),
    (r"\bbots?\b|\bAI\b", "never 'bot' or 'AI' in player text"),
    (r"\bmarket share\b", "retired goal word (market share no longer wins)"),
    (r"\bgame over\b", "never 'game over' (rescue notice)"),
    (r"\bcomrades?\b", "use 'fellow hand', never 'comrade'"),
    (r"\b(waypoint|bundle)s?\b", "glossary: 'Stop at' / 'Mixed load', never waypoint or bundle"),
    (r"\bwarehouse", "glossary: storage, never warehouse"),
    (r"\bmoney\b", "glossary: credits, never money"),
    (r"\b(colony|colonies)\b", "glossary: trading post, never colony"),
    (r"\b(Nasdaq|NYSE|Wall Street|Soviet|USSR|Lenin|Stalin|Politburo|Kremlin)\b", "no real-world names (T341: 'say exchange, not Nasdaq')"),
    (r"\b(beat|beats|weaken|weakens|hurt|hurts|cut down)\b[^.]*\b(Harrow|Velvet|Ostrel|\{bot\d?\})", "never beat, weaken or hurt a house (T287)"),
]
BANNED_RU = [
    (r"затоварива", "owner rule 2026-11-14: never «затоваривание» / «затоваривает»"),
    (r"\bконкурент", "glossary: соперники, never конкуренты"),
    (r"\bбот(ы|ов|ам|ами|ах|а)?\b", "glossary: never боты"),
    (r"\bзаказ\b.*\bподряд|\bгиг\b", "glossary: gig = подряд"),
]
VERDICT = ("good bad right wrong fair unfair safe risky bold kind cruel open closed quiet polite late long short small "
           "big plain clean").split()


def kind_of(eid: str, src: str) -> str:
    if eid.endswith("_BTN"):
        return "button"
    if src in STORY_FILES or STORY_ID_RE.search(eid):
        return "story"
    return "ui"


def sentences(text: str) -> list:
    t = PH_RE.sub("X", text).replace("...", "…")
    parts = re.split(r"(?<=[.?!…])\s+|\n+", t)
    return [p.strip() for p in parts if p.strip()]


def suffix_max(eid: str) -> int:
    for table in (bs.GIG_TEXT_MAX, bs.EVENT_TEXT_MAX):
        for suf, mx in table.items():
            if eid.endswith(suf):
                return mx
    return 0


def load_source() -> dict:
    entries = {}

    def add(eid, text, mx, place, src, line):
        entries.setdefault(eid, {"id": eid, "text": text, "max": mx, "place": place, "src": src, "line": line})

    bs.build_text({}, add)
    return entries


def check(eid: str, text: str, meta: dict, original: str | None, ru: bool = False) -> list:
    f = []

    def hit(rule, level, msg):
        f.append({"rule": rule, "level": level, "msg": msg})

    src = meta.get("src", "")
    kind = kind_of(eid, src)
    mx = meta.get("max") or suffix_max(eid)
    if mx and len(text) > mx:
        # Russian: the English max is a soft target (story/ru/GLOSSARY.md), so only a warning
        hit("H1", "warn" if ru else "fail", f"{len(text)} chars, max {mx}")
    elif not mx:
        hit("H1", "warn", "no known max for this id")
    for s in sentences(text):
        n = len(WORD_RE.findall(s))
        if n > 20:
            hit("H2", "fail", f"sentence of {n} words (max 20): {s[:80]}")
    if "!" in text:
        hit("H3", "fail", "exclamation mark")
    if kind == "story" and not ru and re.search(r"\d", PH_RE.sub("", text)):
        hit("H4", "fail", "digit in a story text (numbers come only from {placeholders})")
    if "—" in text or "–" in text or " - " in text:
        if not ru:
            hit("H5", "fail", "long dash: use a comma or a full stop")
    # placeholders are filled by the game: a house placeholder reads as a house name, any other as a neutral word
    plain = PH_RE.sub(lambda m: "Harrow" if re.fullmatch(r"\{bot\d?\}", m.group(0)) else "X", text)
    for pat, note in (BANNED_RU if ru else BANNED):
        m = re.search(pat, plain, re.I)
        if m:
            hit("H6", "fail", f"'{m.group(0)}': {note}")
    if EMOJI_RE.search(text):
        hit("H7", "fail", "emoji")
    if original is not None:
        a, b = sorted(set(PH_RE.findall(original))), sorted(set(PH_RE.findall(text)))
        if a != b:
            hit("H8", "fail", f"placeholders {b} differ from the source {a}")
    if bs.NOTE_RE.search(text):
        hit("H9", "fail", "designer note inside the text (the build would skip it)")
    if not ru and CHAIN_EFF_RE.search(eid) and not EFF_SHAPE_RE.match(text):
        hit("H10", "fail", "effect line must read 'Get: ... Cost: ... Weather: ...'")
    if not ru and CHAIN_RE.search(eid):
        if re.search(r"\b(but|however|at least)\b", text, re.I) and eid.endswith("_EFF"):
            hit("H10", "fail", "effect line uses but / however / at least")
        words = {w.lower() for w in WORD_RE.findall(text)}
        vw = sorted(words & set(VERDICT))
        if vw:
            hit("H11", "fail" if kind == "button" else "warn", f"verdict word(s) in a chain text: {', '.join(vw)}")
    if kind == "button" and not ru:
        if text.rstrip().endswith(".") and not text.endswith("..."):
            hit("H12", "fail", "button ends with a full stop")
        if text[:1].islower():
            hit("H12", "fail", "button not in sentence case")
    return f


def pair_checks(items: dict) -> None:
    """H13: the two option buttons of one choice stay within 5 characters of each other (voice.md, chain rules)."""
    for eid, it in items.items():
        for a, b in (("_OPA_BTN", "_OPB_BTN"), ("_A_BTN", "_B_BTN")):
            if eid.endswith(a):
                other = items.get(eid[: -len(a)] + b)
                if other and abs(len(it["text"]) - len(other["text"])) > 5:
                    it["findings"].append({"rule": "H13", "level": "warn",
                                           "msg": f"option buttons differ by {abs(len(it['text']) - len(other['text']))} chars (max 5)"})


def select(entries: dict, a) -> list:
    ids = list(entries)
    if a.ids or a.prefix or a.file:
        want = set(x.strip() for x in (a.ids or "").split(",") if x.strip())
        pre = tuple(x.strip() for x in (a.prefix or "").split(",") if x.strip())
        ids = [i for i in ids if i in want or (pre and i.startswith(pre)) or (a.file and entries[i].get("src") == a.file)]
        ids += [i for i in want if i not in entries]
    return ids


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--ids"), p.add_argument("--prefix"), p.add_argument("--file")
    p.add_argument("--candidates"), p.add_argument("--dump"), p.add_argument("--out")
    p.add_argument("--json", action="store_true"), p.add_argument("--ru", action="store_true")
    a = p.parse_args()

    src = load_source()
    if a.ru:
        texts = {}
        for fp in sorted((ROOT / "story" / "ru").glob("*.json")):
            texts.update({k: v for k, v in json.loads(fp.read_text(encoding="utf-8")).items() if isinstance(v, str)})
        pool = {k: {"text": v} for k, v in texts.items()}
    else:
        pool = src
    ids = select(pool if not a.candidates else {**src}, a) if (a.ids or a.prefix or a.file) else None

    if a.dump:
        out = {i: pool[i]["text"] for i in (ids or list(pool)) if i in pool}
        Path(a.dump).write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"dumped {len(out)} texts to {a.dump}")
        return 0

    if a.candidates:
        cand = json.loads(Path(a.candidates).read_text(encoding="utf-8"))
        texts = {k: v for k, v in cand.items() if (ids is None or k in ids)}
        originals = {k: src[k]["text"] for k in texts if k in src}
    elif a.ru:
        texts = {k: v["text"] for k, v in pool.items() if ids is None or k in ids}
        originals = {k: src[k]["text"] for k in texts if k in src}
    else:
        texts = {k: src[k]["text"] for k in (ids or list(src)) if k in src}
        originals = {}

    items = {}
    for eid, text in texts.items():
        meta = src.get(eid, {})
        items[eid] = {"id": eid, "kind": kind_of(eid, meta.get("src", "")), "max": meta.get("max") or suffix_max(eid),
                      "place": meta.get("place", ""), "src": meta.get("src", ""), "line": meta.get("line", 0),
                      "text": text, "findings": check(eid, text, meta, originals.get(eid), ru=a.ru)}
    pair_checks(items)
    n_fail = sum(1 for it in items.values() if any(x["level"] == "fail" for x in it["findings"]))
    n_warn = sum(1 for it in items.values() if it["findings"] and not any(x["level"] == "fail" for x in it["findings"]))
    report = {"summary": {"checked": len(items), "fail_ids": n_fail, "warn_only_ids": n_warn,
                          "rules": "story/text_rules.md"}, "items": list(items.values())}
    if a.out:
        Path(a.out).write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if a.json:
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        for it in items.values():
            for x in it["findings"]:
                print(f"{x['level'].upper():4} {x['rule']:3} {it['id']} ({it['src']}:{it['line']}): {x['msg']}")
        print(f"checked {len(items)}: {n_fail} ids fail, {n_warn} ids warn only")
    return 1 if n_fail else 0


if __name__ == "__main__":
    sys.exit(main())
