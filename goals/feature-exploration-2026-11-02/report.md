**Goal:** Explore three improvements and three new trade mechanics and build only what all three designers agree on, on branch new-features-test.
**Result:** partial. Agreed P1, P2 and N3; N1 not built. P2 done, P1 partial (event arrow built, margin picker not), N3 needs owner approval of bundle_bonus_pct 0.05 and bundle_bonus_cap 150.
**Tests:** sh tools/tests/run.sh gives 574 pass, 0 fail; sim decent play wins at cycle 23, sloppy and never expand do not win.
**Open:** Owner approves the N3 keys; story ids LBL_PRICE_EVENT, LBL_BEST_OPEN_ROUTE, LBL_SETUP_LOST and BTN_MOVE_SHIP needed. Watch always expand plus C1 (wins at cycle 23). Nothing committed.
**Handoffs:** handoffs/ui-programmer/2026-11-02-P1.json, handoffs/gameplay-programmer/2026-11-02-P2.json, handoffs/feature-designer/2026-11-02-N3.json
