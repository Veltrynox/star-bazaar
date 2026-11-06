extends RefCounted
## T171: Storage Link. A goods-priced bridge between the Space Storages of two systems (design/proposals/2026-11-05-storage-link.md).
## Costs goods only (never credits), runs at cycle end without a ship, instant and lossless. Moves stock only: it never buys,
## sells or touches planet storage, ships or events.
##
## Balance keys (all in data/balance.json): link_build_rivets, link_build_energy, link_upkeep_energy, link_rate (units per cycle per
## link, all goods and both directions together), link_max_per_storage, link_orders_max, link_dormant_limit.
## Availability: feature "storage_link" (data/availability.json). Nothing here can be built or ordered while it is hidden; orders can
## only name goods that are visible (Availability.good).
##
## UI API (system ids are the numbers used by Storage.system_key; a link is addressed by its integer id):
##   can_build(a, b) -> String          "" if buildable now, else a story text id (see REASON_*)
##   build_link(a, b, mix := {}) -> int link id, or -1 (reason in last_reason). mix = {system_id: {"rivets": n, "energy": n}} picks
##                                      what each storage pays; empty mix = automatic (the storage with more stock pays first)
##   remove_link(id) -> bool            player scraps a link, no refund
##   set_order(id, good, from_system, amount) -> bool   standing order "move up to amount of good per cycle out of from_system into the
##                                      other end"; the same good and direction replaces its amount; amount 0 removes it
##   remove_order(id, index) -> bool
##   links() -> Array                   ids of live links; link_info(id) -> Dictionary (below); collapsed links are gone from the list
##   state(id) -> String                "active" | "dormant" | "collapsed" (a gone link reports "collapsed")
##   link_info(id) -> {id, a, b, state, dormant, cycles_left, orders: [{good, from, to, amount}], rate, rate_used, upkeep}
##       cycles_left = cycles until collapse while dormant, else -1; rate_used = what the orders would move now (plan), not history
##   cost() -> {"rivets", "energy"}; stock_of(system, good); pair_link(a, b) -> id or -1; count_at(system) -> int
##   settle() -> called once per cycle by main.gd _end_cycle
## Signals: link_built(id), link_removed(id), link_state_changed(id, state), link_collapsed(a, b), link_orders_changed(id),
##   link_transferred(id, moved: Dictionary good -> units), link_notice(text_id, vars).

signal link_built(id: int)
signal link_removed(id: int)
signal link_state_changed(id: int, state: String)
signal link_collapsed(a: int, b: int)
signal link_orders_changed(id: int)
signal link_transferred(id: int, moved: Dictionary)
signal link_notice(text_id: String, vars: Dictionary)

const Storage := preload("res://game/storage.gd")

const REASON_HIDDEN := ""  # hidden feature: no text is shown at all
const REASON_NEED_STORAGE := "LNK_NEED_STORAGE"
const REASON_PAIR := "LNK_ALREADY"
const REASON_MAX := "LNK_MAX_AT_STORAGE"
const REASON_GOODS := "LNK_NEED_GOODS"

var balance: Dictionary = {}
var storage: RefCounted
var main_ref: Object = null  # optional: Main (for open_systems); null in tests
var _links: Array = []  # {id, a, b, state, dormant, orders: [{good, from, amount}]}
var _next_id: int = 1
var last_reason: String = ""

func setup(bal: Dictionary, stor: RefCounted, main_node: Object = null) -> void:
	balance = bal
	storage = stor
	main_ref = main_node
	_links = []
	_next_id = 1

func _i(key: String, d: int) -> int:
	return int(balance.get(key, d))

func cost() -> Dictionary:
	if not Goods.branch_ok("rivets"):  # T239: rivets belong to Military; other branches pay that part in energy
		return {"rivets": 0, "energy": _i("link_build_rivets", 120) + _i("link_build_energy", 200)}
	return {"rivets": _i("link_build_rivets", 120), "energy": _i("link_build_energy", 200)}

