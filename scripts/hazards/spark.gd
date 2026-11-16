extends Area2D
class_name SparkHazard
# spark.gd — Hazard percikan listrik aktif-padam periodik (Layer 4 Hazard, mask 2 Player)

@export var on_time  : float = Config.SPARK_DEFAULT_ON
@export var off_time : float = Config.SPARK_DEFAULT_OFF
@export var damage   : int   = Config.HAZARD_DAMAGE

var _timer     : float = 0.0
var _is_active : bool  = true

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var sprite          : Sprite2D         = get_node_or_null("Sprite2D")
@onready var color_rect      : ColorRect        = get_node_or_null("ColorRect")

func _ready() -> void:
	# Layer 4 = Hazard (bit 4 = 8)
	collision_layer = 8
	# Mask 2 = Player (bit 2 = 2)
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	_set_state(true)

func _physics_process(delta: float) -> void:
	_timer += delta
	if _is_active:
		if _timer >= on_time:
			_timer = 0.0
			_set_state(false)
		else:
			for body in get_overlapping_bodies():
				if body.is_in_group("player"):
					_apply_damage(body)
	else:
		if _timer >= off_time:
			_timer = 0.0
			_set_state(true)

func _set_state(active: bool) -> void:
	_is_active = active
	if collision_shape:
		collision_shape.set_deferred("disabled", not active)
	if sprite:
		sprite.visible = active
	if color_rect:
		color_rect.color = Color(1.0, 0.85, 0.15, 0.95) if active else Color(0.2, 0.2, 0.25, 0.2)

func _on_body_entered(body: Node2D) -> void:
	if _is_active and body.is_in_group("player"):
		_apply_damage(body)

func _apply_damage(body: Node2D) -> void:
	if body.has_method("take_hit"):
		body.take_hit(global_position)
	else:
		GameState.take_damage(damage)
