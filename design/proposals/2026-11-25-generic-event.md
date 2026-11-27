# Proposal: one new generic base event, EV65 (2026-11-25)

Status: proposal only. Nothing built. Owner decides.

## 1. The event (story/events.md format)

EV65 | The tanker that did not come | [price up: Tillam, energy] | Q
Energy at Tillam costs more and pays more for a few cycles. The tanker from Voltara is overdue, and no one will say why. Dispatcher Kess keeps its berth lit and chalks the delay on the board again. Your load can earn more here. The board has no room left.

Title 28 of 32 characters. Body 255 of 280. No digits. Longest sentence 17 words. Real names only: Tillam, Voltara, energy (visible from the start). ID EV65 is unused in story/ and data/.

## 2. Why it fits

The 25 base events cover every planet and good with demand, harvest and strike stories. None is about supply that simply fails to arrive: a ship the player never sees, a timetable and a person waiting on it. It also nudges the player to think of their own lanes and what a late load is worth. Quiet dread: the berth lit, the unexplained delay.

## 3. Suggested mechanics (words only, numbers for the economy designer)

- Planet and good: Tillam, energy. Direction: price up (Buy price and Sell price both rise), clearly.
- Duration: for a few cycles.
- Overlap: EV05 (Frost on Tillam) has the same tag. If the owner wants no repeat, use Ashgate, energy instead (swap the planet name in title-free body text only).

## 4. What building it would touch

- story/events.md: add the EV65 entry in the base events block, after EV16.
- data/events.json: written only by `python3 tools/build_story.py` (never by hand); it adds EV65_TITLE and EV65_BODY text ids with tag and kind.
- story/ru/*.json only if the owner asks for Russian later.
- No game code or mechanics change. Durations and sizes stay with the economy designer.
