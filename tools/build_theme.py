#!/usr/bin/env python3
"""Builds design/theme/star_bazaar.tres (the one Godot Theme) from the design system tokens.json.
To swap the design: replace design/star-bazaar-design-system/, then run  python3 tools/build_theme.py
Also writes white icon copies to design/theme/icons/ (currentColor -> white, tinted in the theme)."""
import json, os, re, glob
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DS = os.path.join(ROOT, "design", "star-bazaar-design-system", "star-bazaar-design-system")
OUT = os.path.join(ROOT, "design", "theme")
tok = json.load(open(os.path.join(DS, "tokens.json")))
C = {t["name"]: t["value"] for t in tok["color"]["tokens"]}
SP = {t["name"]: int(t["value"][:-2]) for t in tok["spacing"]["tokens"]}
RAD = {t["name"]: int(t["value"][:-2]) for t in tok["radius"]["tokens"]}
TY = {s["name"]: s for g in tok["type"]["groups"] for s in g["styles"]}

def col(name_or_hex, alpha=None):
    h = C.get(name_or_hex, name_or_hex).lstrip("#")
    r, g, b = (int(h[i:i+2], 16) / 255 for i in (0, 2, 4))
    a = int(h[6:8], 16) / 255 if len(h) == 8 else 1.0
    if alpha is not None: a = alpha
    return "Color(%.4f, %.4f, %.4f, %.4f)" % (r, g, b, a)

def px(s): return int(float(s["fontSize"][:-2]))
def em(s): return float(s["letterSpacing"][:-2])

# icons
os.makedirs(os.path.join(OUT, "icons"), exist_ok=True)
icons = []
for f in sorted(glob.glob(os.path.join(DS, "icons", "*.svg"))):
    n = os.path.basename(f)[:-4]
    open(os.path.join(OUT, "icons", n + ".svg"), "w").write(open(f).read().replace("currentColor", "#ffffff"))
    icons.append(n)

ext, sub, props = [], [], []
def add_ext(kind, path):
    ext.append('[ext_resource type="%s" path="%s" id="%d"]' % (kind, path, len(ext) + 1)); return 'ExtResource("%d")' % len(ext)
def add_sub(kind, body):
    sid = "r%d" % (len(sub) + 1)
    sub.append('[sub_resource type="%s" id="%s"]\n%s\n' % (kind, sid, "\n".join(body))); return 'SubResource("%s")' % sid

FONT_DIR = os.path.join(ROOT, "design", "fonts")
FILES = {"body": "Jost/static/Jost-Regular.ttf", "button": "Jost/static/Jost-Medium.ttf", "panel-title": "Jost/static/Jost-Medium.ttf",
         "panel-caption": "Jost/static/Jost-Regular.ttf", "map-faction": "Jost/static/Jost-Medium.ttf",
         "readout": "JetBrains_Mono/static/JetBrainsMono-Regular.ttf", "readout-sm": "JetBrains_Mono/static/JetBrainsMono-Regular.ttf"}
font_ext = {}
def font(key, spacing_em, size):
    rel = FILES[key]
    if not os.path.exists(os.path.join(FONT_DIR, rel)): raise SystemExit("missing font file: " + rel)
    if rel not in font_ext:
        font_ext[rel] = add_ext("FontFile", "res://design/fonts/" + rel)
    return add_sub("FontVariation", ['base_font = ' + font_ext[rel], 'spacing_glyph = %d' % round(spacing_em * size)])
F = {}
for k in FILES:
    F[k] = font(k, em(TY[k]), px(TY[k]))
# numbers use the mono face
F["number"] = F["readout"]

