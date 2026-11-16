extends Area2D
# SpamDrone.gd — patroli dua titik

@export var point_a : Vector2 = Vector2(-150, 0)
@export var point_b : Vector2 = Vector2(150, 0)
@export var speed   : float   = 90.0

var _target   := Vector2.ZERO
var _start_pos := Vector2.ZERO

@onready var anim : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("resettable")
	add_to_group("enemy")
	set_collision_layer_value(3, true)
	set_collision_mask_value(2, true)
	_start_pos = global_position
	_target    = _start_pos + point_b
	body_entered.connect(_on_body_entered)
	anim.play("fly")

func _physics_process(delta: float) -> void:
	var dir := (_target - global_position)
	if dir.length() < 4.0:
		_target = _start_pos + (point_a if _target == _start_pos + point_b else point_b)
	global_position += dir.normalized() * speed * delta
	anim.flip_h = dir.x < 0

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.take_hit()

func reset() -> void:
	global_position = _start_pos
	_target = _start_pos + point_b
