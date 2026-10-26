extends RefCounted
## T06: manual trade state and the guided first-trade mission (GDD section 2, 'First 4 cycles').
## Holds cargo, the single trading ship's planet and the mission step. Cash stays in main.gd:
## buy() / sell_all() / send() return the money moved and main.gd applies it.
## Prices come from planets.json base_prices ("<commodity>_buy" is what the player pays,
## "<commodity>_sell" is what the player receives). Capacity and trip cost from balance.json.

enum Step { BUY_SHIP, BUY_ENERGY, GO_SELL_PLANET, SELL_ENERGY, BUY_FOOD, GO_BACK, SELL_FOOD, DONE }

var cargo: Dictionary = {}   # commodity -> int units held
var ship_planet: int = -1    # planet index of the trading ship (where it is docked, or left from while in flight), -1 = no ship yet
var dest: int = -1           # T30: planet the ship is flying to, -1 = docked
var arrive_at: float = 0.0   # T30: cycle progress at which the flight ends
var now: float = 0.0         # T30: current cycle progress, set by main.gd (cycle - 1 + time in cycle)
var step: int = Step.BUY_SHIP

var balance: Dictionary = {}
var planets: Array = []
var buy_planet: int = -1     # planet that sells energy cheaply (energy_buy)
var sell_planet: int = -1    # planet that pays well for energy (energy_sell)

func setup(bal: Dictionary, plist: Array) -> void:
	balance = bal
	planets = plist
	for i in planets.size():
		if price(i, "energy_buy") >= 0 and buy_planet < 0:
			buy_planet = i
		if price(i, "energy_sell") >= 0 and sell_planet < 0:
			sell_planet = i

## Price of a key such as "energy_buy" at planet i, or -1 if missing/UNKNOWN.
func price(i: int, key: String) -> int:
	if i < 0 or i >= planets.size() or typeof(planets[i]) != TYPE_DICTIONARY:
		return -1
	var prices = planets[i].get("base_prices")
	if typeof(prices) != TYPE_DICTIONARY:
		return -1
	var v = prices.get(key)
	return int(v) if (typeof(v) == TYPE_INT or typeof(v) == TYPE_FLOAT) else -1

func capacity() -> int:
	return int(balance.get("cargo", 0))

func held(c: String) -> int:
	return int(cargo.get(c, 0))

func used() -> int:
	var n := 0
	for c in cargo:
		n += int(cargo[c])
	return n

func trip_cost() -> int:
	return int(balance.get("trip_cost", 0))

func on_ship_bought(planet_index: int, ship_count: int) -> void:
	if ship_count == 1 and ship_planet < 0:
		ship_planet = planet_index  # the first ship starts where it was bought

## T30: true while the ship is flying; it cannot trade or be sent again.
func in_flight() -> bool:
	return dest >= 0

## T30: the ship is docked at planet i (ready to trade there).
func docked_at(i: int) -> bool:
	return dest < 0 and ship_planet == i and ship_planet >= 0

func travel_cycles() -> float:
	return maxf(0.0, float(balance.get("travel_cycles_per_leg", 1)))

## T30: whole cycles left in the flight (at least 1 while flying).
func cycles_left() -> int:
	return maxi(1, ceili(arrive_at - now - 0.0001))

## T30: advances the clock; lands the ship when its time is up. Returns true on arrival.
func tick(progress: float) -> bool:
	now = progress
	if dest >= 0 and now >= arrive_at:
		ship_planet = dest
		dest = -1
		return true
	return false

## T30: one-line ship state for the Ships panel.
func status_text() -> String:
	if ship_planet < 0:
		return ""
	if dest >= 0:
		return "In flight to %s, arrives in %d cycle(s)" % [_name(dest), cycles_left()]
	return "Docked at %s" % _name(ship_planet)

## Units the player can buy of commodity c at planet i right now (0 if impossible).
func max_buy(i: int, c: String, cash: int) -> int:
	var p := price(i, c + "_buy")
	if p <= 0 or not docked_at(i):
		return 0
	return maxi(0, mini(capacity() - used(), cash / p))

## Buys qty units (clamped); returns the cash spent.
func buy(i: int, c: String, qty: int, cash: int) -> int:
	var n := mini(qty, max_buy(i, c, cash))
	if n <= 0:
		return 0
	cargo[c] = held(c) + n
	return n * price(i, c + "_buy")

## Sells everything of c; returns the cash earned.
func sell_all(i: int, c: String) -> int:
	var p := price(i, c + "_sell")
	if p < 0 or not docked_at(i) or held(c) <= 0:
		return 0
	var earned := held(c) * p
	cargo.erase(c)
	return earned

## Starts the flight to planet i. Returns the trip cost charged, or -1 if not allowed.
func send(i: int, cash: int, ships: int) -> int:
	if send_reason(i, cash, ships) != "":
		return -1
	dest = i
	arrive_at = now + travel_cycles()
	return trip_cost()

## Empty string if the ship can be sent to planet i, else a short reason.
func send_reason(i: int, cash: int, ships: int) -> String:
	if ships <= 0:
		return "Buy a ship first."
	if in_flight():
		return "Ship is in flight, arrives in %d cycle(s). Resume time to continue." % cycles_left()
	if ship_planet == i:
		return "Ship is already here."
	if cash < trip_cost():
		return "Not enough cash: trip costs %d." % trip_cost()
	return ""

