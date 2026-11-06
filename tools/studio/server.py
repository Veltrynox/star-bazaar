#!/usr/bin/env python3
"""Local server for tools/studio/studio.html: autosaves the skills and event-text drafts to design/drafts/.

Run: python3 tools/studio/server.py   then open http://127.0.0.1:8765
- GET /            rebuilds tools/studio/studio.html from its sources and serves it (fresh schedule snapshot every load)
- GET /ping        {"studio": true}  (the page uses it to switch autosave on)
- GET /draft/<n>   returns design/drafts/<n>.json if it exists
- POST /save/<n>   writes design/drafts/<n>.json   (n is one of NAMES; nothing else can be written)
Only drafts are written: never data/, story/ or the game. Listens on 127.0.0.1 only.
"""
import json
import sys
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import build as build_studio  # noqa: E402

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
DRAFTS = ROOT / "design" / "drafts"
NAMES = {"skills-draft", "events-draft"}
MAX_BYTES = 8 * 1024 * 1024


class H(BaseHTTPRequestHandler):
    def _send(self, code, body=b"", ctype="application/json"):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if self.path in ("/", "/index.html"):
            build_studio.main()
            self._send(200, (HERE / "studio.html").read_bytes(), "text/html; charset=utf-8")
        elif self.path == "/ping":
            self._send(200, b'{"studio": true}')
        elif self.path.startswith("/draft/") and self.path[7:] in NAMES:
            f = DRAFTS / (self.path[7:] + ".json")
            self._send(200, f.read_bytes()) if f.exists() else self._send(404, b"{}")
        else:
            self._send(404, b"{}")

    def do_POST(self):
        n = self.path[6:] if self.path.startswith("/save/") else ""
        size = int(self.headers.get("Content-Length", "0"))
        if n not in NAMES or size > MAX_BYTES:
            return self._send(400, b'{"ok": false}')
        try:
            body = self.rfile.read(size)
            json.loads(body)
        except ValueError:
            return self._send(400, b'{"ok": false, "error": "not json"}')
        DRAFTS.mkdir(parents=True, exist_ok=True)
        tmp = DRAFTS / (n + ".json.tmp")
        tmp.write_bytes(body)
        tmp.replace(DRAFTS / (n + ".json"))
        self._send(200, b'{"ok": true}')

    def log_message(self, *a):
        pass


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    print(f"Studio: http://127.0.0.1:{port}  (drafts autosave to design/drafts/)")
    ThreadingHTTPServer(("127.0.0.1", port), H).serve_forever()
