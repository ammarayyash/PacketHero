extends CanvasLayer
# DebugPanel.gd — Panel debug in-game (hanya aktif di build debug, toggle dengan F3)

@onready var panel_container : PanelContainer = $PanelContainer
@onready var lbl_stats       : Label          = $PanelContainer/MarginContainer/VBox/LblStats
@onready var chk_dash        : CheckBox       = $PanelContainer/MarginContainer/VBox/ChkDash
@onready var chk_dj          : CheckBox       = $PanelContainer/MarginContainer/VBox/ChkDoubleJump
@onready var chk_shield      : CheckBox       = get_node_or_null("PanelContainer/MarginContainer/VBox/ChkShield")
@onready var btn_teleport    : Button         = $PanelContainer/MarginContainer/VBox/BtnTeleport
@onready var btn_damage      : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridActions/BtnDamage")
@onready var btn_heal        : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridActions/BtnHeal")
@onready var btn_add_coin    : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridActions/BtnAddCoin")
@onready var btn_add_exp     : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridActions/BtnAddExp")
@onready var btn_load        : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridSave/BtnLoad")
@onready var btn_delete_save : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridSave/BtnDeleteSave")
@onready var btn_test_quiz   : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridQuiz/BtnTestQuiz")
@onready var btn_add_hint    : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridQuiz/BtnAddHint")
@onready var btn_test_match  : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridQuiz/BtnTestMatch")
@onready var btn_test_order  : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridQuiz/BtnTestOrder")
@onready var btn_open_shop   : Button         = get_node_or_null("PanelContainer/MarginContainer/VBox/GridQuiz/BtnOpenShop")

var _player    : CharacterBody2D = null
var _spawn_pos : Vector2         = Vector2(160.0, 580.0)

func _ready() -> void:
	# Hanya tampil di build debug
	if not OS.is_debug_build():
		queue_free()
		return

	if panel_container:
		panel_container.visible = false

	# Setup event listener checkbox dan tombol aksi
	if chk_dash:
		chk_dash.toggled.connect(_on_dash_toggled)
	if chk_dj:
		chk_dj.toggled.connect(_on_dj_toggled)
	if chk_shield:
		chk_shield.toggled.connect(func(pressed: bool) -> void:
			GameState.shield = pressed
			GameState.stats_changed.emit()
		)
	if btn_teleport:
		btn_teleport.pressed.connect(_on_teleport_pressed)
	if btn_damage:
		btn_damage.pressed.connect(func() -> void: GameState.take_damage(1))
	if btn_heal:
		btn_heal.pressed.connect(func() -> void: GameState.heal(1))
	if btn_add_coin:
		btn_add_coin.pressed.connect(func() -> void: GameState.add_bandwidth(10))
	if btn_add_exp:
		btn_add_exp.pressed.connect(func() -> void: GameState.add_exp(50))

	# Setup tombol save/load
	if btn_load:
		btn_load.pressed.connect(_on_load_pressed)
	if btn_delete_save:
		btn_delete_save.pressed.connect(_on_delete_save_pressed)

	# Setup tombol uji kuis & hint
	if btn_test_quiz:
		btn_test_quiz.pressed.connect(_on_test_quiz_pressed)
	if btn_add_hint:
		btn_add_hint.pressed.connect(func() -> void:
			GameState.hint_charges += 1
			GameState.stats_changed.emit()
			print("[DebugPanel] Hint charges ditambah: %d" % GameState.hint_charges)
		)
	if btn_test_match:
		btn_test_match.pressed.connect(_on_test_match_pressed)
	if btn_test_order:
		btn_test_order.pressed.connect(_on_test_order_pressed)
	if btn_open_shop:
		btn_open_shop.pressed.connect(_on_open_shop_pressed)

	GameState.stats_changed.connect(_sync_checkboxes)
	_find_player()

func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F3:
			if panel_container:
				panel_container.visible = not panel_container.visible
				if panel_container.visible:
					_sync_checkboxes()

