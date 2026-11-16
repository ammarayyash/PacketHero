extends Node

signal stats_changed
signal player_died
signal gate_cleared(layer_id: String)
signal mission_updated

# --- Atribut utama ---
var integrity     : int   = 3
var max_integrity : int   = 3
var bandwidth     : int   = 0
var exp_points    : int   = 0
var energy        : float = 100.0
var max_energy    : float = 100.0
var shield        : bool  = false

# --- Misi & Progres Lapisan ---
var talked_to_admin    : bool = false
var enemies_defeated   : int  = 0
var finish_reached     : bool = false

# --- Skill (unlock di toko) ---
var has_dash        : bool  = true
var has_double_jump : bool  = true
var magnet_radius   : float = 90.0
var hint_charges    : int   = 0

# --- Koleksi & progres ---
var artifacts       : Dictionary = {}   # id -> true
var port_keys       : Dictionary = {}   # id -> true
var gates_cleared   : Dictionary = {}   # 'L7' -> true
var education_cards : Dictionary = {}   # card_id -> true
var checkpoint      : Dictionary = {"level": "res://scenes/Level_1.tscn", "pos": [160.0, 480.0]}
var boss_phase      : int        = 1

func unlock_card(card_id: String) -> void:
	education_cards[card_id] = true
	save_game()

# --- Timer regen energy ---
var _idle_e_t : float = 0.0

func _process(delta: float) -> void:
	_idle_e_t += delta
	if _idle_e_t >= Config.ENERGY_REGEN_DELAY and energy < Config.MAX_ENERGY:
		energy = min(energy + Config.ENERGY_REGEN * delta, Config.MAX_ENERGY)
		stats_changed.emit()

# ─────────────────────────────────────────────
func use_energy(cost: float) -> bool:
	if energy < cost:
		return false
	energy -= cost
	_idle_e_t = 0.0
	stats_changed.emit()
	return true

func take_damage(n: int = 1) -> void:
	if shield:
		shield = false
	else:
		integrity = max(integrity - n, 0)
	stats_changed.emit()
	if integrity == 0:
		player_died.emit()

func heal(n: int = 1) -> void:
	integrity = min(integrity + n, max_integrity)
	stats_changed.emit()

func reset_for_respawn() -> void:
	integrity = max_integrity
	stats_changed.emit()

func clear_gate(layer_id: String) -> void:
	gates_cleared[layer_id] = true
	gate_cleared.emit(layer_id)
	stats_changed.emit()
	mission_updated.emit()

func add_exp(n: int) -> void:
	exp_points += n
	stats_changed.emit()

func add_bandwidth(n: int) -> void:
	bandwidth += n
	stats_changed.emit()
	mission_updated.emit()

func can_buy_item(item_id: String) -> bool:
	match item_id:
		"shield":
			return not shield
		"integrity":
			return max_integrity < Config.MAX_INTEGRITY
		"hint":
			return true
		"double_jump":
			return not has_double_jump
		"dash":
			return not has_dash
		"magnet":
			return magnet_radius < Config.COIN_MAGNET_UPGRADED
		_:
			return false

func apply_item_effect(item_id: String) -> bool:
	if not can_buy_item(item_id):
		return false
	match item_id:
		"shield":
			shield = true
		"integrity":
			max_integrity = min(max_integrity + 1, Config.MAX_INTEGRITY)
			heal(1)
		"hint":
			hint_charges += 1
		"double_jump":
			has_double_jump = true
		"dash":
			has_dash = true
		"magnet":
			magnet_radius = Config.COIN_MAGNET_UPGRADED
	stats_changed.emit()
	return true

func record_admin_talk() -> void:
	if not talked_to_admin:
		talked_to_admin = true
		stats_changed.emit()
		mission_updated.emit()

func record_enemy_defeated() -> void:
	enemies_defeated += 1
	stats_changed.emit()
	mission_updated.emit()

func record_finish_reached() -> void:
	finish_reached = true
	stats_changed.emit()
	mission_updated.emit()

# ─────────────────────────────────────────────
func final_score() -> int:
	return exp_points + 300 * artifacts.size() + 100 * integrity + int(0.5 * bandwidth)

func get_rank() -> String:
	var s := final_score()
	if s >= 3500: return "S"
	if s >= 2800: return "A"
	if s >= 2000: return "B"
	return "C"

