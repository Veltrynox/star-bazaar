# Rebuilds art/textures/ui/*.png. Pure python, no deps. Run: python3 make_ui.py
import zlib, struct, math, os
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "textures", "ui")
os.makedirs(OUT, exist_ok=True)
def png(name, w, h, px):
    raw = b"".join(b"\0" + bytes(c for p in px[y*w:(y+1)*w] for c in p) for y in range(h))
    def ch(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    open(os.path.join(OUT, name), "wb").write(b"\x89PNG\r\n\x1a\n" + ch(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)) + ch(b"IDAT", zlib.compress(raw, 9)) + ch(b"IEND", b""))
def mix(a, b, t): return tuple(a[i]+(b[i]-a[i])*t for i in range(3))
def over(dst, col, a):  # dst rgba floats, col rgb, a 0..1
    oa = a + dst[3]*(1-a)
    if oa <= 0: return (0,0,0,0)
    return tuple((col[i]*a + dst[i]*dst[3]*(1-a))/oa for i in range(3)) + (oa,)
def fin(p): return (int(p[0]+.5), int(p[1]+.5), int(p[2]+.5), int(p[3]*255+.5))
def smooth(d): return max(0.0, min(1.0, 0.5 - d))  # d in pixels, signed distance
# (a) glass panel 48x48, radius 8, 9-slice margin 10
def panel():
    S = 48; R = 8; px = []
    for y in range(S):
        row = []
        for x in range(S):
            cx = min(max(x+.5, R), S-R); cy = min(max(y+.5, R), S-R)
            d = math.hypot(x+.5-cx, y+.5-cy) - R   # <0 inside
            cov = smooth(d)
            ring = smooth(abs(d+0.5) - 0.5)          # 1px border
            top = max(0, 1 - y/20.0)                 # faint top light
            fill = (14+10*top, 18+12*top, 28+16*top)
            p = (fill[0], fill[1], fill[2], 0.82*cov)
            p = over(p, (170, 182, 204), 0.34*ring*(0.7+0.6*top))
            row.append(fin(p))
        px += row
    png("ui_panel_glass.png", S, S, px)
# (b) header strip 320x96: dark horizon with soft light
def header():
    W, H = 320, 96; hz = 62; px = []
    for y in range(H):
        for x in range(W):
            if y < hz:
                t = y/hz
                c = mix((10, 14, 24), (30, 38, 56), t**2)
                g = math.exp(-(((x-210)/90.0)**2 + ((y-hz)/26.0)**2))
                c = mix(c, (255, 201, 120), 0.55*g)
                if ((x*73856093 ^ y*19349663) * 2654435761 >> 7) % 260 == 0 and y < hz-12: c = (200, 210, 230)
            else:
                t = (y-hz)/(H-hz)
                c = mix((16, 20, 30), (6, 8, 14), t)
                g = math.exp(-(((x-210)/70.0)**2 + ((y-hz)/5.0)**2))
                c = mix(c, (255, 201, 120), 0.35*g)
            edge = abs(y-hz+0.5) < 0.8
            if edge: c = mix(c, (170, 182, 204), 0.35)
            px.append(fin(c + (1.0,)))
    png("ui_header_horizon.png", W, H, px)
# (c) round thumbs 96px, thin ring, one per planet type (volcanic, temperate, barren)
def hsh(i, j, sd):
    n = (i*374761393 + j*668265263 + sd*2147483647) & 0xffffffff
    n = ((n ^ (n >> 13)) * 1274126177) & 0xffffffff
    return ((n ^ (n >> 16)) & 0xffff) / 65535.0
def vnoise(x, y, sd):
    i, j = math.floor(x), math.floor(y); fx, fy = x-i, y-j
    fx = fx*fx*(3-2*fx); fy = fy*fy*(3-2*fy)
    a = hsh(i, j, sd); b = hsh(i+1, j, sd); c = hsh(i, j+1, sd); d = hsh(i+1, j+1, sd)
    return (a+(b-a)*fx) + ((c+(d-c)*fx) - (a+(b-a)*fx))*fy
def fbm(x, y, sd):
    return 0.55*vnoise(x, y, sd) + 0.3*vnoise(2*x, 2*y, sd+1) + 0.15*vnoise(4*x, 4*y, sd+2)
