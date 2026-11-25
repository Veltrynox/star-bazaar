#!/usr/bin/env python3
"""Render tools/assignment_pdf/assignment_7.html to ASSIGNMENT_7.pdf (A4) with headless Chromium.

Two passes: the first PDF's outline (bookmarks from the h2 headings) gives the page each section starts on;
those numbers are written into the contents page and the PDF is rendered again.

Needs Playwright with Chromium. Set up once (kept on the Work volume, not in the repo):
  python3 -m venv /Volumes/Work/pdf_tools/venv
  /Volumes/Work/pdf_tools/venv/bin/pip install playwright pypdf
  PLAYWRIGHT_BROWSERS_PATH=/Volumes/Work/pdf_tools/browsers /Volumes/Work/pdf_tools/venv/bin/playwright install chromium
Run:
  PLAYWRIGHT_BROWSERS_PATH=/Volumes/Work/pdf_tools/browsers /Volumes/Work/pdf_tools/venv/bin/python tools/assignment_pdf/render.py
"""
import io
from pathlib import Path

from playwright.sync_api import sync_playwright
from pypdf import PdfReader

HERE = Path(__file__).resolve().parent
SRC = HERE / "assignment_7.html"
OUT = HERE.parent.parent / "ASSIGNMENT_7.pdf"


def section_pages(pdf_bytes):
    reader = PdfReader(io.BytesIO(pdf_bytes))
    pages = {}

    def walk(items):
        for it in items:
            if isinstance(it, list):
                walk(it)
            else:
                pages[it.title.strip()] = reader.get_destination_page_number(it) + 1

    walk(reader.outline)
    return pages, len(reader.pages)


def render(page):
    return page.pdf(format="A4", print_background=True, prefer_css_page_size=True, outline=True, tagged=True)


with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto(SRC.as_uri(), wait_until="networkidle")
    page.evaluate("document.fonts.ready")
    pages, total = section_pages(render(page))
    missing = page.evaluate(
        """(pages) => {
            const miss = [];
            for (const el of document.querySelectorAll('[data-toc]')) {
                const n = pages[el.dataset.toc];
                if (n === undefined) { miss.push(el.dataset.toc); continue; }
                el.textContent = String(n).padStart(2, '0');
            }
            return miss;
        }""",
        pages,
    )
    if missing:
        raise SystemExit(f"no bookmark for: {missing} (outline had {sorted(pages)})")
    OUT.write_bytes(render(page))
    browser.close()

print(f"wrote {OUT} ({total} pages)")
for title, n in sorted(pages.items(), key=lambda kv: kv[1]):
    print(f"  p{n:02d}  {title}")
