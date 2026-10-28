#!/usr/bin/env python3
"""Print one task from schedule.json (plus the status of its dependencies).

Usage: python3 tools/task.py T07 [T08 ...]
Agents use this instead of reading the whole schedule.json.
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent


def main(ids):
    data = json.loads((ROOT / "schedule.json").read_text())
    tasks = {t["task_id"]: t for t in data["tasks"]}
    done = set(data.get("done_task_ids", []))
    for tid in ids:
        task = tasks.get(tid)
        if task is None:
            where = "done (see handoffs/archive/schedule-done-*.json)" if tid in done else "not found"
            print(f"{tid}: {where}")
            continue
        print(json.dumps(task, indent=2, ensure_ascii=False))
        for dep in task.get("depends_on", []):
            state = tasks[dep]["status"] if dep in tasks else ("done" if dep in done else "unknown")
            print(f"  depends_on {dep}: {state}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    main(sys.argv[1:])
