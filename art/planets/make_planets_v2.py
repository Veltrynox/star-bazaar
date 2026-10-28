# Planet models v2. Rebuilds height_<type>_v2.png (384x192 equirect, R=height, G=crack, B=cell tone),
# planet_<type>_v2.tres, and the software preview renders/planet_<type>_v2.png.
# Pure python, no deps. Run: python3 make_planets_v2.py [type ...]   (SS=2 env for supersampled preview)
# Height = layered terraces: Voronoi plates (straight sharp edges) at 3-4 levels, inset stacked tops,
# sharp-rim craters with deep floors, continuous cracks from a fine warped Voronoi (no threshold beads).
import zlib, struct, math, os, random, sys
HERE = os.path.dirname(os.path.abspath(__file__))
W = int(os.environ.get("TW", "384")); H = W // 2
SS = int(os.environ.get("SS", "1"))

def png(path, w, h, rows, ch=3):
    raw = b"".join(b"\0" + bytes(r) for r in rows)
    def c(t, d):
        x = struct.pack(">I", len(d)) + t + d
        return x + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    open(path, "wb").write(b"\x89PNG\r\n\x1a\n" + c(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + c(b"IDAT", zlib.compress(raw, 9)) + c(b"IEND", b""))
def sm(a, b, x):
    t = max(0.0, min(1.0, (x - a) / (b - a))); return t * t * (3 - 2 * t)
def nrm(v):
    l = math.sqrt(sum(c * c for c in v)); return [c / l for c in v]
def cross(a, b): return [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]]
def rdir(r):
    while True:
        v = [r.uniform(-1, 1) for _ in range(3)]; l = sum(c * c for c in v)
        if 0.01 < l <= 1: l = math.sqrt(l); return [c / l for c in v]
def noise_fn(seed, n=14, k0=2, k1=9):
    r = random.Random(seed); ws = []
    for _ in range(n): ws.append((rdir(r), r.uniform(k0, k1), r.uniform(0, 6.28)))
    return lambda p: sum(math.sin((p[0]*d[0]+p[1]*d[1]+p[2]*d[2]) * k + ph) for d, k, ph in ws) / len(ws) * 2
def seeds(r, n, mind):
    out = []
    while len(out) < n:
        d = rdir(r)
        if all(d[0]*o[0]+d[1]*o[1]+d[2]*o[2] < math.cos(mind) for o in out): out.append(d)
        elif r.random() < .02: mind *= .97
    return out
def vor2(p, S):
    # returns (best idx, second idx, angle gap d2-d1)
    b1 = b2 = -2.0; i1 = i2 = 0
    for i, s in enumerate(S):
        d = p[0]*s[0] + p[1]*s[1] + p[2]*s[2]
        if d > b1: b2, i2, b1, i1 = b1, i1, d, i
        elif d > b2: b2, i2 = d, i
    return i1, i2, math.acos(max(-1, min(1, b1))) * -1 + math.acos(max(-1, min(1, b2)))
def hsh(a, b): return random.Random(a * 7919 + b * 104729 + 13).random()

