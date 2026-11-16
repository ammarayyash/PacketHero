extends Control

@export var target_scene: String = "res://scenes/MainMenu.tscn"

@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var skip_label: Label = $CanvasLayer/MarginContainer/SkipLabel

var _transitioned := false

const VIDEO_CANDIDATES = [
	"res://assets/videos/intro.ogv",
	"res://assets/videos/gemini_generated_video_72e3ed29.ogv",
	"res://assets/ui/gemini_generated_video_72e3ed29.ogv"
]

func _ready() -> void:
	if not video_player.finished.is_connected(_on_video_finished):
		video_player.finished.connect(_on_video_finished)

	# Jika stream belum di-assign di editor, cari dari daftar kandidat
	if video_player.stream == null:
		var found_path := ""
		for path in VIDEO_CANDIDATES:
			if ResourceLoader.exists(path) or FileAccess.file_exists(path):
				found_path = path
				break
		if found_path != "":
			var stream = load(found_path)
			if stream:
				video_player.stream = stream
		else:
			push_warning("Video intro (.ogv) belum ditemukan.")
			_go_to_menu()
			return

	if not video_player.is_playing():
		video_player.play()

	# Efek fade in halus pada label petunjuk skip
	if skip_label:
		skip_label.modulate.a = 0.0
		var tw := create_tween()
		tw.tween_interval(1.0)
		tw.tween_property(skip_label, "modulate:a", 0.75, 0.6)

func _unhandled_input(event: InputEvent) -> void:
	if _transitioned:
		return
	# Skip jika menekan tombol keyboard, klik mouse, atau sentuh layar
	if event is InputEventKey and event.pressed and not event.echo:
		_go_to_menu()
	elif event is InputEventMouseButton and event.pressed:
		_go_to_menu()
	elif event is InputEventScreenTouch and event.pressed:
		_go_to_menu()

func _on_video_finished() -> void:
	_go_to_menu()

func _go_to_menu() -> void:
	if _transitioned:
		return
	_transitioned = true

	if video_player and video_player.is_playing():
		video_player.stop()

	var transition = get_node_or_null("/root/SceneTransition")
	if transition and transition.has_method("change_scene"):
		transition.change_scene(target_scene, 0.4)
	else:
		get_tree().change_scene_to_file(target_scene)
