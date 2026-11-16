extends Node2D
# PopUpTurret.gd — tembak ke pemain setiap beberapa detik

@export var fire_interval := 2.5
@export var bullet_speed  := 220.0

@onready var timer : Timer = $Timer
@onready var anim  : AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("resettable")
	timer.wait_time = fire_interval
	timer.timeout.connect(_fire)
	timer.start()
	anim.play("idle")

func _fire() -> void:
	var players : Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player   : Node2D  = players[0] as Node2D
	var dist     : float   = global_position.distance_to(player.global_position)
	if dist > 700.0:
		return
	var dir      : Vector2 = (player.global_position - global_position).normalized()
	anim.play("shoot")
	get_tree().create_timer(0.4).timeout.connect(func() -> void:
		if is_instance_valid(anim):
			anim.play("idle")
	)

	# Buat projectile sederhana
	var bullet   := ColorRect.new()
	bullet.size  = Vector2(10, 10)
	bullet.color = Color("#FF3DF2")
	var body     := Area2D.new()
	body.global_position = global_position
	body.add_child(bullet)
	var col      := CollisionShape2D.new()
	var shape    := CircleShape2D.new()
	shape.radius = 6.0
	col.shape    = shape
	body.add_child(col)
	body.set_collision_layer_value(4, true)
	body.set_collision_mask_value(2, true)
	body.body_entered.connect(func(b):
		if b.is_in_group("player"): b.take_hit()
		body.queue_free()
	)
	get_parent().add_child(body)

	# Gerakkan bullet via Tween
	var tw := body.create_tween()
	tw.tween_property(body, "global_position",
		body.global_position + dir * 600, 600.0 / bullet_speed)
	tw.tween_callback(body.queue_free)

func reset() -> void:
	timer.start()