# levels: height of each level; thr = colour thresholds; weights favour clusters via seed noise
TYPES = {
 "volcanic": dict(seed=3, cells=80, mind=.22, lv=[.22, .40, .58], lvw=[.42, .36, .22], inset=[(.10, .07), (.08, .15)],
                  stack_from=2, craters=(6, .08, .20), grain=.012, crack=(0, 1), crack_depth=.10, crack_keep=.62, cw=.032,
                  fine=130),
 "temperate": dict(seed=7, cells=90, mind=.2, lv=[.22, .36, .52, .66], lvw=[.30, .24, .30, .16], inset=[(.07, .06)],
                  stack_from=3, craters=(0, 0, 0), grain=.008, crack=(2, 3), crack_depth=.07, crack_keep=.45, cw=.026,
                  fine=110),
 "barren": dict(seed=11, cells=34, mind=.3, lv=[.26, .34, .42], lvw=[.4, .35, .25], inset=[],
                stack_from=9, craters=(60, .035, .28), grain=.020, crack=(9, 9), crack_depth=0, crack_keep=0, cw=.03,
                fine=8),
}
GRID = {}
def build(name, c):
    r = random.Random(c["seed"]); nzs = noise_fn(c["seed"] * 5, 12, 1, 3); grain = noise_fn(c["seed"] * 9 + 1, 24, 12, 45)
    wa, wb, wc = (noise_fn(c["seed"] * 31 + i, 6, 2, 5) for i in range(3))
    S = seeds(r, c["cells"], c["mind"])
    # level per cell: clustered quantile of noise + jitter
    scores = [nzs(s) + r.uniform(-.35, .35) for s in S]
    order = sorted(range(len(S)), key=lambda i: scores[i]); lvl = [0] * len(S); acc = 0; tot = sum(c["lvw"])
    for rank, i in enumerate(order):
        f = (rank + .5) / len(S); a = 0
        for L, w in enumerate(c["lvw"]):
            a += w / tot
            if f <= a: lvl[i] = L; break
    tone = [r.random() for _ in S]; tilt = [r.uniform(-.015, .015) for _ in S]
    FS = seeds(r, c["fine"], .12) if c["fine"] > 0 else []
    cr = []
    n, a, b = c["craters"]
    for _ in range(n):
        # power law: many small, few big
        rad = a * (b / a) ** (r.random() ** 1.6); cr.append((rdir(r), rad, r.uniform(.8, 1)))
    cr.sort(key=lambda t: -t[1])
    w = .010
    rows = []
    for y in range(H):
        row = []; th = (y + .5) / H * math.pi; sy = math.cos(th); sr = math.sin(th)
        for x in range(W):
            ph = (x + .5) / W * 2 * math.pi - math.pi
            p = (sr * math.sin(ph), sy, sr * math.cos(ph))
            q = nrm((p[0] + .05 * wa(p), p[1] + .05 * wb(p), p[2] + .05 * wc(p)))  # slight warp: plates not perfect polygons
            i1, i2, g = vor2(q, S)
            L1, L2 = lvl[i1], lvl[i2]
            h1 = c["lv"][L1] + tilt[i1]; h2 = c["lv"][L2] + tilt[i2]
            # terraces (stacked tops) inside tall cells: shrunken copy of the polygon
            def top(L, g):
                t = 0.0
                if L >= c["stack_from"]:
                    for k, (amp, ins) in enumerate(c["inset"]):
                        t += amp * sm(ins - w, ins + w, g)
                return t
            h1 += top(L1, g); h2 += top(L2, 0.0)
            t = .5 + .5 * sm(0, w * 2, g)
            h = h2 + (h1 - h2) * t
            cell = i1 if t > .5 else i2
            h += c["grain"] * grain(p)
            # cracks: fine warped Voronoi borders, broken by a per-edge hash, continuous
            cm = 0.0
            if FS and c["crack"][0] <= L1 <= c["crack"][1] and g > .04:
                f1, f2, fg = vor2(q, FS)
                if hsh(min(f1, f2), max(f1, f2)) < c["crack_keep"]:
                    cm = 1 - sm(c["cw"] * .35, c["cw"], fg)
                    cm *= sm(.02, .06, g)   # fade out before plate cliffs
            h -= cm * c["crack_depth"]
            for d, rad, amp in cr:
                ang = math.acos(max(-1, min(1, p[0]*d[0]+p[1]*d[1]+p[2]*d[2])))
                u = ang / rad
                if u >= 1.2: continue
                bowl = 1 - sm(.62, .93, u)
                rim = sm(.72, .96, u) * (1 - sm(1.0, 1.16, u))
                peak = (1 - sm(0, .25, u)) * .06 if rad > .14 else 0
                h += -amp * (.14 + .20 * min(1, rad / .2)) * bowl + amp * .13 * rim + peak * bowl
                cm *= 1 - bowl
            h = max(0, min(1, h))
            tn = tone[cell]
            row += [int(h * 63 + .5) * 4, int(cm * 15 + .5) * 17, int(tn * 7 + .5) * 36]
        rows.append(row)
    png(os.path.join(HERE, "height_%s_v2.png" % name), W, H, rows)
    GRID[name] = rows

