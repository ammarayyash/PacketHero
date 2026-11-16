extends CanvasLayer
# UI_TouchControls.gd

@onready var controls   : Control           = $Controls
@onready var btn_left   : TouchScreenButton = $Controls/Left
@onready var btn_right  : TouchScreenButton = $Controls/Right
@onready var btn_jump   : TouchScreenButton = $Controls/Jump
@onready var btn_dash   : TouchScreenButton = $Controls/Dash
@onready var btn_action : TouchScreenButton = $Controls/Action

func _ready() -> void:
	# Tampilkan bila touchscreen tersedia atau diaktifkan di setting
	if not DisplayServer.is_touchscreen_available():
		# Tetap tampilkan tapi semi-transparan bila ingin digunakan via mouse/pengujian
		controls.modulate.a = 0.8

	if btn_dash:
		var dash_tex: Texture2D = load("res://assets/sprites/ui_new/icons/icon_dash.png")
		if dash_tex:
			btn_dash.texture_normal = dash_tex
