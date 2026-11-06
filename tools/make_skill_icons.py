#!/usr/bin/env python3
"""Writes art_source/ui_glyph_skill_atlas.svg: one 64x64 cell per skill, 8 columns x 4 rows, in ORDER below.
White 5 px round strokes (2 px at 32 px), no fill, transparent background; the button tints them.
Then rasterise to art/ui/ui_glyph_skill_atlas.png with
  tools/godot/Godot.app/Contents/MacOS/Godot --headless --path . --script tools/make_skill_atlas.gd
The ORDER list must match game/skill_icons.gd (IDS). Run: python3 tools/make_skill_icons.py"""
import os

SW = 5
def circle(cx, cy, r): return f'<circle cx="{cx}" cy="{cy}" r="{r}"/>'
def line(x1, y1, x2, y2): return f'<path d="M{x1} {y1} L{x2} {y2}"/>'
def poly(*pts): return '<path d="M' + ' L'.join(f'{x} {y}' for x, y in pts) + ' Z"/>'
def pline(*n):  # flat x, y, x, y ... open polyline
    pts = list(zip(n[0::2], n[1::2]))
    return '<path d="M' + ' L'.join(f'{x} {y}' for x, y in pts) + '"/>'
def rect(x, y, w, h, r=0): return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}"/>'
def path(d): return f'<path d="{d}"/>'

