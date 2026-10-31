#!/usr/bin/env python3
"""Centres the sun disc in every cut frame. Plain Python, stdlib only (pngio.py decodes/encodes PNG).

Why: the sheets are AI generated, so the disc wanders from frame to frame. A crop cannot fix that.

Method (measures the disc, not the flares):
 1. Luminance (Rec.709), blurred with a 3x3 box twice, so granulation and fine flare threads fade.
 2. The disc has a bright limb and a dark-ish textured inside; outside is black with flare arcs. A plain
    brightness threshold would pick the flares, so the edge is fitted instead: for a candidate circle
    (cx, cy, r) the score is the mean, over 90 angles, of the brightness drop from just inside (r-1.5)
    to just outside (r+1.5) the circle, clipped to [0, 60]. Flares only cover some arcs, so we average
    the best 70% of the angles (trimmed mean) and flare arcs cannot pull the fit away.
 3. Search: coarse grid (step 2 px, centre within +-16 px of the frame centre, r 40..75), then a fine
    search (step 0.25 px centre, 0.25 px radius) around the best. Result is sub-pixel.
 3b. Pass 2 (whole set): the disc is one object, so its radius is constant; flares can fake a larger one and
    drag the centre. Each frame is refitted with the radius held within +-1 px of the set median.
 3c. Pass 3 (outliers): the sheets are 8 x 8 grids and the cut drift follows row and column, so each centre is
    predicted by a median-polish model (row + column effect, x and y). A frame more than 3 px from its
    prediction is a misfit (a flare ring won); it is refitted near the prediction (+-3 px, radius as pass 2).
 4. Shift: the frame moves by round(frame_centre - disc_centre) whole pixels (no resampling, so no blur),
    padded with black. Radius is never changed; its spread is only reported.
Raw frames live in art/sun/frames_raw/ (copied once, never overwritten). Centred frames go to
art/sun/frames/ with the same names. Re-run any time; input is always the raw set.
After writing, the centred frames are measured again and that residual is printed.

Usage (project root):  python3 tools/sun_center/center_frames.py [set ...]   default set: sun_flare
        (sets: sun_flare = in use, sun_storm, sun_calm = not used by the game)
        --dry   measure only, write nothing."""
import math, os, shutil, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from pngio import read_png, write_png

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FRAMES = os.path.join(ROOT, "art/sun/frames")
RAW = os.path.join(ROOT, "art/sun/frames_raw")
COUNT = 64
NANG = 90
ANG = [(math.cos(math.tau * k / NANG), math.sin(math.tau * k / NANG)) for k in range(NANG)]

def luma(px, w, h):
    return [[0.2126 * r + 0.7152 * g + 0.0722 * b for r, g, b in row] for row in px]

def blur(L, w, h):
    for _ in range(2):
        o = [[0.0] * w for _ in range(h)]
        for y in range(h):
            for x in range(w):
                s = n = 0
                for yy in range(max(0, y - 1), min(h, y + 2)):
                    for xx in range(max(0, x - 1), min(w, x + 2)):
                        s += L[yy][xx]; n += 1
                o[y][x] = s / n
        L = o
    return L

def sample(L, w, h, x, y):
    if x < 0 or y < 0 or x >= w - 1 or y >= h - 1: return 0.0
    ix, iy = int(x), int(y); fx, fy = x - ix, y - iy
    a, b = L[iy][ix], L[iy][ix + 1]; c, d = L[iy + 1][ix], L[iy + 1][ix + 1]
    return (a + (b - a) * fx) * (1 - fy) + (c + (d - c) * fx) * fy

def score(L, w, h, cx, cy, r):
    v = []
    for ca, sa in ANG:
        d = sample(L, w, h, cx + ca * (r - 1.5), cy + sa * (r - 1.5)) - sample(L, w, h, cx + ca * (r + 1.5), cy + sa * (r + 1.5))
        v.append(min(60.0, max(0.0, d)))
    v.sort()
    top = v[int(NANG * 0.3):]
    return sum(top) / len(top)

def fit_L(L, w, h):
    c0x, c0y = (w - 1) / 2.0, (h - 1) / 2.0
    best = (-1, c0x, c0y, 55)
    for cy in [c0y + i * 2 for i in range(-8, 9)]:
        for cx in [c0x + i * 2 for i in range(-8, 9)]:
            for r in range(40, 76, 2):
                s = score(L, w, h, cx, cy, r)
                if s > best[0]: best = (s, cx, cy, r)
    return refine(L, w, h, best[1], best[2], best[3], 0, 99)

def refine(L, w, h, bx, by, br, rmin, rmax):
    """Fine search around (bx, by, br); radius kept inside [rmin, rmax]. Returns cx, cy, r, score."""
    best = (score(L, w, h, bx, by, min(max(br, rmin), rmax)), bx, by, min(max(br, rmin), rmax))
    for step, span in ((0.5, 2.0), (0.25, 0.5)):
        n = int(span / step)
        cur = best
        for iy in range(-n, n + 1):
            for ix in range(-n, n + 1):
                for ir in range(-n, n + 1):
                    cx, cy, r = best[1] + ix * step, best[2] + iy * step, best[3] + ir * step
                    if r < rmin or r > rmax: continue
                    s = score(L, w, h, cx, cy, r)
                    if s > cur[0]: cur = (s, cx, cy, r)
        best = cur
    return best[1], best[2], best[3], best[0]

