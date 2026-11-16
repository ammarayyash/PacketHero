extends Area2D
# KillZone.gd — Pemain jatuh -> Integrity -1 dan pindah ke titik aman terakhir (checkpoint)

@export var damage: int = 1

func _ready() -> void:
	# Layer 4 = Hazard
	collision_layer = 8
	# Mask 2 = Player
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	# Kurangi 1 Integrity (GameState.take_damage otomatis menangani Shield jika aktif)
	GameState.take_damage(damage)
	
	# Ambil posisi checkpoint terakhir
	var cp: Dictionary = GameState.checkpoint
	var pos: Array = cp.get("pos", [160.0, 580.0])
	var target_pos: Vector2 = Vector2(pos[0], pos[1]) if pos.size() >= 2 else Vector2(160.0, 580.0)
	
	# Hentikan gerak jatuh
	if "velocity" in body:
		body.velocity = Vector2.ZERO

	# Pindahkan ke checkpoint
	if GameState.integrity > 0:
		body.global_position = target_pos
		if "_hurt_t" in body:
			body._hurt_t = Config.HURT_COOLDOWN
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/player_hit.ogg")
	else:
		# Jika mati, tempatkan di posisi checkpoint agar tidak terjatuh lebih jauh saat timer layar mati
		body.global_position = target_pos