G = {
 # Foundations
 "FND_STORAGE": [rect(8, 34, 23, 20), rect(33, 34, 23, 20), rect(20, 11, 24, 21)],            # stacked crates
 "FND_PERMIT": [circle(32, 15, 7), rect(25, 22, 14, 14), rect(10, 36, 44, 12, 2), line(10, 56, 54, 56)],  # stamp
 "FND_PROSPECT": [circle(32, 32, 16), line(32, 6, 32, 20), line(32, 44, 32, 58), line(6, 32, 20, 32), line(44, 32, 58, 32)],
 # Military: hull / shield motif
 "MIL_1": [path("M8 36 L56 36 L47 52 L17 52 Z"), line(32, 36, 32, 10), poly((32, 10), (46, 28), (32, 28))],  # hull + sail
 "MIL_2": [rect(21, 8, 22, 48, 11), line(21, 32, 43, 32)],                                    # pulse cell
 "MIL_3": [pline(14, 14, 30, 32, 14, 50), pline(32, 14, 48, 32, 32, 50)],                      # quick: double chevron
 "MIL_4": [path("M32 7 L53 15 V32 C53 44 43 53 32 58 C21 53 11 44 11 32 V15 Z")],               # armour shield
 "MIL_5": [circle(32, 32, 22), line(16, 16, 48, 48)],                                          # embargo
 "MIL_6": [rect(15, 7, 34, 50, 3), line(23, 21, 41, 21), line(23, 32, 41, 32), line(23, 43, 33, 43)],  # contract
 "MIL_7": [poly((32, 8), (43, 28), (21, 28)), poly((16, 34), (27, 54), (5, 54)), poly((48, 34), (59, 54), (37, 54))],  # fleet
 # Luxury: gem / sparkle motif
 "LUX_1": [path("M5 32 Q32 8 59 32 Q32 56 5 32 Z"), circle(32, 32, 8)],                        # eye: next prices
 "LUX_2": [path("M32 7 L39 25 L57 32 L39 39 L32 57 L25 39 L7 32 L25 25 Z")],                   # sparkle: finishing
 "LUX_3": [poly((32, 8), (58, 53), (6, 53)), line(32, 24, 32, 38), line(32, 45, 32, 46)],       # warning triangle
 "LUX_4": [path("M18 8 H46 C55 24 55 40 46 56 H18 C9 40 9 24 18 8 Z"), line(12, 22, 52, 22), line(12, 42, 52, 42)],  # cask
 "LUX_5": [rect(13, 7, 38, 50, 3), circle(23, 21, 2), circle(23, 32, 2), circle(23, 43, 2), line(32, 21, 42, 21), line(32, 32, 42, 32), line(32, 43, 42, 43)],  # list
 "LUX_6": [poly((16, 14), (48, 14), (58, 27), (32, 56), (6, 27)), line(6, 27, 58, 27), pline(22, 14, 32, 27, 42, 14)],  # gem: hallmark
 "LUX_7": [circle(32, 32, 24), circle(32, 32, 13), line(32, 26, 32, 38), line(26, 32, 38, 32)],  # wax seal
 # Minerals: ore / tool motif
 "MIN_1": [poly((8, 56), (8, 30), (24, 40), (24, 30), (40, 40), (40, 12), (56, 12), (56, 56))],  # factory
 "MIN_2": [path("M13 24 H51 L45 54 H19 Z"), line(25, 6, 25, 16), line(39, 6, 39, 16)],          # smelter pot
 "MIN_3": [line(32, 6, 32, 58), line(9, 19, 55, 45), line(9, 45, 55, 19)],                      # cold: snowflake
 "MIN_4": [circle(23, 32, 15), circle(41, 32, 15)],                                            # alloy: two circles
 "MIN_5": [line(12, 56, 44, 24), path("M16 22 Q34 6 56 22"), line(44, 24, 52, 32)],             # pickaxe
 "MIN_6": [rect(10, 10, 44, 44, 2), line(24.7, 10, 24.7, 54), line(39.3, 10, 39.3, 54), line(10, 24.7, 54, 24.7), line(10, 39.3, 54, 39.3)],  # lattice
 "MIN_7": [pline(12, 12, 12, 52, 52, 52), line(24, 42, 52, 14), line(34, 42, 52, 24)],           # cornered seam
 # Biotech: leaf / cell motif
 "BIO_1": [path("M32 10 A22 22 0 1 1 10 32"), pline(2, 40, 10, 30, 19, 40)],                   # standing orders: loop
 "BIO_2": [path("M26 7 H38 M28 7 V26 L10 54 H54 L36 26 V7"), line(19, 42, 45, 42)],              # culture flask
 "BIO_3": [line(32, 56, 32, 30), path("M32 36 C32 22 20 18 11 20 C11 32 20 38 32 36"), path("M32 30 C32 17 42 11 53 13 C53 26 44 32 32 30")],  # sprout
 "BIO_4": [path("M20 7 C52 20 52 44 20 57"), path("M44 7 C12 20 12 44 44 57"), line(24, 22, 40, 22), line(24, 42, 40, 42)],  # helix
 "BIO_5": [poly((25, 8), (39, 8), (39, 25), (56, 25), (56, 39), (39, 39), (39, 56), (25, 56), (25, 39), (8, 39), (8, 25), (25, 25))],  # clinic cross
 "BIO_6": [path("M10 54 C5 24 28 8 56 9 C58 38 38 56 10 54 Z"), line(10, 54, 42, 22)],            # hardy leaf
 "BIO_7": [rect(8, 14, 48, 38, 2), line(8, 26.7, 56, 26.7), line(8, 39.3, 56, 39.3), line(32, 14, 32, 26.7), line(20, 26.7, 20, 39.3), line(44, 26.7, 44, 39.3), line(32, 39.3, 32, 52)],  # wall
 # Tier-3 side skills (T173), appended so the older cells keep their place
 "LUX_5B": [path("M5 32 Q32 8 59 32 Q32 56 5 32 Z"), circle(32, 32, 8), pline(46, 8, 58, 8), pline(52, 2, 52, 14)],  # eye + far sight
 "MIN_5B": [path("M32 7 L53 15 V32 C53 44 43 53 32 58 C21 53 11 44 11 32 V15 Z"), poly((32, 20), (42, 34), (32, 48), (22, 34))],  # shield + ore
}
ORDER = list(G.keys())
COLS, CELL = 8, 64

def main():
    assert len(ORDER) == 36
    rows = (len(ORDER) + COLS - 1) // COLS
    out = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{COLS*CELL}" height="{rows*CELL}" viewBox="0 0 {COLS*CELL} {rows*CELL}">']
    for i, k in enumerate(ORDER):
        x, y = (i % COLS) * CELL, (i // COLS) * CELL
        out.append(f'<g id="{k}" transform="translate({x} {y})" fill="none" stroke="#ffffff" stroke-width="{SW}" stroke-linecap="round" stroke-linejoin="round">')
        out.extend(G[k])
        out.append('</g>')
    out.append('</svg>')
    root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
    p = os.path.join(root, "art_source", "ui_glyph_skill_atlas.svg")
    open(p, "w").write("\n".join(out) + "\n")
    print("wrote", p)
    print("IDS:", ", ".join(f'"{k}"' for k in ORDER))

if __name__ == "__main__":
    main()
