# Rebuilds art/icons/*.png and the placeholder goods SVGs (icon_<good>_64.svg). Pure python, no deps. Run from the project root: python3 tools/make_icons.py
import zlib, struct, math, os
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "art", "icons")
OUTLINE = (18, 24, 43)
ICONS = {  # id: (fill colour, shape)
    "energy": ((255, 201, 51), "bolt"),
    "food": ((107, 203, 91), "leaf"),
}
BOLT = [(0.58,0.06),(0.22,0.54),(0.46,0.54),(0.38,0.94),(0.78,0.42),(0.54,0.42),(0.70,0.06)]
def in_poly(p, x, y):
    c = False; n = len(p)
    for i in range(n):
        x1,y1 = p[i]; x2,y2 = p[(i+1)%n]
        if (y1 > y) != (y2 > y) and x < (x2-x1)*(y-y1)/(y2-y1)+x1: c = not c
    return c
def leaf(x, y):  # lens shape from two circles, tilted, plus stem
    u = (x+y)/1.4142-0.7071*1.4142/1.0 + 0.0
    a, b = x-0.5, y-0.5
    r = (a+b)*0.7071; s = (a-b)*0.7071   # r along diagonal
    lens = abs(s) < 0.30*math.cos(r/0.46*math.pi/2) if abs(r) < 0.46 else False
    stem = abs(s) < 0.04 and -0.62 < r < -0.30
    return lens or stem
def inside(shape, x, y, grow):
    if shape == "bolt":
        if grow == 0: return in_poly(BOLT, x, y)
        return any(in_poly(BOLT, x+dx, y+dy) for dx,dy in
                   [(math.cos(k*0.785)*grow, math.sin(k*0.785)*grow) for k in range(8)]+[(0,0)])
    if grow == 0: return leaf(x, y)
    return any(leaf(x+math.cos(k*0.785)*grow, y+math.sin(k*0.785)*grow) for k in range(8)) or leaf(x,y)
def render(shape, col, size, ss=4):
    rows = []
    ow = 0.055
    for py in range(size):
        row = bytearray()
        for px in range(size):
            f = o = 0
            for sy in range(ss):
                for sx in range(ss):
                    x = (px+(sx+.5)/ss)/size; y = (py+(sy+.5)/ss)/size
                    x = (x-0.06)/0.88; y = (y-0.06)/0.88
                    if inside(shape, x, y, 0): f += 1; o += 1
                    elif inside(shape, x, y, ow*0.88): o += 1
            n = ss*ss
            if o == 0: row += bytes((0,0,0,0)); continue
            t = f/o
            c = [round(col[i]*t+OUTLINE[i]*(1-t)) for i in range(3)]
            row += bytes(c+[round(255*o/n)])
        rows.append(b"\0"+bytes(row))
    raw = b"".join(rows)
    def ch(t, d): return struct.pack(">I", len(d))+t+d+struct.pack(">I", zlib.crc32(t+d))
    return b"\x89PNG\r\n\x1a\n"+ch(b"IHDR", struct.pack(">IIBBBBB", size, size, 8, 6, 0, 0, 0))+ch(b"IDAT", zlib.compress(raw, 9))+ch(b"IEND", b"")
for name,(col,shape) in ICONS.items():
    for s in (64,128):
        open(os.path.join(OUT, f"icon_{name}_{s}.png"), "wb").write(render(shape, col, s))

# Placeholder line glyphs (24 px grid, one 1.5 stroke, near-white; Ui.good_icon tints them with commodity_col).
SVG_HEAD = '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#ebe7df" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">'
SVG_ICONS = {
    "silk": '<path d="M5 8c4-3 10 3 14 0M5 12c4-3 10 3 14 0M5 16c4-3 10 3 14 0"/><path d="M5 5v14M19 5v14"/>',
    "chips": None,  # hand-made file kept as is
    "ore": '<path d="M4.5 15.5L7 8l5-3.5 5.5 3 2 7-4.5 5h-8z"/><path d="M7 8l5 3.5 5.5-3.5M12 11.5V20.5"/>',
    "dross": '<path d="M5 18c0-4 3-5 3-8s3-4 5-2 4 1 4 5 2 5-2 5H7z"/><path d="M9 14h.01M14 13h.01M12 17h.01"/>',
    "nullglass": '<circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="3.5"/><path d="M6.5 6.5l11 11"/>',
    "plate": '<rect x="4" y="6" width="16" height="12" rx="1.5"/><path d="M7 9h.01M17 9h.01M7 15h.01M17 15h.01M8 12h8"/>',
    "rivets": '<circle cx="7" cy="7" r="2.2"/><circle cx="17" cy="7" r="2.2"/><circle cx="7" cy="17" r="2.2"/><circle cx="17" cy="17" r="2.2"/><circle cx="12" cy="12" r="2.2"/>',
    "cells": '<rect x="8" y="5" width="8" height="15" rx="1.5"/><path d="M10.5 3h3v2h-3zM12 9v6M9.8 12h4.4"/>',
    "armour": '<path d="M12 3.5l7 2.5v5.5c0 4.5-3 7.5-7 9-4-1.5-7-4.5-7-9V6z"/><path d="M12 3.5v17"/>',
    "musk": '<path d="M10 4h4v3h-4z"/><path d="M8 9h8l1 10.5H7z"/><path d="M10 13c1-1.2 3 1.2 4 0"/>',
    "cask": '<path d="M7 4h10c2 2.5 2 13.500 0 16H7c-2-2.500-2-13.500 0-16z"/><path d="M5.800 9h12.400M5.800 15h12.400"/>',
    "gems": '<path d="M7 5h10l4 5-9 10.500L3 10z"/><path d="M3 10h18M9.500 5L8 10l4 10.500L16 10l-1.500-5"/>',
    "ingot": '<path d="M7 7h10l3.500 10h-17z"/><path d="M9.500 11h5"/>',
    "alloy": '<path d="M3.500 14h11l2.500 5H6z"/><path d="M8 14l1.500-4.500h10L17 14M9.500 9.500L11 5h8l.5 4.500"/>',
    "spores": '<circle cx="12" cy="12" r="2.500"/><circle cx="6" cy="8" r="1.500"/><circle cx="18" cy="7" r="1.500"/><circle cx="17" cy="17.500" r="2"/><circle cx="7" cy="17" r="1.200"/>',
    "gel": '<path d="M12 3.500c4 5 6.500 8 6.500 11.500a6.500 6.500 0 0 1-13 0C5.500 11.500 8 8.500 12 3.500z"/><path d="M9 15a3 3 0 0 0 3 3"/>',
    "seed": '<path d="M12 3.500c4 3.500 5.500 7 5.500 10a5.500 5.500 0 0 1-11 0c0-3 1.500-6.500 5.500-10z"/><path d="M12 8v13M12 13l-2.500-2M12 16l2.500-2"/>',
}
for name, body in SVG_ICONS.items():
    if body is None: continue
    open(os.path.join(OUT, f"icon_{name}_64.svg"), "w").write(SVG_HEAD + body + "</svg>\n")
