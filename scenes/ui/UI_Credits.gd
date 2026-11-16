extends CanvasLayer
# UI_Credits.gd

signal closed

@onready var credits_label : RichTextLabel = $Panel/VBox/Scroll/CreditsLabel
@onready var btn_close      : Button        = $Panel/VBox/BtnClose

func _ready() -> void:
	btn_close.pressed.connect(_on_close)
	_load_credits()

func _load_credits() -> void:
	if FileAccess.file_exists("res://Credits.txt"):
		var f : FileAccess = FileAccess.open("res://Credits.txt", FileAccess.READ)
		if f != null:
			var content : String = f.get_as_text()
			f.close()
			credits_label.text = content
	else:
		credits_label.text = "PACKET HERO\nGame Edukasi Jaringan Komputer\nUAS Mata Kuliah Game Semester 5"

func _on_close() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_close.ogg")
	closed.emit()
	queue_free()
