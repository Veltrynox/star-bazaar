# Station-to-station transfer (T165)

This design is the storage link. T165 asked for a transfer mechanic between space stations; the owner then specified it (a link that eats goods instead of money and allows transfers), and T169 wrote it up.

Read: `design/proposals/2026-11-05-storage-link.md` (handoff `handoffs/feature-designer/2026-11-05-T169.json`).

Summary of the design there:
- One link per pair of Space Storages, at most 2 per storage; costs goods only, never credits.
- Build cost 120 rivets and 200 energy; upkeep 20 energy per cycle.
- Transfer: 60 units per cycle per link, instant and lossless, up to 4 standing orders per link.
- If upkeep runs out the link goes dormant, and collapses after 4 dormant cycles (owner may drop the collapse).
- Unlock rule `storage_link` in `data/availability.json`.

Build task: T171 (T166 is the old name for the same build and is superseded).
