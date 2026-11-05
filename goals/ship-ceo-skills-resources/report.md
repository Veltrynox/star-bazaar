Goal: ship-select screen with 3D preview, CEO bios EN/RU with stats and perks, skill tree redone with agent sign-off, resource and crafting audit.
Result: done. 4 ships and 4 CEOs chosen on two new-game screens; 31 skills reviewed by economy, feature and QA agents; rivets and musk now have recipes; Luxury and alloy unlock order fixed; tests 1866 pass.
Changed: new game/ceos.gd, game/ship_setup.gd, data/ceos.json, ships.json; skills.json, balance.json (v49), goods.json, availability.json; skill, ship and CEO texts EN/RU; softlock fix (dead-end bankruptcy).
Open: LUX_6 uses batch yield, not saturation (no saturation rule in the build); pirate effects have no source (EV19 text); RU layout and ship preview size unchecked by eye; 3 of 16 combos borderline; man_02 perk does not feed share.
Handoffs: handoffs/*/2026-11-05-*.json; reports in design/proposals/2026-11-05-*.md and qa/reports/2026-11-05-*.md.