def box(bg, border=None, bw=1, radius=6, margin=(12, 6), shadow=None, bottom_only=False):
    b = ['bg_color = ' + col(bg)]
    if border:
        if bottom_only: b.append('border_width_bottom = %d' % bw)
        else: b += ['border_width_left = %d' % bw, 'border_width_top = %d' % bw, 'border_width_right = %d' % bw, 'border_width_bottom = %d' % bw]
        b.append('border_color = ' + col(border))
    for c in ("top_left", "top_right", "bottom_right", "bottom_left"): b.append('corner_radius_%s = %d' % (c, radius))
    b += ['content_margin_left = %d' % margin[0], 'content_margin_top = %d' % margin[1],
          'content_margin_right = %d' % margin[0], 'content_margin_bottom = %d' % margin[1], 'anti_aliasing = true']
    if shadow: b += ['shadow_color = ' + col(shadow[0]), 'shadow_size = %d' % shadow[1], 'shadow_offset = Vector2(0, %d)' % shadow[2]]
    return add_sub("StyleBoxFlat", b)
def line_box(c):
    return add_sub("StyleBoxLine", ['color = ' + col(c), 'thickness = 1'])
def empty(): return add_sub("StyleBoxEmpty", [])

def P(t, k, v): props.append("%s/%s = %s" % (t, k, v))
def button_type(t, normal, hover, pressed, disabled, focus, font_c, hover_c, icon_c=None):
    P(t, "styles/normal", normal); P(t, "styles/hover", hover); P(t, "styles/pressed", pressed)
    P(t, "styles/disabled", disabled); P(t, "styles/focus", focus)
    P(t, "fonts/font", F["button"]); P(t, "font_sizes/font_size", px(TY["button"]))
    P(t, "colors/font_color", col(font_c)); P(t, "colors/font_hover_color", col(hover_c))
    P(t, "colors/font_pressed_color", col(hover_c)); P(t, "colors/font_focus_color", col(font_c))
    P(t, "colors/font_hover_pressed_color", col(hover_c))
    P(t, "colors/font_disabled_color", col("ink-subtle"))
    for s, c in (("normal", icon_c or "ink-muted"), ("hover", "ink"), ("pressed", "ink"), ("focus", icon_c or "ink-muted"), ("disabled", "ink-subtle")):
        P(t, "colors/icon_%s_color" % s, col(c))
    P(t, "constants/h_separation", SP["space-2"])

PADB = (SP["space-3"] + 2, SP["space-2"])
sec_n = box("panel-100", "line-200", 1, RAD["radius-md"], PADB)
sec_h = box("panel-200", "line-300", 1, RAD["radius-md"], PADB)
sec_p = box("panel-300", "line-300", 1, RAD["radius-md"], PADB)
sec_d = box("panel-100", "line-100", 1, RAD["radius-md"], PADB)
sec_f = box("panel-100", "star-warm", 1, RAD["radius-md"], PADB)
button_type("Button", sec_n, sec_h, sec_p, sec_d, sec_f, "ink", "ink")
# Primary
pri = lambda bg, line: box(bg, "star-warm", 1, RAD["radius-md"], PADB, shadow=("#f1d4a02e", 8, 0))
props.append("")
props.append("ButtonPrimary/base_type = &\"Button\"")
button_type("ButtonPrimary", pri("panel-100", ""), box("panel-200", "star-warm", 1, RAD["radius-md"], PADB, shadow=("#f1d4a066", 12, 0)),
            box("panel-300", "star-warm", 1, RAD["radius-md"], PADB), sec_d, sec_f, "star-warm", "star-core", "star-warm")
props.append("ButtonPrimaryLarge/base_type = &\"Button\"")
LG = (SP["space-4"] + 4, SP["space-3"] + 2)
button_type("ButtonPrimaryLarge", box("panel-100", "star-warm", 1, RAD["radius-md"], LG, shadow=("#f1d4a02e", 8, 0)),
            box("panel-200", "star-warm", 1, RAD["radius-md"], LG, shadow=("#f1d4a066", 12, 0)),
            box("panel-300", "star-warm", 1, RAD["radius-md"], LG), box("panel-100", "line-100", 1, RAD["radius-md"], LG),
            box("panel-100", "star-warm", 1, RAD["radius-md"], LG), "star-warm", "star-core", "star-warm")