func _process(_delta: float) -> void:
	if panel_container == null or not panel_container.visible or not OS.is_debug_build():
		return

	if _player == null or not is_instance_valid(_player):
		_find_player()
		if _player == null:
			if lbl_stats:
				lbl_stats.text = "Player: Tidak ditemukan"
			return

	var v         : Vector2 = _player.velocity
	var on_fl     : bool    = _player.is_on_floor()
	var coyote    : float   = _player.coyote_t if "coyote_t" in _player else 0.0
	var buffer    : float   = _player.buffer_t if "buffer_t" in _player else 0.0
	var anim_name : String  = _player.anim.animation if (_player.anim and _player.anim.sprite_frames) else "-"
	var booster_info : String = "Aktif (%.1f s)" % _player.booster_t if ("booster_t" in _player and _player.booster_t > 0.0) else "Tidak"

	var state_text : String = "Floor" if on_fl else ("Up" if v.y < 0.0 else "Down")
	if "dash_t" in _player and _player.dash_t > 0.0:
		state_text = "Dash"

	if lbl_stats:
		lbl_stats.text = "=== DEBUG PANEL (F3) ===\n" + \
			"HP        : %d/%d (Shield: %s)\n" % [GameState.integrity, GameState.max_integrity, str(GameState.shield)] + \
			"Energy    : %3.0f / %3.0f\n" % [GameState.energy, GameState.max_energy] + \
			"BW / EXP  : %d BW | %d EXP\n" % [GameState.bandwidth, GameState.exp_points] + \
			"Hints     : %d\n" % GameState.hint_charges + \
			"Booster   : %s (Spd: %.1fx | Jmp: %.1fx)\n" % [booster_info, _player.speed_mult, _player.jump_mult] + \
			"Artifacts : %d | PortKeys: %d\n" % [GameState.artifacts.size(), GameState.port_keys.size()] + \
			"Save File : %s\n" % ("Ada (user://save.json)" if GameState.has_save() else "Kosong / Tidak ada") + \
			"Kecepatan : X: %6.1f | Y: %6.1f\n" % [v.x, v.y] + \
			"State     : %s (Anim: %s)\n" % [state_text, anim_name] + \
			"on_floor  : %s\n" % str(on_fl) + \
			"coyote    : %.2f s\n" % coyote + \
			"buffer    : %.2f s" % buffer

func _find_player() -> void:
	var players : Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player = players[0] as CharacterBody2D
		_spawn_pos = _player.global_position
		_sync_checkboxes()

func _sync_checkboxes() -> void:
	if chk_dash:
		chk_dash.set_pressed_no_signal(GameState.has_dash)
	if chk_dj:
		chk_dj.set_pressed_no_signal(GameState.has_double_jump)
	if chk_shield:
		chk_shield.set_pressed_no_signal(GameState.shield)

func _on_dash_toggled(button_pressed: bool) -> void:
	GameState.has_dash = button_pressed

func _on_dj_toggled(button_pressed: bool) -> void:
	GameState.has_double_jump = button_pressed

func _on_teleport_pressed() -> void:
	if _player and is_instance_valid(_player):
		_player.global_position = _spawn_pos
		_player.velocity = Vector2.ZERO

func _on_load_pressed() -> void:
	if GameState.load_game():
		_sync_checkboxes()
		var cp: Dictionary = GameState.checkpoint
		var pos: Array = cp.get("pos", [])
		if pos.size() >= 2 and _player and is_instance_valid(_player):
			_player.global_position = Vector2(pos[0], pos[1])
			_player.velocity = Vector2.ZERO
		get_tree().call_group("pickup", "reset")
		get_tree().call_group("resettable", "reset")
		print("[DebugPanel] Berhasil memuat progres dari user://save.json")
	else:
		print("[DebugPanel] File user://save.json tidak ditemukan atau gagal diparsing")

func _on_delete_save_pressed() -> void:
	GameState.delete_save()
	print("[DebugPanel] File user://save.json berhasil dihapus")

func _on_test_quiz_pressed() -> void:
	var q: QuizQuestion = QuizDatabase.get_for_layer("L7")
	var ui_scene: PackedScene = load("res://scenes/ui/UI_Quiz.tscn") as PackedScene
	if ui_scene == null:
		push_warning("[DebugPanel] UI_Quiz.tscn tidak ditemukan.")
		return
	var ui: Node = ui_scene.instantiate()
	get_tree().current_scene.add_child(ui)
	ui.finished.connect(func(passed: bool) -> void:
		get_tree().paused = false
		print("[DebugPanel] Kuis selesai. Lulus: %s" % str(passed))
	)
	ui.start(q, "L7")
	get_tree().paused = true

func _on_test_match_pressed() -> void:
	var q: Resource = load("res://resources/questions/L4_MATCH_01.tres")
	var ui_scene: PackedScene = load("res://scenes/ui/UI_Quiz.tscn") as PackedScene
	if ui_scene == null:
		return
	var ui: Node = ui_scene.instantiate()
	get_tree().current_scene.add_child(ui)
	ui.finished.connect(func(passed: bool) -> void:
		get_tree().paused = false
		print("[DebugPanel] Match selesai. Lulus: %s" % str(passed))
	)
	ui.start(q, "L4")
	get_tree().paused = true

func _on_test_order_pressed() -> void:
	var q: Resource = load("res://resources/questions/L1_ORDER_01.tres")
	var ui_scene: PackedScene = load("res://scenes/ui/UI_Quiz.tscn") as PackedScene
	if ui_scene == null:
		return
	var ui: Node = ui_scene.instantiate()
	get_tree().current_scene.add_child(ui)
	ui.finished.connect(func(passed: bool) -> void:
		get_tree().paused = false
		print("[DebugPanel] Order selesai. Lulus: %s" % str(passed))
	)
	ui.start(q, "L1")
	get_tree().paused = true

func _on_open_shop_pressed() -> void:
	var shop_scene: PackedScene = load("res://scenes/ui/UI_Shop.tscn") as PackedScene
	if shop_scene == null:
		return
	var shop: Node = shop_scene.instantiate()
	get_tree().current_scene.add_child(shop)
	get_tree().paused = true
	if shop.has_signal("closed"):
		shop.closed.connect(func(): get_tree().paused = false)