func upkeep() -> int:
	return _i("link_upkeep_energy", 20)

func rate() -> int:
	return _i("link_rate", 60)

func visible_feature() -> bool:
	return Availability.feature("storage_link")

func stock_of(system: int, good: String) -> int:
	return storage.amount(Storage.system_key(system), good)

func _usable(system: int) -> bool:
	if not storage.established(Storage.system_key(system)):
		return false
	if main_ref != null and system != 1 and not main_ref.open_systems.has(system):
		return false  # a storage in a system that is not open is not reachable
	return true

func count_at(system: int) -> int:
	var n := 0
	for l in _links:
		if int(l["a"]) == system or int(l["b"]) == system:
			n += 1
	return n

func pair_link(a: int, b: int) -> int:
	for l in _links:
		if (int(l["a"]) == a and int(l["b"]) == b) or (int(l["a"]) == b and int(l["b"]) == a):
			return int(l["id"])
	return -1

func _link_by_id(id: int) -> Variant:
	for l in _links:
		if int(l["id"]) == id:
			return l
	return null

## "" if buildable now, else a text id. Hidden feature or bad endpoints give REASON_HIDDEN-like "" only through build_link's -1.
func can_build(a: int, b: int) -> String:
	if a == b or not _usable(a) or not _usable(b):
		return REASON_NEED_STORAGE
	if pair_link(a, b) >= 0:
		return REASON_PAIR
	var mx := _i("link_max_per_storage", 2)
	if count_at(a) >= mx or count_at(b) >= mx:
		return REASON_MAX
	var c := cost()
	if stock_of(a, "rivets") + stock_of(b, "rivets") < int(c["rivets"]) or stock_of(a, "energy") + stock_of(b, "energy") < int(c["energy"]):
		return REASON_GOODS
	return ""

func _auto_mix(a: int, b: int) -> Dictionary:
	var c := cost()
	var mix := {a: {"rivets": 0, "energy": 0}, b: {"rivets": 0, "energy": 0}}
	for g in ["rivets", "energy"]:
		var need := int(c[g])
		var first := a if stock_of(a, g) >= stock_of(b, g) else b
		var second := b if first == a else a
		var t1 := mini(need, stock_of(first, g))
		mix[first][g] = t1
		mix[second][g] = need - t1
	return mix

func build_link(a: int, b: int, mix: Dictionary = {}) -> int:
	last_reason = ""
	if not visible_feature():
		return -1
	var why := can_build(a, b)
	if why != "":
		last_reason = why
		return -1
	if mix.is_empty():
		mix = _auto_mix(a, b)
	var c := cost()
	for g in ["rivets", "energy"]:  # the mix must pay exactly the cost and every storage must hold its share
		var sum := 0
		for s in [a, b]:
			var n := int(mix.get(s, {}).get(g, 0))
			if n < 0 or n > stock_of(s, g):
				last_reason = REASON_GOODS
				return -1
			sum += n
		if sum != int(c[g]):
			last_reason = REASON_GOODS
			return -1
	for s in [a, b]:
		for g in ["rivets", "energy"]:
			storage.remove(Storage.system_key(s), g, int(mix.get(s, {}).get(g, 0)))
	var id := _next_id
	_next_id += 1
	_links.append({"id": id, "a": mini(a, b), "b": maxi(a, b), "state": "active", "dormant": 0, "orders": []})
	link_built.emit(id)
	return id

func remove_link(id: int) -> bool:
	var l = _link_by_id(id)
	if l == null:
		return false
	_links.erase(l)
	link_removed.emit(id)
	return true

func links() -> Array:
	var out := []
	for l in _links:
		out.append(int(l["id"]))
	return out

func state(id: int) -> String:
	var l = _link_by_id(id)
	return "collapsed" if l == null else str(l["state"])

func _other(l: Dictionary, from: int) -> int:
	return int(l["b"]) if from == int(l["a"]) else int(l["a"])