## Rows for the planet panel: one per commodity with at least one price at planet i.
func rows(i: int, commodities: Array, cash: int, ships: int) -> Array:
	var out: Array = []
	for c in commodities:
		var cs := str(c)
		var bp := price(i, cs + "_buy")
		var sp := price(i, cs + "_sell")
		if bp < 0 and sp < 0:
			continue
		var buy_reason := ""
		var sell_reason := ""
		if ships <= 0:
			buy_reason = "Buy a ship first."
			sell_reason = buy_reason
		elif in_flight():
			buy_reason = "Your ship is in flight. Resume time to let it arrive."
			sell_reason = buy_reason
		elif ship_planet != i:
			buy_reason = "No ship of yours is docked here."
			sell_reason = buy_reason
		else:
			if capacity() - used() <= 0:
				buy_reason = "Cargo full."
			elif bp > 0 and cash < bp:
				buy_reason = "Not enough cash."
			if held(cs) <= 0:
				sell_reason = "Nothing to sell."
		out.append({"commodity": cs, "buy": bp, "sell": sp, "held": held(cs),
			"max_buy": max_buy(i, cs, cash), "buy_reason": buy_reason, "sell_reason": sell_reason})
	return out

## Moves the mission forward while the current step's condition is met.
## Returns true if the mission has just been completed.
func advance(ships: int) -> bool:
	var before := step
	while step < Step.DONE and _step_done(ships):
		step += 1
	return before != Step.DONE and step == Step.DONE

func _step_done(ships: int) -> bool:
	match step:
		Step.BUY_SHIP: return ships > 0
		Step.BUY_ENERGY: return held("energy") > 0
		Step.GO_SELL_PLANET: return docked_at(sell_planet)
		Step.SELL_ENERGY: return docked_at(sell_planet) and held("energy") == 0
		Step.BUY_FOOD: return held("food") > 0
		Step.GO_BACK: return docked_at(buy_planet)
		Step.SELL_FOOD: return docked_at(buy_planet) and held("food") == 0
	return false

## Planet the pulsing halo should mark, or -1 when the mission is over.
func hint_planet(first_planet: int) -> int:
	match step:
		Step.BUY_SHIP: return first_planet
		Step.BUY_ENERGY, Step.GO_BACK, Step.SELL_FOOD: return buy_planet
		Step.GO_SELL_PLANET, Step.SELL_ENERGY, Step.BUY_FOOD: return sell_planet
	return -1

func _name(i: int) -> String:
	if i < 0 or i >= planets.size():
		return "the planet"
	return str(planets[i].get("name", planets[i].get("id", "?")))

## Plain-text current step for the notification board.
func mission_text(paused: bool = false) -> String:
	if step >= Step.DONE:
		return "Mission complete: you made your first trade."
	if step == Step.BUY_SHIP:
		return "Mission: Buy a ship"
	if in_flight():
		if paused:
			return "Your ship is flying. Press Space to resume time."
		return "Your ship is flying to %s. Arrives in %d cycle(s)." % [_name(dest), cycles_left()]
	var target := hint_planet(-1)
	var action := ""
	match step:
		Step.BUY_ENERGY: action = "buy energy (%d cr each; Buy max earns the most)" % price(buy_planet, "energy_buy")
		Step.GO_SELL_PLANET: action = "sell the energy"
		Step.SELL_ENERGY: action = "sell all your energy (%d cr each)" % price(sell_planet, "energy_sell")
		Step.BUY_FOOD: action = "buy food (%d cr each; Buy max earns the most)" % price(sell_planet, "food_buy")
		Step.GO_BACK: action = "sell the food"
		Step.SELL_FOOD: action = "sell all your food (%d cr each)" % price(buy_planet, "food_sell")
	var go_step := step == Step.GO_SELL_PLANET or step == Step.GO_BACK
	if go_step:
		return "Mission: Send your ship to %s and %s." % [_name(target), action]
	if ship_planet != target:
		return "Mission: Send your ship to %s, then %s." % [_name(target), action]
	return "Mission: At %s, %s." % [_name(target), action]

## How-to-trade text shown on the board once the first ship is bought.
func guide_text() -> String:
	return ("How to trade: buy energy at %s for %d cr and sell it at %s for %d cr. "
		+ "Buy food at %s for %d cr and sell it at %s for %d cr. "
		+ "Flying empty earns nothing and each leg costs %d cr, so carry cargo both ways.") % [
		_name(buy_planet), price(buy_planet, "energy_buy"), _name(sell_planet), price(sell_planet, "energy_sell"),
		_name(sell_planet), price(sell_planet, "food_buy"), _name(buy_planet), price(buy_planet, "food_sell"),
		trip_cost()]

func collect() -> Dictionary:
	return {"cargo": cargo, "ship_planet": ship_planet, "mission_step": step,
		"dest": dest, "flight_left": maxf(0.0, arrive_at - now) if dest >= 0 else 0.0}

## Restores from a save; every key has a default so old saves still load.
func apply(s: Dictionary, ships: int, first_planet: int) -> void:
	cargo = {}
	var raw = s.get("cargo")
	if ships > 0 and typeof(raw) == TYPE_DICTIONARY:
		for k in raw:
			var n := int(raw[k])
			if typeof(k) == TYPE_STRING and n > 0:
				cargo[k] = n
	ship_planet = int(s.get("ship_planet", first_planet if ships > 0 else -1))
	if ships <= 0 or ship_planet < 0 or ship_planet >= planets.size():
		ship_planet = first_planet if ships > 0 else -1
	dest = int(s.get("dest", -1))  # T30: old saves have no flight, the ship is docked
	if ships <= 0 or dest < 0 or dest >= planets.size() or dest == ship_planet:
		dest = -1
	arrive_at = now + maxf(0.0, float(s.get("flight_left", 0.0)))
	step = clampi(int(s.get("mission_step", Step.BUY_ENERGY if ships > 0 else Step.BUY_SHIP)), 0, Step.DONE)
	advance(ships)
