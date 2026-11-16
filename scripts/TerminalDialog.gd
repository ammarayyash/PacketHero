extends Area2D
# TerminalDialog.gd — Terminal interaktif dengan dialog box sederhana
class_name TerminalDialog

@export var terminal_title    : String    = "TERMINAL SISTEM"
@export_multiline var dialog_message  : String    = "Selamat datang di Kota Data, Admin! Lapisan OSI sedang mengalami gangguan integritas. Pulihkan protokol di setiap lapisan!"
@export var terminal_texture  : Texture2D = null

var _player_in_area  : bool = false
var _dialog_instance : Node = null

@onready var sprite     : Sprite2D = get_node_or_null("Sprite2D")
@onready var prompt_lbl : Label    = get_node_or_null("PromptLabel")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Layer 6 = Trigger (32), Mask 2 = Player (2)
	collision_layer = 32
	collision_mask = 2
	
	if terminal_texture and sprite:
		sprite.texture = terminal_texture
		
	if prompt_lbl:
		prompt_lbl.visible = false
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _player_in_area and _dialog_instance == null and Input.is_action_just_pressed("interact"):
		_open_dialog()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = true
		if prompt_lbl and _dialog_instance == null:
			prompt_lbl.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_area = false
		if prompt_lbl:
			prompt_lbl.visible = false

func _open_dialog() -> void:
	if prompt_lbl:
		prompt_lbl.visible = false
		
	var dialog_scene: PackedScene = load("res://scenes/ui/UI_DialogBox.tscn") as PackedScene
	if dialog_scene:
		_dialog_instance = dialog_scene.instantiate()
		get_tree().current_scene.add_child(_dialog_instance)
		if _dialog_instance.has_method("setup"):
			_dialog_instance.setup(terminal_title, dialog_message)
		get_tree().paused = true
		if _dialog_instance.has_signal("closed"):
			_dialog_instance.closed.connect(_on_dialog_closed)
		if AudioManager:
			AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")

func _on_dialog_closed() -> void:
	_dialog_instance = null
	get_tree().paused = false
	if _player_in_area and prompt_lbl:
		prompt_lbl.visible = true