P("ButtonPrimaryLarge", "font_sizes/font_size", 17)
RL = (8, 8)
props.append("ButtonRail/base_type = &\"Button\"")
button_type("ButtonRail", box("#00000000", None, 0, 12, RL), box("#ffffff14", None, 0, 12, RL), box("#ffffff22", None, 0, 12, RL),
            box("#00000000", None, 0, 12, RL), box("#ffffff14", "star-warm", 1, 12, RL), "ink-muted", "ink")
ghost_n = box("#00000000", None, 0, RAD["radius-md"], PADB)
props.append("ButtonGhost/base_type = &\"Button\"")
button_type("ButtonGhost", ghost_n, box("panel-200", "line-200", 1, RAD["radius-md"], PADB), sec_p, box("#00000000", None, 0, RAD["radius-md"], PADB), sec_f, "ink-muted", "ink")
props.append("ButtonDanger/base_type = &\"Button\"")
button_type("ButtonDanger", sec_n, box("panel-200", "signal-bad", 1, RAD["radius-md"], PADB), box("panel-300", "signal-bad", 1, RAD["radius-md"], PADB), sec_d, sec_f, "ink", "signal-bad")
props.append("ButtonSmall/base_type = &\"Button\"")
SM = (SP["space-2"] + 2, SP["space-1"])
button_type("ButtonSmall", box("panel-100", "line-200", 1, RAD["radius-md"], SM), box("panel-200", "line-300", 1, RAD["radius-md"], SM),
            box("panel-300", "line-300", 1, RAD["radius-md"], SM), box("panel-100", "line-100", 1, RAD["radius-md"], SM),
            box("panel-100", "star-warm", 1, RAD["radius-md"], SM), "ink", "ink")
P("ButtonSmall", "font_sizes/font_size", 13)

# Labels
P("Label", "fonts/font", F["body"]); P("Label", "font_sizes/font_size", px(TY["body"]))
P("Label", "colors/font_color", col("ink")); P("Label", "constants/line_spacing", 2)
def label_var(name, fontkey, size, color):
    props.append(""); props.append('%s/base_type = &"Label"' % name)
    P(name, "fonts/font", F[fontkey]); P(name, "font_sizes/font_size", size); P(name, "colors/font_color", col(color))
label_var("LabelHero", "panel-title", 40, "ink")
label_var("LabelTitle", "panel-title", px(TY["panel-title"]), "ink")
label_var("LabelHeading", "panel-title", 17, "ink")
label_var("LabelStrong", "body", 15, "ink")
label_var("LabelSmall", "body", 12, "ink-muted")
label_var("LabelCaption", "panel-caption", px(TY["panel-caption"]), "ink-muted")
label_var("LabelMuted", "body", px(TY["body"]), "ink-muted")
label_var("LabelAccent", "body", px(TY["body"]), "star-warm")
label_var("LabelInfo", "body", px(TY["body"]), "signal-info")
label_var("LabelGood", "body", px(TY["body"]), "signal-good")
label_var("LabelWarn", "body", px(TY["body"]), "signal-warn")
label_var("LabelBad", "body", px(TY["body"]), "signal-bad")
label_var("LabelReadout", "readout", px(TY["readout"]), "cash")
label_var("LabelNumber", "number", 15, "ink")
label_var("LabelNumberMuted", "number", 12, "ink-muted")
label_var("LabelNumberAccent", "number", 15, "star-warm")

# Panels: glass = dark translucent, 1 px light border, 8 px corners
GLASS_M = (SP["space-4"], SP["space-4"] - 4)
def glass(alpha=0.78, radius=8, margin=GLASS_M, shadow=True):
    b = ['bg_color = ' + col("void-100", alpha)]
    b += ['border_width_%s = 1' % s for s in ("left", "top", "right", "bottom")]
    b.append('border_color = ' + col("ink", 0.16))
    for c in ("top_left", "top_right", "bottom_right", "bottom_left"): b.append('corner_radius_%s = %d' % (c, radius))
    b += ['content_margin_left = %d' % margin[0], 'content_margin_top = %d' % margin[1],
          'content_margin_right = %d' % margin[0], 'content_margin_bottom = %d' % margin[1], 'anti_aliasing = true']
    if shadow: b += ['shadow_color = ' + col("#000000", 0.45), 'shadow_size = 16', 'shadow_offset = Vector2(0, 6)']
    return add_sub("StyleBoxFlat", b)
