extends Area2D
# Pickup.gd — Generic pickup untuk Koin, Energy Cell, Hati, Booster, Artefak, dan Port Key

enum Jenis { COIN, ENERGY_CELL, HEART, BOOSTER, ARTIFACT, PORT_KEY }

@export var jenis : Jenis = Jenis.COIN:
	set(val):
		jenis = val
		if is_node_ready():
			_setup_type()

@export var id : String = "":
	set(val):
		id = val
		if item_id != val:
			item_id = val

@export var item_id : String = "":
	set(val):
		item_id = val
		if id != val:
			id = val

# Backward compatibility jika properti diakses sebagai 'type'
var type : Jenis:
	get: return jenis
	set(val): jenis = val

var _collected     : bool    = false
var _magnet_target : Node2D  = null
var _magnet_speed  : float   = 260.0
var _start_pos     : Vector2 = Vector2.ZERO
var _bob_tween     : Tween   = null

@onready var sprite          : Sprite2D         = get_node_or_null("Sprite2D")
@onready var anim            : AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")
@onready var collision_shape : CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	add_to_group("pickup")
	# Layer 5 = Pickup (bit 5 = 16)
	collision_layer = 16
	# Mask 2 = Player (bit 2 = 2)
	collision_mask = 2

	# Jangan muncul lagi jika artefak atau kunci sudah diambil
	if _should_be_removed():
		queue_free()
		return

	_start_pos = position
	body_entered.connect(_on_body_entered)
	_setup_type()
	_start_bob()

func _should_be_removed() -> bool:
	var key_id: String = item_id if item_id != "" else id
	if key_id != "":
		if jenis == Jenis.ARTIFACT and GameState.artifacts.has(key_id):
			return true
		if jenis == Jenis.PORT_KEY and GameState.port_keys.has(key_id):
			return true
	return false

func _setup_type() -> void:
	if jenis == Jenis.COIN:
		add_to_group("coin")
		if is_in_group("resettable"):
			remove_from_group("resettable")
	elif jenis == Jenis.ENERGY_CELL:
		add_to_group("resettable")
		if is_in_group("coin"):
			remove_from_group("coin")
	else:
		if is_in_group("coin"):
			remove_from_group("coin")
		if is_in_group("resettable"):
			remove_from_group("resettable")

	_update_visual()

func _update_visual() -> void:
	var tex: Texture2D = null
	var tex_scale: Vector2 = Vector2.ONE

	match jenis:
		Jenis.COIN:
			tex = load("res://assets/sprites/items_new/coin_bandwidth.png")
		Jenis.ENERGY_CELL:
			tex = load("res://assets/sprites/items_new/energy_cell.png")
		Jenis.HEART:
			tex = load("res://assets/sprites/ui_new/icons/icon_heart.png")
			tex_scale = Vector2(0.65, 0.65)
		Jenis.BOOSTER:
			if ResourceLoader.exists("res://assets/sprites/items_new/booster.png"):
				tex = load("res://assets/sprites/items_new/booster.png")
			elif ResourceLoader.exists("res://assets/sprites/items/booster.png"):
				tex = load("res://assets/sprites/items/booster.png")
		Jenis.ARTIFACT:
			var art_id: String = item_id if item_id != "" else id
			var specific_path: String = "res://assets/sprites/items_new/%s.png" % art_id.to_lower()
			if art_id != "" and ResourceLoader.exists(specific_path):
				tex = load(specific_path)
			elif ResourceLoader.exists("res://assets/sprites/items_new/artifact_l1.png"):
				tex = load("res://assets/sprites/items_new/artifact_l1.png")
			elif ResourceLoader.exists("res://assets/sprites/items/artifact.png"):
				tex = load("res://assets/sprites/items/artifact.png")
		Jenis.PORT_KEY:
			if ResourceLoader.exists("res://assets/sprites/items_new/port_key.png"):
				tex = load("res://assets/sprites/items_new/port_key.png")
			elif ResourceLoader.exists("res://assets/sprites/items/key_port.png"):
				tex = load("res://assets/sprites/items/key_port.png")

	if sprite and tex:
		sprite.texture = tex
		sprite.scale = tex_scale
	elif anim and tex:
		var sf := SpriteFrames.new()
		if not sf.has_animation("default"):
			sf.add_animation("default")
		else:
			sf.clear("default")
		sf.add_frame("default", tex)
		anim.sprite_frames = sf
		anim.scale = tex_scale

