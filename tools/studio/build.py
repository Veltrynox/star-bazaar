#!/usr/bin/env python3
"""Builds tools/studio/studio.html: one page with the task board, the project workflow and the draft skills tree.

Sources: data/story_text.json, data/events.json (event texts, read only), tools/studio/template.html, tools/studio/task_board.html, tools/project_workflow.html (stays in tools/: build_readme.py reads it),
schedule.json (task snapshot) and design/skills-board/final-skills.json (the draft skills).
The skills tab edits a DRAFT only (browser storage and a file the owner picks); it never writes data/ or the game.
Usage: python3 tools/studio/build.py  (or python3 tools/studio/server.py for autosave)
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent


def js_str(s: str) -> str:
    return json.dumps(s).replace("</", "<\\/")


def main() -> None:
    tpl = (HERE / "template.html").read_text()
    board = (HERE / "task_board.html").read_text()
    snap = json.loads((ROOT / "schedule.json").read_text())
    # Preload the schedule snapshot into the embedded task board (its own Open/Save still work).
    board = board.replace("</script>\n</body>", "load(" + json.dumps(snap).replace("</", "<\\/") + ");\n</script>\n</body>", 1) \
        if "</script>\n</body>" in board else board + "<script>load(" + json.dumps(snap).replace("</", "<\\/") + ");</script>"
    flow = (ROOT / "tools" / "project_workflow.html").read_text()
    st = json.loads((ROOT / "data" / "story_text.json").read_text())["entries"]
    evs = {x["title_id"]: x for x in json.loads((ROOT / "data" / "events.json").read_text())["entries"]}
    entries = []
    for x in st:
        i = x["id"]
        if not i.startswith("EV"):
            continue
        t = i.split("_")
        g = t[0] if t[0] != "EV" else ("_".join(t[:3]) if len(t) > 2 and t[1] in ("MIL", "LUX", "MIN", "BIO") else "_".join(t[:2]))
        if t[0].startswith("EVT") or g == "EV_EFF":
            g = "UI event strings"
        e = {"id": i, "group": g, "text": x["text"], "max": x.get("max", 0), "place": x.get("place", "")}
        meta = evs.get(g + "_TITLE")
        if meta:
            e["tag"] = meta.get("tag", ""); e["kind"] = meta.get("kind", "")
        if i.endswith("_TITLE"):
            e["title"] = x["text"]
        entries.append(e)
    titles = {e["group"]: e["text"] for e in entries if e["id"].endswith("_TITLE")}
    for e in entries:
        e["title"] = titles.get(e["group"], e.get("title", ""))
    evseed = json.dumps({"entries": entries}, ensure_ascii=False)
    seed = (ROOT / "design" / "skills-board" / "final-skills.json").read_text()
    out = (tpl.replace("/*SEED*/", seed.replace("</", "<\\/"))
              .replace("/*EVSEED*/", evseed.replace("</", "<\\/"))
              .replace('/*TASKS_SRCDOC*/""', js_str(board))
              .replace('/*FLOW_SRCDOC*/""', js_str(flow)))
    (HERE / "studio.html").write_text(out)
    print("wrote tools/studio/studio.html", len(out), "bytes")


if __name__ == "__main__":
    main()
