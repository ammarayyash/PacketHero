extends CanvasLayer
# UI_LevelComplete.gd — Layar ringkasan akhir level (Level Complete)

signal completed_accepted

@onready var lbl_exp: Label = $SafeMargin/Center/Panel/MarginContainer/VBox/StatsGrid/LblExpVal
@onready var lbl_bw: Label = $SafeMargin/Center/Panel/MarginContainer/VBox/StatsGrid/LblBwVal
@onready var lbl_art: Label = $SafeMargin/Center/Panel/MarginContainer/VBox/StatsGrid/LblArtVal
@onready var lbl_hp: Label = $SafeMargin/Center/Panel/MarginContainer/VBox/StatsGrid/LblHpVal
@onready var btn_next: Button = $SafeMargin/Center/Panel/MarginContainer/VBox/BtnNext

var _can_proceed: bool = false
var _is_proceeding: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 110
	_populate_stats()
	btn_next.pressed.connect(_on_btn_next_pressed)
	# Mencegah tertekan langsung jika pemain masuk portal sambil menahan tombol
	get_tree().create_timer(0.2, true, false, true).timeout.connect(func() -> void:
		_can_proceed = true
		btn_next.grab_focus()
	)

func _populate_stats() -> void:
	# Hitung artefak level 1 yang terkumpul (maksimal 3)
	var art_count: int = 0
	for art_id: String in ["artifact_L7", "artifact_L6", "artifact_L5", "artifact_l7", "artifact_l6", "artifact_l5"]:
		if GameState.artifacts.has(art_id):
			art_count += 1
	art_count = mini(art_count, 3)

	if lbl_exp:
		lbl_exp.text = "%d EXP" % GameState.exp_points
	if lbl_bw:
		lbl_bw.text = "%d BW" % GameState.bandwidth
	if lbl_art:
		lbl_art.text = "%d / 3" % art_count
	if lbl_hp:
		var max_h: int = maxi(GameState.max_integrity, 1)
		var pct: int = int((float(GameState.integrity) / float(max_h)) * 100.0)
		lbl_hp.text = "%d / %d (%d%%)" % [GameState.integrity, GameState.max_integrity, pct]

func _unhandled_input(event: InputEvent) -> void:
	if not _can_proceed or _is_proceeding:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_on_btn_next_pressed()

func _on_btn_next_pressed() -> void:
	if _is_proceeding:
		return
	_is_proceeding = true
	btn_next.disabled = true
	if AudioManager:
		AudioManager.play_sfx("res://assets/audio/sfx/ui_confirm.ogg")
	completed_accepted.emit()
	get_tree().paused = false
	SceneTransition.change_scene("res://scenes/Level_2.tscn", 0.5)
