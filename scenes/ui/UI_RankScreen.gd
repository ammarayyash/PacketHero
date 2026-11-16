extends CanvasLayer
# UI_RankScreen.gd

@onready var lbl_rank   : Label = $Panel/VBox/RankBadge
@onready var lbl_score  : Label = $Panel/VBox/ScoreDetails
@onready var btn_replay : Button = $Panel/VBox/HBox/BtnReplay
@onready var btn_menu   : Button = $Panel/VBox/HBox/BtnMenu

func _ready() -> void:
	var final_s = GameState.final_score()
	var rank = GameState.get_rank()
	
	lbl_rank.text = "RANK: %s" % rank
	match rank:
		"S": lbl_rank.add_theme_color_override("font_color", Color("#FFE600"))
		"A": lbl_rank.add_theme_color_override("font_color", Color("#39E6FF"))
		"B": lbl_rank.add_theme_color_override("font_color", Color("#39FF88"))
		_:   lbl_rank.add_theme_color_override("font_color", Color("#CCCCCC"))
		
	lbl_score.text = "EXP: %d\nArtefak Header: %d (Bonus: +%d)\nIntegrity Sisa: %d (Bonus: +%d)\nBandwidth: %d\n\nTotal Score: %d" % [
		GameState.exp_points,
		GameState.artifacts.size(),
		GameState.artifacts.size() * 300,
		GameState.integrity,
		GameState.integrity * 100,
		GameState.bandwidth,
		final_s
	]
	
	btn_replay.pressed.connect(_on_replay)
	btn_menu.pressed.connect(_on_menu)

func _on_replay() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_confirm.ogg")
	GameState.reset()
	SceneTransition.change_scene("res://scenes/Level_1.tscn")

func _on_menu() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	SceneTransition.change_scene("res://scenes/MainMenu.tscn")
