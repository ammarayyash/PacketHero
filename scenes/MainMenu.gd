extends Node2D
# MainMenu.gd

@onready var btn_new_game : Button = $CanvasLayer/VBox/BtnNewGame
@onready var btn_continue : Button = $CanvasLayer/VBox/BtnContinue
@onready var btn_settings : Button = $CanvasLayer/VBox/BtnSettings
@onready var btn_journal  : Button = $CanvasLayer/VBox/BtnJournal
@onready var btn_preview  : Button = $CanvasLayer/VBox/BtnPreview
@onready var btn_credits  : Button = $CanvasLayer/VBox/BtnCredits

const SETTINGS_SCENE := preload("res://scenes/ui/UI_Settings.tscn")
const JOURNAL_SCENE  := preload("res://scenes/ui/UI_Journal.tscn")
const CREDITS_SCENE  := preload("res://scenes/ui/UI_Credits.tscn")

func _ready() -> void:
	btn_new_game.pressed.connect(_on_new_game)
	btn_continue.pressed.connect(_on_continue)
	btn_settings.pressed.connect(_on_settings)
	btn_journal.pressed.connect(_on_journal)
	btn_preview.pressed.connect(_on_preview)
	btn_credits.pressed.connect(_on_credits)

	# Tombol continue hanya aktif bila file save ditemukan
	btn_continue.disabled = not GameState.has_save()

	AudioManager.play_music("res://assets/audio/music/music_level1.mp3")

func _on_new_game() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_confirm.ogg")
	GameState.reset()
	SceneTransition.change_scene("res://scenes/Level_1.tscn")

func _on_continue() -> void:
	if GameState.load_game():
		AudioManager.play_sfx("res://assets/audio/sfx/ui_confirm.ogg")
		var target_level: String = GameState.checkpoint.get("level", "res://scenes/Level_1.tscn")
		SceneTransition.change_scene(target_level)

func _on_settings() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	var settings_ui : Node = SETTINGS_SCENE.instantiate()
	add_child(settings_ui)

func _on_journal() -> void:
	# UI_Journal memutar SFX journal_open.ogg di _ready()
	var journal_ui : Node = JOURNAL_SCENE.instantiate()
	add_child(journal_ui)

func _on_preview() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	SceneTransition.change_scene("res://scenes/LevelPreview.tscn")

func _on_credits() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	var credits_ui : Node = CREDITS_SCENE.instantiate()
	add_child(credits_ui)
