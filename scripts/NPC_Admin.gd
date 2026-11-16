extends CharacterBody2D
class_name NPC_Admin
# NPC_Admin.gd — AI NPC Pak Admin: Patroli, menyapa pemain saat mendekat, berinteraksi dan berbicara

@export var patrol_range   : float = 110.0
@export var patrol_speed   : float = 38.0
@export var talk_radius    : float = 95.0

const GRAVITY : float = 980.0

var _spawn_x       : float = 0.0
var _patrol_dir   : float = 1.0
var _dialog_index : int   = 0

const DIALOG_LIST := [
	"Halo Pak E! Selamat datang di Kota Data (OSI Layer)!\nGunakan [A/D] jalan, [SPACE] lompat, [SHIFT] dash!",
	"Waspadalah terhadap Malware dan Noise Bat di atas jurang!\nKumpulkan Koin Bandwidth untuk upgrade di Checkpoint!",
	"Setiap Gerbang memerlukan verifikasi kuis protokol.\nSelesaikan kuis untuk membuka segel lapisan berikutnya!"
]

@onready var anim      : AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_lbl: Label            = get_node_or_null("Label")
@onready var bubble_bg : ColorRect        = get_node_or_null("BubbleBg")

func _ready() -> void:
	_spawn_x = global_position.x
	add_to_group("npc")
	
	# Layer 0 (tidak menabrak player agar tidak mendorong player)
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, false)
	# Mask 1 = Lantai/World agar bisa berdiri & berjalan di atas platform
	set_collision_mask_value(1, true)
	
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
		anim.play("idle")
	
	_update_dialog_text()

func _physics_process(delta: float) -> void:
	# Terapkan gravitasi agar menapak di lantai
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	var player := _get_player()
	var dist := 9999.0
	if player:
		dist = global_position.distance_to(player.global_position)

	if dist <= talk_radius and player != null:
		# Dekat dengan pemain: Berhenti dan tatap pemain
		velocity.x = 0.0
		GameState.record_admin_talk()
		var facing_left : bool = (player.global_position.x < global_position.x)
		if anim:
			anim.flip_h = facing_left
			if anim.sprite_frames and anim.sprite_frames.has_animation("talk"):
				if anim.animation != "talk":
					anim.play("talk")

		if dialog_lbl:
			dialog_lbl.visible = true
		if bubble_bg:
			bubble_bg.visible = true

		# Interaksi tombol E / Enter untuk ganti dialog
		if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("ui_accept"):
			_cycle_dialog()

	else:
		# Pemain jauh: Patroli jalan santai bolak-balik
		if global_position.x > _spawn_x + patrol_range:
			_patrol_dir = -1.0
		elif global_position.x < _spawn_x - patrol_range:
			_patrol_dir = 1.0

		if is_on_wall():
			_patrol_dir *= -1.0

		velocity.x = _patrol_dir * patrol_speed
		if anim:
			anim.flip_h = (_patrol_dir < 0)
			if anim.sprite_frames and anim.sprite_frames.has_animation("idle"):
				if anim.animation != "idle":
					anim.play("idle")

		# Sembunyikan bubble dialog saat pemain jauh
		if dialog_lbl:
			dialog_lbl.visible = false
		if bubble_bg:
			bubble_bg.visible = false

	move_and_slide()

func _cycle_dialog() -> void:
	_dialog_index = (_dialog_index + 1) % DIALOG_LIST.size()
	_update_dialog_text()
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

func _update_dialog_text() -> void:
	if dialog_lbl:
		dialog_lbl.text = "Pak Admin:\n\"%s\"\n[Tekan E / SPACE untuk lanjut]" % DIALOG_LIST[_dialog_index]

func _get_player() -> Node2D:
	var players : Array[Node] = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		return players[0] as Node2D
	return null
