# Rebuilds art/textures/icons/*.png. Pure python, no deps. Run: python3 make_icons.py
import zlib, struct, math, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "textures", "icons")
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
