extends Node2D
# LevelPreview.gd

@onready var cam          : Camera2D       = $Camera2D
@onready var level_holder : Node2D         = $LevelContainer
@onready var lbl_info     : Label          = $UI/TopBar/Margin/HBox/LblInfo
@onready var btn_l1       : Button         = $UI/TopBar/Margin/HBox/BtnL1
@onready var btn_l2       : Button         = $UI/TopBar/Margin/HBox/BtnL2
@onready var btn_l3       : Button         = $UI/TopBar/Margin/HBox/BtnL3
@onready var chk_far      : CheckBox       = $UI/TopBar/Margin/HBox/ChkFar
@onready var chk_mid      : CheckBox       = $UI/TopBar/Margin/HBox/ChkMid
@onready var chk_near     : CheckBox       = $UI/TopBar/Margin/HBox/ChkNear
@onready var chk_terrain  : CheckBox       = $UI/TopBar/Margin/HBox/ChkTerrain
@onready var btn_back     : Button         = $UI/TopBar/Margin/HBox/BtnBack
@onready var zoom_slider  : HSlider        = $UI/BottomBar/Margin/HBox/ZoomSlider
@onready var lbl_zoom     : Label          = $UI/BottomBar/Margin/HBox/LblZoom

var current_level_idx := 1
var current_level_node : Node2D = null

const CAM_SPEED := 900.0
var _is_dragging := false
var _drag_start_mouse := Vector2.ZERO
var _drag_start_cam := Vector2.ZERO

func _ready() -> void:
	btn_l1.pressed.connect(func(): _load_level(1))
	btn_l2.pressed.connect(func(): _load_level(2))
	btn_l3.pressed.connect(func(): _load_level(3))
	btn_back.pressed.connect(_on_back)
	
	chk_far.toggled.connect(_on_toggle_far)
	chk_mid.toggled.connect(_on_toggle_mid)
	chk_near.toggled.connect(_on_toggle_near)
	chk_terrain.toggled.connect(_on_toggle_terrain)
	
	zoom_slider.value_changed.connect(_on_zoom_slider)
	
	_load_level(1)

func _load_level(idx: int) -> void:
	current_level_idx = idx
	if current_level_node:
		current_level_node.queue_free()
		current_level_node = null
		await get_tree().process_frame
		
	var path := "res://scenes/Level_%d.tscn" % idx
	var scn := load(path)
	if scn:
		current_level_node = scn.instantiate()
		level_holder.add_child(current_level_node)
		
		# Nonaktifkan komponen gameplay agar preview bersih
		if current_level_node.has_node("Player"):
			var p = current_level_node.get_node("Player")
			p.set_physics_process(false)
			p.set_process(false)
			# Matikan kamera player agar kamera preview yang aktif
			if p.has_node("Camera2D"):
				p.get_node("Camera2D").enabled = false
		if current_level_node.has_node("UI_HUD"):
			current_level_node.get_node("UI_HUD").visible = false
		if current_level_node.has_node("UI_TouchControls"):
			current_level_node.get_node("UI_TouchControls").visible = false
			
		# Reset posisi kamera preview
		cam.position = Vector2(640, 360)
		cam.zoom = Vector2(0.65, 0.65)
		zoom_slider.value = 0.65
		
		lbl_info.text = "LEVEL %d PREVIEW" % idx
		AudioManager.play_music("res://assets/audio/music/music_level%d.mp3" % idx, false)
		_sync_layers()

func _sync_layers() -> void:
	_on_toggle_far(chk_far.button_pressed)
	_on_toggle_mid(chk_mid.button_pressed)
	_on_toggle_near(chk_near.button_pressed)
	_on_toggle_terrain(chk_terrain.button_pressed)

func _process(delta: float) -> void:
	# Kontrol keyboard
	var move := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		move.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		move.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		move.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		move.y += 1
		
	var speed := CAM_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= 3.0
		
	if move != Vector2.ZERO:
		cam.position += move.normalized() * (speed / cam.zoom.x) * delta
		
	# Shortcut angka
	if Input.is_action_just_pressed("pause"):
		_on_back()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_is_dragging = true
				_drag_start_mouse = event.position
				_drag_start_cam = cam.position
			else:
				_is_dragging = false
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_set_zoom(cam.zoom.x + 0.05)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_set_zoom(cam.zoom.x - 0.05)
			
	elif event is InputEventMouseMotion and _is_dragging:
		var delta_mouse = event.position - _drag_start_mouse
		cam.position = _drag_start_cam - (delta_mouse / cam.zoom.x)

func _set_zoom(val: float) -> void:
	val = clamp(val, 0.2, 2.0)
	cam.zoom = Vector2(val, val)
	zoom_slider.value = val
	lbl_zoom.text = "Zoom: %d%%" % int(val * 100)

func _on_zoom_slider(val: float) -> void:
	cam.zoom = Vector2(val, val)
	lbl_zoom.text = "Zoom: %d%%" % int(val * 100)

func _on_toggle_far(on: bool) -> void:
	if current_level_node and current_level_node.has_node("ParallaxBG/LayerFar"):
		current_level_node.get_node("ParallaxBG/LayerFar").visible = on

func _on_toggle_mid(on: bool) -> void:
	if current_level_node and current_level_node.has_node("ParallaxBG/LayerMid"):
		current_level_node.get_node("ParallaxBG/LayerMid").visible = on

func _on_toggle_near(on: bool) -> void:
	if current_level_node and current_level_node.has_node("ParallaxBG/LayerNear"):
		current_level_node.get_node("ParallaxBG/LayerNear").visible = on

func _on_toggle_terrain(on: bool) -> void:
	if current_level_node and current_level_node.has_node("Terrain"):
		current_level_node.get_node("Terrain").visible = on

func _on_back() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/ui_click.ogg")
	SceneTransition.change_scene("res://scenes/MainMenu.tscn")
