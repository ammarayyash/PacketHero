extends CanvasLayer
# UI_DialogBox.gd — Kotak dialog UI sederhana untuk pesan terminal dan NPC
class_name UIDialogBox

signal closed

@onready var panel         : Control = $SafeMargin/Center/Panel
@onready var lbl_title     : Label   = $SafeMargin/Center/Panel/MarginContainer/VBox/TitleLabel
@onready var lbl_content   : Label   = $SafeMargin/Center/Panel/MarginContainer/VBox/ContentLabel
@onready var prompt_footer : Label   = $SafeMargin/Center/Panel/MarginContainer/VBox/PromptFooter

var _can_close: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Menghindari langsung tertutup jika tombol baru saja ditekan pada frame yang sama
	_can_close = false
	get_tree().create_timer(0.15, true, false, true).timeout.connect(func(): _can_close = true)

func _unhandled_input(event: InputEvent) -> void:
	if not _can_close:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_dialog()

func setup(title: String, content: String) -> void:
	if lbl_title:
		lbl_title.text = title
	if lbl_content:
		lbl_content.text = content

func close_dialog() -> void:
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	closed.emit()
	queue_free()
