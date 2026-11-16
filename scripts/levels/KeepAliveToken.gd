extends Area2D
# KeepAliveToken.gd — Token keep-alive penambah waktu +10 detik di Session Tower
class_name KeepAliveToken

@export var manager_path : NodePath
@export var time_bonus   : float = 10.0

var _manager : Node = null

@onready var sprite : Sprite2D         = get_node_or_null("Sprite2D")
@onready var col    : CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var lbl    : Label            = get_node_or_null("Label")

func _ready() -> void:
	add_to_group("keep_alive_token")
	add_to_group("resettable")
	
	collision_layer = 32
	collision_mask = 2
	
	if has_node(manager_path):
		_manager = get_node(manager_path)
		
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	if _manager and _manager.has_method("add_time"):
		_manager.add_time(time_bonus)
	elif get_parent() and get_parent().has_method("add_time"):
		get_parent().add_time(time_bonus)
		
	visible = false
	if col:
		col.set_deferred("disabled", true)

func reset_token() -> void:
	visible = true
	if col:
		col.set_deferred("disabled", false)

func reset() -> void:
	reset_token()
