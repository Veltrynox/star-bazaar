#!/bin/bash
# QA 2026-11-05 T173 round 3 sign-off (owned by qa-analyst). Same method as more_skills_signoff.sh, new data.
# Data: skills v7 (36 nodes; FND_BULK and MIL_5B dropped), balance data_version 53. Event forecast drawn 2 cycles ahead for all runs.
# Every focus run and ablation uses --skip-tutorial --keep-running=38; dom_* runs stop at the win (as the earlier rounds).
#   reg_<m>        regression: decent, default (no focus) and --market=mil|lux|min|bio (4 seeds)
#   dom_<s>        sloppy, always_expand, never_expand (4 seeds)
#   nat_<NODE>     natural ablation: decent in the node's focus, --skip-skill=NODE (baseline reg_<m>)
#   brb_*          controlled branch arms: whitelist identical on and off, only the node differs
#   lock_*         chosen-bot lock with BIO_6B (hit 0.35): MIL_5 + BIO_6B, LUX_7 + BIO_6B
# Usage: qa/bots/more_skills_signoff_r3.sh <out_dir> [parallel=8]
# Output: <out_dir>/results_all.jsonl (one RESULT per run). Then python3 -I qa/bots/more_skills_signoff_r3_analyse.py <out_dir>.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="${1:?usage: more_skills_signoff_r3.sh <out_dir> [parallel]}"
PAR="${2:-8}"
mkdir -p "$OUT"
JOBS="$OUT/jobs.txt"
: > "$JOBS"
S4="1 2 3 4"
KEEP="--skip-tutorial --keep-running=38"
add() { # tag strategy seeds extra...
  local tag="$1" strat="$2" seeds="$3"; shift 3
  for s in $seeds; do echo "$tag $strat $s $*" >> "$JOBS"; done
}
# Regression
add reg_default decent "$S4" $KEEP
for m in mil lux min bio; do add "reg_$m" decent "$S4" $KEEP --market=$m; done
for s in sloppy always_expand never_expand; do add "dom_$s" "$s" "$S4" --skip-tutorial; done
# Natural ablations (node removed in the focus that fits it)
add nat_LUX_5B decent "$S4" $KEEP --market=lux --skip-skill=LUX_5B
add nat_LUX_6B decent "$S4" $KEEP --market=lux --skip-skill=LUX_6B
add nat_MIN_5B decent "$S4" $KEEP --market=min --skip-skill=MIN_5B
add nat_BIO_5B decent "$S4" $KEEP --market=bio --skip-skill=BIO_5B
add nat_BIO_6B decent "$S4" $KEEP --market=bio --skip-skill=BIO_6B
# Controlled branch arms (whitelist fixed; node on or off)
FND3="FND_STORAGE,FND_PERMIT,FND_PROSPECT"
add brb_lux_base decent "$S4" $KEEP --market=lux --skills=$FND3,LUX_1,LUX_3,LUX_5
add brb_lux_5B   decent "$S4" $KEEP --market=lux --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_5B
add brb_lux_5B_6B decent "$S4" $KEEP --market=lux --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_5B,LUX_6B
add brb_min_base decent "$S4" $KEEP --market=min --skills=$FND3,MIN_1,MIN_3,MIN_5
add brb_min_5B   decent "$S4" $KEEP --market=min --skills=$FND3,MIN_1,MIN_3,MIN_5,MIN_5B
add brb_bio_base decent "$S4" $KEEP --market=bio --skills=$FND3,BIO_1,BIO_3,BIO_5
add brb_bio_5B   decent "$S4" $KEEP --market=bio --skills=$FND3,BIO_1,BIO_3,BIO_5,BIO_5B
add brb_bio_6B   decent "$S4" $KEEP --market=bio --skills=$FND3,BIO_1,BIO_3,BIO_5,BIO_6B
# Chosen-bot lock with BIO_6B at 0.35
add lock_mil5_bio6b decent "$S4" $KEEP --skills=$FND3,MIL_1,MIL_3,MIL_5,BIO_1,BIO_3,BIO_5,BIO_6B
add lock_lux7_bio6b decent "$S4" $KEEP --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_7,BIO_1,BIO_3,BIO_5,BIO_6B
N=$(wc -l < "$JOBS")
echo "jobs: $N" >&2
xargs -P "$PAR" -L 1 bash "$REPO/qa/bots/skill_signoff_one.sh" "$OUT" < "$JOBS"
cat "$OUT"/rows/*.json > "$OUT/results_all.jsonl"
echo "done: $(wc -l < "$OUT/results_all.jsonl") records" >&2
