extends Area2D
# SessionLever.gd — Saklar pembuka dan tuas penutup sesi di Session Tower
class_name SessionLever

@export var is_start_switch : bool     = true
@export var manager_path    : NodePath

var _manager        : Node   = null
var _player_in_area : Node2D = null

@onready var sprite     : Sprite2D = get_node_or_null("Sprite2D")
@onready var prompt_lbl : Label    = get_node_or_null("PromptLabel")
@onready var status_lbl : Label    = get_node_or_null("StatusLabel")

func _ready() -> void:
	collision_layer = 32
	collision_mask = 2
	
	if has_node(manager_path):
		_manager = get_node(manager_path)
		
	if prompt_lbl:
		prompt_lbl.visible = false
		prompt_lbl.text = "[E] BUKA SESI" if is_start_switch else "[E] TUTUP SESI"
		
	if status_lbl:
		status_lbl.text = "SAKLAR SESI" if is_start_switch else "TUAS PUNCAK"
		status_lbl.add_theme_color_override("font_color", Color(0.2, 0.85, 1.0, 1.0) if is_start_switch else Color(1.0, 0.85, 0.2, 1.0))
		
	if sprite:
		sprite.modulate = Color(0.2, 0.85, 1.0, 1.0) if is_start_switch else Color(1.0, 0.85, 0.2, 1.0)
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _player_in_area and Input.is_action_just_pressed("interact"):
		_interact()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = body
		if prompt_lbl:
			prompt_lbl.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_area:
		_player_in_area = null
		if prompt_lbl:
			prompt_lbl.visible = false

func _interact() -> void:
	var mgr : Node = _manager if _manager else get_parent()
	if mgr == null:
		return
		
	if is_start_switch:
		if mgr.has_method("start_session"):
			mgr.start_session(_player_in_area)
			if status_lbl:
				status_lbl.text = "SESI AKTIF"
				status_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
	else:
		if mgr.has_method("close_session"):
			mgr.close_session()
			if status_lbl:
				status_lbl.text = "SESI TERTUTUP"
				status_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
			if sprite:
				sprite.modulate = Color(0.2, 1.0, 0.4, 1.0)
			if prompt_lbl:
				prompt_lbl.visible = false
