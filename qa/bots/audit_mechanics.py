#!/usr/bin/env python3
"""Static dead-mechanic audit (QA). Stdlib only. Reads, never writes.

Lists every balance key (values.* and targets.*), every skill id (from skill_cost_<id>),
every skill effect key (skill_* other than skill_cost_* and skill_points_*), and every event
id in data/events.json. For each, searches the game code for a reader:

  - READ        : at least one game script (not debug_menu.gd) reads it by its quoted name,
                  or by the quoted prefix for generated keys (e.g. "skill_cost_" + id).
  - DISPLAY     : every reader is a display or UI script (see DISPLAY_PATTERN).
  - NO_READER   : no game script reads it. debug_menu.gd reads every key live, so it is excluded.

Events are checked by quoted id. An id with no quoted reference is POOL if events.gd loads the
data file (events are then picked from data), otherwise NO_READER.

Static reading does not prove the key changes the win or the story path. Those claims need
dynamic evidence (skill ablation runs, see metrics.py section d). This script only reports what
the code reads. Usage: python3 qa/bots/audit_mechanics.py [--root REPO] [--json OUT]
"""
import argparse
import json
import os
import re
import sys

DISPLAY_PATTERN = re.compile(
    r"(_ui|^ui|_screen|_panel|notice|hint|forecast|menu|story_text|end_screen|route_line|"
    r"galaxy_view|^map|debug_menu|event_notice|planet_panel|ship_panel|skill_screen|game_menu|"
    r"main_menu|cash_forecast)\.gd$")
EXCLUDE_READERS = {"debug_menu.gd"}  # reads every balance key live for the editor, not gameplay
META_KEYS = {"note", "source", "schema_version", "data_version"}  # text and metadata, not tuning values
SKILL_ID = re.compile(r"^[ABC][1-5]$")


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def flatten(obj, prefix=""):
    """Leaf keys of balance.json as (name, dotted path). Only the values and targets sections."""
    out = []
    if isinstance(obj, dict):
        for k, v in obj.items():
            out.extend(flatten(v, prefix + "." + k if prefix else k))
    elif isinstance(obj, list):
        for i, v in enumerate(obj):
            out.extend(flatten(v, "%s[%d]" % (prefix, i)))
    else:
        leaf = prefix.split(".")[-1].split("[")[0]
        if leaf in META_KEYS:
            return out
        out.append((leaf, prefix))
    return out


def game_sources(root):
    srcs = {}
    for dirpath, _dirs, files in os.walk(os.path.join(root, "game")):
        for name in files:
            if name.endswith(".gd"):
                p = os.path.join(dirpath, name)
                with open(p, encoding="utf-8") as f:
                    srcs[os.path.relpath(p, root)] = f.read()
    return srcs


def readers_of(name, srcs):
    pat = re.compile(r"""["']%s["']""" % re.escape(name))
    return sorted(p for p, text in srcs.items()
                  if os.path.basename(p) not in EXCLUDE_READERS and pat.search(text))


def classify(readers):
    if not readers:
        return "NO_READER"
    if all(DISPLAY_PATTERN.search(os.path.basename(r)) for r in readers):
        return "DISPLAY"
    return "READ"


def prefix_readers(key, srcs):
    """Generated key: skill_cost_A1 is read as "skill_cost_" + id. Use the quoted prefix up to the last _."""
    if "_" not in key:
        return []
    prefix = key.rsplit("_", 1)[0] + "_"
    return readers_of(prefix, srcs)


def data_refs(root, name):
    """Other data files (not balance.json) that name the key in quotes. Code reads them by file."""
    pat = re.compile(r"""["']%s["']""" % re.escape(name))
    hits = []
    data_dir = os.path.join(root, "data")
    for fn in sorted(os.listdir(data_dir)):
        if fn.endswith(".json") and fn != "balance.json":
            with open(os.path.join(data_dir, fn), encoding="utf-8") as f:
                if pat.search(f.read()):
                    hits.append("data/" + fn)
    return hits


