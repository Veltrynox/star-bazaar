#!/bin/bash
# QA 2026-11-05 sign-off batch (owned by qa-analyst). Current data (balance v50, skills v3, goods, availability).
# Every focus run and ablation uses --keep-running=38: the win ends the game at cycle 27-35, the kept run plays on to
# cycle 39 (the game itself ends a run at cycle 40, win_cycle_markets). Keep-running does not change the win itself.
#   base          decent, no focus (4 seeds), keep-running. base_notut: same without --skip-tutorial (4 seeds).
#   focus_<m>     decent --market=m (4 seeds each)
#   abl_<NODE>    the node removed in its market focus: --skip-skill=ID for skills, --skip-tech=ID for techs (4 seeds)
#   brb_<m>, abl_<CAP>  capstone arm: the market branch only (--skills=...), with and without the capstone (4 seeds)
#   dom_<s>       sloppy, always_expand, never_expand, no market, no keep-running (4 seeds)
#   ce_<ceo>_<ship>  CEO x ship check: decent, 16 combos x 3 seeds, no market, no keep-running
# Usage: qa/bots/skill_signoff.sh <out_dir> [parallel=8]
# Output: <out_dir>/results_all.jsonl (one RESULT per run). Then python3 qa/bots/skill_signoff_analyse.py <out_dir>.
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="${1:?usage: skill_signoff.sh <out_dir> [parallel]}"
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
# Baselines
add base decent "$S4" $KEEP
add base_notut decent "$S4" --keep-running=38
for m in mil lux min bio; do add "focus_$m" decent "$S4" $KEEP --market=$m; done
# Ablations (16 nodes, 4 seeds each): techs by --skip-tech, skills by --skip-skill, in the node's market focus
abl() { local node="$1" kind="$2" mk="$3"; add "abl_$node" decent "$S4" $KEEP --market=$mk --skip-$kind=$node; }
abl MIL_2 tech mil; abl MIL_3 skill mil; abl MIL_4 tech mil; abl MIL_5 skill mil; abl MIL_6 tech mil
abl LUX_1 skill lux; abl LUX_2 tech lux; abl LUX_4 tech lux; abl LUX_5 skill lux; abl LUX_6 tech lux
abl MIN_2 tech min; abl MIN_6 tech min
abl BIO_2 tech bio; abl BIO_4 tech bio; abl BIO_5 skill bio; abl BIO_6 tech bio
# Capstones: market branch only, so the points go to the branch (the open tree spends them on other markets)
BR_LUX="FND_STORAGE,FND_PERMIT,FND_PROSPECT,LUX_1,LUX_3,LUX_5,LUX_7"
BR_MIN="FND_STORAGE,FND_PERMIT,FND_PROSPECT,MIN_1,MIN_3,MIN_5,MIN_7"
BR_BIO="FND_STORAGE,FND_PERMIT,FND_PROSPECT,BIO_1,BIO_3,BIO_5,BIO_7"
add brb_lux decent "$S4" $KEEP --market=lux --skills=$BR_LUX
add brb_min decent "$S4" $KEEP --market=min --skills=$BR_MIN
add brb_bio decent "$S4" $KEEP --market=bio --skills=$BR_BIO
add abl_LUX_7 decent "$S4" $KEEP --market=lux --skills=$BR_LUX --skip-skill=LUX_7
add abl_MIN_7 decent "$S4" $KEEP --market=min --skills=$BR_MIN --skip-skill=MIN_7
add abl_BIO_7 decent "$S4" $KEEP --market=bio --skills=$BR_BIO --skip-skill=BIO_7
# Dominance: the other strategies on the final tree (not keep-running)
for s in sloppy always_expand never_expand; do add "dom_$s" "$s" "$S4" --skip-tutorial; done
# CEO x ship check (decent, 3 seeds, 16 combos)
for c in ceo_man_01 ceo_man_02 ceo_woman_01 ceo_woman_02; do
  for sh in small bulk dart fleet; do add "ce_${c}_${sh}" decent "1 2 3" --skip-tutorial --ceo=$c --ship=$sh; done
done
N=$(wc -l < "$JOBS")
echo "jobs: $N" >&2
# One run per line, PAR at a time. Each run writes its own row file, so the parallel runs do not share output.
xargs -P "$PAR" -L 1 bash "$REPO/qa/bots/skill_signoff_one.sh" "$OUT" < "$JOBS"
cat "$OUT"/rows/*.json > "$OUT/results_all.jsonl"
echo "done: $(wc -l < "$OUT/results_all.jsonl") records" >&2
