extends EnemyBase
class_name PopUpTurret
# popup_turret.gd — Turret diam, menembak proyektil lambat setiap 2 detik bila dalam jangkauan (bisa diinjak)

@export var fire_interval : float = Config.TURRET_FIRE_INTERVAL
@export var detect_range  : float = Config.TURRET_DETECT_RANGE

var _fire_timer : float = 0.0

func _ready() -> void:
	can_patrol = false
	move_speed = 0.0
	is_flying  = false
	super._ready()
	_fire_timer = fire_interval
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")

func _physics_process(delta: float) -> void:
	if not _is_alive:
		return

	# Turret diam di tempat pada lantai
	if not is_on_floor():
		velocity.y = min(velocity.y + Config.GRAVITY * delta, 1200.0)
	else:
		velocity.y = 0.0
	velocity.x = 0.0
	move_and_slide()

	# Timer tembak setiap 2 detik
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = fire_interval
		_check_and_fire()

func _check_and_fire() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player: Node2D = players[0] as Node2D
	if not player:
		return

	var dist: float = global_position.distance_to(player.global_position)
	if dist <= detect_range:
		var dir: Vector2 = (player.global_position - global_position).normalized()

		if anim:
			anim.flip_h = (dir.x > 0)
			if anim.sprite_frames and anim.sprite_frames.has_animation("shoot"):
				anim.play("shoot")

		_spawn_projectile(dir)

		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/laser_active.ogg")

		# Kembali ke animasi idle setelah jeda tembak 0.4s agar terbaca jelas bagi pemain
		await get_tree().create_timer(0.4).timeout
		if _is_alive and anim and anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
			anim.play("idle")

func _spawn_projectile(dir: Vector2) -> void:
	var proj_scene: PackedScene = load("res://scenes/enemies/Projectile.tscn") as PackedScene
	if proj_scene:
		var proj: Projectile = proj_scene.instantiate() as Projectile
		if proj:
			proj.direction = dir
			proj.global_position = global_position + dir * 16.0
			get_parent().add_child(proj)

func reset() -> void:
	_fire_timer = fire_interval
	super.reset()
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
