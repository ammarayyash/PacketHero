extends Node2D
# Level_1.gd

@onready var slot_exit_l6: Node = get_node_or_null("Slot_Exit_L6")
@onready var gate_l6: Node = get_node_or_null("QuizGates/GateL6")

var _level_complete_shown: bool = false

func _ready() -> void:
	AudioManager.play_music("res://assets/audio/music/music_level1.mp3")
	$UI_HUD.set_section("Startup Plaza", "Startup Plaza")
	if slot_exit_l6 and gate_l6:
		slot_exit_l6.accepted.connect(func(_id: String) -> void:
			if gate_l6.has_method("unlock_gate"):
				gate_l6.unlock_gate()
		)

	# Posisikan player jika ada checkpoint tersimpan di level ini
	var cp : Dictionary = GameState.checkpoint
	if cp.has("pos") and cp.get("level") == scene_file_path:
		var pos : Array = cp.get("pos", [])
		if pos.size() >= 2:
			$Player.global_position = Vector2(pos[0], pos[1])

@onready var fog_deep: ParallaxLayer = get_node_or_null("ParallaxBG/LayerFogDeep")
@onready var fog_mid: ParallaxLayer = get_node_or_null("ParallaxBG/LayerFogMid")
@onready var fog_low: ParallaxLayer = get_node_or_null("ParallaxBG/LayerFogLow")

func _process(delta: float) -> void:
	# Efek kabut melayang halus secara atmosferik
	if fog_deep:
		fog_deep.motion_offset.x -= 8.0 * delta
	if fog_mid:
		fog_mid.motion_offset.x -= 16.0 * delta
	if fog_low:
		fog_low.motion_offset.x -= 26.0 * delta

func _toggle_pause() -> void:
	if has_node("PauseOverlay") and $PauseOverlay.has_method("toggle_pause"):
		$PauseOverlay.toggle_pause()
	else:
		get_tree().paused = not get_tree().paused

func _on_kill_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameState.take_damage(GameState.integrity)

func _on_portal_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not _level_complete_shown:
		_level_complete_shown = true
		GameState.record_finish_reached()
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/gate_open.ogg")
		var lc_scene: PackedScene = load("res://scenes/ui/UI_LevelComplete.tscn") as PackedScene
		if lc_scene:
			var lc: Node = lc_scene.instantiate()
			add_child(lc)
			get_tree().paused = true
		else:
			SceneTransition.change_scene("res://scenes/Level_2.tscn", 0.5)
