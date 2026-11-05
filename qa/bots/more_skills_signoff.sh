#!/bin/bash
# QA 2026-11-05 T173 sign-off batch for the seven new skill nodes (owned by qa-analyst).
# Data: skills v6 (38 nodes), balance v52. Every focus run and ablation uses --skip-tutorial --keep-running=38
# (the win at cycle 27-32 ends the run; the kept run plays on to cycle 39). Clock: fast (bot default).
#   reg_<m>        regression: decent, default (no focus) and --market=mil|lux|min|bio (4 seeds)
#   dom_<s>        sloppy, always_expand, never_expand (4 seeds), no keep-running (as the 2026-11-05 round)
#   nat_<NODE>     natural ablation: decent in the node's focus, --skip-skill=NODE (baseline reg_<m>)
#   brb_*          controlled ablation: market branch whitelist (--skills=...), node on/off, same seeds
#                  brb_<m>_base = FND_STORAGE,FND_PERMIT,FND_PROSPECT + the market's 3 pre-T173 nodes
#                  brb_fnd_*   = FND trio, with and without FND_BULK (no focus)
#   lock_*         chosen-bot lock: BIO_6B with MIL_5 and LUX_7 (decent, whitelist of their closures)
#   fit_*          points fit: a second market on top of a focus does not fit the supply
# Usage: qa/bots/more_skills_signoff.sh <out_dir> [parallel=8]
# Output: <out_dir>/results_all.jsonl (one RESULT per run). Then python3 qa/bots/more_skills_signoff_analyse.py <out_dir>.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="${1:?usage: more_skills_signoff.sh <out_dir> [parallel]}"
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
# Natural ablations: the node removed in the focus that fits it (FND_BULK in the default run)
add nat_FND_BULK decent "$S4" $KEEP --skip-skill=FND_BULK
add nat_MIL_5B decent "$S4" $KEEP --market=mil --skip-skill=MIL_5B
add nat_LUX_5B decent "$S4" $KEEP --market=lux --skip-skill=LUX_5B
add nat_LUX_6B decent "$S4" $KEEP --market=lux --skip-skill=LUX_6B
add nat_MIN_5B decent "$S4" $KEEP --market=min --skip-skill=MIN_5B
add nat_BIO_5B decent "$S4" $KEEP --market=bio --skip-skill=BIO_5B
add nat_BIO_6B decent "$S4" $KEEP --market=bio --skip-skill=BIO_6B
# Controlled branch arms: the whitelist is the same for on and off, only the node differs
FND3="FND_STORAGE,FND_PERMIT,FND_PROSPECT"
add brb_mil_base decent "$S4" $KEEP --market=mil --skills=$FND3,MIL_1,MIL_3,MIL_5
add brb_mil_5B   decent "$S4" $KEEP --market=mil --skills=$FND3,MIL_1,MIL_3,MIL_5,MIL_5B
add brb_lux_base decent "$S4" $KEEP --market=lux --skills=$FND3,LUX_1,LUX_3,LUX_5
add brb_lux_5B   decent "$S4" $KEEP --market=lux --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_5B
add brb_lux_5B_6B decent "$S4" $KEEP --market=lux --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_5B,LUX_6B
add brb_min_base decent "$S4" $KEEP --market=min --skills=$FND3,MIN_1,MIN_3,MIN_5
add brb_min_5B   decent "$S4" $KEEP --market=min --skills=$FND3,MIN_1,MIN_3,MIN_5,MIN_5B
add brb_bio_base decent "$S4" $KEEP --market=bio --skills=$FND3,BIO_1,BIO_3,BIO_5
add brb_bio_5B   decent "$S4" $KEEP --market=bio --skills=$FND3,BIO_1,BIO_3,BIO_5,BIO_5B
add brb_bio_6B   decent "$S4" $KEEP --market=bio --skills=$FND3,BIO_1,BIO_3,BIO_5,BIO_6B
add brb_fnd_base decent "$S4" $KEEP --skills=$FND3
add brb_fnd_bulk decent "$S4" $KEEP --skills=$FND3,FND_BULK
# Chosen-bot lock (BIO_6B with MIL_5 and LUX_7); control arm without BIO_6B; all three together
add lock_mil5_bio6b decent "$S4" $KEEP --skills=$FND3,MIL_1,MIL_3,MIL_5,BIO_1,BIO_3,BIO_5,BIO_6B
add lock_lux7_bio6b decent "$S4" $KEEP --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_7,BIO_1,BIO_3,BIO_5,BIO_6B
add lock_mil5_lux7  decent "$S4" $KEEP --skills=$FND3,MIL_1,MIL_3,MIL_5,LUX_1,LUX_3,LUX_5,LUX_7
add lock_all3       decent "$S4" $KEEP --skills=$FND3,MIL_1,MIL_3,MIL_5,LUX_1,LUX_3,LUX_5,LUX_7,BIO_1,BIO_3,BIO_5,BIO_6B
# Points fit: a focus branch (lux, 16 points with FND) and a focus plus a second market (no focus, 24 points)
add fit_one_lux decent "$S4" $KEEP --market=lux --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_5B,LUX_6B,LUX_7
add fit_two_mkts decent "$S4" $KEEP --skills=$FND3,LUX_1,LUX_3,LUX_5,LUX_5B,LUX_6B,LUX_7,MIL_1,MIL_3,MIL_5,MIL_5B
N=$(wc -l < "$JOBS")
echo "jobs: $N" >&2
xargs -P "$PAR" -L 1 bash "$REPO/qa/bots/skill_signoff_one.sh" "$OUT" < "$JOBS"
cat "$OUT"/rows/*.json > "$OUT/results_all.jsonl"
echo "done: $(wc -l < "$OUT/results_all.jsonl") records" >&2