def audit(root):
    balance = load_json(os.path.join(root, "data", "balance.json"))
    events = load_json(os.path.join(root, "data", "events.json"))
    srcs = game_sources(root)
    events_gd = srcs.get("game/events.gd", "")
    loads_pool = "events.json" in events_gd or "PATH" in events_gd

    rows = {"balance": [], "skill_ids": [], "skill_effect_keys": [], "events": []}

    balance_keys = []
    for name, path in flatten({k: balance[k] for k in ("values", "targets") if k in balance}):
        balance_keys.append((name, path))
    seen = set()
    for name, path in balance_keys:
        if name in seen:
            continue
        seen.add(name)
        readers = readers_of(name, srcs) or prefix_readers(name, srcs)
        if readers:
            cls = classify(readers)
        else:
            # Read through another data file (e.g. systems.json permit_cost_key, ships.json hauler_*).
            drefs = data_refs(root, name)
            readers = drefs
            cls = "READ_VIA_DATA" if drefs else "NO_READER"
        rows["balance"].append({"key": path, "class": cls, "readers": readers})

    skill_ids = sorted(n[len("skill_cost_"):] for n, _ in balance_keys
                       if n.startswith("skill_cost_") and SKILL_ID.match(n[len("skill_cost_"):]))
    for sid in skill_ids:
        readers = readers_of(sid, srcs)
        rows["skill_ids"].append({"id": sid, "class": classify(readers) if readers else "NO_READER",
                                  "readers": readers, "effect_hook": bool(readers)})

    effect_keys = [n for n, _ in balance_keys if n.startswith("skill_")
                   and not n.startswith("skill_cost_") and not n.startswith("skill_points_")]
    for name in sorted(set(effect_keys)):
        readers = readers_of(name, srcs)
        rows["skill_effect_keys"].append({"key": name, "class": classify(readers), "readers": readers})

    for ev in events:
        eid = ev.get("id", "")
        readers = readers_of(eid, srcs)
        if readers:
            cls = classify(readers)
        else:
            cls = "POOL" if loads_pool else "NO_READER"
        rows["events"].append({"id": eid, "kind": ev.get("kind", ""), "class": cls, "readers": readers})
    # ids in the EV01..EV20 sequence that are absent from events.json and from code
    ids = {e.get("id", "") for e in events}
    missing = ["EV%02d" % i for i in range(1, 21) if "EV%02d" % i not in ids]
    rows["event_id_gaps"] = [m for m in missing if not readers_of(m, srcs)]
    return rows


def summarise(rows):
    out = {}
    for section in ("balance", "skill_effect_keys", "events", "skill_ids"):
        counts = {}
        for r in rows[section]:
            counts[r["class"]] = counts.get(r["class"], 0) + 1
        out[section] = counts
    return out


def print_report(rows):
    print("Balance keys (%d):" % len(rows["balance"]))
    for cls in ("NO_READER", "DISPLAY", "READ_VIA_DATA", "READ"):
        hits = [r["key"] for r in rows["balance"] if r["class"] == cls]
        print("  %-9s %d%s" % (cls, len(hits), (": " + ", ".join(hits)) if hits and cls != "READ" else ""))
    print("Skill ids (%d): %s" % (len(rows["skill_ids"]), ", ".join(
        "%s:%s" % (r["id"], "hook" if r["effect_hook"] else "NO_HOOK") for r in rows["skill_ids"])))
    print("Skill effect keys (%d):" % len(rows["skill_effect_keys"]))
    for r in rows["skill_effect_keys"]:
        print("  %-24s %-9s %s" % (r["key"], r["class"], ", ".join(r["readers"]) or "-"))
    print("Events (%d):" % len(rows["events"]))
    for r in rows["events"]:
        print("  %-5s kind=%s %-9s %s" % (r["id"], r["kind"], r["class"], ", ".join(r["readers"]) or "-"))
    print("Event ids missing from data and code (EV01..EV20): %s" % (", ".join(rows["event_id_gaps"]) or "none"))


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--root", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
    ap.add_argument("--json", help="also write the full rows as JSON to this path")
    args = ap.parse_args(argv)
    root = os.path.abspath(args.root)
    rows = audit(root)
    print_report(rows)
    print("Summary:", json.dumps(summarise(rows)))
    if args.json:
        with open(args.json, "w", encoding="utf-8") as f:
            json.dump({"rows": rows, "summary": summarise(rows)}, f, indent=2)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
