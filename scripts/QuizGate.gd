extends Area2D
# QuizGate.gd — Gerbang Kuis Edukasi Model OSI

signal gate_cleared(layer_id: String)

@export var layer_id    : String = "L7"
@export var gate_color  : Color  = Color("#39E6FF")
@export var locked      : bool   = false

var _opened      : bool = false
var _quiz_active : bool = false

@onready var sprite_closed : Sprite2D         = get_node_or_null("SpriteClosed")
@onready var sprite_open   : Sprite2D         = get_node_or_null("SpriteOpen")
@onready var col           : CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var gate_label    : Label            = get_node_or_null("GateLabel")

func _ready() -> void:
	add_to_group("quiz_gate")
	add_to_group("resettable")

	# Layer 6 = Trigger (bit 6 = 32), Mask 2 = Player (bit 2 = 2)
	collision_layer = 32
	collision_mask = 2

	body_entered.connect(_on_body_entered)
	GameState.stats_changed.connect(_on_stats_changed)

	_update_gate_visuals()

	# Jika sudah dibuka sebelumnya (misal load dari save file)
	if GameState.gates_cleared.has(layer_id):
		_open_gate(false)
	else:
		_close_gate()

func _update_gate_visuals() -> void:
	if gate_label:
		gate_label.text = "GATE %s" % layer_id
		gate_label.modulate = gate_color

	var gate_tex_map := {
		"L1": "res://assets/sprites/environment_new/gate_l1_physical.png",
		"L2": "res://assets/sprites/environment_new/gate_l2_datalink.png",
		"L3": "res://assets/sprites/environment_new/gate_l3_network.png",
		"L4": "res://assets/sprites/environment_new/gate_l4_transport.png",
		"L5": "res://assets/sprites/environment_new/gate_l5_session.png",
		"L6": "res://assets/sprites/environment_new/gate_l6_presentation.png",
		"L7": "res://assets/sprites/environment_new/gate_l7_application.png"
	}
	if gate_tex_map.has(layer_id):
		var tex_path: String = gate_tex_map[layer_id]
		if ResourceLoader.exists(tex_path):
			var tex: Texture2D = load(tex_path)
			if tex and sprite_closed:
				sprite_closed.texture = tex
				sprite_closed.modulate = Color.WHITE
	else:
		if sprite_closed:
			sprite_closed.modulate = gate_color

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return

	# Jika gerbang sudah terbuka
	if _opened or GameState.gates_cleared.has(layer_id):
		if not _opened:
			_open_gate(false)
		return

	if locked and not GameState.gates_cleared.has(layer_id):
		if gate_label:
			gate_label.text = "TERKUNCI"
			gate_label.modulate = Color(1.0, 0.3, 0.3)
		return

	if _quiz_active:
		return

	_start_quiz()

func unlock_gate() -> void:
	locked = false
	if gate_label:
		gate_label.text = "SIAP: %s" % layer_id
		gate_label.modulate = Color(0.3, 1.0, 0.5)

func _start_quiz() -> void:
	_quiz_active = true
	get_tree().paused = true

	var ui_scene: PackedScene = load("res://scenes/ui/UI_Quiz.tscn") as PackedScene
	if ui_scene == null:
		push_warning("QuizGate: UI_Quiz.tscn tidak ditemukan.")
		get_tree().paused = false
		_quiz_active = false
		return

	var ui: Node = ui_scene.instantiate()
	get_tree().current_scene.add_child(ui)
	ui.finished.connect(_on_quiz_finished)

	var q: QuizQuestion = QuizDatabase.get_for_layer(layer_id)
	ui.start(q, layer_id)

func _on_quiz_finished(passed: bool) -> void:
	_quiz_active = false
	get_tree().paused = false

	if passed:
		GameState.gates_cleared[layer_id] = true
		GameState.gate_cleared.emit(layer_id)
		gate_cleared.emit(layer_id)

		_activate_checkpoint()
		_open_gate(true)
	else:
		# Jika gagal (misal Integrity 0 atau mati), kuis tetap dapat diulang saat masuk lagi
		_close_gate()

func _activate_checkpoint() -> void:
	var cur_scene_path: String = ""
	if get_tree().current_scene:
		cur_scene_path = get_tree().current_scene.scene_file_path
	GameState.checkpoint = {
		"level": cur_scene_path,
		"pos":   [global_position.x, global_position.y]
	}
	GameState.save_game()
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/checkpoint.ogg")

func _open_gate(animate: bool = true) -> void:
	_opened = true
	if col:
		col.set_deferred("disabled", true)

	if sprite_closed:
		if animate:
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/gate_open.ogg")
			var tw := create_tween()
			tw.tween_property(sprite_closed, "modulate:a", 0.0, 0.4)
			tw.parallel().tween_property(sprite_closed, "scale", Vector2(1.15, 1.15), 0.4)
			tw.tween_callback(func() -> void:
				if sprite_closed:
					sprite_closed.visible = false
				if sprite_open:
					sprite_open.visible = true
			)
		else:
			sprite_closed.visible = false
			if sprite_open:
				sprite_open.visible = true
	if gate_label:
		gate_label.text = "TERBUKA"
		gate_label.modulate = Color(0.3, 1.0, 0.4)

func _close_gate() -> void:
	_opened = false
	if col:
		col.set_deferred("disabled", false)
	if sprite_closed:
		sprite_closed.visible = true
		sprite_closed.modulate.a = 1.0
		sprite_closed.scale = Vector2.ONE
	if sprite_open:
		sprite_open.visible = false
	if gate_label:
		gate_label.text = "GATE %s" % layer_id
		gate_label.modulate = gate_color

func reset() -> void:
	if GameState.gates_cleared.has(layer_id):
		_open_gate(false)
	else:
		_close_gate()

func _on_stats_changed() -> void:
	if GameState.gates_cleared.has(layer_id) and not _opened:
		_open_gate(false)