def fit_set(images):
    """Two passes over a whole set. Pass 1: free fit per frame. Pass 2: the disc is one object, so its
    radius is the same in every frame; flares can fake a bigger radius and drag the centre. Refit each
    frame with the radius held within +-1 px of the set median. Returns (free fits, final fits)."""
    Ls, free = [], []
    for w, h, px in images:
        L = blur(luma(px, w, h), w, h); Ls.append(L)
        free.append(fit_L(L, w, h))
    med = sorted(f[2] for f in free)[len(free) // 2]
    final = [refine(Ls[i], images[i][0], images[i][1], free[i][0], free[i][1], med, med - 1, med + 1) for i in range(len(free))]
    if len(final) == 64:
        for i in outliers(final):
            w, h = images[i][0], images[i][1]
            px, py = predict(final)[i]
            best = None
            for cy in [py + k * 0.5 for k in range(-6, 7)]:
                for cx in [px + k * 0.5 for k in range(-6, 7)]:
                    for r in [med - 1 + k * 0.25 for k in range(9)]:
                        sc = score(Ls[i], w, h, cx, cy, r)
                        if best is None or sc > best[0]: best = (sc, cx, cy, r)
            print("  outlier frame %d: refit %.2f,%.2f -> %.2f,%.2f" % (i, final[i][0], final[i][1], best[1], best[2]))
            final[i] = (best[1], best[2], best[3], best[0])
    return free, final

def predict(fits):
    """Median-polish prediction of the centre of frame i = row effect + column effect (8 x 8 sheet)."""
    out = [[0.0, 0.0] for _ in fits]
    for ax in (0, 1):
        v = [[fits[r * 8 + c][ax] for c in range(8)] for r in range(8)]
        rows, cols = [0.0] * 8, [0.0] * 8
        for _ in range(4):
            for r in range(8):
                m = sorted(v[r][c] - cols[c] for c in range(8))[3:5]; rows[r] = sum(m) / 2
            for c in range(8):
                m = sorted(v[r][c] - rows[r] for r in range(8))[3:5]; cols[c] = sum(m) / 2
        for r in range(8):
            for c in range(8): out[r * 8 + c][ax] = rows[r] + cols[c]
    return out

def outliers(fits):
    pr = predict(fits)
    return [i for i, f in enumerate(fits) if math.hypot(f[0] - pr[i][0], f[1] - pr[i][1]) > 3.0]

def shifted(px, w, h, dx, dy):
    out = [[(0, 0, 0)] * w for _ in range(h)]
    for y in range(h):
        sy = y - dy
        if 0 <= sy < h:
            for x in range(w):
                sx = x - dx
                if 0 <= sx < w: out[y][x] = px[sy][sx]
    return out

def stats(name, res, w, h):
    c0x, c0y = (w - 1) / 2.0, (h - 1) / 2.0
    dist = [math.hypot(r[0] - c0x, r[1] - c0y) for r in res]
    rad = [r[2] for r in res]
    print("%s: max centre distance %.2f px, mean %.2f px, radius min %.2f max %.2f mean %.2f (spread %.1f%%)" % (
        name, max(dist), sum(dist) / len(dist), min(rad), max(rad), sum(rad) / len(rad),
        100 * (max(rad) - min(rad)) / (sum(rad) / len(rad))))

def main():
    args = sys.argv[1:]
    dry = "--dry" in args
    sets = [a for a in args if not a.startswith("--")] or ["sun_flare"]
    os.makedirs(RAW, exist_ok=True)
    for name in sets:
        raws = []
        for i in range(COUNT):
            f = "%s_%02d.png" % (name, i)
            rp = os.path.join(RAW, f)
            if not os.path.exists(rp):
                shutil.copy2(os.path.join(FRAMES, f), rp)  # first run only: keep the raw cut
            raws.append(rp)
        imgs = [read_png(rp) for rp in raws]
        w, h = imgs[0][0], imgs[0][1]
        free, final = fit_set(imgs)
        c0x, c0y = (w - 1) / 2.0, (h - 1) / 2.0
        for i, (cx, cy, r, s) in enumerate(final):
            dx, dy = round(c0x - cx), round(c0y - cy)
            print("%s_%02d centre %.2f,%.2f radius %.2f (free fit %.2f) score %.1f shift %+d,%+d" % (name, i, cx, cy, r, free[i][2], s, dx, dy))
            if not dry:
                write_png(os.path.join(FRAMES, "%s_%02d.png" % (name, i)), w, h, shifted(imgs[i][2], w, h, dx, dy))
        stats(name + " BEFORE (free radius)", free, w, h)
        stats(name + " BEFORE (radius held)", final, w, h)
        if not dry:
            out = [read_png(os.path.join(FRAMES, "%s_%02d.png" % (name, i))) for i in range(COUNT)]
            fa, fb = fit_set(out)
            stats(name + " AFTER  (free radius)", fa, w, h)
            stats(name + " AFTER  (radius held)", fb, w, h)

if __name__ == "__main__":
    main()