func set_order(id: int, good: String, from_system: int, amount: int) -> bool:
	var l = _link_by_id(id)
	if l == null or not visible_feature() or not Availability.good(good):
		return false
	if from_system != int(l["a"]) and from_system != int(l["b"]):
		return false
	var orders: Array = l["orders"]
	for i in orders.size():
		if str(orders[i]["good"]) == good and int(orders[i]["from"]) == from_system:
			if amount <= 0:
				orders.remove_at(i)
			else:
				orders[i]["amount"] = amount
			link_orders_changed.emit(id)
			return true
	if amount <= 0 or orders.size() >= _i("link_orders_max", 4) or not storage.commodities.has(good):
		return false
	orders.append({"good": good, "from": from_system, "amount": amount})
	link_orders_changed.emit(id)
	return true

func remove_order(id: int, index: int) -> bool:
	var l = _link_by_id(id)
	if l == null or index < 0 or index >= l["orders"].size():
		return false
	l["orders"].remove_at(index)
	link_orders_changed.emit(id)
	return true

func _plan_used(l: Dictionary) -> int:
	var left := rate()
	var used := 0
	for o in l["orders"]:
		var fk := Storage.system_key(int(o["from"]))
		var tk := Storage.system_key(_other(l, int(o["from"])))
		var n := mini(mini(int(o["amount"]), left), mini(storage.amount(fk, str(o["good"])), storage.space(tk, str(o["good"]))))
		n = maxi(0, n)
		used += n
		left -= n
	return used

func link_info(id: int) -> Dictionary:
	var l = _link_by_id(id)
	if l == null:
		return {}
	var orders := []
	for o in l["orders"]:
		orders.append({"good": str(o["good"]), "from": int(o["from"]), "to": _other(l, int(o["from"])), "amount": int(o["amount"])})
	var left := -1
	if str(l["state"]) == "dormant":
		left = maxi(0, _i("link_dormant_limit", 4) - int(l["dormant"]))
	return {"id": id, "a": int(l["a"]), "b": int(l["b"]), "state": str(l["state"]), "dormant": int(l["dormant"]), "cycles_left": left,
		"orders": orders, "rate": rate(), "rate_used": _plan_used(l), "upkeep": upkeep()}

## T227: energy the link upkeep takes from the storage `key` next cycle (read-only; same payer rule as _pay_upkeep).
## `have` is the projected stock of `key`. Used by the Next cycle line so deliveries and drains add up.
func upkeep_drain(key: String, good: String, have: int) -> int:
	if good != "energy":
		return 0
	var total := 0
	for l in _links:
		var a := int(l["a"])
		var b := int(l["b"])
		if Storage.system_key(a) != key and Storage.system_key(b) != key:
			continue
		if not _usable(a) or not _usable(b):
			continue
		var mine := a if Storage.system_key(a) == key else b
		var other := b if mine == a else a
		var other_have := stock_of(other, good)
		if have + other_have - total < upkeep():
			continue  # dormant: pays nothing
		if have - total >= other_have:
			total += mini(upkeep(), have - total)
		else:
			total += maxi(0, upkeep() - other_have)
	return total

## Pays the upkeep: first from the storage with more energy, the rest from the other. False (nothing taken) if the two are short.
func _pay_upkeep(l: Dictionary) -> bool:
	var a := int(l["a"])
	var b := int(l["b"])
	var need := upkeep()
	if stock_of(a, "energy") + stock_of(b, "energy") < need:
		return false
	var first := a if stock_of(a, "energy") >= stock_of(b, "energy") else b
	var second := b if first == a else a
	var got: int = int(storage.remove(Storage.system_key(first), "energy", need))
	storage.remove(Storage.system_key(second), "energy", need - got)
	return true