func _start_bob() -> void:
	if _bob_tween and _bob_tween.is_valid():
		_bob_tween.kill()
	_bob_tween = create_tween().set_loops()
	_bob_tween.tween_property(self, "position:y", _start_pos.y - 6.0, 0.7).set_trans(Tween.TRANS_SINE)
	_bob_tween.tween_property(self, "position:y", _start_pos.y, 0.7).set_trans(Tween.TRANS_SINE)

func _physics_process(delta: float) -> void:
	if _magnet_target and not _collected:
		if _bob_tween and _bob_tween.is_valid():
			_bob_tween.kill()
		var dir: Vector2 = (_magnet_target.global_position - global_position).normalized()
		_magnet_speed = min(_magnet_speed + 700.0 * delta, 900.0)
		global_position += dir * _magnet_speed * delta

func attract_to(target: Node2D) -> void:
	if jenis == Jenis.COIN and not _collected:
		_magnet_target = target

func _on_body_entered(body: Node) -> void:
	if _collected or not body.is_in_group("player"):
		return
	_collected = true
	_apply_effect()

	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/ui_confirm.ogg")

	# Efek ambil: tween kecil lalu queue_free (atau hide jika Energy Cell yang dibuat ulang saat reset)
	if _bob_tween and _bob_tween.is_valid():
		_bob_tween.kill()

	var tw := create_tween()
	tw.tween_property(self, "scale", scale * 1.4, 0.1)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.15)

	if jenis == Jenis.ENERGY_CELL:
		tw.tween_callback(_deactivate_for_reset)
	else:
		tw.tween_callback(queue_free)

func _deactivate_for_reset() -> void:
	hide()
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if collision_shape:
		collision_shape.set_deferred("disabled", true)

func reset() -> void:
	# Cek apakah item artefak/kunci ini sudah pernah tersimpan di save/session GameState
	if _should_be_removed():
		queue_free()
		return

	# Energy Cell dibuat ulang / muncul kembali saat reset level
	if jenis == Jenis.ENERGY_CELL:
		_collected = false
		_magnet_target = null
		_magnet_speed = 260.0
		scale = Vector2.ONE
		modulate.a = 1.0
		position = _start_pos
		show()
		set_deferred("monitoring", true)
		set_deferred("monitorable", true)
		if collision_shape:
			collision_shape.set_deferred("disabled", false)
		_start_bob()

func _apply_effect() -> void:
	match jenis:
		Jenis.COIN:
			var bw: int = randi_range(Config.COIN_BW_MIN, Config.COIN_BW_MAX)
			GameState.add_bandwidth(bw)
		Jenis.ENERGY_CELL:
			GameState.energy = min(GameState.energy + Config.ENERGY_CELL_RESTORE, Config.MAX_ENERGY)
			GameState.stats_changed.emit()
		Jenis.HEART:
			GameState.heal(Config.HEART_HEAL_AMOUNT)
		Jenis.BOOSTER:
			var player := get_tree().get_first_node_in_group("player")
			if player and player.has_method("apply_booster"):
				player.apply_booster(Config.BOOSTER_DURATION)
		Jenis.ARTIFACT:
			var art_id: String = item_id if item_id != "" else id
			if art_id != "":
				GameState.artifacts[art_id] = true
			GameState.add_exp(Config.ARTIFACT_EXP)
			GameState.mission_updated.emit()
		Jenis.PORT_KEY:
			var key_id: String = item_id if item_id != "" else id
			if key_id != "":
				GameState.port_keys[key_id] = true
			GameState.add_exp(Config.PORT_KEY_EXP)
			GameState.mission_updated.emit()
