extends Area2D
# Boss_BugLord.gd — Boss Pertarungan Final Level 3

signal defeated

@export var max_hp         : int   = 5
@export var attack_cooldown: float = 3.0
@export var bullet_speed   : float = 240.0

var hp          : int   = 5
var _is_defeated: bool  = false
var _fire_timer : float = 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var col : CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	hp = max_hp
	add_to_group("boss")
	add_to_group("enemy")
	set_collision_layer_value(4, true)
	set_collision_mask_value(2, true)
	body_entered.connect(_on_body_entered)
	anim.play("idle")

func _physics_process(delta: float) -> void:
	if _is_defeated:
		return
	
	_fire_timer += delta
	if _fire_timer >= attack_cooldown:
		_fire_timer = 0.0
		_launch_attack()

func _launch_attack() -> void:
	anim.play("laser")
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	
	# Spawn virus projectile
	var players = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player = players[0]
	var dir = (player.global_position - global_position).normalized()
	
	var bullet = Area2D.new()
	bullet.global_position = global_position
	
	var spr = Sprite2D.new()
	var tex = load("res://assets/sprites/boss/virus_projectile.png")
	if tex:
		spr.texture = tex
		spr.scale = Vector2(1.5, 1.5)
	bullet.add_child(spr)
	
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	bullet.add_child(shape)
	
	bullet.set_collision_layer_value(4, true)
	bullet.set_collision_mask_value(2, true)
	bullet.body_entered.connect(func(b):
		if b.is_in_group("player"):
			b.take_hit()
		bullet.queue_free()
	)
	
	get_parent().add_child(bullet)
	
	var tw = bullet.create_tween()
	tw.tween_property(bullet, "global_position", bullet.global_position + dir * 800.0, 800.0 / bullet_speed)
	tw.tween_callback(bullet.queue_free)
	
	await get_tree().create_timer(1.0).timeout
	if not _is_defeated:
		anim.play("idle")

func take_hit(dmg := 1) -> void:
	if _is_defeated:
		return
	hp -= dmg
	var tw = create_tween()
	tw.tween_property(anim, "modulate", Color(2.0, 0.4, 0.4), 0.1)
	tw.tween_property(anim, "modulate", Color.WHITE, 0.1)
	
	if hp <= 0:
		_die()

func _die() -> void:
	_is_defeated = true
	col.set_deferred("disabled", true)
	anim.play("die")
	AudioManager.play_sfx("res://assets/audio/sfx/explosion.ogg")
	GameState.add_exp(500)
	GameState.add_bandwidth(100)
	defeated.emit()
	
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 1.5)
	tw.tween_callback(queue_free)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and not _is_defeated:
		body.take_hit()