# palette: a,b,c,d layer colours (low to top), e accent patch, crack, crack_hot, rim, halo
PAL = {
 "volcanic": dict(a="0.165,0.045,0.035", b="0.43,0.13,0.07", c="0.82,0.34,0.08", d="1.0,0.66,0.2", e="0.17,0.15,0.14",
                  crack="1.0,0.38,0.05", hot="1.0,0.8,0.3", rim="0.10,0.02,0.02", halo="1.0,0.35,0.08",
                  t=(.31, .49, .64), acc=(0.0, .31), acc_amt=.85, pole=0.0, glow=1.1, crack_dark=0.0, halo_k=.55, bump=1.0),
 "temperate": dict(a="0.05,0.25,0.34", b="0.12,0.46,0.52", c="0.42,0.62,0.42", d="0.88,0.95,0.97", e="0.74,0.68,0.46",
                   crack="0.03,0.12,0.2", hot="0,0,0", rim="0.02,0.08,0.16", halo="0.35,0.75,1.0",
                   t=(.29, .44, .60), acc=(.44, .60), acc_amt=.85, pole=1.0, glow=0.0, crack_dark=.85, halo_k=.5, bump=1.0),
 "barren": dict(a="0.22,0.17,0.14", b="0.40,0.32,0.25", c="0.62,0.52,0.40", d="0.62,0.52,0.40", e="0.66,0.58,0.46",
                crack="0.1,0.08,0.07", hot="0,0,0", rim="0.05,0.04,0.04", halo="0.7,0.62,0.52",
                t=(.30, .38, .90), acc=(.30, .48), acc_amt=.6, pole=0.0, glow=0.0, crack_dark=.0, halo_k=.22, bump=1.0),
}
def write_tres(k, p):
    cs = lambda s: "Color(%s, 1)" % s
    open(os.path.join(HERE, "planet_%s_v2.tres" % k), "w").write(f'''[gd_resource type="ShaderMaterial" load_steps=3 format=3]

[ext_resource type="Shader" path="res://art/planets/planet_v2.gdshader" id="1"]
[ext_resource type="Texture2D" path="res://art/planets/height_{k}_v2.png" id="2"]

[resource]
shader = ExtResource("1")
shader_parameter/height_tex = ExtResource("2")
shader_parameter/col_a = {cs(p["a"])}
shader_parameter/col_b = {cs(p["b"])}
shader_parameter/col_c = {cs(p["c"])}
shader_parameter/col_d = {cs(p["d"])}
shader_parameter/col_e = {cs(p["e"])}
shader_parameter/crack_col = {cs(p["crack"])}
shader_parameter/crack_hot = {cs(p["hot"])}
shader_parameter/rim_col = {cs(p["rim"])}
shader_parameter/thr = Vector3({p["t"][0]}, {p["t"][1]}, {p["t"][2]})
shader_parameter/acc_range = Vector2({p["acc"][0]}, {p["acc"][1]})
shader_parameter/acc_amt = {p["acc_amt"]}
shader_parameter/pole_frost = {p["pole"]}
shader_parameter/glow = {p["glow"]}
shader_parameter/crack_dark = {p["crack_dark"]}
shader_parameter/bump = {p["bump"]}
''')
    open(os.path.join(HERE, "halo_%s_v2.tres" % k), "w").write(f'''[gd_resource type="ShaderMaterial" load_steps=2 format=3]

[ext_resource type="Shader" path="res://art/planets/halo_v2.gdshader" id="1"]

[resource]
shader = ExtResource("1")
shader_parameter/halo_col = {cs(p["halo"])}
shader_parameter/strength = {p["halo_k"]}
''')

# ---- software preview, mirrors planet_v2.gdshader + halo_v2.gdshader (no GPU window in the sandbox) ----
def pcol(s): return [float(v) for v in s.split(",")]
def sample(rows, n):
    u = (math.atan2(n[0], n[2]) / (2*math.pi) + .5) * W - .5
    v = math.acos(max(-1, min(1, n[1]))) / math.pi * H - .5
    x0 = math.floor(u); y0 = math.floor(v); fx = u - x0; fy = v - y0
    def px(x, y):
        y = max(0, min(H-1, y)); i = (x % W) * 3; return rows[y][i:i+3]
    a, b, c2, d = px(x0, y0), px(x0+1, y0), px(x0, y0+1), px(x0+1, y0+1)
    return [((a[k]*(1-fx) + b[k]*fx) * (1-fy) + (c2[k]*(1-fx) + d[k]*fx) * fy) / 255 for k in range(3)]
DISP = .06
def preview(name, S=512):
    rows = GRID[name]; p = PAL[name]
    cols = {k: pcol(p[k]) for k in ("a", "b", "c", "d", "e", "crack", "hot", "rim", "halo")}
    t1, t2, t3 = p["t"]
    cx, sx, cy, sy = math.cos(.26), math.sin(.26), math.cos(.35), math.sin(.35)
    def tolocal(v):
        x, y, z = v
        x, z = cy*x - sy*z, sy*x + cy*z
        y, z = cx*y + sx*z, -sx*y + cx*z
        return [x, y, z]
    Ld = nrm([.55, .45, .7])
    bg = [5, 6, 10]
    out = []
    # supersample on a SS grid, average
    for j in range(S):
        row = []
        for i in range(S):
            acc = [0.0, 0.0, 0.0]
            for sj in range(SS):
                for si in range(SS):
                    x = ((i + (si + .5) / SS) / S * 2 - 1) * 1.28; y = (1 - (j + (sj + .5) / SS) / S * 2) * 1.28
                    c = shade(rows, p, cols, t1, t2, t3, x, y, tolocal, cx, sx, cy, sy, Ld)
                    for k in range(3): acc[k] += c[k]
            row += [int(min(1, (acc[k] / (SS*SS)) ) ** (1/1.6) * 255) for k in range(3)] if False else [int(min(1.0, max(0.0, acc[k] / (SS*SS))) * 255) for k in range(3)]
        out.append(row)
    png(os.path.join(HERE, "renders", "planet_%s_v2.png" % name), S, S, out)
