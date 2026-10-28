# Rebuilds art/planets/height_<type>.png (256x128 equirect, R=height, G=crack lines) and
# planet_<type>.tres materials. Pure python, no deps. Run: python3 make_planets.py
# Height = vector-style soft shapes (blobs/craters as spherical discs) + low noise. Seamless: sampled in 3D.
import zlib, struct, math, os, random
HERE = os.path.dirname(os.path.abspath(__file__))
W, H = 256, 128
def png(path, w, h, rows):
    raw = b"".join(b"\0" + bytes(r) for r in rows)
    def ch(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    open(path, "wb").write(b"\x89PNG\r\n\x1a\n" + ch(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + ch(b"IDAT", zlib.compress(raw, 9)) + ch(b"IEND", b""))
def sm(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
def rdir(r):
    while True:
        v = [r.uniform(-1, 1) for _ in range(3)]; l = sum(c * c for c in v)
        if 0.01 < l <= 1: l = math.sqrt(l); return [c / l for c in v]
def noise_fn(seed):
    r = random.Random(seed); ws = []
    for _ in range(14):
        d = rdir(r); ws.append((d, r.uniform(2, 9), r.uniform(0, 6.28)))
    def f(p):
        return sum(math.sin((p[0]*d[0]+p[1]*d[1]+p[2]*d[2]) * k + ph) for d, k, ph in ws) / len(ws) * 2
    return f
# type: n plates, plate radius range (rad), n craters, crater radius range, noise amount
TYPES = {
  "volcanic":  dict(seed=3, plates=(26, .20, .38), craters=(4, .12, .2), noise=.10, cracks=True),
  "temperate": dict(seed=7, plates=(40, .16, .34), craters=(0, 0, 0), noise=.05, cracks=False),
  "barren":    dict(seed=11, plates=(0, 0, 0), craters=(30, .08, .26), noise=.14, cracks=False),
}
def build(name, c):
    r = random.Random(c["seed"]); nz = noise_fn(c["seed"] * 5); nz2 = noise_fn(c["seed"] * 9 + 1)
    shapes = []
    n, a, b = c["plates"]
    for _ in range(n): shapes.append(("p", rdir(r), r.uniform(a, b), r.uniform(.7, 1)))
    n, a, b = c["craters"]
    for _ in range(n): shapes.append(("c", rdir(r), r.uniform(a, b), r.uniform(.6, 1)))
    rows = []
    for y in range(H):
        row = []; th = (y + .5) / H * math.pi; sy = math.cos(th); sr = math.sin(th)
        for x in range(W):
            ph = (x + .5) / W * 2 * math.pi - math.pi
            p = (sr * math.sin(ph), sy, sr * math.cos(ph))  # matches shader uv mapping
            h = .30 + c["noise"] * nz(p)
            for k, d, rad, amp in shapes:
                ang = math.acos(max(-1, min(1, p[0]*d[0]+p[1]*d[1]+p[2]*d[2])))
                u = ang / rad
                if u >= 1.3: continue
                if k == "p":   # rounded flat-topped plate with soft edge
                    h += amp * .45 * (1 - sm(.55, 1.0, u))
                else:          # dent with a small raised lip
                    h -= amp * .28 * (1 - sm(0, .9, u)) ; h += amp * .08 * math.exp(-((u - 1.0) / .18) ** 2)
            h = max(0, min(1, h))
            g = 0
            if c["cracks"]:
                v = abs(nz2((p[0]*1.8, p[1]*1.8, p[2]*1.8)))
                g = 1 - sm(.0, .05, v)
            row += [int(h * 255 + .5), int(g * 255 + .5), 0]
        rows.append(row)
    png(os.path.join(HERE, "height_%s.png" % name), W, H, rows)
    GRID[name] = rows
GRID = {}
for k, c in TYPES.items(): build(k, c)

# palettes: base, plate, crack(glow), rim, plate threshold, displace, glow strength
PAL = {
  "volcanic":  dict(base="0.30,0.07,0.05", plate="0.95,0.5,0.1", crack="1.0,0.4,0.05", rim="0.12,0.02,0.02", thr=.52, glow=0.9),
  "temperate": dict(base="0.10,0.36,0.42", plate="0.88,0.95,0.97", crack="0,0,0", rim="0.02,0.08,0.16", thr=.50, glow=0.0),
  "barren":    dict(base="0.36,0.31,0.27", plate="0.36,0.31,0.27", crack="0,0,0", rim="0.05,0.04,0.04", thr=2.0, glow=0.0),
}
for k, p in PAL.items():
    cs = lambda s: "Color(%s, 1)" % s
    open(os.path.join(HERE, "planet_%s.tres" % k), "w").write(f'''[gd_resource type="ShaderMaterial" load_steps=3 format=3]

[ext_resource type="Shader" path="res://art/planets/planet.gdshader" id="1"]
[ext_resource type="Texture2D" path="res://art/planets/height_{k}.png" id="2"]

[resource]
shader = ExtResource("1")
shader_parameter/height_tex = ExtResource("2")
shader_parameter/base_col = {cs(p["base"])}
shader_parameter/plate_col = {cs(p["plate"])}
shader_parameter/crack_col = {cs(p["crack"])}
shader_parameter/rim_col = {cs(p["rim"])}
shader_parameter/plate_thr = {p["thr"]}
shader_parameter/glow = {p["glow"]}
''')

# ---- software preview (mirrors planet.gdshader; used because the sandbox cannot open a GPU window) ----
def pcol(s): return [float(v) for v in s.split(",")]
def sample(rows, n):
    u = (math.atan2(n[0], n[2]) / (2*math.pi) + .5) * W - .5
    v = math.acos(max(-1, min(1, n[1]))) / math.pi * H - .5
    x0 = math.floor(u); y0 = math.floor(v); fx = u - x0; fy = v - y0
    def px(x, y, ch):
        y = max(0, min(H-1, y)); return rows[y][(x % W) * 3 + ch]
    out = []
    for ch in (0, 1):
        a = px(x0, y0, ch) * (1-fx) + px(x0+1, y0, ch) * fx
        b = px(x0, y0+1, ch) * (1-fx) + px(x0+1, y0+1, ch) * fx
        out.append((a * (1-fy) + b * fy) / 255)
    return out
def nrm(v):
    l = math.sqrt(sum(c*c for c in v)); return [c/l for c in v]
def cross(a, b): return [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]
def preview(name, S=512):
    rows = GRID[name]; p = PAL[name]; DISP = .07
    base, plate, crack, rim = pcol(p["base"]), pcol(p["plate"]), pcol(p["crack"]), pcol(p["rim"])
    # planet tilt: rotate view vector instead of mesh (rx 15deg, ry 20deg)
    cx, sx, cy, sy = math.cos(.26), math.sin(.26), math.cos(.35), math.sin(.35)
    def tolocal(v):  # inverse of Ry*Rx applied to world -> local
        x, y, z = v
        x, z = cy*x - sy*z, sy*x + cy*z       # undo Ry (approx sign)
        y, z = cx*y + sx*z, -sx*y + cx*z      # undo Rx
        return [x, y, z]
    Ld = nrm([-.5, .5, .75]); Ld = nrm([.55, .45, .7])  # light from upper right front (view space)
    R = 1.0 / 3.0 * 3.0
    out = []
    zoom = 3.0 / math.sqrt(9 - 1)  # fit sphere to ~ 78% of frame
    for j in range(S):
        row = []
        for i in range(S):
            x = ((i + .5) / S * 2 - 1) * 1.28; y = (1 - (j + .5) / S * 2) * 1.28
            d2 = x*x + y*y
            if d2 >= 1:
                row += [5, 6, 10]; continue
            zv = math.sqrt(1 - d2); nv = [x, y, zv]          # view-space normal of sphere
            n = nrm(tolocal(nv)); t = sample(rows, n); h, cr = t
            up = [1, 0, 0] if abs(n[1]) > .95 else [0, 1, 0]
            tg = nrm(cross(up, n)); bt = cross(n, tg); e = .02
            def hh(m): return (sample(rows, nrm(m))[0] - .3) * DISP * 2
            gx = (hh([n[k] + tg[k]*e for k in range(3)]) - hh([n[k] - tg[k]*e for k in range(3)])) / (2*e)
            gy = (hh([n[k] + bt[k]*e for k in range(3)]) - hh([n[k] - bt[k]*e for k in range(3)])) / (2*e)
            nl = nrm([n[k] - tg[k]*gx - bt[k]*gy for k in range(3)])
            # back to view space (forward rotation): apply Rx then Ry
            a, b, c2 = nl; b, c2 = cx*b - sx*c2, sx*b + cx*c2; a, c2 = cy*a + sy*c2, -sy*a + cy*c2
            nw = [a, b, c2]
            pm = max(0, min(1, (h - (p["thr"] - .03)) / .06)); pm = pm*pm*(3-2*pm)
            col = [base[k] + (plate[k] - base[k]) * pm for k in range(3)]
            col = [c * (.8 + .4*h) for c in col]
            fres = (1 - max(0, min(1, nw[2]))) ** 2.2
            m = max(0, min(1, fres * 1.1)); col = [col[k] + (rim[k] - col[k]) * m for k in range(3)]
            diff = max(0, sum(nw[k]*Ld[k] for k in range(3)))
            lit = [col[k] * (.5 * .27 + 1.5 * diff / math.pi * 1.9) for k in range(3)]
            cg = cr * (1 - pm) * p["glow"]
            em = [crack[k] * cg * (1 - fres) + plate[k] * pm * p["glow"] * .25 * (1 - fres) for k in range(3)]
            # simple filmic-ish clamp
            row += [int(min(1, (lit[k] + em[k]) ** (1/1.6)) * 255) for k in range(3)]
        out.append(row)
    png(os.path.join(HERE, "renders", "planet_%s.png" % name), S, S, out)
if os.environ.get("PREVIEW", "1") == "1":
    for k in TYPES: preview(k)
