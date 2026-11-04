extends RefCounted
## Company setup: random company names. Pattern "<Place> <Trade> <Kind>", for example "Hollin Freight Concern".
## Deterministic for a given seed; never longer than MAX_LEN. Plain words, no real companies.

const MAX_LEN := 24
const FIRST: Array[String] = ["Hollin", "Quiet", "Brass", "Tallow", "Vesper", "Marrow", "Lantern", "Cobalt", "Ember", "Orrin", "Pale", "Kestrel", "Sable", "Moss", "Tern"]
const TRADE: Array[String] = ["Freight", "Ledger", "Cargo", "Hauling", "Tariff", "Dock", "Ration", "Ballast", "Manifest", "Barter", "Lading", "Quota", "Charter"]
const KIND: Array[String] = ["Concern", "Collective", "Haulage", "Syndicate", "Guild", "Bureau", "Cooperative", "Trust", "Union", "Office"]

## Same seed gives the same name. seed < 0 picks a fresh random seed.
static func generate(seed_value: int = -1) -> String:
	var rng := RandomNumberGenerator.new()
	if seed_value < 0:
		rng.randomize()
	else:
		rng.seed = seed_value
	for _i in 8:
		var n := "%s %s %s" % [FIRST[rng.randi() % FIRST.size()], TRADE[rng.randi() % TRADE.size()], KIND[rng.randi() % KIND.size()]]
		if n.length() <= MAX_LEN:
			return n
	return "%s %s" % [FIRST[rng.randi() % FIRST.size()], KIND[rng.randi() % KIND.size()]]