# ── Serialization & Penyimpanan ───────────────
func to_dict() -> Dictionary:
	var cp_pos: Array = []
	if checkpoint.has("pos"):
		if checkpoint["pos"] is Vector2:
			cp_pos = [checkpoint["pos"].x, checkpoint["pos"].y]
		elif checkpoint["pos"] is Array:
			cp_pos = checkpoint["pos"]
		else:
			cp_pos = [160.0, 580.0]
	else:
		cp_pos = [160.0, 580.0]

	return {
		"integrity": integrity,
		"max_integrity": max_integrity,
		"bandwidth": bandwidth,
		"exp_points": exp_points,
		"energy": energy,
		"shield": shield,
		"has_dash": has_dash,
		"has_double_jump": has_double_jump,
		"magnet_radius": magnet_radius,
		"hint_charges": hint_charges,
		"artifacts": artifacts.duplicate(true),
		"port_keys": port_keys.duplicate(true),
		"gates_cleared": gates_cleared.duplicate(true),
		"education_cards": education_cards.duplicate(true),
		"checkpoint": {
			"level": checkpoint.get("level", "res://scenes/TestLevel.tscn"),
			"pos":   cp_pos
		},
		"boss_phase": boss_phase,
		"talked_to_admin": talked_to_admin,
		"enemies_defeated": enemies_defeated,
		"finish_reached": finish_reached,
	}

func from_dict(data: Dictionary) -> void:
	if data == null or data.is_empty():
		return
	integrity        = int(data.get("integrity", 3))
	max_integrity    = int(data.get("max_integrity", 3))
	bandwidth        = int(data.get("bandwidth", 0))
	exp_points       = int(data.get("exp_points", 0))
	energy           = float(data.get("energy", 100.0))
	shield           = bool(data.get("shield", false))
	has_dash         = bool(data.get("has_dash", true))
	has_double_jump  = bool(data.get("has_double_jump", true))
	magnet_radius    = float(data.get("magnet_radius", 90.0))
	hint_charges     = int(data.get("hint_charges", 0))
	artifacts        = data.get("artifacts", {}).duplicate(true)
	port_keys        = data.get("port_keys", {}).duplicate(true)
	gates_cleared    = data.get("gates_cleared", {}).duplicate(true)
	education_cards  = data.get("education_cards", {}).duplicate(true)
	boss_phase       = int(data.get("boss_phase", 1))
	talked_to_admin  = bool(data.get("talked_to_admin", false))
	enemies_defeated = int(data.get("enemies_defeated", 0))
	finish_reached   = bool(data.get("finish_reached", false))

	var raw_cp = data.get("checkpoint", {})
	if raw_cp is Dictionary:
		var pos_arr: Array = raw_cp.get("pos", [160.0, 580.0])
		checkpoint = {
			"level": str(raw_cp.get("level", "res://scenes/TestLevel.tscn")),
			"pos":   pos_arr
		}

	stats_changed.emit()
	mission_updated.emit()

func save_game() -> void:
	var data: Dictionary = to_dict()
	var json_str: String = JSON.stringify(data, "\t")
	var f := FileAccess.open("user://save.json", FileAccess.WRITE)
	if f:
		f.store_string(json_str)
		f.close()

func load_game() -> bool:
	if not FileAccess.file_exists("user://save.json"):
		return false
	var f := FileAccess.open("user://save.json", FileAccess.READ)
	if not f:
		return false
	var text: String = f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		from_dict(parsed)
		return true
	return false

func delete_save() -> void:
	if FileAccess.file_exists("user://save.json"):
		DirAccess.remove_absolute("user://save.json")

func has_save() -> bool:
	return FileAccess.file_exists("user://save.json")

func reset() -> void:
	integrity        = 3
	max_integrity    = 3
	bandwidth        = 0
	exp_points       = 0
	energy           = 100.0
	shield           = false
	has_dash         = true
	has_double_jump  = true
	magnet_radius    = 90.0
	hint_charges     = 0
	artifacts        = {}
	port_keys        = {}
	gates_cleared    = {}
	education_cards  = {}
	checkpoint       = {"level": "res://scenes/Level_1.tscn", "pos": [160.0, 300.0]}
	boss_phase       = 1
	talked_to_admin  = false
	enemies_defeated = 0
	finish_reached   = false
	stats_changed.emit()
	mission_updated.emit()