## Once per cycle from main.gd _end_cycle. Dormant links neither pay nor move; they wake when the energy is back.
func settle() -> void:
	for l in _links.duplicate():
		if not _usable(int(l["a"])) or not _usable(int(l["b"])):
			continue  # an end is not reachable now: the link idles without counting
		if _pay_upkeep(l):
			if str(l["state"]) == "dormant":
				l["state"] = "active"
				l["dormant"] = 0
				link_state_changed.emit(int(l["id"]), "active")
			_transfer(l)
			continue
		l["dormant"] = int(l["dormant"]) + 1
		var limit := _i("link_dormant_limit", 4)
		if int(l["dormant"]) >= limit:
			_links.erase(l)
			link_collapsed.emit(int(l["a"]), int(l["b"]))
			link_state_changed.emit(int(l["id"]), "collapsed")
			link_notice.emit("LNK_NOT_COLLAPSED", {"a": int(l["a"]), "b": int(l["b"])})
			continue
		if str(l["state"]) != "dormant":
			l["state"] = "dormant"
			link_state_changed.emit(int(l["id"]), "dormant")
		if int(l["dormant"]) == 1:
			link_notice.emit("LNK_NOT_DORMANT", {"n": upkeep(), "cycles": limit - 1})
		elif int(l["dormant"]) == limit - 1:
			link_notice.emit("LNK_NOT_LAST", {"n": upkeep()})

func _transfer(l: Dictionary) -> void:
	var left := rate()
	var moved := {}
	for o in l["orders"]:
		if left <= 0:
			break
		var good := str(o["good"])
		var from := int(o["from"])
		var fk := Storage.system_key(from)
		var tk := Storage.system_key(_other(l, from))
		var n := maxi(0, mini(mini(int(o["amount"]), left), mini(storage.amount(fk, good), storage.space(tk, good))))
		if n <= 0:
			continue
		var took: int = storage.remove(fk, good, n)
		var put: int = storage.add(tk, good, took)
		if put < took:  # cannot happen (space was checked); never lose goods
			storage.add(fk, good, took - put)
		left -= put
		moved[good] = int(moved.get(good, 0)) + put
	if not moved.is_empty():
		link_transferred.emit(int(l["id"]), moved)

func to_array() -> Array:
	var out := []
	for l in _links:
		out.append({"id": int(l["id"]), "a": int(l["a"]), "b": int(l["b"]), "state": str(l["state"]), "dormant": int(l["dormant"]), "orders": l["orders"].duplicate(true)})
	return out

## Old saves: no key = no links. Bad entries (unknown good, same ends, too many links) are dropped.
func from_array(saved) -> void:
	_links = []
	_next_id = 1
	if typeof(saved) != TYPE_ARRAY:
		return
	var mx := _i("link_max_per_storage", 2)
	for e in saved:
		if typeof(e) != TYPE_DICTIONARY:
			continue
		var a := int(e.get("a", 0))
		var b := int(e.get("b", 0))
		if a <= 0 or b <= 0 or a == b or pair_link(a, b) >= 0 or count_at(a) >= mx or count_at(b) >= mx:
			continue
		var orders := []
		var olist = e.get("orders", [])
		if typeof(olist) == TYPE_ARRAY:
			for o in olist:
				if typeof(o) == TYPE_DICTIONARY and orders.size() < _i("link_orders_max", 4) and storage.commodities.has(str(o.get("good", ""))) \
						and (int(o.get("from", 0)) == a or int(o.get("from", 0)) == b) and int(o.get("amount", 0)) > 0:
					orders.append({"good": str(o["good"]), "from": int(o["from"]), "amount": int(o["amount"])})
		var id := maxi(1, int(e.get("id", _next_id)))
		if _link_by_id(id) != null:
			id = _next_id
		_next_id = maxi(_next_id, id + 1)
		_links.append({"id": id, "a": mini(a, b), "b": maxi(a, b), "state": "dormant" if str(e.get("state", "")) == "dormant" else "active",
			"dormant": maxi(0, int(e.get("dormant", 0))), "orders": orders})