CRATERS = [(-0.35, -0.30, 0.20), (0.30, -0.45, 0.13), (0.15, 0.10, 0.24), (-0.45, 0.35, 0.15), (0.50, 0.40, 0.12), (-0.05, -0.68, 0.09), (0.0, 0.62, 0.10)]
def surf_volcanic(u, v):
    x, y = u/44.0, v/44.0
    c = mix((26, 18, 20), (52, 34, 30), fbm(x*3.2+5, y*3.2, 11))      # dark crust
    n = fbm(x*4.0, y*4.0, 21)
    crack = max(0.0, 1 - abs(n-0.5)/0.035)                              # thin glowing cracks
    crack = crack**1.5
    c = mix(c, (255, 120, 40), min(1, crack))
    return mix(c, (255, 190, 80), max(0, crack-0.6)*1.2)
def surf_temperate(u, v):
    x, y = u/44.0, v/44.0
    h = fbm(x*2.6+3, y*2.6, 31)
    c = (mix((28, 90, 150), (46, 130, 120), (h-0.45)*5) if h < 0.5 else mix((46, 130, 120), (92, 160, 100), min(1, (h-0.5)*6)))
    cl = max(0.0, min(1, (fbm(x*3.0+9, y*5.0, 41)-0.5)*4.0))            # soft clouds
    return mix(c, (232, 240, 248), 0.8*cl)
def surf_barren(u, v):
    x, y = u/44.0, v/44.0
    c = mix((96, 84, 74), (128, 112, 96), fbm(x*5+2, y*5, 51))
    for cx, cy, r in CRATERS:
        d = math.hypot(x-cx, y-cy)/r
        if d < 1: c = mix(c, (62, 54, 48), 0.85*(1-d*d*0.35))
        if 1 <= d < 1.25: c = mix(c, (150, 134, 116), 0.6*(1-(d-1)/0.25))   # lit rim
    return c
def thumb(name, surf, shade, ringc=(200, 210, 225)):
    S = 96; ss = 3; R = 44; px = []
    for y in range(S):
        for x in range(S):
            acc = [0, 0, 0, 0]
            for sy in range(ss):
                for sx in range(ss):
                    u = x+(sx+.5)/ss-S/2; v = y+(sy+.5)/ss-S/2
                    d = math.hypot(u, v)
                    if d > R+1: continue
                    cov = smooth(d-R) if d > R-1 else 1.0
                    c = surf(u, v)
                    if d <= R-1.5:
                        lx = (u*-0.6 + v*-0.8)/R
                        c = mix(c, shade, max(0, min(1, 0.5+0.55*(-lx)))*0.85)  # dark away from top-left light
                    ring = smooth(abs(d-(R-0.5))-0.5)
                    c = mix(c, ringc, 0.8*ring)
                    acc[0]+=c[0]*cov; acc[1]+=c[1]*cov; acc[2]+=c[2]*cov; acc[3]+=cov
            n = ss*ss
            a = acc[3]/n
            px.append(fin((acc[0]/acc[3], acc[1]/acc[3], acc[2]/acc[3], a)) if acc[3] else (0,0,0,0))
    png(name, S, S, px)
# (d) glyphs 32px, 2px stroke, amber and grey
def seg_d(px_, py_, a, b):
    ax, ay = a; bx, by = b; dx, dy = bx-ax, by-ay
    t = max(0, min(1, ((px_-ax)*dx+(py_-ay)*dy)/(dx*dx+dy*dy)))
    return math.hypot(px_-ax-t*dx, py_-ay-t*dy)
def glyph(name, col, segs, sw=1.0, S=32, ss=3):
    px = []
    for y in range(S):
        for x in range(S):
            a = 0
            for sy in range(ss):
                for sx in range(ss):
                    X = x+(sx+.5)/ss; Y = y+(sy+.5)/ss
                    d = min(seg_d(X, Y, s[0], s[1]) for s in segs)
                    a += smooth(d-sw)
            a /= ss*ss
            px.append(fin(col + (a,)))
    png(name, S, S, px)
def main():
    panel(); header()
    thumb("ui_thumb_volcanic.png", surf_volcanic, (8, 6, 12))
    thumb("ui_thumb_temperate.png", surf_temperate, (6, 14, 28))
    thumb("ui_thumb_barren.png", surf_barren, (12, 10, 16))
    for cn, col in (("amber", (255, 201, 51)), ("grey", (138, 148, 166))):
        glyph(f"ui_glyph_pause_{cn}.png", col, [((11,8),(11,24)), ((21,8),(21,24))])
        glyph(f"ui_glyph_chevron_{cn}.png", col, [((12,7),(20,16)), ((20,16),(12,25))])
main()
