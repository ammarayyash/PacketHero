extends Area2D
# DataStation.gd — Stasiun pengolahan data (Kompresi & Enkripsi) di Encoding Alley
class_name DataStation

enum StationType { COMPRESSION, ENCRYPTION }

@export var station_type  : StationType = StationType.COMPRESSION
@export var station_title : String      = "STASIUN KOMPRESI"
@export var station_color : Color       = Color(0.2, 0.9, 0.6)

var _feedback_timer : float = 0.0

@onready var sprite       : Sprite2D = get_node_or_null("Sprite2D")
@onready var lbl_title    : Label    = get_node_or_null("TitleLabel")
@onready var lbl_feedback : Label    = get_node_or_null("FeedbackLabel")

func _ready() -> void:
	collision_layer = 32
	collision_mask = 2
	
	if sprite:
		sprite.modulate = station_color
	if lbl_title:
		lbl_title.text = station_title
		lbl_title.add_theme_color_override("font_color", station_color)
	if lbl_feedback:
		lbl_feedback.visible = false
		
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if _feedback_timer > 0.0:
		_feedback_timer -= delta
		if _feedback_timer <= 0.0 and lbl_feedback:
			lbl_feedback.visible = false

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
		
	var item: Node2D = body.get("carried_item")
	if item == null:
		_show_feedback("Bawa Token Data ke sini untuk diproses.", Color(0.8, 0.85, 1.0))
		return
		
	if not (item is TokenData):
		_show_feedback("Item ini bukan Token Data!", Color(1.0, 0.4, 0.4))
		return
		
	var token := item as TokenData
	
	match station_type:
		StationType.COMPRESSION:
			_process_compression(token)
		StationType.ENCRYPTION:
			_process_encryption(token)

func _process_compression(token: TokenData) -> void:
	match token.current_state:
		TokenData.State.RAW:
			token.set_state(TokenData.State.COMPRESSED)
			_show_feedback("Data Berhasil Dikompres!", Color(0.2, 1.0, 0.5))
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/gate_open.ogg")
		TokenData.State.INVALID:
			_show_feedback("Gagal! Data terenkripsi sulit dikompres. Ulangi dari awal!", Color(1.0, 0.3, 0.3))
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/player_hit.ogg")
		TokenData.State.COMPRESSED, TokenData.State.READY:
			_show_feedback("Data sudah terkompres.", Color(0.6, 0.9, 1.0))

func _process_encryption(token: TokenData) -> void:
	match token.current_state:
		TokenData.State.COMPRESSED:
			token.set_state(TokenData.State.READY)
			_show_feedback("Data Berhasil Dienkripsi! (Terkompres + Terenkripsi)", Color(0.8, 0.4, 1.0))
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/checkpoint.ogg")
		TokenData.State.RAW:
			token.set_state(TokenData.State.INVALID)
			_show_feedback("Terenkripsi, sulit dikompres! Harus diulang dari awal.", Color(1.0, 0.3, 0.3))
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/player_hit.ogg")
		TokenData.State.INVALID:
			_show_feedback("Data tidak valid. Harus diulang dari awal!", Color(1.0, 0.3, 0.3))
			if AudioManager:
				AudioManager.play_sfx("res://assets/audio/sfx/player_hit.ogg")
		TokenData.State.READY:
			_show_feedback("Data sudah terenkripsi.", Color(0.8, 0.5, 1.0))

func _show_feedback(msg: String, col: Color) -> void:
	if lbl_feedback:
		lbl_feedback.text = msg
		lbl_feedback.add_theme_color_override("font_color", col)
		lbl_feedback.visible = true
		_feedback_timer = Config.CARRY_SLOT_FEEDBACK_DURATION
