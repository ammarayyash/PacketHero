extends Node2D
# Level_3.gd

func _ready() -> void:
	AudioManager.play_music("res://assets/audio/music/music_level3.mp3")
	$UI_HUD.set_layer_badge("L2-L1")
	
	var cp = GameState.checkpoint
	if cp.has("pos") and cp.get("level") == scene_file_path:
		var pos = cp["pos"]
		$Player.global_position = Vector2(pos[0], pos[1])

func _process(_delta: float) -> void:
	pass

func _toggle_pause() -> void:
	if has_node("PauseOverlay") and $PauseOverlay.has_method("toggle_pause"):
		$PauseOverlay.toggle_pause()
	else:
		get_tree().paused = not get_tree().paused

func _on_kill_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_hit()
		body.take_hit()

func _on_portal_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		AudioManager.play_sfx("res://assets/audio/sfx/gate_open.ogg")
		# Selesai Level 3 -> Menuju Rank Screen
		SceneTransition.change_scene("res://scenes/ui/UI_RankScreen.tscn")
