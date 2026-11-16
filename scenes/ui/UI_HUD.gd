extends CanvasLayer
# UI_HUD.gd — Tampilan Status, Misi, dan Layar Koneksi Terputus

@onready var hearts_box    : HBoxContainer = $SafeMargin/HUD/Left/StatusRow/HeartsBox
@onready var shield_icon   : Label         = $SafeMargin/HUD/Left/StatusRow/ShieldIcon
@onready var energy_bar    : ProgressBar   = $SafeMargin/HUD/Right/EnergyBar
@onready var lbl_bw        : Label         = $SafeMargin/HUD/Right/LblBW
@onready var lbl_exp       : Label         = $SafeMargin/HUD/Right/LblEXP
@onready var lbl_layer     : Label         = $SafeMargin/HUD/Center/LblLayer
@onready var lbl_section   : Label         = get_node_or_null("SafeMargin/HUD/Center/LblSection")
@onready var lbl_timer     : Label         = get_node_or_null("SafeMargin/HUD/Center/LblTimer")
@onready var death_overlay : Control       = get_node_or_null("DeathOverlay")

@onready var lbl_m_admin   : Label = get_node_or_null("SafeMargin/HUD/Left/MissionBox/LblMissionAdmin")
@onready var lbl_m_bw      : Label = get_node_or_null("SafeMargin/HUD/Left/MissionBox/LblMissionBW")
@onready var lbl_m_malware : Label = get_node_or_null("SafeMargin/HUD/Left/MissionBox/LblMissionMalware")
@onready var lbl_m_gate    : Label = get_node_or_null("SafeMargin/HUD/Left/MissionBox/LblMissionGate")
@onready var lbl_m_key     : Label = get_node_or_null("SafeMargin/HUD/Left/MissionBox/LblMissionKey")
@onready var lbl_m_finish  : Label = get_node_or_null("SafeMargin/HUD/Left/MissionBox/LblMissionFinish")

const HEART_FULL  := "❤"
const HEART_EMPTY := "🖤"

func _ready() -> void:
	GameState.stats_changed.connect(_refresh)
	GameState.player_died.connect(_on_player_died)
	if GameState.has_signal("mission_updated"):
		GameState.mission_updated.connect(_update_missions)
	if death_overlay:
		death_overlay.visible = false
	_refresh()
	_update_missions()

func _on_player_died() -> void:
	if death_overlay:
		death_overlay.visible = true
		await get_tree().create_timer(Config.DEATH_OVERLAY_DURATION).timeout
		death_overlay.visible = false

func _refresh() -> void:
	# Refresh tampilan hati
	for child in hearts_box.get_children():
		child.queue_free()

	var heart_tex: Texture2D = load("res://assets/sprites/ui_new/hud_heart.png")
	var max_hearts: int = mini(GameState.max_integrity, 6)
	for i in max_hearts:
		if heart_tex:
			var tex_rect := TextureRect.new()
			tex_rect.texture = heart_tex
			tex_rect.custom_minimum_size = Vector2(24, 24)
			tex_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
			tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			tex_rect.modulate = Color.WHITE if i < GameState.integrity else Color(0.2, 0.2, 0.2, 0.5)
			hearts_box.add_child(tex_rect)
		else:
			var lbl := Label.new()
			lbl.text = HEART_FULL if i < GameState.integrity else HEART_EMPTY
			lbl.add_theme_font_size_override("font_size", 24)
			lbl.add_theme_color_override("font_color",
				Color("#FF4466") if i < GameState.integrity else Color(0.3, 0.3, 0.3))
			hearts_box.add_child(lbl)

	shield_icon.visible = GameState.shield

	# Energy bar
	energy_bar.max_value = GameState.max_energy
	energy_bar.value     = GameState.energy

	# Labels
	lbl_bw.text  = "BW: %d" % GameState.bandwidth
	lbl_exp.text = "EXP: %d" % GameState.exp_points

func set_section(section_name: String, layer_badge: String = "") -> void:
	if lbl_section:
		lbl_section.text = section_name
	if layer_badge != "" and lbl_layer:
		lbl_layer.text = "[ %s ]" % layer_badge

func set_layer_badge(layer_id: String) -> void:
	if lbl_layer:
		lbl_layer.text = "[ %s ]" % layer_id

func set_session_timer(time_left: float, is_visible: bool) -> void:
	if lbl_timer:
		lbl_timer.visible = is_visible
		if is_visible:
			var m: int = int(time_left / 60.0)
			var s: int = int(time_left) % 60
			lbl_timer.text = "⏱ SESI: %02d:%02d" % [m, s]
			if time_left <= 10.0:
				lbl_timer.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25, 1.0))
			else:
				lbl_timer.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2, 1.0))

func _update_missions() -> void:
	if lbl_m_admin:
		if GameState.talked_to_admin:
			lbl_m_admin.text = "[OK] Temui Pak Admin"
			lbl_m_admin.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45, 1.0))
		else:
			lbl_m_admin.text = "[  ] Temui Pak Admin"
			lbl_m_admin.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0, 0.85))

	if lbl_m_bw:
		var bw_target := 50
		var current_bw := GameState.bandwidth
		if current_bw >= bw_target:
			lbl_m_bw.text = "[OK] Bandwidth: %d/%d" % [current_bw, bw_target]
			lbl_m_bw.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45, 1.0))
		else:
			lbl_m_bw.text = "[  ] Bandwidth: %d/%d" % [current_bw, bw_target]
			lbl_m_bw.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0, 0.85))

	if lbl_m_malware:
		var mal_target := 3
		var count := mini(GameState.enemies_defeated, mal_target)
		if GameState.enemies_defeated >= mal_target:
			lbl_m_malware.text = "[OK] Basmi Malware: %d/%d" % [GameState.enemies_defeated, mal_target]
			lbl_m_malware.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45, 1.0))
		else:
			lbl_m_malware.text = "[  ] Basmi Malware: %d/%d" % [count, mal_target]
			lbl_m_malware.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0, 0.85))

	if lbl_m_gate:
		if GameState.gates_cleared.has("L7"):
			lbl_m_gate.text = "[OK] Gerbang L7 (Aplikasi)"
			lbl_m_gate.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45, 1.0))
		else:
			lbl_m_gate.text = "[  ] Buka Gerbang L7 (Aplikasi)"
			lbl_m_gate.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0, 0.85))

	if lbl_m_key:
		if GameState.port_keys.size() > 0:
			lbl_m_key.text = "[OK] Port Key Skyway"
			lbl_m_key.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45, 1.0))
		else:
			lbl_m_key.text = "[  ] Ambil Port Key Skyway"
			lbl_m_key.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0, 0.85))

	if lbl_m_finish:
		if GameState.finish_reached:
			lbl_m_finish.text = "[OK] Server Core Finish"
			lbl_m_finish.add_theme_color_override("font_color", Color(0.25, 1.0, 0.45, 1.0))
		else:
			lbl_m_finish.text = "[  ] Capai Server Core Finish"
			lbl_m_finish.add_theme_color_override("font_color", Color(0.75, 0.85, 1.0, 0.85))
