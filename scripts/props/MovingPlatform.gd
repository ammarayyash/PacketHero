extends AnimatableBody2D
# MovingPlatform.gd — Platform bergerak bolak-balik untuk rintangan platforming
class_name MovingPlatform

@export var move_distance : Vector2 = Vector2(160.0, 0.0)
@export var speed         : float   = 55.0
@export var pause_time    : float   = 0.5
@export var plat_texture  : Texture2D = null

var _start_pos  : Vector2 = Vector2.ZERO
var _target_pos : Vector2 = Vector2.ZERO
var _forward    : bool    = true
var _pause_t    : float   = 0.0

@onready var sprite : Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	collision_layer = 1
	collision_mask = 0
	sync_to_physics = true
	
	_start_pos = global_position
	_target_pos = _start_pos + move_distance
	
	if plat_texture and sprite:
		sprite.texture = plat_texture

func _physics_process(delta: float) -> void:
	if _pause_t > 0.0:
		_pause_t -= delta
		return
		
	var dest := _target_pos if _forward else _start_pos
	global_position = global_position.move_toward(dest, speed * delta)
	
	if global_position.distance_to(dest) < 1.0:
		_forward = not _forward
		_pause_t = pause_time
