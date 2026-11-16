extends Area2D
class_name DataCorruptionPool
# data_corruption_pool.gd — Kolam korupsi data diam (Layer 4 Hazard, Mask 2 Player)

@export var damage : int = Config.HAZARD_DAMAGE

func _ready() -> void:
	# Layer 4 = Hazard (bit 4 = 8)
	collision_layer = 8
	# Mask 2 = Player (bit 2 = 2)
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	# Berikan damage berkala jika pemain tetap berdiri di dalam kolam
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_apply_damage(body)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_apply_damage(body)

func _apply_damage(body: Node2D) -> void:
	if body.has_method("take_hit"):
		body.take_hit(global_position)
	else:
		GameState.take_damage(damage)
