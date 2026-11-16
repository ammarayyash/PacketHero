extends Area2D
class_name Projectile
# projectile.gd — Proyektil lambat dari PopUpTurret (Layer 4 Hazard, mask 1 World & 2 Player)

@export var speed  : float = Config.PROJECTILE_SPEED
@export var damage : int   = Config.PROJECTILE_DAMAGE

var direction : Vector2 = Vector2.LEFT

func _ready() -> void:
	# Layer 4 = Hazard (bit 4 = 8)
	collision_layer = 8
	# Mask 1 = World (bit 1 = 1) dan Mask 2 = Player (bit 2 = 2) -> 1 + 2 = 3
	collision_mask = 3

	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

	# Auto-destroy setelah 6 detik agar tidak menumpuk di memori
	get_tree().create_timer(6.0).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_hit"):
			body.take_hit(global_position)
		else:
			GameState.take_damage(damage)
		queue_free()
	elif not body.is_in_group("enemy"):
		# Menabrak dinding / terrain -> hilang
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	var parent_body: Node = area.get_parent()
	if parent_body and parent_body.is_in_group("player"):
		if parent_body.has_method("take_hit"):
			parent_body.take_hit(global_position)
		else:
			GameState.take_damage(damage)
		queue_free()
