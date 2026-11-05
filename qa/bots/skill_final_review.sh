#!/bin/bash
# QA 2026-11-05: skill final review batch (owned by qa-analyst). Runs the decent bot on the committed skill tree.
#   base    : decent, no focus (4 seeds)
#   focus   : decent --market=mil|lux|min|bio (4 seeds each), the dominance check
#   abl     : each node removed in its market focus (4 seeds each). Skills: --skip-skill=ID. Techs: --skip-tech=ID
#             (bot-side: the tech never finishes, see _ablate_techs in bot_run.gd). Baseline for an ablation = its focus run.
# Usage: qa/bots/skill_final_review.sh <out_dir>   (raw RESULT lines: <out_dir>/results_all.jsonl)
set -u
REPO="$(cd "$(dirname "$0")/../.." && pwd)"
OUT="${1:?usage: skill_final_review.sh <out_dir>}"
mkdir -p "$OUT/tmp"
export TMPDIR="$OUT/tmp"   # a writable scratch root for each run's HOME (see run_batch.sh)
export SEEDS="1 2 3 4"
export STRATEGIES="decent"
export LIMIT=600
RUN="$REPO/qa/bots/run_batch.sh"
SKIP="--skip-tutorial"
job() { # tag extra
  TAG="$1" EXTRA="$2 $SKIP" bash "$RUN" "$OUT/$1" > "$OUT/$1.out" 2>&1
}
mkdir -p "$OUT"
job base ""
for m in mil lux min bio; do job "focus_$m" "--market=$m"; done
# Ablations: skill (--skip-skill) or tech (--skip-tech), in the market focus of the node.
job abl_MIL_2 "--market=mil --skip-tech=MIL_2"
job abl_MIL_3 "--market=mil --skip-skill=MIL_3"
job abl_MIL_4 "--market=mil --skip-tech=MIL_4"
job abl_MIL_5 "--market=mil --skip-skill=MIL_5"
job abl_MIL_6 "--market=mil --skip-tech=MIL_6"
job abl_LUX_1 "--market=lux --skip-skill=LUX_1"
job abl_LUX_2 "--market=lux --skip-tech=LUX_2"
job abl_LUX_4 "--market=lux --skip-tech=LUX_4"
job abl_LUX_5 "--market=lux --skip-skill=LUX_5"
job abl_LUX_6 "--market=lux --skip-tech=LUX_6"
job abl_LUX_7 "--market=lux --skip-skill=LUX_7"
job abl_MIN_2 "--market=min --skip-tech=MIN_2"
job abl_MIN_3 "--market=min --skip-skill=MIN_3"
job abl_MIN_4 "--market=min --skip-tech=MIN_4"
job abl_MIN_5 "--market=min --skip-skill=MIN_5"
job abl_MIN_6 "--market=min --skip-tech=MIN_6"
job abl_MIN_7 "--market=min --skip-skill=MIN_7"
job abl_BIO_1 "--market=bio --skip-skill=BIO_1"
job abl_BIO_2 "--market=bio --skip-tech=BIO_2"
job abl_BIO_3 "--market=bio --skip-skill=BIO_3"
job abl_BIO_4 "--market=bio --skip-tech=BIO_4"
job abl_BIO_5 "--market=bio --skip-skill=BIO_5"
job abl_BIO_6 "--market=bio --skip-tech=BIO_6"
job abl_BIO_7 "--market=bio --skip-skill=BIO_7"
# Concatenate every RESULT record, tagged by its batch.
cat "$OUT"/*/results_*.jsonl > "$OUT/results_all.jsonl"
echo "done: $(wc -l < "$OUT/results_all.jsonl") records"
