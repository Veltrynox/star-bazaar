"""Minimal 8-bit RGB/RGBA/gray PNG reader and RGB writer, stdlib only (zlib, struct)."""
import struct, zlib

def read_png(path):
    d = open(path, "rb").read()
    assert d[:8] == b"\x89PNG\r\n\x1a\n", "not a PNG"
    p, idat, hdr = 8, b"", None
    while p < len(d):
        n, t = struct.unpack(">I4s", d[p:p + 8])
        body = d[p + 8:p + 8 + n]
        if t == b"IHDR": hdr = struct.unpack(">IIBBBBB", body)
        elif t == b"IDAT": idat += body
        p += 12 + n
    w, h, depth, ctype, _, _, il = hdr
    assert depth == 8 and il == 0 and ctype in (0, 2, 6), "unsupported PNG"
    bpp = {0: 1, 2: 3, 6: 4}[ctype]
    raw, stride = zlib.decompress(idat), w * bpp
    out, prev, q = [], bytearray(stride), 0
    for _ in range(h):
        f, row = raw[q], bytearray(raw[q + 1:q + 1 + stride]); q += 1 + stride
        for i in range(stride):
            a = row[i - bpp] if i >= bpp else 0
            b, c = prev[i], (prev[i - bpp] if i >= bpp else 0)
            if f == 1: row[i] = (row[i] + a) & 255
            elif f == 2: row[i] = (row[i] + b) & 255
            elif f == 3: row[i] = (row[i] + ((a + b) >> 1)) & 255
            elif f == 4:
                pa, pb, pc = abs(b - c), abs(a - c), abs(a + b - 2 * c)
                row[i] = (row[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        out.append(row); prev = row
    # return rows of (r,g,b) tuples
    px = []
    for row in out:
        if bpp == 1: px.append([(v, v, v) for v in row])
        else: px.append([tuple(row[i:i + 3]) for i in range(0, stride, bpp)])
    return w, h, px

def write_png(path, w, h, px):
    raw = b"".join(b"\x00" + bytes(c for p in row for c in p) for row in px)
    def chunk(t, b):
        c = struct.pack(">I", len(b)) + t + b
        return c + struct.pack(">I", zlib.crc32(t + b) & 0xFFFFFFFF)
    open(path, "wb").write(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                           + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))