def shade(rows, p, cols, t1, t2, t3, x, y, tolocal, cx, sx, cy, sy, Ld):
    bgc = [5/255, 6/255, 10/255]
    d2 = x*x + y*y
    if d2 >= 1:
        # halo shell radius 1.2: fresnel falloff, additive
        Rs = 1.2; rho2 = d2 / (Rs*Rs)
        if rho2 < 1:
            nv = math.sqrt(1 - rho2); a = (nv ** 2.2) * p["halo_k"]
            a *= 0.55 + 0.45 * max(0, min(1, (x*Ld[0] + y*Ld[1]) / math.sqrt(d2) * .5 + .5))  # lit side stronger (preview only; shader is uniform)
            hc = cols["halo"]
            return [bgc[k] + hc[k] * a * a * 1.1 for k in range(3)] if False else [min(1, bgc[k] + hc[k] * a) for k in range(3)]
        return bgc
    zv = math.sqrt(1 - d2); nv = [x, y, zv]
    n = nrm(tolocal(nv)); h, cr, tn = sample(rows, n)
    up = [1, 0, 0] if abs(n[1]) > .95 else [0, 1, 0]
    tg = nrm(cross(up, n)); bt = cross(n, tg); e = .012
    def hh(m): return sample(rows, nrm(m))[0]
    h1 = hh([n[k] + tg[k]*e for k in range(3)]); h0 = hh([n[k] - tg[k]*e for k in range(3)])
    v1 = hh([n[k] + bt[k]*e for k in range(3)]); v0 = hh([n[k] - bt[k]*e for k in range(3)])
    amp = DISP * 2 * p["bump"] * 2.2
    gx = (h1 - h0) * amp / (2*e); gy = (v1 - v0) * amp / (2*e)
    nl = nrm([n[k] - tg[k]*gx - bt[k]*gy for k in range(3)])
    a, b, c2 = nl; b, c2 = cx*b - sx*c2, sx*b + cx*c2; a, c2 = cy*a + sy*c2, -sy*a + cy*c2
    nw = [a, b, c2]
    avg = (h1 + h0 + v1 + v0) / 4
    # layer colours
    sw = lambda t: sm(t - .018, t + .018, h)
    w1, w2, w3 = sw(t1), sw(t2), sw(t3)
    mix = lambda A, B, t: [A[k] + (B[k] - A[k]) * t for k in range(3)]
    col = mix(mix(mix(cols["a"], cols["b"], w1), cols["c"], w2), cols["d"], w3)
    lo, hi = p["acc_range"] if "acc_range" in p else p["acc"]
    am = sm(lo - .02, lo + .02, h) * (1 - sm(hi - .02, hi + .02, h)) * sm(.70, .74, tn) * p["acc_amt"]
    col = mix(col, cols["e"], am)
    if p["pole"] > 0:
        pole = sm(.80, .84, abs(n[1]) + (tn - .5) * .12 + (h - .4) * .3) * p["pole"]; col = mix(col, cols["d"], pole)
    col = [c * (.84 + .32 * tn) for c in col]
    cav = max(0, avg - h) ; cvx = max(0, h - avg)
    ao = 1 - min(.45, cav * 8); hl = 1 + min(.5, cvx * 10)
    col = [c * ao * hl for c in col]
    # cracks
    if p["crack_dark"] > 0: col = mix(col, cols["crack"], cr * p["crack_dark"])
    fres = (1 - max(0, min(1, nw[2]))) ** 2.2
    m = max(0, min(1, fres * 1.0)); col = mix(col, cols["rim"], m)
    diff = max(0, sum(nw[k]*Ld[k] for k in range(3)))
    lit = [col[k] * (.5 * .27 + 1.5 * diff / math.pi * 1.9) for k in range(3)]
    em = [0, 0, 0]
    if p["glow"] > 0:
        core = cr ** 3
        ec = mix(cols["crack"], cols["hot"], core)
        em = [ec[k] * cr * p["glow"] * (1 - fres) for k in range(3)]
        # lit edges: amber layers glow faintly
        em = [em[k] + cols["d"][k] * w3 * .10 * (1 - fres) for k in range(3)]
    res = [(lit[k] + em[k]) for k in range(3)]
    res = [min(1.0, r) ** (1/1.35) for r in res]
    # halo also overlaps the planet silhouette edge slightly
    return res

if __name__ == "__main__":
    names = sys.argv[1:] or list(TYPES)
    for k in names:
        build(k, TYPES[k]); write_tres(k, PAL[k]); preview(k)