props.append("")
P("PanelContainer", "styles/panel", glass())
props.append('PanelBar/base_type = &"PanelContainer"')
P("PanelBar", "styles/panel", glass(0.55, 0, (SP["space-5"] - 8, 6), shadow=False))
props.append('PanelFlat/base_type = &"PanelContainer"')
P("PanelFlat", "styles/panel", glass(0.6, 8, GLASS_M, shadow=False))
props.append('PanelRail/base_type = &"PanelContainer"')
P("PanelRail", "styles/panel", glass(0.7, 16, (6, 8)))
P("Panel", "styles/panel", glass(0.78, 8, (SP["space-4"], SP["space-4"])))
# Dialogs and popups
dlg = box("void-100", "line-300", 1, RAD["radius-lg"], (SP["space-4"], SP["space-4"]), shadow=("#00000099", 32, 12))
P("Window", "styles/embedded_border", dlg); P("Window", "styles/embedded_unfocused_border", dlg)
P("Window", "colors/title_color", col("ink")); P("Window", "constants/title_height", 28)
P("Window", "fonts/title_font", F["panel-title"]); P("Window", "font_sizes/title_font_size", 16)
P("AcceptDialog", "styles/panel", dlg)
P("PopupPanel", "styles/panel", dlg)
P("PopupMenu", "styles/panel", dlg)
P("TooltipPanel", "styles/panel", box("panel-200", "line-300", 1, RAD["radius-md"], (SP["space-2"], SP["space-1"] + 2)))
P("TooltipLabel", "colors/font_color", col("ink")); P("TooltipLabel", "font_sizes/font_size", 12)
# Bars, lines, scroll
P("ProgressBar", "styles/background", box("#ffffff14", None, 0, RAD["radius-sm"], (0, 0)))
P("ProgressBar", "styles/fill", box("cash", None, 0, RAD["radius-sm"], (0, 0)))
P("ProgressBar", "constants/outline_size", 0)
props.append('ProgressBarThin/base_type = &"ProgressBar"')
P("ProgressBarThin", "styles/background", box("#ffffff14", None, 0, 1, (0, 0)))
P("ProgressBarThin", "styles/fill", box("cash", None, 0, 1, (0, 0)))
P("HSeparator", "styles/separator", line_box("line-100")); P("HSeparator", "constants/separation", SP["space-2"])
P("VSeparator", "styles/separator", line_box("line-100"))
P("RichTextLabel", "colors/default_color", col("ink")); P("RichTextLabel", "fonts/normal_font", F["body"])
P("CheckButton", "colors/font_color", col("ink")); P("CheckBox", "colors/font_color", col("ink"))

# Icons and colours as custom theme types so scripts never hard-code them
for n in icons:
    P("Icons", "icons/" + n, add_ext("Texture2D", "res://design/theme/icons/%s.svg" % n))
for n in C:
    P("Colors", "colors/" + n.replace("-", "_"), col(n))
P("Colors", "colors/orbit_line", col("line-200"))  # system map orbit rings (SystemView.html)
P("Colors", "colors/orbit_line_outer", col("line-100"))  # dashed outer storage orbit
P("Colors", "colors/scrim", col("void-000", 0.85))
P("Colors", "colors/scrim_soft", col("void-000", 0.7))
P("Spacing", "constants/space_6", SP["space-6"])

out = ['[gd_resource type="Theme" load_steps=%d format=3]\n' % (len(ext) + len(sub) + 1)]
out += ext + [""] + sub + ["[resource]"] + props
open(os.path.join(OUT, "star_bazaar.tres"), "w").write("\n".join(out) + "\n")
print("wrote theme:", len(icons), "icons,", len(C), "colours")
