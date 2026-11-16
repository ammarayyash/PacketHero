extends Area2D
# TerminalL7.gd — Mengelola pengantaran 3 lencana protokol HTTP Boulevard dan aktivasi QuizGate L7
class_name TerminalL7

signal all_slots_cleared

@export var slot_web_path  : NodePath
@export var slot_mail_path : NodePath
@export var slot_dns_path  : NodePath
@export var gate_l7_path   : NodePath

var is_activated     : bool   = false
var _player_in_area  : bool   = false
var _dialog_instance : Node   = null

var _slot_web  : Node = null
var _slot_mail : Node = null
var _slot_dns  : Node = null
var _gate_l7   : Node = null

@onready var sprite     : Sprite2D = get_node_or_null("Sprite2D")
@onready var prompt_lbl : Label    = get_node_or_null("PromptLabel")
@onready var status_lbl : Label    = get_node_or_null("StatusLabel")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	collision_layer = 32
	collision_mask = 2
	
	if prompt_lbl:
		prompt_lbl.visible = false
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	call_deferred("_bind_nodes")

func _bind_nodes() -> void:
	if has_node(slot_web_path):
		_slot_web = get_node(slot_web_path)
		if _slot_web and _slot_web.has_signal("accepted"):
			_slot_web.accepted.connect(_check_slots)
			
	if has_node(slot_mail_path):
		_slot_mail = get_node(slot_mail_path)
		if _slot_mail and _slot_mail.has_signal("accepted"):
			_slot_mail.accepted.connect(_check_slots)
			
	if has_node(slot_dns_path):
		_slot_dns = get_node(slot_dns_path)
		if _slot_dns and _slot_dns.has_signal("accepted"):
			_slot_dns.accepted.connect(_check_slots)
			
	if has_node(gate_l7_path):
		_gate_l7 = get_node(gate_l7_path)
		if _gate_l7 and not is_activated and not GameState.gates_cleared.has("L7"):
			_gate_l7.set("locked", true)
			
	_check_slots("")

func _process(_delta: float) -> void:
	if _player_in_area and _dialog_instance == null and Input.is_action_just_pressed("interact"):
		_interact()

func _count_filled() -> int:
	var count : int = 0
	if _slot_web and _slot_web.get("is_filled"):
		count += 1
	if _slot_mail and _slot_mail.get("is_filled"):
		count += 1
	if _slot_dns and _slot_dns.get("is_filled"):
		count += 1
	return count

func _check_slots(_dummy: String = "") -> void:
	var count := _count_filled()
	if count >= 3 or GameState.gates_cleared.has("L7"):
		if not is_activated:
			is_activated = true
			if sprite:
				sprite.modulate = Color(0.2, 1.0, 0.4, 1.0)
			if status_lbl:
				status_lbl.text = "ONLINE"
				status_lbl.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))
			if _gate_l7 and _gate_l7.has_method("unlock_gate"):
				_gate_l7.unlock_gate()
			all_slots_cleared.emit()
	else:
		if status_lbl:
			status_lbl.text = "TERKUNCI (%d/3)" % count
			status_lbl.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2, 1.0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = true
		if prompt_lbl and _dialog_instance == null:
			prompt_lbl.text = "[E] KUIS L7" if is_activated else "[E] STATUS PROTOKOL"
			prompt_lbl.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = false
		if prompt_lbl:
			prompt_lbl.visible = false

func _interact() -> void:
	var count := _count_filled()
	var title := "TERMINAL PROTOKOL L7 (APLIKASI)"
	var content := ""
	
	if is_activated or GameState.gates_cleared.has("L7"):
		content = "STATUS: TERVERIFIKASI!\nSeluruh protokol (HTTP, SMTP, DNS) terpasang di gedung yang cocok.\nGerbang L7 kini terbuka untuk verifikasi kuis akhir!"
	else:
		content = "STATUS: TERKUNCI (%d/3 Selesai)\nAntarkan lencana protokol ke server yang sesuai:\n- WEB SERVER (Minta web) -> HTTP\n- MAIL SERVER (Kirim email) -> SMTP\n- DNS SERVER (Cari alamat web) -> DNS" % count

	var dialog_scene: PackedScene = load("res://scenes/ui/UI_DialogBox.tscn") as PackedScene
	if dialog_scene:
		_dialog_instance = dialog_scene.instantiate()
		get_tree().current_scene.add_child(_dialog_instance)
		if _dialog_instance.has_method("setup"):
			_dialog_instance.setup(title, content)
		get_tree().paused = true
		if _dialog_instance.has_signal("closed"):
			_dialog_instance.closed.connect(func():
				_dialog_instance = null
				get_tree().paused = false
				if _player_in_area and prompt_lbl:
					prompt_lbl.visible = true
			)
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
