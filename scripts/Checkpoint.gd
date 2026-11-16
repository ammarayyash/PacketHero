extends Area2D
# Checkpoint.gd — Titik Simpan & Pemulihan Paket Data Hero

var _activated      : bool   = false
var _player_in_area : Node2D = null

@export var checkpoint_id  : int     = 0
@export var is_shop        : bool    = true
@export var respawn_offset : Vector2 = Vector2(0.0, -10.0)

@onready var sprite          : Sprite2D = get_node_or_null("Sprite2D")
@onready var sprite_off      : Sprite2D = get_node_or_null("SpriteOff")
@onready var sprite_on       : Sprite2D = get_node_or_null("SpriteOn")
@onready var status_light    : CanvasItem = get_node_or_null("StatusLight")
@onready var status_label    : Label    = get_node_or_null("StatusLabel")
@onready var interact_prompt : Label    = get_node_or_null("InteractPrompt")

func _ready() -> void:
	# Layer 6 = Trigger
	collision_layer = 32
	# Mask 2 = Player
	collision_mask = 2
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visual(false)

func _process(_delta: float) -> void:
	if _player_in_area and is_shop and Input.is_action_just_pressed("interact"):
		_open_shop()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_area = body
	if interact_prompt and is_shop:
		interact_prompt.visible = true
	if not _activated:
		_activated = true
		var cur_scene_path: String = ""
		if get_tree().current_scene:
			cur_scene_path = get_tree().current_scene.scene_file_path
		GameState.checkpoint = {
			"level": cur_scene_path,
			"pos":   [global_position.x + respawn_offset.x, global_position.y + respawn_offset.y]
		}
		# Autosave saat checkpoint aktif
		GameState.save_game()
		_update_visual(true)
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/checkpoint.ogg")

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_area:
		_player_in_area = null
		if interact_prompt:
			interact_prompt.visible = false

func _update_visual(animate: bool = false) -> void:
	if sprite_off and sprite_on:
		sprite_off.visible = not _activated
		sprite_on.visible  = _activated
	elif sprite:
		sprite.modulate = Color(0.25, 1.0, 0.5, 1.0) if _activated else Color(0.55, 0.65, 0.75, 0.75)

	if status_light:
		status_light.modulate = Color(0.2, 1.0, 0.4, 1.0) if _activated else Color(0.85, 0.2, 0.2, 0.8)

	if status_label:
		status_label.text = "ONLINE" if _activated else "STANDBY"
		status_label.add_theme_color_override("font_color",
			Color(0.25, 1.0, 0.5, 1.0) if _activated else Color(0.65, 0.7, 0.75, 0.8))

	if animate:
		var target: Node2D = sprite_on if (sprite_on and sprite_on.visible) else sprite
		if target:
			var base_scale: Vector2 = target.scale
			var tw := create_tween()
			tw.tween_property(target, "scale", base_scale * 1.25, 0.1)
			tw.tween_property(target, "scale", base_scale, 0.15)

func _open_shop() -> void:
	var shop_scene: PackedScene = load("res://scenes/ui/UI_Shop.tscn") as PackedScene
	if shop_scene:
		var shop: Node = shop_scene.instantiate()
		get_tree().current_scene.add_child(shop)
		get_tree().paused = true
		if shop.has_signal("closed"):
			shop.closed.connect(func(): get_tree().paused = false)
