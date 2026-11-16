extends CanvasLayer
# UI_Settings.gd

signal closed

@onready var music_slider : HSlider = $Panel/VBox/Grid/MusicSlider
@onready var sfx_slider   : HSlider = $Panel/VBox/Grid/SFXSlider
@onready var music_val    : Label   = $Panel/VBox/Grid/MusicVal
@onready var sfx_val      : Label   = $Panel/VBox/Grid/SFXVal
@onready var chk_fullscreen : CheckBox = $Panel/VBox/FullscreenBox/ChkFullscreen
@onready var btn_close    : Button  = $Panel/VBox/BtnClose

func _ready() -> void:
	music_slider.value = AudioManager.music_volume * 100.0
	sfx_slider.value = AudioManager.sfx_volume * 100.0
	_update_labels()

	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	chk_fullscreen.toggled.connect(_on_fullscreen_toggled)
	btn_close.pressed.connect(_on_close)

	var mode : int = DisplayServer.window_get_mode()
	chk_fullscreen.button_pressed = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)

func _update_labels() -> void:
	music_val.text = "%d%%" % int(music_slider.value)
	sfx_val.text = "%d%%" % int(sfx_slider.value)

func _on_music_changed(val: float) -> void:
	AudioManager.set_music_volume(val / 100.0)
	_update_labels()

func _on_sfx_changed(val: float) -> void:
	AudioManager.set_sfx_volume(val / 100.0)
	_update_labels()

func _on_fullscreen_toggled(pressed: bool) -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	if pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_close() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_close.ogg")
	closed.emit()
	queue_free()
